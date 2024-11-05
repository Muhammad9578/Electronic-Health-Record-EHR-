import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xor_encryption/xor_encryption.dart';

import '../custom_encrypter/encrypter/file_cryptor.dart';
import 'cacha20.dart';
import 'package:cryptography/cryptography.dart' as cryptography;

class TestEncryption extends StatefulWidget {
  const TestEncryption({super.key});

  @override
  State<TestEncryption> createState() => _TestEncryptionState();
}

class _TestEncryptionState extends State<TestEncryption> {
  String encryptedPath = "";
  String decryptedPath = "";
  bool decrypting = false;
  bool encrypting = false;
  String path = "files/";
  late final Directory appDocumentsDir;
  String extension = "";
  String fileName = "";

  FileCryptor fileCryptor = FileCryptor(
    key: "qwertyuiop@#%^&*()_+1234567890,;",
    iv: 8,
    dir: "example",
    // useCompress: true,
  );

  File? pickedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        pickedFile = File(result.files.single.path!);
        extension = getFileExtension(pickedFile!.path);
        print("extestion: $extension");
        fileName = getFileName(pickedFile!.path);

        print('File name: $fileName');
      });
    } else {
      // User canceled the file picking
    }
  }

  String getFileExtension(String filePath) {
    RegExp regExp = RegExp(r'\.([a-zA-Z0-9]+)$');
    Match? match = regExp.firstMatch(filePath);

    return match?.group(1) ?? ''; // Returns an empty string if no match is found
  }

  String getFileName(String filePath) {
    return basename(filePath);
  }

  Future<void> _saveFile() async {
    if (pickedFile == null) {
      // No file picked
      return;
    }

    // You can customize the destination path and file name as needed
    String destinationPath =
        '/storage/emulated/0/Download/${pickedFile!.path.split('/').last}';

    try {
      await pickedFile!.copy(destinationPath);
      print('File saved to: $destinationPath');
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  encryptAES() async {
    print("start encryption: ${DateTime.now()}");
    setState(() {
      encrypting = true;
    });
    try {
      print("inputFile: pickedFile?.path,: ${pickedFile?.path}");
      File encryptedFile = await fileCryptor.encryptAesEcb(
          inputFile: pickedFile?.path,
          outputFile: "${appDocumentsDir.path}/${fileName}.aes");
      print(encryptedFile.absolute);
      print("end encryption: ${DateTime.now()}");

      setState(() {
        encryptedPath = encryptedFile.absolute.toString();
        encrypting = false;
      });
    } catch (e) {
      print("exception: $e");
      setState(() {
        encryptedPath = "exception: $e";
        encrypting = false;
      });
    }
  }

  decryptAES() async {
    print("start decryption: ${DateTime.now()}");

    setState(() {
      decrypting = true;
    });
    try {
      File decryptedFile = await fileCryptor.decryptAesEcb(
          inputFile: "${appDocumentsDir.path}/${fileName}.aes",
          outputFile: "${appDocumentsDir.path}/${fileName}");
      print(decryptedFile.absolute);
      print("end decryption: ${DateTime.now()}");

      setState(() {
        decryptedPath = decryptedFile.absolute.toString();
        decrypting = false;
      });
    } catch (e) {
      print("exception: $e");
      setState(() {
        decryptedPath = "exception: $e";
        decrypting = false;
      });
    }
  }

  encryptSalsa20() async {
    print("start encryption: ${DateTime.now()}");
    setState(() {
      encrypting = true;
    });
    try {
      print("inputFile: pickedFile?.path,: ${pickedFile?.path}");
      File encryptedFile = await fileCryptor.encryptSalsa20(
        inputFile: pickedFile?.path,
        outputFile: "${appDocumentsDir.path}/${fileName}.aes",
      );
      print(encryptedFile.absolute);
      print("end encryption: ${DateTime.now()}");

      setState(() {
        encryptedPath = encryptedFile.absolute.toString();
        encrypting = false;
      });
    } catch (e) {
      print("exception: $e");
      setState(() {
        encryptedPath = "exception: $e";
        encrypting = false;
      });
    }
  }

  decryptSalsa20() async {
    print("start decryption: ${DateTime.now()}");

    setState(() {
      decrypting = true;
    });
    try {
      File decryptedFile = await fileCryptor.decryptSalsa20(
        inputFile: "${appDocumentsDir.path}/${fileName}.aes",
        outputFile: "${appDocumentsDir.path}/${fileName}",
      );

      print(decryptedFile.absolute);
      print("end decryption: ${DateTime.now()}");

      setState(() {
        decryptedPath = decryptedFile.absolute.toString();
        decrypting = false;
      });
    } catch (e) {
      print("exception: $e");
      setState(() {
        decryptedPath = "exception: $e";
        decrypting = false;
      });
    }
  }

  void xorEncryption() {
    final String key = XorCipher().getSecretKey(20);
    print('key: $key');
    String text = '123456';
    print("start encryption: ${DateTime.now()}");

    final encrypted = XorCipher().encryptData(text, key);
    print('encreypteed: ${encrypted}');
    print("end encryption: ${DateTime.now()}");

    final decrypted = XorCipher().encryptData(encrypted, key);
    print('encreypteed: ${decrypted}');
  }

  encryptXor() async {
    print("start encryption: ${DateTime.now()}");
    setState(() {
      encrypting = true;
    });
    try {
      print("inputFile: pickedFile?.path,: ${pickedFile?.path}");
      File encryptedFile = await fileCryptor.encryptXor(
        inputFile: pickedFile?.path,
        outputFile: "${appDocumentsDir.path}/${fileName}.xor",
      );
      print(encryptedFile.absolute);
      print("end encryption: ${DateTime.now()}");

      setState(() {
        encryptedPath = encryptedFile.absolute.toString();
        encrypting = false;
      });
    } catch (e) {
      print("exception: $e");
      setState(() {
        encryptedPath = "exception: $e";
        encrypting = false;
      });
    }
  }

  decryptXor() async {
    print("start decryption: ${DateTime.now()}");

    setState(() {
      decrypting = true;
    });
    try {
      File decryptedFile = await fileCryptor.decryptXor(
        inputFile: "${appDocumentsDir.path}/${fileName}.xor",
        outputFile: "${appDocumentsDir.path}/${fileName}",
      );

      print(decryptedFile.path);
      print("end decryption: ${DateTime.now()}");

      setState(() {
        decryptedPath = decryptedFile.absolute.toString();
        decrypting = false;
      });
    } catch (e) {
      print("exception: $e");
      setState(() {
        decryptedPath = "exception: $e";
        decrypting = false;
      });
    }
  }

  getPath() async {
    final permissionStatus = await Permission.storage.status;
    if (permissionStatus.isDenied) {
      // Here just ask for the permission for the first time
      await Permission.storage.request();

      // I noticed that sometimes popup won't show after user press deny
      // so I do the check once again but now go straight to appSettings
      if (permissionStatus.isDenied) {
        await openAppSettings();
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      // Here open app settings for user to manually enable permission in case
      // where permission was permanently denied
      await openAppSettings();
    } else {
      // Do stuff that require permission here
    }
    appDocumentsDir = (await getApplicationDocumentsDirectory())!;
    print("appDocumentsDir: $appDocumentsDir");
    setState(() {});
  }

  @override
  void initState() {
    getPath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("khurram"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            encrypting
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  )
                : Column(
                    children: [
                      ElevatedButton(onPressed: encryptAES, child: Text("EncryptAES")),
                      ElevatedButton(
                          onPressed: encryptSalsa20, child: Text("Encrypt Salsa20")),
                      ElevatedButton(onPressed: encryptXor, child: Text("Encrypt XOR")),
                      SizedBox(height: 5),
                      Text("Encrypted path",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
                      SizedBox(height: 5),
                      Text(encryptedPath),
                    ],
                  ),
            SizedBox(height: 30),
            decrypting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      ElevatedButton(onPressed: decryptAES, child: Text("DecryptAES")),
                      ElevatedButton(
                          onPressed: decryptSalsa20, child: Text("DecryptSalsa20")),
                      ElevatedButton(onPressed: decryptXor, child: Text("DecryptXor")),
                      SizedBox(height: 5),
                      Text("Deccrypted path",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
                      SizedBox(height: 5),
                      Text(decryptedPath),
                    ],
                  ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Pick a File'),
            ),
            SizedBox(height: 16),
            if (pickedFile != null) Text('Picked file: ${pickedFile!.path}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveFile,
              child: Text('Save File'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => CipherPage(),
            //         ));
            //   },
            //   child: Text('Move to android'),
            // ),
          ],
        ),
      ),
    );
  }
}
