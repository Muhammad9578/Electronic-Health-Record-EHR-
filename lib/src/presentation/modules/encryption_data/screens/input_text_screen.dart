import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patient_health_record/src/presentation/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../custom_encrypter/encrypter/file_cryptor.dart';
import '../../../../core/constants/app_constants.dart';
import '../db_helper.dart';
import '../models/file_model.dart';
import 'isolate_for_encryption.dart';

class InputTextScreen extends StatefulWidget {
  final FileModel? fileModel;

  const InputTextScreen({super.key, this.fileModel});

  @override
  State<InputTextScreen> createState() => _InputTextScreenState();
}

class _InputTextScreenState extends State<InputTextScreen> {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  FileCryptor fileCryptor = FileCryptor(
    key: "qwertyuiop@#%^&*()_+1234567890,;",
    iv: 8,
    dir: "KhurramData",
    // useCompress: true,
  );
  bool loading = false;

  @override
  void initState() {
    if (widget.fileModel != null) {
      decryptXor();
    }
    super.initState();
  }

  Future<void> decryptXor() async {
    print("start decryption: ${DateTime.now()}");
    setState(() {
      loading = true;
    });
    try {
      String decryptedFile = await fileCryptor.decryptAesText(
        encryptedText: widget.fileModel!.data!,
      );
      controller.text = decryptedFile;

      setState(() {
        loading = false;
      });
    } catch (e) {
      print("exception: $e");
    }
  }

  Future<void> _saveFiles(context, {bool withIsolate = false}) async {
    try {
      setState(() {
        loading = true;
      });
      if (!withIsolate) {
        final encryptedFile = await encryptXor1(controller.text);
        FileModel fileModel = FileModel(
          name: controller.text.substring(0, 10),
          type: TypeOfFile.text,
          data: encryptedFile,
        );
        if (widget.fileModel != null) {
          fileModel.id = widget.fileModel!.id;
        }
        if (widget.fileModel != null) {
          await _databaseHelper.updateWordById(widget.fileModel!.id!, fileModel.toJson());
        } else {
          await _databaseHelper.insertMedia(fileModel.toJson());
        }
      } else {
        // List<FileModel> encryptedFiles = await Isolate.run(() => saveFiles(
        //     EncryptionDataHandler(
        //         files: widget.files,
        //         appDocumentsDir: appDocumentsDir,
        //         databaseHelper: _databaseHelper,
        //         fileCryptor: fileCryptor)));

        // await compute(
        //     saveFiles,
        //     EncryptionDataHandler(
        //         files: widget.files,
        //         appDocumentsDir: appDocumentsDir,
        //         databaseHelper: _databaseHelper,
        //         fileCryptor: fileCryptor));

        // for (FileModel newFile in encryptedFiles) {
        //   print("file name: ${newFile.name}");
        //   print("file path: ${newFile.path}");
        //   await _databaseHelper.insertMedia(newFile.toJson());
        // }
      }
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text data saved successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
      print("exception: $e");
    }
  }

  Future<dynamic> encryptXor1(String path) async {
    print("start encryption: ${DateTime.now()}");
    print("path: ${path}");
    try {
      var encryptedFile = await fileCryptor.encryptAesText(
        dataToEncrypt: path,
      );
      print("encryptedFile.absolute: ${encryptedFile}");
      print("end encryption: ${DateTime.now()}");
      return encryptedFile;
    } catch (e) {
      print("exception: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Input Your Text",
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Expanded(
                child: TextFormField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Input your text to save";
                    } else if (value.length < 10) {
                      return "Length should be more than 10 characters";
                    } else
                      return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Input your text here",
                  ),
                ),
              ),
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : GreenButton(
                    btnText: "Save",
                    btnTap: () {
                      if (formKey.currentState!.validate()) {
                        _saveFiles(context);
                      }
                    },
                  )
          ],
        ),
      ),
    );
  }
}
