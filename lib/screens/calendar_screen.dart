import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
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

final calendarNotifierProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(
  CalendarNotifier.new,
);

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final userId = ref.watch(currentUserIdProvider);
    final sobrietyLogsAsync = ref.watch(currentUserSobrietyLogsProvider);
    final currentStreak = ref.watch(currentStreakProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Sobriety Journey',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white.withOpacity(0.95),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.9)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background church image
          Positioned.fill(
            child: Image.asset(
              'assets/images/church_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1a4d6d),
                        const Color(0xFF2d5a7b),
                        const Color(0xFF1e3a4f),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: userId == null
                ? _buildLoginPrompt()
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(currentUserSobrietyLogsProvider);
                      ref.invalidate(currentStreakProvider);
                    },
                    color: AppColors.crossGold,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildStreakCard(currentStreak),
                            const SizedBox(height: AppSpacing.lg),
                            sobrietyLogsAsync.when(
                              data: (sobrietyData) => Column(
                                children: [
                                  _buildCalendar(calendarState, sobrietyData),
                                  const SizedBox(height: AppSpacing.lg),
                                  _buildMonthSummary(sobrietyData, calendarState.focusedDay),
                                  const SizedBox(height: AppSpacing.lg),
                                  if (calendarState.selectedDay != null)
                                    _buildDayActions(
                                      calendarState.selectedDay!,
                                      sobrietyData,
                                    ),
                                ],
                              ),
                              loading: () => Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  child: CircularProgressIndicator(
                                    color: AppColors.crossGold,
                                  ),
                                ),
                              ),
                              error: (error, stack) => _buildErrorCard(error),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildEncouragementCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: _buildGlassCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.holyBlue.withOpacity(0.7),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Please log in to track your sobriety journey',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(int streak) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.orange.withOpacity(0.95),
                  size: 56,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Day${streak != 1 ? 's' : ''} Clean',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (streak > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.graceGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(
                  color: AppColors.graceGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: AppColors.graceGreen,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _getStreakMessage(streak),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.graceGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStreakMessage(int streak) {
    if (streak == 1) return 'Great start!';
    if (streak < 7) return 'Keep going!';
    if (streak < 30) return 'Building momentum!';
    if (streak < 90) return 'Strong foundation!';
    return 'Amazing progress!';
  }

  Widget _buildCalendar(
      CalendarState calendarState, Map<DateTime, dynamic> sobrietyData) {
    return _buildGlassCard(
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
          ref
              .read(calendarNotifierProvider.notifier)
              .selectDay(selectedDay, focusedDay);
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
            border: Border.all(color: AppColors.holyBlue, width: 2),
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.holyBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.holyBlue.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          defaultTextStyle: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.85),
          ),
          weekendTextStyle: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: true,
          formatButtonTextStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.95),
          ),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Colors.white.withOpacity(0.85),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
          weekendStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, date, focusedDay) {
            return _buildCalendarDay(date, sobrietyData, false, false);
          },
          todayBuilder: (context, date, focusedDay) {
            return _buildCalendarDay(date, sobrietyData, true, false);
          },
          selectedBuilder: (context, date, focusedDay) {
            return _buildCalendarDay(date, sobrietyData, false, true);
          },
        ),
      ),
    );
  }

  Widget _buildCalendarDay(
      DateTime date, Map<DateTime, dynamic> sobrietyData, bool isToday, bool isSelected) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final log = sobrietyData[normalizedDate];
    
    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;
    Color? iconColor;

    if (log != null) {
      if (log.isClean) {
        backgroundColor = AppColors.graceGreen.withOpacity(0.15);
        borderColor = AppColors.graceGreen;
        icon = Icons.check_circle;
        iconColor = AppColors.graceGreen;
      } else {
        backgroundColor = AppColors.panicRed.withOpacity(0.15);
        borderColor = AppColors.panicRed;
        icon = Icons.cancel;
        iconColor = AppColors.panicRed;
      }
    }

    if (isSelected) {
      backgroundColor = AppColors.holyBlue;
      borderColor = AppColors.holyBlue;
    } else if (isToday && log == null) {
      backgroundColor = AppColors.holyBlue.withOpacity(0.1);
      borderColor = AppColors.holyBlue;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.inkBlack,
              fontWeight: log != null ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          if (icon != null && !isSelected)
            Positioned(
              bottom: 2,
              child: Icon(
                icon,
                size: 12,
                color: iconColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(Map<DateTime, dynamic> sobrietyData, DateTime focusedMonth) {
    final monthStart = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final monthEnd = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    
    int cleanDays = 0;
    int totalDays = 0;

    for (var day = monthStart; day.isBefore(monthEnd.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
      if (day.isAfter(DateTime.now())) break;
      
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final log = sobrietyData[normalizedDay];
      
      if (log != null) {
        totalDays++;
        if (log.isClean) {
          cleanDays++;
        }
      }
    }

    final percentage = totalDays > 0 ? (cleanDays / totalDays * 100).toStringAsFixed(0) : '0';

    return _buildGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.holyBlue, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${DateFormat('MMMM yyyy').format(focusedMonth)} Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                icon: Icons.check_circle,
                color: AppColors.graceGreen,
                label: 'Clean Days',
                value: '$cleanDays',
              ),
              _buildSummaryItem(
                icon: Icons.bar_chart,
                color: AppColors.holyBlue,
                label: 'Success Rate',
                value: '$percentage%',
              ),
              _buildSummaryItem(
                icon: Icons.edit_calendar,
                color: Colors.white.withOpacity(0.8),
                label: 'Tracked',
                value: '$totalDays',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDayActions(
      DateTime selectedDay, Map<DateTime, dynamic> sobrietyData) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const SizedBox.shrink();

    final normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final log = sobrietyData[normalizedDay];
    final hasEntry = log != null;
    final isClean = log?.isClean ?? false;
    final isFuture = selectedDay.isAfter(DateTime.now());

    return _buildGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_calendar,
                color: AppColors.holyBlue,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(selectedDay),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ),
            ],
          ),
          if (isFuture) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Cannot mark future dates',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.md),
            if (hasEntry)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isClean
                      ? AppColors.graceGreen.withOpacity(0.2)
                      : AppColors.panicRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: isClean
                        ? AppColors.graceGreen
                        : AppColors.panicRed,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isClean ? Icons.check_circle : Icons.cancel,
                      color: isClean
                          ? AppColors.graceGreen
                          : AppColors.panicRed,
                      size: 28,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Marked as ${isClean ? 'Clean' : 'Relapse'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isClean
                            ? AppColors.graceGreen
                            : AppColors.panicRed,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            if (!hasEntry || !isClean)
              _buildActionButton(
                text: 'Mark as Clean',
                icon: Icons.check_circle,
                color: AppColors.graceGreen,
                onPressed: () => _markDayAsClean(userId, selectedDay),
              ),
            if ((hasEntry && isClean) || !hasEntry)
              const SizedBox(height: AppSpacing.sm),
            if (!hasEntry || isClean)
              _buildActionButton(
                text: 'Mark as Relapse',
                icon: Icons.cancel,
                color: AppColors.panicRed,
                onPressed: () => _markDayAsRelapse(userId, selectedDay),
              ),
            if (hasEntry) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildActionButton(
                text: 'Remove Entry',
                icon: Icons.delete_outline,
                color: Colors.white.withOpacity(0.7),
                onPressed: () => _removeEntry(userId, selectedDay),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildEncouragementCard() {
    final encouragements = [
      {
        'quote': '"Blessed are the pure in heart, for they shall see God."',
        'reference': 'Matthew 5:8',
        'icon': Icons.favorite,
      },
      {
        'quote': '"I can do all things through Christ who strengthens me."',
        'reference': 'Philippians 4:13',
        'icon': Icons.bolt,
      },
      {
        'quote': '"The Lord is my strength and my shield."',
        'reference': 'Psalm 28:7',
        'icon': Icons.shield,
      },
    ];

    final selected = encouragements[DateTime.now().day % encouragements.length];

    return _buildGlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.crossGold.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.crossGold.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              selected['icon'] as IconData,
              color: AppColors.crossGold,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Icon(
            Icons.format_quote,
            color: AppColors.crossGold.withOpacity(0.3),
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            selected['quote'] as String,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '— ${selected['reference']}',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.crossGold.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(Object error) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.panicRed,
            size: 56,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Error loading calendar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.panicRed,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionButton(
            text: 'Retry',
            icon: Icons.refresh,
            color: AppColors.holyBlue,
            onPressed: () {
              ref.invalidate(currentUserSobrietyLogsProvider);
            },
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📅 Track Your Journey',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Tap any date to mark it as clean or relapse'),
              Text('• Green circles = Clean days'),
              Text('• Red circles = Relapse days'),
              SizedBox(height: 16),
              Text('🔥 Build Your Streak',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Track consecutive clean days'),
              Text('• View monthly summaries'),
              Text('• Pull down to refresh'),
              SizedBox(height: 16),
              Text('💪 Stay Encouraged',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Daily scripture encouragement'),
              Text('• Progress tracking'),
              Text('• One day at a time'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _markDayAsClean(String userId, DateTime day) async {
    final repository = ref.read(sobrietyRepositoryProvider);

    try {
      // Normalize the date to midnight UTC to avoid timezone issues
      final normalizedDay = DateTime.utc(day.year, day.month, day.day);
      
      await repository.logSobrietyDay(
        userId: userId,
        date: normalizedDay,
        status: 'clean',
      );

      // Refresh both providers to ensure UI updates
      ref.invalidate(currentUserSobrietyLogsProvider);
      ref.invalidate(currentStreakProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(child: Text('Day marked as clean! 🙏')),
              ],
            ),
            backgroundColor: AppColors.graceGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.panicRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _markDayAsRelapse(String userId, DateTime day) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Relapse'),
        content: const Text(
          'Remember, God\'s mercy is new every morning. This is just a step in your journey.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repository = ref.read(sobrietyRepositoryProvider);

    try {
      final normalizedDay = DateTime.utc(day.year, day.month, day.day);
      
      await repository.logSobrietyDay(
        userId: userId,
        date: normalizedDay,
        status: 'relapse',
      );

      ref.invalidate(currentUserSobrietyLogsProvider);
      ref.invalidate(currentStreakProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Entry logged. Tomorrow is a new beginning.'),
                ),
              ],
            ),
            backgroundColor: AppColors.holyBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.panicRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeEntry(String userId, DateTime day) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Entry'),
        content: const Text('Are you sure you want to remove this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repository = ref.read(sobrietyRepositoryProvider);

    try {
      final normalizedDay = DateTime.utc(day.year, day.month, day.day);
      
      await repository.deleteSobrietyLog(
        userId: userId,
        date: normalizedDay,
      );

      ref.invalidate(currentUserSobrietyLogsProvider);
      ref.invalidate(currentStreakProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(child: Text('Entry removed')),
              ],
            ),
            backgroundColor: AppColors.inkBlack,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.panicRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}