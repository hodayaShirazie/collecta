import 'package:flutter/material.dart';
import '../widgets/custom_popup_dialog.dart';

/// Shared helper that drives the "complete missing fields" dialog loop.
/// Each homepage provides its own [contentBuilder] and [onSave] callbacks.
class ProfileCompletionFlow {
  static void show({
    required BuildContext context,
    required List<String> fields,
    required Widget Function(String field, TextEditingController controller)
        contentBuilder,
    required Future<void> Function(String field, String value) onSave,
  }) {
    if (fields.isEmpty) return;

    int index = 0;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    void showNext() {
      final field = fields[index];

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(
          builder: (ctx, _) {
            return Form(
              key: formKey,
              child: CustomPopupDialog(
                title: "השלמת פרטים",
                cancelText: "דלג",
                buttonText: "שמור",
                content: contentBuilder(field, controller),
                onCancel: () {
                  controller.clear();
                  if (index < fields.length - 1) {
                    index++;
                    showNext();
                  }
                },
                onConfirm: () async {
                  if (formKey.currentState!.validate()) {
                    final value = controller.text.trim();
                    if (value.isNotEmpty) {
                      await onSave(field, value);
                    }
                    controller.clear();
                    if (index < fields.length - 1) {
                      index++;
                      Navigator.pop(ctx);
                      showNext();
                    } else {
                      Navigator.pop(ctx);
                    }
                  }
                },
              ),
            );
          },
        ),
      );
    }

    showNext();
  }
}
