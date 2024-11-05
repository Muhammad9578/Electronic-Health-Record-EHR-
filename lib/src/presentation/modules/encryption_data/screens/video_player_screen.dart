import 'dart:io';

import 'package:flutter/material.dart';
import 'package:patient_health_record/custom_encrypter/file_cryptor.dart';
import 'package:patient_health_record/src/core/helpers/helpers.dart';
import 'package:patient_health_record/src/presentation/modules/encryption_data/models/file_model.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/constants/app_constants.dart';

class VideoPlayerScreen extends StatefulWidget {
  final FileModel fileModel;

  const VideoPlayerScreen({super.key, required this.fileModel});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  late FileModel _fileModel;
  FileCryptor fileCryptor = FileCryptor(
    key: "qwertyuiop@#%^&*()_+1234567890,;",
    iv: 8,
    dir: "KhurramData",
  );

  @override
  void initState() {
    _fileModel = widget.fileModel;
    decrypt();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  decrypt() async {
    print("_fileModel.path!: ${_fileModel.path!}");
    // File decryptedData =
    //     await decryptAesEcb(_fileModel.path!, _fileModel.extension!, fileCryptor);
    // File decryptedData =
    //     await decryptTwofish(_fileModel.path!, _fileModel.extension!, fileCryptor);
    await Future.delayed(const Duration(milliseconds: 100));
    File decryptedData =
        await decryptBblowfish(_fileModel.path!, _fileModel.extension!, fileCryptor);
    print("decryptedData: ${decryptedData.path}");

    await _initializeVideoPlayer(decryptedData.path!);
  }

  // Future<File> decryptTwoFish(String path, String name) async {
  //   print("start encryption: ${DateTime.now()}");
  //   print("path: ${path}");
  //   print("path: ${name}");
  //   String encryptedPath;
  //   try {
  //     File encryptedFile = await fileCryptor.encryptTwoFish(
  //       inputFile: path,
  //       outputFile: "${Constants.appDocumentsDir!.path}/${name}",
  //     );
  //     print("encryptedFile.absolute: ${encryptedFile.absolute}");
  //     print("end encryption: ${DateTime.now()}");
  //     return encryptedFile;
  //   } catch (e) {
  //     print("exception: $e");
  //     encryptedPath = "exception: $e";
  //     rethrow;
  //   }
  // }

  Future<void> _initializeVideoPlayer(String filePath) async {
    print("filePath: $filePath");
    _controller = VideoPlayerController.file(File(filePath))
      ..initialize().then((_) {
        setState(() {}); // Ensure the first frame is shown
        _controller?.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                        textAlign: TextAlign.center,
                        'Decrypting your video. Please wait, it may take a while ...'),
                  ),
          ],
        ),
      ),
      floatingActionButton: _controller != null && _controller!.value.isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
