import 'package:flutter/material.dart';
import '/src/presentation/widgets/widgets.dart';
import 'pick_records_choice_sheet.dart';

class PickRecordsButton extends StatelessWidget {
  const PickRecordsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 15),
      child: GreenButton(
          btnTap: () {
            // Navigator.pushNamed(
            //     context, 'pickMedicalRecordScreen');
            const PickRecordsChoiceSheet();
          },
          btnText: "Pick File"),
    );
  }
}
