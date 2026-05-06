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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final dialogWidth = isMobile ? screenWidth * 0.70 : 100.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.12),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: Padding(
            padding: isMobile
                ? const EdgeInsets.fromLTRB(14, 16, 14, 12)
                : const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 20,
                    fontWeight: FontWeight.bold,
                    color: _blue,
                    fontFamily: _font,
                  ),
                ),

                SizedBox(height: isMobile ? 5 : 8),
                Container(
                  height: 2,
                  width: 32,
                  decoration: BoxDecoration(
                    color: _blue.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 16),

                content ??
                    Text(
                      message ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        color: const Color(0xFF555555),
                        fontFamily: _font,
                        height: 1.5,
                      ),
                    ),

                SizedBox(height: isMobile ? 14 : 24),

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
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF888888).withOpacity(0.22);
                            }
                            if (states.contains(WidgetState.hovered)) {
                              return const Color(0xFF888888).withOpacity(0.10);
                            }
                            return null;
                          }),
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.hovered)) {
                              return const Color(0xFFEEEEEE);
                            }
                            return null;
                          }),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          ),
                        ),
                        child: Text(
                          cancelText!,
                          style: TextStyle(
                            fontFamily: _font,
                            fontSize: isMobile ? 12 : 14,
                            color: const Color(0xFF888888),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 18 : 24,
                          vertical: isMobile ? 6 : 8,
                        ),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.hovered) ||
                              states.contains(WidgetState.pressed)) {
                            return Colors.white.withOpacity(0.08);
                          }
                          return null;
                        }),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              buttonText,
                              style: TextStyle(
                                fontFamily: _font,
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                    ),

                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
