import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:patient_health_record/src/core/constants/app_constants.dart';
import 'package:patient_health_record/src/core/helpers/helpers.dart';
import 'package:patient_health_record/src/data/resources/local/local_database/local_database.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '/src/data/models/models.dart';
// import '/main.dart';

import '../../../../../../custom_encrypter/encrypter/file_cryptor.dart';
import '../../../../../core/themes/themes.dart';
import '../../../../widgets/widgets.dart';
import '../../widget/display_picked_file.dart';
import '../../widget/medical_record_icons.dart';

class PickMedicalRecordScreen extends StatefulWidget {
  const PickMedicalRecordScreen({super.key});

  @override
  State<PickMedicalRecordScreen> createState() =>
      _PickMedicalRecordScreenState();
}

class _PickMedicalRecordScreenState extends State<PickMedicalRecordScreen> {
  File? pickedFile;
  Uint8List? pdfUint8List;
  String fileName = "";
  bool isLoading = false;
  String extension = "";
  final fileNameController = TextEditingController();
  FileCryptor fileCryptor = FileCryptor(
    key: "qwertyuiop@#%^&*()_+1234567890,;",
    iv: 8,
    dir: "example",
    // useCompress: true,
  );
  late final Directory appDocumentsDir;


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
    appDocumentsDir = (await getExternalStorageDirectory())!;
    print("appDocumentsDir: $appDocumentsDir");
    _pickFile();
    setState(() {});
  }

  @override
  void initState() {
    getPath();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("pickedFile 2: ${pickedFile}");
    return MyScaffold(
        showAppbar: false,
        body: Stack(
          children: [
            Positioned(
              left: 20,
              top: 55,
              child: MedicalRecordIcon(
                icon: MyIcons.close,
                height: 25,
                width: 25,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              right: 70,
              top: 50,
              child: MedicalRecordIcon(
                icon: MyIcons.save,
                height: 30,
                width: 30,
              ),
            ),
            Positioned(
              right: 20,
              top: 50,
              child: MedicalRecordIcon(
                icon: MyIcons.replace,
                height: 35,
                width: 35,
                onTap: _pickFile,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 80,
              bottom: 0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: fileNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter file name";
                        } else if (value.contains('.')) {
                          return "dot (.) is not allowed";
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "File name",
                        labelText: "File name",
                      ),
                    ),
                  ),
                  pickedFile != null
                      ? Expanded(
                    child: PDFScreen(
                      // pdfData: pdfUint8List,
                      path: pickedFile!.path,
                      key: UniqueKey(),
                    ),
                  )
                      : Text("File not picked"),
                ],
              ),
            ),
          ],
        ));
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // _openFile(result.files.first);

      setState(() {
        File fl = File(result.files.single.path!);
        pickedFile = fl;

        // extension = getFileExtension(pickedFile!.path);
        fileNameController.text = p.basenameWithoutExtension(fl.path);
        // print("extestion: $extension");
        // fileName = getFileName(fl!.path);
        // print('File name: $fileName');
      });
    } else {
      // User canceled the file picking
    }
  }

  saveRecord() async {
    isLoading = true;
    setState(() {

    });
    String path = await encryptSalsa20();

    MedicalRecord record = MedicalRecord(
        name: "${p.basenameWithoutExtension(pickedFile!.path)}",
        size: "2 mb",
        description: "file description",
        extension: "${p.extension(pickedFile!.path)}",
        path: path
    );
    await getIt.get<LocalDatabase>().addMedicalRecord(record);
    isLoading = false;
    setState(() {});
  }

  Future<String> encryptSalsa20() async {
    debugLog("start encryption: ${DateTime.now()}");
    setState(() {
      isLoading = true;
    });
    try {
      print("inputFile: pickedFile?.path,: ${pickedFile?.path}");
      File encryptedFile = await fileCryptor.encryptSalsa20(
        inputFile: pickedFile?.path,
        outputFile: "${appDocumentsDir.path}/${fileName}.aes",
      );
      print(encryptedFile.absolute);
      print("end encryption: ${DateTime.now()}");

      // setState(() {
      return encryptedFile.absolute.toString();

      // });
    } catch (e) {
      print("exception: $e");
      throw "Error, unable ti encrypt";
    }
  }

//
// void _openFile(PlatformFile file) {
//   OpenFile.open(file.path);
// }
}
