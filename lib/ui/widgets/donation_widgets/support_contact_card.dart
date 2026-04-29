import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showEmailOptions(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontFamily: 'Assistant',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: const Icon(Icons.open_in_new,
                    color: HomepageTheme.latetBlue),
                title: const Text('פתח Gmail',
                    style: TextStyle(fontFamily: 'Assistant')),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final uri = Uri.parse('mailto:$email');
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.copy, color: HomepageTheme.latetBlue),
                title: const Text('העתק כתובת מייל',
                    style: TextStyle(fontFamily: 'Assistant')),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: email));
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('כתובת המייל הועתקה'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
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
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              if (supportPhone != null)
                _ContactButton(
                  icon: Icons.phone_outlined,
                  label: supportPhone!,
                  onTap: () => _launchPhone(supportPhone!),
                ),
              if (supportMail != null)
                _ContactButton(
                  icon: Icons.email_outlined,
                  label: supportMail!,
                  onTap: () => _showEmailOptions(context, supportMail!),
                ),
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
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: HomepageTheme.latetBlue.withValues(alpha: 0.25)),
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
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: HomepageTheme.latetBlue,
                  fontFamily: 'Assistant',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
