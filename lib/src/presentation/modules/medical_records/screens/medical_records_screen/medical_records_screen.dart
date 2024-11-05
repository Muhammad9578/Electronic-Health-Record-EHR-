import 'dart:io';

import 'package:flutter/material.dart';
import 'package:patient_health_record/src/core/helpers/dummyData.dart';
import 'package:patient_health_record/src/core/routes/app_routes.dart';
import 'package:patient_health_record/src/data/models/medical_record.dart';

import '../../../../widgets/widgets.dart';
import '../../widget/empty_records.dart';

class MedicalRecordsScreen extends StatefulWidget {
  static const String route = medicalRecordsScreen;

  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Medical Records",
      leading: backIcon(onTap: () {
        Navigator.pop(context);
      }),
      body: Column(
        children: [
          Column(children: [
            ValueListenableBuilder<List<MedicalRecord>>(
              valueListenable: dummyMedicalRecords,
              builder: (context, medicalRecordsList, _) {
                return medicalRecordsList.isEmpty
                    ? const EmptyRecords()
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: medicalRecordsList.length,
                              itemBuilder: (context, index) {
                                MedicalRecord medicalRecord =
                                    medicalRecordsList[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("${medicalRecord.name}"),
                                );
                              },
                            ),
                          ),
                        ],
                      );
              },
            ),
          ]),
        ],
      ),
    );
  }
}
