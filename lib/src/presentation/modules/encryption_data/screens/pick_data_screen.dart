import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patient_health_record/custom_encrypter/encrypter/file_cryptor.dart';
import 'package:patient_health_record/src/core/helpers/console_log_functions.dart';
import 'package:patient_health_record/src/core/helpers/helpers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/app_constants.dart';
import '../../../widgets/buttons.dart';
import '../db_helper.dart';
import '../models/file_model.dart';
import 'isolate_for_encryption.dart';

class SaveFilesArguments {
  final String appDirPath;
  final SendPort sendPort;

  SaveFilesArguments(this.appDirPath, this.sendPort);
}

class PickDataScreen extends StatefulWidget {
  final TypeOfFile type;

  const PickDataScreen({super.key, required this.type});

  @override
  _PickDataScreenState createState() => _PickDataScreenState();
}

class _PickDataScreenState extends State<PickDataScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<FileModel> selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  FileCryptor fileCryptor = FileCryptor(
    key: "qwertyuiop@#%^&*()_+1234567890,;",
    iv: 8,
    dir: "KhurramData",
    // useCompress: true,
  );
  bool loading = true;
  bool encrypting = false;
  late final TypeOfFile type;

  @override
  void initState() {
    type = widget.type;

    if (type == TypeOfFile.image) {
      pickImages(context);
    } else if (type == TypeOfFile.video) {
      pickVideos(context);
    } else {
      pickDocuments(context);
    }
    super.initState();
  }

  makeFileInstance(List<XFile> file, TypeOfFile typeOfFile, context) {
    for (XFile element in file) {
      FileModel fileModel = FileModel(
        type: typeOfFile,
        path: element.path,
        name: p.basename(element.path).split('.')[0],
        extension: p.basename(element.path).split('.')[1],
      );
      selectedFiles.add(fileModel);
    }
    loading = false;
    setState(() {});
    //if (file.isNotEmpty) navigateToGridView(context);
  }

  Future<void> pickImages(context) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images != null) {
      makeFileInstance(images, TypeOfFile.image, context);
    } else {
      loading = false;
      setState(() {});
    }
  }

  Future<void> pickVideos(context) async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      makeFileInstance([video], TypeOfFile.video, context);
    } else {
      loading = false;
      setState(() {});
    }
  }

  Future<void> pickDocuments(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: true);

    if (result != null) {
      List<XFile> xfiles = result.files.map((file) => XFile(file.path!)).toList();
      makeFileInstance(xfiles, TypeOfFile.document, context);
    } else {
      loading = false;
      setState(() {});
    }
  }

  Future<File> decryptXor(String fileName, String extension) async {
    print("start decryption: ${DateTime.now()}");

    try {
      File decryptedFile = await fileCryptor.decryptXor(
        inputFile: "${fileName}",
        outputFile: "${fileName}.$extension",
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

  encryptionLoop() {
    performCalculationInMainThread();
    performCalculationInIsolate();
  }

  Future<void> _saveFiles(context, {bool withIsolate = false}) async {
    try {
      setState(() {
        encrypting = true;
      });
      await Future.delayed(const Duration(milliseconds: 50));

      if (!withIsolate) {
        final encryption = selectedFiles.map((FileModel fileModel) async {
          // final File encryptedFile = await encryptAesEcb(fileModel.path!, fileModel.name);
          // final File encryptedFile =
          //     await encryptTwoFish(fileModel.path!, fileModel.name);
          final File encryptedFile =
              await encryptBlowFish(fileModel.path!, fileModel.name);
          FileModel newFile = fileModel.copyWith();
          newFile.path = encryptedFile.path;
          await _databaseHelper.insertMedia(newFile.toJson());
        }).toList();

        await Future.wait(encryption);
      } else {
        List<FileModel> encryptedFiles = await Isolate.run(() => saveFiles(
            EncryptionDataHandler(
                files: selectedFiles,
                appDocumentsDir: Constants.appDocumentsDir!,
                databaseHelper: _databaseHelper,
                fileCryptor: fileCryptor)));

        // await compute(
        //     saveFiles,
        //     EncryptionDataHandler(
        //         files: widget.files,
        //         appDocumentsDir: appDocumentsDir,
        //         databaseHelper: _databaseHelper,
        //         fileCryptor: fileCryptor));

        for (FileModel newFile in encryptedFiles) {
          print("file name: ${newFile.name}");
          print("file path: ${newFile.path}");
          await _databaseHelper.insertMedia(newFile.toJson());
        }
      }
      setState(() {
        encrypting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Files saved successfully!')),
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        encrypting = false;
      });
      print("exception: $e");
    }
  }

  Future<File> encryptAesEcb(String path, String name) async {
    print("start encryption: ${DateTime.now()}");
    print("path: ${path}");
    print("path: ${name}");
    String encryptedPath;
    try {
      File encryptedFile = await fileCryptor.encryptAesEcb(
        inputFile: path,
        outputFile: "${Constants.appDocumentsDir!.path}/${name}",
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

  Future<File> encryptTwoFish(String path, String name) async {
    print("start encryption: ${DateTime.now()}");
    print("path: ${path}");
    print("path: ${name}");
    String encryptedPath;
    try {
      File encryptedFile = await fileCryptor.encryptTwoFish(
        inputFile: path,
        outputFile: "${Constants.appDocumentsDir!.path}/${name}",
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

  Future<File> encryptBlowFish(String path, String name) async {
    print("start encryption: ${DateTime.now()}");
    print("path: ${path}");
    print("path: ${name}");
    String encryptedPath;
    try {
      File encryptedFile = await fileCryptor.encryptBlowFish(
        inputFile: path,
        outputFile: "${Constants.appDocumentsDir!.path}/${name}",
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

  Future<File> encryptXor1(String path, String name) async {
    print("start encryption: ${DateTime.now()}");
    print("path: ${path}");
    print("path: ${name}");
    String encryptedPath;
    try {
      File encryptedFile = await fileCryptor.encryptXor(
        inputFile: path,
        outputFile: "${Constants.appDocumentsDir!.path}/${name}",
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

  getAllMedia() async {
    final List<Map<String, dynamic>> data =
        await _databaseHelper.getAllMedia(type: TypeOfFile.image.name);
    // logJSON(object: data);
    for (Map<String, dynamic> element in data) {
      // print("element: ${element}");
      File decdata = await decryptXor(element['path'], element['type']);
      print("decdata: ${decdata}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Display Picked Files'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : encrypting
                        ? const Center(child: Text("Saving your data, please wait ..."))
                        : selectedFiles.isEmpty
                            ? pickButtonBuild(context)
                            : buildGridView(),
              ),
              ...selectedFiles.isEmpty || encrypting || loading
                  ? []
                  : [
                      GreenButton(
                        btnTap: () async {
                          await _saveFiles(context);
                        },
                        btnText: "Encrypt & save",
                      ),
                      // GreenButton(
                      //   btnTap: () async {
                      //     await _saveFiles(context, withIsolate: true);
                      //   },
                      //   btnText: "Encrypt & save using separate Thread",
                      // ),
                      // GreenButton(
                      //   btnTap: () async {
                      //     encryptionLoop();
                      //   },
                      //   btnText: "Test enc loop",
                      // ),
                      // GreenButton(
                      //   btnTap: () async {
                      //     await getAllMedia();
                      //   },
                      //   btnText: "Print data",
                      // ),
                    ],
            ],
          ),
        ));
  }

  Column pickButtonBuild(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (type == TypeOfFile.image)
          GreenButton(
            btnTap: () async {
              await pickImages(context);
            },
            btnText: "Pick Images",
          )
        else if (type == TypeOfFile.video)
          GreenButton(
            btnTap: () async {
              await pickVideos(context);
            },
            btnText: "Pick Videos",
          )
        else
          GreenButton(
            btnTap: () async {
              await pickDocuments(context);
            },
            btnText: "Pick Documents",
          ),
      ],
    );
  }

  GridView buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: selectedFiles.length,
      itemBuilder: (context, index) {
        final FileModel file = selectedFiles[index];
        final size = getFileSizeInMB(File(file.path!));
        return Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(colors: [
                const Color(0xffB0BEC5).withAlpha(50),
                const Color(0xff0097A7).withAlpha(50),
              ])),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: [
                Expanded(
                  child: file.type == TypeOfFile.video
                      ? const Icon(Icons.video_library)
                      : file.type == TypeOfFile.document
                          ? const Icon(Icons.file_open)
                          : Image.file(File(file.path!)),
                ),
                Text(
                  file.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  "Size: ${size.toStringAsFixed(2)} MB",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
