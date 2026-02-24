import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/homepage_theme.dart';
import '../widgets/homepage_button.dart';

class AdminHomepage extends StatelessWidget {
  const AdminHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    // ===== FAKE DATA =====
    const String adminName = "רוני";
    const int totalDonations = 3050;
    const int waitingApproval = 14;
    const int growth = 52;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: HomepageTheme.pageGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // same decorative circle as driver
              Positioned(
                top: -120,
                right: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: HomepageTheme.decorativeCircle,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    const SizedBox(height: HomepageTheme.topPadding),

                    const SizedBox(height: 40),

                    // ===== WELCOME =====
                    Text(
                      'היי, $adminName',
                      style: HomepageTheme.welcomeTextStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '!שמחים לראות אותך שוב',
                      style: HomepageTheme.subtitleTextStyle.copyWith(
                        color: HomepageTheme.latetBlue.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ===== EXACT SAME BUTTONS STYLE =====
                    HomepageButton(
                      title: 'הנהגים שלי',
                      icon: Icons.local_shipping_outlined,
                      onPressed: () {},
                    ),
                    const SizedBox(height: HomepageTheme.betweenButtons),
                    HomepageButton(
                      title: 'צפייה בתרומות',
                      icon: Icons.list_alt_outlined,
                      onPressed: () {},
                    ),

                    const SizedBox(height: 35),

                    // ===== STATS ROW =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(
                          title: "אחוז גדילה",
                          value: "+$growth%",
                        ),
                        _StatItem(
                          title: "ממתינות לאישור",
                          value: waitingApproval.toString(),
                        ),
                        _StatItem(
                          title: "תרומות שהתקבלו",
                          value: totalDonations.toString(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ===== PIE CHART =====
                    SizedBox(
                      height: 170,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: 40,
                              color: Colors.red,
                              title: "40%",
                            ),
                            PieChartSectionData(
                              value: 25,
                              color: Colors.orange,
                              title: "25%",
                            ),
                            PieChartSectionData(
                              value: 20,
                              color: Colors.green,
                              title: "20%",
                            ),
                            PieChartSectionData(
                              value: 15,
                              color: Colors.blue,
                              title: "15%",
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // bottom logo like driver
                    Image.asset(
                      "assets/images/latet_logo.png",
                      height: HomepageTheme.deptLogoHeight,
                    ),
                    const SizedBox(height: 20),
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
        const SizedBox(height: 5),
        Text(
          title,
          style: HomepageTheme.subtitleTextStyle.copyWith(
            fontSize: 14,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}
