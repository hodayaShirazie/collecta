import 'package:flutter/material.dart';

class CustomPopupDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final String? message;
  final String buttonText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  const CustomPopupDialog({
    super.key,
    required this.title,
    this.content,
    this.message,
    this.buttonText = "סגור",
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  });

  static const Color _blue = Color(0xFF1E5DAA);
  static const String _font = 'Assistant';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.12),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ─── כותרת ───────────────────────────────────────
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _blue,
                  fontFamily: _font,
                ),
              ),

              const SizedBox(height: 8),
              Container(
                height: 2,
                width: 40,
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // ─── תוכן ─────────────────────────────────────────
              content ??
                  Text(
                    message ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF555555),
                      fontFamily: _font,
                      height: 1.5,
                    ),
                  ),

              const SizedBox(height: 24),

              // ─── כפתורים ──────────────────────────────────────
              Row(
                mainAxisAlignment: cancelText != null
                    ? MainAxisAlignment.spaceEvenly
                    : MainAxisAlignment.center,
                children: [

                  if (cancelText != null)
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              onCancel?.call();
                            },
                      child: Text(
                        cancelText!,
                        style: const TextStyle(
                          fontFamily: _font,
                          fontSize: 15,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ),

                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : (onConfirm ?? () => Navigator.of(context).pop()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 11),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            buttonText,
                            style: const TextStyle(
                              fontFamily: _font,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                  ),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
