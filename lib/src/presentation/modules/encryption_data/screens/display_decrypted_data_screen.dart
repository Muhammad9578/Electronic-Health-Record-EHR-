import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patient_health_record/custom_encrypter/encrypter/file_cryptor.dart';
import 'package:patient_health_record/src/core/constants/app_constants.dart';
import 'package:patient_health_record/src/core/helpers/console_log_functions.dart';
import 'package:patient_health_record/src/core/helpers/helpers.dart';
import 'package:patient_health_record/src/presentation/modules/encryption_data/models/file_model.dart';
import 'package:patient_health_record/src/presentation/modules/encryption_data/screens/video_player_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/view_pdf_screen.dart';
import '../db_helper.dart';
import 'pick_data_screen.dart';

class DisplayDecryptedDataScreen extends StatefulWidget {
  final TypeOfFile type;

  const DisplayDecryptedDataScreen({super.key, required this.type});

  @override
  _DisplayDecryptedDataScreenState createState() => _DisplayDecryptedDataScreenState();
}

class _DisplayDecryptedDataScreenState extends State<DisplayDecryptedDataScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<FileModel> files = [];
  late final TypeOfFile type;
  FileCryptor fileCryptor = FileCryptor(
    key: "qwertyuiop@#%^&*()_+1234567890,;",
    iv: 8,
    dir: "KhurramData",
  );

  int _currentPage = 0;
  final int _pageSize = 5;
  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    type = widget.type;
    getPath();
    getAllMedia();
    super.initState();
  }

  getAllMedia() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final List<Map<String, dynamic>> data = await _databaseHelper.getAllMedia(
        limit: _pageSize, offset: _currentPage * _pageSize, type: type.name);
    logJSON(object: data);

    List<Future<FileModel>> decryptionTasks = data.map((element) async {
      String path = element['path'];
      if (element['type'] == TypeOfFile.image.name) {
        // File decryptedData =
        //     await decryptAesEcb(element['path'], element['extension'], fileCryptor);
        // File decryptedData =
        //     await decryptTwofish(element['path'], element['extension'], fileCryptor);
        File decryptedData =
            await decryptBblowfish(element['path'], element['extension'], fileCryptor);
        path = decryptedData.path;
      }
      final map = {
        'path': path,
        'type': element['type'],
        'name': element['name'],
        'extension': element['extension'],
        'type': element['type']
      };
      return FileModel.fromJson(map);
    }).toList();
    await Future.delayed(const Duration(milliseconds: 50));
    List<FileModel> decryptedData = await Future.wait(decryptionTasks);

    setState(() {
      files = [...?files, ...decryptedData];
      _isLoading = false;
      _currentPage++;
      if (data.length < _pageSize) {
        _hasMoreData = false;
      }
    });
  }

  getPath() {
    if (Constants.appDocumentsDir == null) {
      getAppDirectoryPath();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Selected Media'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: Text("Fetching Your data. Please wait..."))
                    : files.isEmpty
                        ? const Center(child: Text("You have no data"))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemCount: files?.length,
                            itemBuilder: (context, index) {
                              FileModel file = files![index];

                              final size = getFileSizeInMB(File(file.path!));
                              print("image path: ${file.path}");
                              return Container(
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    const Color(0xffB0BEC5).withAlpha(50),
                                    const Color(0xff0097A7).withAlpha(50),
                                  ]),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    onTap: file.type == TypeOfFile.image
                                        ? null
                                        : () {
                                            file.type == TypeOfFile.document
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ViewPDFScreen(
                                                        fileModel: file,
                                                      ),
                                                    ))
                                                : Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoPlayerScreen(
                                                        fileModel: file,
                                                      ),
                                                    ));
                                          },
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: file.type == TypeOfFile.video
                                              ? const Icon(Icons.video_library)
                                              : file.type == TypeOfFile.document
                                                  ? const Icon(Icons.description)
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
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingIconButton(
              btnTap: () => navigateToInputScreen(context),
              icon: Icons.add,
            ),
            SizedBox(
              height: 10,
            ),
            _hasMoreData
                ? FloatingIconButton(
                    btnTap: () {
                      getAllMedia();
                    },
                    icon: Icons.more_outlined,
                  )
                : const SizedBox.shrink(),
          ],
        ));
  }

  void navigateToInputScreen(context) {
    if (Constants.appDocumentsDir == null) {
      getAppDirectoryPath();
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickDataScreen(
            type: type,
          ),
        )).then((v) {
      if (v != null && v) {
        files.clear();
        _currentPage = 0;
        getAllMedia();
      }
    });
  }
}
