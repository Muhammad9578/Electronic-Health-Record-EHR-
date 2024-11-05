import 'package:flutter/material.dart';
import 'package:patient_health_record/src/core/helpers/helpers.dart';
import 'package:patient_health_record/src/presentation/widgets/buttons.dart';

import '../screens/medical_records_screen/p_add_work_image_screen.dart';

class PickRecordsChoiceSheet extends StatelessWidget {
  const PickRecordsChoiceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 30.spaceY,
          GreenButton(
              btnTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotographerPickWorkImageScreen(),
                    ));
              },
              btnText: "Pick Images"),
          GreenButton(btnTap: () {}, btnText: "Pick Files"),
        ],
      ),
    );
  }
}
