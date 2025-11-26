import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/widgets/paper_card.dart';
import '../core/widgets/custom_button.dart';
import '../providers/providers.dart';

// Calendar state provider
class CalendarState {
  final DateTime focusedDay;
  final DateTime? selectedDay;

  CalendarState({
    required this.focusedDay,
    this.selectedDay,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final today = DateTime.now();
    return CalendarState(
      focusedDay: today,
      selectedDay: today,
    );
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    state = state.copyWith(
      selectedDay: selectedDay,
      focusedDay: focusedDay,
    );
  }
}

final calendarNotifierProvider = NotifierProvider<CalendarNotifier, CalendarState>(
  CalendarNotifier.new,
);

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final userId = ref.watch(currentUserIdProvider);
    
    // Watch sobriety logs and current streak using new providers
    final sobrietyLogsAsync = ref.watch(currentUserSobrietyLogsProvider);
    final currentStreak = ref.watch(currentStreakProvider);

    return Scaffold(
      backgroundColor: AppColors.paperWhite,
      appBar: AppBar(
        title: Text(
          'Sobriety Calendar',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.inkBlack,
          ),
        ),
        backgroundColor: AppColors.paperCream,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.inkBlack),
      ),
      body: userId == null
          ? const Center(child: Text('Please log in to track sobriety'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Streak Card
                  _buildStreakCard(currentStreak),
                  const SizedBox(height: AppSpacing.lg),

                  // Calendar
                  sobrietyLogsAsync.when(
                    data: (sobrietyData) => _buildCalendar(calendarState, sobrietyData),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Text('Error loading calendar: $error'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Legend
                  _buildLegend(),
                  const SizedBox(height: AppSpacing.lg),

                  // Day Actions
                  if (calendarState.selectedDay != null)
                    sobrietyLogsAsync.whenData(
                      (sobrietyData) => _buildDayActions(
                        calendarState.selectedDay!,
                        sobrietyData,
                      ),
                    ).value ?? const SizedBox.shrink(),
                  const SizedBox(height: AppSpacing.lg),

                  // Encouragement Card
                  _buildEncouragementCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStreakCard(int streak) {
    return PaperCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_fire_department,
              color: AppColors.panicRed,
              size: 48,
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              children: [
                Text(
                  '$streak',
                  style: AppTextStyles.display1.copyWith(
                    color: AppColors.holyBlue,
                    fontSize: 48,
                  ),
                ),
                Text(
                  'Day${streak != 1 ? 's' : ''} Clean',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.inkBlack,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(CalendarState calendarState, Map<DateTime, dynamic> sobrietyData) {
    return PaperCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: calendarState.focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(calendarState.selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            ref.read(calendarNotifierProvider.notifier).selectDay(selectedDay, focusedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            ref.read(calendarNotifierProvider.notifier).selectDay(
              calendarState.selectedDay ?? focusedDay,
              focusedDay,
            );
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.holyBlue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.holyBlue,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppColors.graceGreen,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonTextStyle: AppTextStyles.bodySmall,
            titleTextStyle: AppTextStyles.h2,
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: AppColors.paperEdge),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final normalizedDate = DateTime(date.year, date.month, date.day);
              final log = sobrietyData[normalizedDate];
              
              if (log == null) return null;
              
              final status = log.status.name;
              final isClean = status == 'clean';
              final color = isClean ? AppColors.graceGreen : AppColors.panicRed;
              
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return PaperCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Legend', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _buildLegendItem(AppColors.graceGreen, 'Clean Day'),
                const SizedBox(width: AppSpacing.md),
                _buildLegendItem(AppColors.panicRed, 'Relapse'),
                const SizedBox(width: AppSpacing.md),
                _buildLegendItem(AppColors.paperEdge, 'No Entry'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildDayActions(DateTime selectedDay, Map<DateTime, dynamic> sobrietyData) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const SizedBox.shrink();

    final normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final log = sobrietyData[normalizedDay];
    final hasEntry = log != null;
    final status = log?.status.name;

    return PaperCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mark ${DateFormat('MMM dd, yyyy').format(selectedDay)}',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.md),
            if (!hasEntry || status != 'clean')
              CustomButton(
                text: 'Mark as Clean',
                onPressed: () => _markDayAsClean(userId, selectedDay),
                icon: Icons.check_circle,
              ),
            if (hasEntry && status == 'clean') const SizedBox(height: AppSpacing.sm),
            if (!hasEntry || status != 'relapse')
              CustomButton(
                text: 'Mark as Relapse',
                onPressed: () => _markDayAsRelapse(userId, selectedDay),
                icon: Icons.cancel,
              ),
            if (hasEntry) ...[
              const SizedBox(height: AppSpacing.sm),
              CustomButton(
                text: 'Remove Entry',
                onPressed: () => _removeEntry(userId, selectedDay),
                icon: Icons.delete_outline,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEncouragementCard() {
    return PaperCard(
      hasCornerFold: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Icon(
              Icons.favorite,
              color: AppColors.crossGold,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '"Blessed are the pure in heart, for they shall see God."',
              style: AppTextStyles.display3.copyWith(
                fontSize: 18,
                color: AppColors.inkBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '- Matthew 5:8',
              style: AppTextStyles.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markDayAsClean(String userId, DateTime day) async {
    final repository = ref.read(sobrietyRepositoryProvider);
    
    try {
      await repository.logSobrietyDay(
        userId: userId,
        date: day,
        status: 'clean',
      );
      
      // Refresh the streak
      ref.invalidate(currentStreakProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Day marked as clean! 🙏'),
            backgroundColor: AppColors.graceGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    }
  }

  Future<void> _markDayAsRelapse(String userId, DateTime day) async {
    final repository = ref.read(sobrietyRepositoryProvider);
    
    try {
      await repository.logSobrietyDay(
        userId: userId,
        date: day,
        status: 'relapse',
      );
      
      // Refresh the streak
      ref.invalidate(currentStreakProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry logged. Remember, God\'s mercy is new every morning.'),
            backgroundColor: AppColors.panicRed,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    }
  }

  Future<void> _removeEntry(String userId, DateTime day) async {
    final repository = ref.read(sobrietyRepositoryProvider);
    
    try {
      await repository.deleteSobrietyLog(
        userId: userId,
        date: day,
      );
      
      // Refresh the streak
      ref.invalidate(currentStreakProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry removed'),
            backgroundColor: AppColors.paperEdge,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.panicRed,
          ),
        );
      }
    }
  }
}
