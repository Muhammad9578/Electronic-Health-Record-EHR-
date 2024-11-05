import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:patient_health_record/custom_encrypter/file_cryptor.dart';
import 'package:patient_health_record/src/core/helpers/console_log_functions.dart';
import 'package:patient_health_record/src/presentation/modules/encryption_data/db_helper.dart';

import '../models/file_model.dart';

class EncryptionDataHandler {
  final List<FileModel> files;
  final DatabaseHelper databaseHelper;
  final FileCryptor fileCryptor;
  final Directory appDocumentsDir;

  EncryptionDataHandler(
      {required this.files,
      required this.appDocumentsDir,
      required this.fileCryptor,
      required this.databaseHelper});
}

Future<List<FileModel>> saveFiles(EncryptionDataHandler data) async {
  try {
    final DatabaseHelper databaseHelper = data.databaseHelper;
    final List<FileModel> files = data.files;
    final FileCryptor fileCryptor = data.fileCryptor;
    final Directory appDocumentsDir = data.appDocumentsDir;
    List<FileModel> encryptedFiles = [];
    final encryption = files.map((FileModel fileModel) async {
      final File encryptedFile =
          await encryptXor(fileModel.path!, fileModel.name, fileCryptor, appDocumentsDir);
      FileModel newFile = fileModel.copyWith();
      newFile.path = encryptedFile.path;
      encryptedFiles.add(newFile);

      // await databaseHelper.insertMedia(newFile.toJson());
    }).toList();

    await Future.wait(encryption);
    return encryptedFiles;
  } catch (e) {
    logError("Error in encryption isolate: $e");
    rethrow;
  }
}

Future<File> encryptXor(
    String path, String name, FileCryptor fileCryptor, Directory appDocumentsDir) async {
  print("start encryption: ${DateTime.now()}");
  print("path: ${path}");
  print("path: ${name}");
  String encryptedPath;
  try {
    File encryptedFile = await fileCryptor.encryptXor(
      inputFile: path,
      outputFile: "${appDocumentsDir.path}/${name}",
    );
    print("encryptedFile.absolute: ${encryptedFile.absolute}");
    print("end encryption: ${DateTime.now()}");
    return encryptedFile;
  } catch (e) {
    print("exception: $e");
    encryptedPath = "exception: $e";
    rethrow;
  }
}

void performCalculationInMainThread() {
  final stopwatch = Stopwatch()..start();
  // Replace this with your actual calculation
  final result = heavyComputation();
  stopwatch.stop();
  print('Main thread computation took: ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> performCalculationInIsolate() async {
  final stopwatch = Stopwatch()..start();
  final result = compute(heavyComputation as ComputeCallback, null);
  stopwatch.stop();
  print('Isolate computation took: ${stopwatch.elapsedMilliseconds} ms');
}

int heavyComputation() {
  // Simulate heavy computation
  int sum = 0;
  for (int i = 0; i < 1000000000; i++) {
    sum += i;
  }
  return sum;
}
