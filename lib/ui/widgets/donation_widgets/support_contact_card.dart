import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/homepage_theme.dart';

class SupportContactCard extends StatelessWidget {
  final String? supportPhone;
  final String? supportMail;

  const SupportContactCard({
    super.key,
    this.supportPhone,
    this.supportMail,
  });

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    if (supportPhone == null && supportMail == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: HomepageTheme.latetBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: HomepageTheme.latetBlue.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'צריך עזרה במילוי הטופס?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: HomepageTheme.latetBlue,
              fontFamily: 'Assistant',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'צוות התמיכה שלנו כאן בשבילך',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontFamily: 'Assistant',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (supportPhone != null) ...[
                _ContactButton(
                  icon: Icons.phone_outlined,
                  label: supportPhone!,
                  onTap: () => _launch('tel:$supportPhone'),
                ),
              ],
              if (supportPhone != null && supportMail != null)
                const SizedBox(width: 12),
              if (supportMail != null) ...[
                _ContactButton(
                  icon: Icons.email_outlined,
                  label: supportMail!,
                  onTap: () => _launch('mailto:$supportMail'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HomepageTheme.latetBlue.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: HomepageTheme.latetBlue),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HomepageTheme.latetBlue,
                fontFamily: 'Assistant',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
