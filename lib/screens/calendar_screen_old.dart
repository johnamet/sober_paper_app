import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/widgets/paper_card.dart';
import '../core/widgets/custom_button.dart';

// Calendar state provider
class CalendarState {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, String> sobrietyData; // 'clean', 'relapse', or null

  CalendarState({
    required this.focusedDay,
    this.selectedDay,
    required this.sobrietyData,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    Map<DateTime, String>? sobrietyData,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      sobrietyData: sobrietyData ?? this.sobrietyData,
    );
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    // Initialize with some mock data for the past month
    final today = DateTime.now();
    final mockData = <DateTime, String>{};
    
    // Add some mock clean and relapse days
    for (int i = 1; i <= 60; i++) {
      final date = today.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      // Most days clean, occasional relapses
      if (i == 13 || i == 32 || i == 55) {
        mockData[normalizedDate] = 'relapse';
      } else if (i < 48) {
        mockData[normalizedDate] = 'clean';
      }
    }
    
    return CalendarState(
      focusedDay: today,
      selectedDay: today,
      sobrietyData: mockData,
    );
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    state = state.copyWith(
      selectedDay: selectedDay,
      focusedDay: focusedDay,
    );
  }

  void markDayAsClean(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final newData = Map<DateTime, String>.from(state.sobrietyData);
    newData[normalizedDay] = 'clean';
    state = state.copyWith(sobrietyData: newData);
  }

  void markDayAsRelapse(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final newData = Map<DateTime, String>.from(state.sobrietyData);
    newData[normalizedDay] = 'relapse';
    state = state.copyWith(sobrietyData: newData);
  }

  void removeEntry(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final newData = Map<DateTime, String>.from(state.sobrietyData);
    newData.remove(normalizedDay);
    state = state.copyWith(sobrietyData: newData);
  }

  int getCurrentStreak() {
    final today = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final status = state.sobrietyData[normalizedDate];
      
      if (status == 'clean') {
        streak++;
      } else if (status == 'relapse') {
        break;
      } else if (i > 0) {
        // No entry for this day, but not today
        break;
      }
    }
    
    return streak;
  }
}

final calendarProvider = NotifierProvider<CalendarNotifier, CalendarState>(
  CalendarNotifier.new,
);

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final calendarNotifier = ref.read(calendarProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        title: Text('Sobriety Calendar', style: AppTextStyles.h1),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Streak Card
            PaperCard(
              hasCornerFold: true,
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: AppColors.panicRed,
                        size: 32,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Current Streak',
                        style: AppTextStyles.h2,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    '${calendarNotifier.getCurrentStreak()}',
                    style: AppTextStyles.counter.copyWith(
                      color: AppColors.graceGreen,
                    ),
                  ),
                  Text(
                    'Days Clean',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.inkBrown,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Calendar Card
            PaperCard(
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: calendarState.focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(calendarState.selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      calendarNotifier.selectDay(selectedDay, focusedDay);
                    },
                    calendarStyle: CalendarStyle(
                      // Clean days
                      markerDecoration: BoxDecoration(
                        color: AppColors.graceGreen,
                        shape: BoxShape.circle,
                      ),
                      // Today
                      todayDecoration: BoxDecoration(
                        color: AppColors.holyBlue.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      // Selected day
                      selectedDecoration: BoxDecoration(
                        color: AppColors.holyBlue,
                        shape: BoxShape.circle,
                      ),
                      // Default text
                      defaultTextStyle: AppTextStyles.bodyMedium,
                      weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.inkBrown,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: AppTextStyles.h2,
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: AppColors.inkBlack,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: AppColors.inkBlack,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final normalizedDay = DateTime(day.year, day.month, day.day);
                        final status = calendarState.sobrietyData[normalizedDay];
                        
                        if (status == 'clean') {
                          return Container(
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.graceGreen.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.graceGreen,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.inkBlack,
                                ),
                              ),
                            ),
                          );
                        } else if (status == 'relapse') {
                          return Container(
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.panicRed.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.panicRed,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.inkBlack,
                                ),
                              ),
                            ),
                          );
                        }
                        
                        return null; // Use default styling
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(
                        Icons.check_circle,
                        'Clean Day',
                        AppColors.graceGreen,
                      ),
                      _buildLegendItem(
                        Icons.cancel,
                        'Relapse',
                        AppColors.panicRed,
                      ),
                      _buildLegendItem(
                        Icons.circle_outlined,
                        'No Entry',
                        AppColors.inkFaded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Day Actions Card
            if (calendarState.selectedDay != null)
              PaperCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Mark ${DateFormat('MMM d, y').format(calendarState.selectedDay!)}',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Clean',
                            onPressed: () {
                              calendarNotifier.markDayAsClean(calendarState.selectedDay!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Day marked as clean ✓'),
                                  backgroundColor: AppColors.graceGreen,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icons.check_circle,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              calendarNotifier.markDayAsRelapse(calendarState.selectedDay!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Day marked as relapse'),
                                  backgroundColor: AppColors.panicRed,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(Icons.cancel, size: 20),
                            label: Text(
                              'Relapse',
                              style: AppTextStyles.button,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.panicRed,
                              foregroundColor: AppColors.paperWhite,
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () {
                        calendarNotifier.removeEntry(calendarState.selectedDay!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Entry removed'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(Icons.delete_outline, size: 20),
                      label: Text(
                        'Remove Entry',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.inkBrown,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.inkBrown),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: AppSpacing.xl),
            
            // Encouragement Card
            PaperCard(
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.crossGold,
                    size: 32,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Keep Going!',
                    style: AppTextStyles.h2,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '"Blessed are the pure in heart, for they shall see God." - Matthew 5:8',
                    style: AppTextStyles.prayer,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.inkBrown,
          ),
        ),
      ],
    );
  }
}
