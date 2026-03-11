import 'package:flutter/material.dart';
import '../../widgets/donation_widgets/section_title.dart';
import '../../widgets/donation_widgets/card.dart';
import '../../theme/homepage_theme.dart';
import '../../theme/report_donation_theme.dart';

class TimeSlotsCard extends StatelessWidget {
  final List<String> timeSlots;
  final List<String> selectedTimeSlots;
  final Function(String) toggleTime;

  const TimeSlotsCard({
    required this.timeSlots,
    required this.selectedTimeSlots,
    required this.toggleTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleWidget(text: "חלונות זמן לאיסוף"),
          Row(
            children: timeSlots.map((slot) {
              final selected = selectedTimeSlots.contains(slot);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => toggleTime(slot),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: ReportDonationTheme.chipDecoration(selected),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 13,
                          color: HomepageTheme.latetBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}