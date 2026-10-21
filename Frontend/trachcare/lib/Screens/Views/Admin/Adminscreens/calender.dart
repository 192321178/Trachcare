import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

import 'package:trachcare/Screens/Views/Admin/Adminscreens/dailyupdatedetails.dart';

/// Date picker for one patient's daily query history.
class a_CalendarScreen extends StatefulWidget {
  final String patientId;
  final String name;

  /// Raw server path (may start with `../`); resolved by the screens it feeds.
  final String imagePath;

  const a_CalendarScreen({
    super.key,
    required this.patientId,
    required this.name,
    required this.imagePath,
  });

  @override
  State<a_CalendarScreen> createState() => _a_CalendarScreenState();
}

class _a_CalendarScreenState extends State<a_CalendarScreen> {
  DateTime _selected = DateTime.now();
  DateTime _focused = DateTime.now();

  void _openDay(DateTime day) {
    setState(() {
      _selected = day;
      _focused = day;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Viewdailyupdates(
          // The backend matches on a full YYYY-MM-DD; trimming the century here
          // made every day report come back empty.
          selecteddate: day.toString().split(' ').first,
          patientId: widget.patientId,
          imagePath: widget.imagePath,
          name: widget.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      appBar: NormalAppbar(
        Title: 'Daily reports',
        subtitle: 'Pick a day to open that entry',
        height: 92,
        onTap: () => Navigator.maybePop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.page, AppSpacing.lg, AppSpacing.page, 40),
        children: [
          TcPatientHeader(
            name: widget.name,
            patientId: 'Patient ID ${widget.patientId}',
            imagePath: trachcareAsset(widget.imagePath),
          ),
          const SizedBox(height: AppSpacing.xl),
          TcCard(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.lg),
            child: TableCalendar(
              availableGestures: AvailableGestures.horizontalSwipe,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink),
                leftChevronIcon: const Icon(Icons.chevron_left_rounded,
                    color: AppColors.inkMuted),
                rightChevronIcon: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.inkMuted),
              ),
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                todayDecoration: const BoxDecoration(
                  color: AppColors.mintSoft,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                    color: AppColors.tealDeep, fontWeight: FontWeight.w700),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
                weekendTextStyle: const TextStyle(color: AppColors.sky),
                defaultTextStyle: const TextStyle(color: AppColors.ink),
                outsideTextStyle: const TextStyle(color: AppColors.inkMuted),
                cellPadding: const EdgeInsets.symmetric(vertical: 6),
              ),
              focusedDay: _focused,
              firstDay: DateTime(2000, 1, 1),
              lastDay: DateTime(2100, 12, 31),
              selectedDayPredicate: (day) => isSameDay(day, _selected),
              enabledDayPredicate: (day) => !day.isAfter(today),
              onDaySelected: (selectedDay, focusedDay) => _openDay(selectedDay),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.inkMuted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Days after today are disabled — a chart can only be read up '
                  'to the present.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
