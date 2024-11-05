import 'package:flutter/material.dart';
import 'package:patient_health_record/src/presentation/modules/medical_records/medical_records.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("All dcotors"),
            GreenButton(
                btnTap: () {
                  appNavigationKey!.currentState!
                      .pushNamed(MedicalRecordsScreen.route);
                },
                btnText: "Medical Records"),
          ],
        ),
      ),
    );
  }
}
