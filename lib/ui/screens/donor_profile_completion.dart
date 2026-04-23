import 'package:flutter/material.dart';

import '../../data/models/donor_model.dart';
import '../../services/donor_service.dart';

import '../widgets/donation_widgets/input_field.dart';
import '../widgets/donation_widgets/card.dart';
import '../widgets/donation_widgets/section_title.dart';

import '../utils/validators/phone_validator.dart';
import '../utils/validators/business_id_validator.dart';

import '../../app/routes.dart';

class DonorProfileCompletionScreen extends StatefulWidget {
  final DonorProfile donor;

  const DonorProfileCompletionScreen({super.key, required this.donor});

  @override
  State<DonorProfileCompletionScreen> createState() => _State();
}

class _State extends State<DonorProfileCompletionScreen> {

  final _formKey = GlobalKey<FormState>();
  final DonorService _donorService = DonorService();

  int step = 0;
  bool _isLoading = false;

  late List<String> fields;

  final businessNameCtrl = TextEditingController();
  final businessPhoneCtrl = TextEditingController();
  final contactNameCtrl = TextEditingController();
  final contactPhoneCtrl = TextEditingController();
  final crnCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fields = widget.donor.missingFields();
  }

  Future<void> nextStep() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updated = widget.donor.copyWith(
        businessName: businessNameCtrl.text,
        businessPhone: businessPhoneCtrl.text,
        contactName: contactNameCtrl.text,
        contactPhone: contactPhoneCtrl.text,
        crn: crnCtrl.text,
      );

      await _donorService.updateDonorProfile(updated);

      if (!mounted) return;

      if (step < fields.length - 1) {
        setState(() {
          step++;
          _isLoading = false;
        });
      } else {
        Navigator.pushReplacementNamed(context, Routes.donor);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    if (fields.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("אין שדות חסרים")),
      );
    }

    final field = fields[step];

    return Scaffold(
      appBar: AppBar(title: const Text("השלמת פרטים")),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,
          child: Column(
            children: [

              CardWidget(
                child: Column(
                  children: [

                    const SectionTitleWidget(text: "השלמת פרטים"),

                    const SizedBox(height: 20),

                    _buildField(field),
                  ],
                ),
              ),

              const Spacer(),

              Row(
                children: [

                  TextButton(
                    onPressed: () {
                      if (step < fields.length - 1) {
                        setState(() => step++);
                      }
                    },
                    child: const Text("דלג"),
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: _isLoading ? null : nextStep,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text("המשך"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String field) {

    switch (field) {

      case "businessName":
        return InputFieldWidget(
          hint: "שם העסק",
          controller: businessNameCtrl,
        );

      case "businessPhone":
        return InputFieldWidget(
          hint: "טלפון העסק",
          controller: businessPhoneCtrl,
          validator: validatePhone,
          keyboardType: TextInputType.phone,
        );

      case "contactName":
        return InputFieldWidget(
          hint: "איש קשר",
          controller: contactNameCtrl,
        );

      case "contactPhone":
        return InputFieldWidget(
          hint: "טלפון איש קשר",
          controller: contactPhoneCtrl,
          validator: validatePhone,
          keyboardType: TextInputType.phone,
        );

      case "crn":
        return InputFieldWidget(
          hint: "ח.פ",
          controller: crnCtrl,
          validator: validatecrn,
        );

      default:
        return const SizedBox();
    }
  }
}