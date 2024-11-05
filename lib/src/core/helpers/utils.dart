//here we will write common standalone functions also called utilities functions
import "dart:convert";
import "dart:io";
import 'package:device_info_plus/device_info_plus.dart';
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";
import "package:patient_health_record/custom_encrypter/encrypter/file_cryptor.dart";
import "package:patient_health_record/src/core/helpers/console_log_functions.dart";
import "package:permission_handler/permission_handler.dart";

import "../constants/app_constants.dart";

String getFileExtension(String filePath) {
  return p.extension(filePath);
}

String getFileName(String filePath) {
  return p.basename(filePath);
}

void debugLog(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}

double getFileSizeInMB(File file) {
  // Get the size of the file in bytes
  final int bytes = file.lengthSync();
  // Convert bytes to megabytes
  final double megabytes = bytes / (1024 * 1024);
  return megabytes;
}

Future<List<File>> pickImagesFromGallery(context) async {
  final picker = ImagePicker(); // Instance of Image picker
  List<File> selectedImages = [];
  final pickedFile = await picker.pickMultiImage(
// imageQuality: 100, // To set quality of images
// maxHeight: 300, // To set maxheight of images that you want in your app
// maxWidth: 300
      ); // To set maxheight of images that you want in your app
  List<XFile> xfilePick = pickedFile;

  if (xfilePick.isNotEmpty) {
    for (var i = 0; i < xfilePick.length; i++) {
      selectedImages.add(File(xfilePick[i].path));
    }
    return selectedImages;
  } else {
// If no image is selected it will show a
// snackbar saying nothing is selected
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1), content: Text('Nothing selected')));

    return selectedImages;
  }
}

Future<File> decryptXor(
    String filePath, String extension, FileCryptor fileCryptor) async {
  print("start decryption: ${DateTime.now()}");

  try {
    File decryptedFile = await fileCryptor.decryptXor(
      inputFile: filePath,
      outputFile: "$filePath.$extension",
    );

    print(decryptedFile.path);
    print("end decryption: ${DateTime.now()}");

    return decryptedFile;
    decryptedFile.absolute.toString();
  } catch (e) {
    print("exception: $e");
    rethrow;
  }
}

Future<File> decryptAesEcb(
    String filePath, String extension, FileCryptor fileCryptor) async {
  print("start decryption: ${DateTime.now()}");

  try {
    File decryptedFile = await fileCryptor.decryptAesEcb(
      inputFile: filePath,
      outputFile: "$filePath.$extension",
    );

    print(decryptedFile.path);
    print("end decryption: ${DateTime.now()}");

    return decryptedFile;
    decryptedFile.absolute.toString();
  } catch (e) {
    print("exception: $e");
    rethrow;
  }
}

Future<File> decryptTwofish(
    String filePath, String extension, FileCryptor fileCryptor) async {
  print("start decryption: ${DateTime.now()}");

  try {
    File decryptedFile = await fileCryptor.decryptTwofish(
      inputFile: filePath,
      outputFile: "$filePath.$extension",
    );

    print(decryptedFile.path);
    print("end decryption: ${DateTime.now()}");

    return decryptedFile;
    decryptedFile.absolute.toString();
  } catch (e) {
    print("exception: $e");
    rethrow;
  }
}

Future<File> decryptBblowfish(
    String filePath, String extension, FileCryptor fileCryptor) async {
  print("start decryption: ${DateTime.now()}");

  try {
    File decryptedFile = await fileCryptor.decryptBlowfish(
      inputFile: filePath,
      outputFile: "$filePath.$extension",
    );

    print(decryptedFile.path);
    print("end decryption: ${DateTime.now()}");

    return decryptedFile;
    decryptedFile.absolute.toString();
  } catch (e) {
    print("exception: $e");
    rethrow;
  }
}

extension SpaceXY on int {
  SizedBox get spaceX => SizedBox(
        width: toDouble(),
      );

  SizedBox get spaceY => SizedBox(
        height: toDouble(),
      );
}

Future<int> getAndroidVersion() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
  return androidDeviceInfo.version.sdkInt;
}

Uint8List stringToUint8List(String str) {
  return Uint8List.fromList(utf8.encode(str));
}

Future<bool> getAppDirectoryPath() async {
  int version = 29;
  if (Platform.isAndroid) {
    version = await getAndroidVersion();
    if (version < 33) {
      PermissionStatus permissionStatus = await Permission.storage.status;
      logInfo("permissionStatus: $permissionStatus");
      if (permissionStatus.isDenied) {
        permissionStatus = await Permission.storage.request();
        if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
          await openAppSettings();
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        await openAppSettings();
      } else {
        Constants.appDocumentsDir = (await getApplicationDocumentsDirectory())!;

        return true;
      }
    } else {
      PermissionStatus permissionStatus = await Permission.photos.status;
      logInfo("permissionStatus: $permissionStatus");

      if (permissionStatus.isDenied) {
        permissionStatus = await Permission.photos.request();
        logInfo("permissionStatus2: $permissionStatus");

        if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
          await openAppSettings();
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        await openAppSettings();
      } else {
        Constants.appDocumentsDir = (await getApplicationDocumentsDirectory())!;
        return true;
      }
    }
  }
  return false;
}
