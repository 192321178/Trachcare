import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/Screens/Views/patient/patientscreens/dailyReports.dart';
import 'package:trachcare/style/design_system.dart';

class calender extends StatefulWidget {
  final String name;
  final String imagePath;

  const calender({
    super.key,
    required this.name,
    required this.imagePath,
  });

  @override
  State<calender> createState() => _calenderState();
}

class _calenderState extends State<calender> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
      focusedDate = focusedDay;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Viewdailyupdates(
          selecteddate: selectedDay.toString().split(' ').first,
          patientId: patient_id,
          imagePath: widget.imagePath,
          name: widget.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppbar(
        Title: 'Daily report history',
        subtitle: widget.name,
        height: 92,
        onTap: () {
          // This screen is pushed on top of the patient shell, so popping
          // lands back on the Records tab with the bottom nav intact.
          Navigator.maybePop(context);
        },
      ),
      body: ListView(
        padding:
            const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxxl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: TcPatientHeader(
              name: widget.name,
              patientId: patient_id,
              imagePath: trachcareAsset('${widget.imagePath}'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: TcCard(
              child: TableCalendar(
                availableGestures: AvailableGestures.horizontalSwipe,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                rowHeight: 42,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  headerPadding: const EdgeInsets.symmetric(vertical: 6),
                  titleTextStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                  leftChevronIcon: const Icon(Icons.chevron_left_rounded,
                      color: AppColors.teal),
                  rightChevronIcon: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.teal),
                ),
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  todayDecoration: const BoxDecoration(
                    color: AppColors.mintSoft,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: AppColors.tealDeep,
                    fontWeight: FontWeight.w800,
                  ),
                  selectedDecoration: const BoxDecoration(
                    gradient: AppColors.brandGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.raised,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  weekendDecoration: const BoxDecoration(),
                  weekendTextStyle: const TextStyle(color: AppColors.coral),
                  defaultTextStyle: const TextStyle(color: AppColors.inkBody),
                  outsideTextStyle: TextStyle(
                      color: AppColors.inkMuted.withValues(alpha: 0.5)),
                  outsideDaysVisible: false,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkMuted,
                  ),
                  weekendStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.coral,
                  ),
                ),
                focusedDay: focusedDate,
                firstDay: DateTime(2000, 1, 1),
                lastDay: DateTime(2100, 12, 31),
                selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                enabledDayPredicate: (day) =>
                    day.isBefore(DateTime.now().add(const Duration(days: 1))),
                onDaySelected: (selectedDay, focusedDay) {
                  if (selectedDay
                      .isBefore(DateTime.now().add(const Duration(days: 1)))) {
                    onDaySelected(selectedDay, focusedDay);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Row(
              children: const [
                _Legend(color: AppColors.teal, label: 'Selected'),
                SizedBox(width: AppSpacing.lg),
                _Legend(color: AppColors.mint, label: 'Today'),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    'Tap a day to open that report',
                    style: TextStyle(fontSize: 11.5, color: AppColors.inkMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.inkBody)),
      ],
    );
  }
}
