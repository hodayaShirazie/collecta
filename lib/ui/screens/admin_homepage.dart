import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/homepage_theme.dart';
import '../widgets/homepage_button.dart';
import '../widgets/layout_wrapper.dart';
import 'all_donation_admin.dart';
import 'all_driver_admin.dart';
import '../../services/donation_service.dart';
import 'package:collecta/app/routes.dart';

const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  final DonationService _donationService = DonationService();

  int totalDonations = 0;
  int collected = 0;
  int pending = 0;
  int canceled = 0;
  int growth = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }


  Future<void> _loadStats() async {
    try {
      // 1) total donations (all, regardless of status)
      final total =
          await _donationService.getDonationsCount(kOrganizationId);
      print("TOTAL donations: $total");

      // 2) collected donations
      final collectedCount =
          await _donationService.getDonationsConfirmedCount(kOrganizationId);
      print("COLLECTED donations: $collectedCount");

      // 3) pending
      final pendingCount =
          await _donationService.getDonationsPendingCount(kOrganizationId);
      print("PENDING donations: $pendingCount");

      // 4) canceled
      final canceledCount =
          await _donationService.getDonationsCanceledCount(kOrganizationId);
      print("CANCELED donations: $canceledCount");

      // 5) growth calculation 
      final currentMonthTotal =
          await _donationService.getDonationsCountByMonth(
            organizationId: kOrganizationId,
            monthOffset: 0,
          );

      final lastMonthTotal =
          await _donationService.getDonationsCountByMonth(
            organizationId: kOrganizationId,
            monthOffset: 1,
          );

      double growthCalc;
      if (lastMonthTotal == 0 && currentMonthTotal == 0) {
        growthCalc = 0;
      } else if (lastMonthTotal == 0) {
        growthCalc = 100;
      } else {
        growthCalc = ((currentMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
      }

      setState(() {
        totalDonations = total;
        collected = collectedCount;
        pending = pendingCount;
        canceled = canceledCount;
        growth = growthCalc.round();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutWrapper(
        child: Container(
          decoration: BoxDecoration(
            gradient: HomepageTheme.pageGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                top: -120,
                right: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: HomepageTheme.decorativeCircle,
                ),
              ),

              if (loading)
                const Center(child: CircularProgressIndicator())
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      const SizedBox(height: HomepageTheme.topPadding),
                      const SizedBox(height: 30),

                      Text(
                        'מרכז ניהול',
                        style: HomepageTheme.welcomeTextStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ברוכים הבאים למערכת הניהול',
                        style: HomepageTheme.subtitleTextStyle.copyWith(
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 45),

                      HomepageButton(
                        title: 'הנהגים שלי',
                        flipIcon: true,
                        icon: Icons.local_shipping_outlined,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllDriverAdmin(organizationId: kOrganizationId),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: HomepageTheme.betweenButtons + 20),

                      HomepageButton(
                        title: 'צפייה בתרומות',
                        flipIcon: true,
                        icon: Icons.list_alt_outlined,
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.allDonationAdmin);
                        },
                      ),
                      const SizedBox(height: HomepageTheme.betweenButtons + 20),

                      HomepageButton(
                        title: 'אזורי פעילות',
                        flipIcon: true,
                        icon: Icons.location_on_outlined,
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.activityZones);
                        },
                      ),

                      const SizedBox(height: 60),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            title: "התקבלו",
                            // סך הכל כל התרומות שדווחו אי פעם
                            value: totalDonations.toString(),
                          ),
                          _StatItem(
                            title: "ממתינות",
                            value: pending.toString(),
                          ),
                          _StatItem(
                            title: "בוטלו",
                            value: canceled.toString(),
                          ),
                          _StatItem(
                            title: "אחוז גדילה",
                            value: "$growth%",
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      _DonutChart(
                        collected: collected.toDouble(),
                        pending: pending.toDouble(),
                        canceled: canceled.toDouble(),
                      ),

                      const SizedBox(height: 20),
                      // לא צריך Spacer – LayoutWrapper מאפשר גלילה
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== STAT ITEM =====
class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: HomepageTheme.coinsTextStyle,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: HomepageTheme.subtitleTextStyle.copyWith(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}


class _DonutChart extends StatefulWidget {
  final double collected;
  final double pending;
  final double canceled;

  const _DonutChart({
    required this.collected,
    required this.pending,
    required this.canceled,
  });

  @override
  State<_DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<_DonutChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final total = widget.collected + widget.pending + widget.canceled;

    final collectedPercent = total == 0 ? 0 : (widget.collected / total) * 100;
    final pendingPercent = total == 0 ? 0 : (widget.pending / total) * 100;
    final canceledPercent = total == 0 ? 0 : (widget.canceled / total) * 100;

    final values = [
      widget.collected,
      widget.pending,
      widget.canceled,
    ];

    final labels = [
      "נאספו",
      "ממתינות",
      "בוטלו",
    ];

    final colors = [
      HomepageTheme.latetBlue.withOpacity(0.85),
      HomepageTheme.latetYellow.withOpacity(0.9),
      const Color.fromARGB(255, 160, 183, 233),
    ];

    return SizedBox(
      height: 210,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 45,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = null;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: List.generate(3, (i) {
                  final isTouched = i == touchedIndex;
                  final double value = values[i];
                  final double percent =
                      total == 0 ? 0 : (value / total) * 100;

                  return PieChartSectionData(
                    value: value,
                    color: colors[i],
                    title: isTouched
                        ? value.toStringAsFixed(0)
                        : "${percent.round()}%",
                    radius: isTouched ? 45 : 40,
                    titleStyle: TextStyle(
                      fontSize: isTouched ? 15 : 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: List.generate(3, (i) {
              return _LegendItem(
                color: colors[i],
                label: labels[i],
              );
            }),
          ),
        ],
      ),
    );
  }
}


// ===== LEGEND ITEM =====
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
