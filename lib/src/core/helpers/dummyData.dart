

import 'package:flutter/material.dart';

import '/src/data/models/models.dart';

// List<MedicalRecord> dummyMedicalRecords = [];

final ValueNotifier<List<MedicalRecord>> dummyMedicalRecords =
ValueNotifier<List<MedicalRecord>>([]);

// class MedicalRecordNotifier extends ValueNotifier<List<MedicalRecord>> {
//   MedicalRecordNotifier(List<MedicalRecord> value) : super(value);
// }
//
// final MedicalRecordNotifier recordNotifier = MedicalRecordNotifier([]);
