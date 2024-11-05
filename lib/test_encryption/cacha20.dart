// import 'dart:convert';
// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// List<int> _fromHex(String s) {
//   s = s.replaceAll(' ', '').replaceAll('\n', '');
//   return List<int>.generate(s.length ~/ 2, (i) {
//     var byteInHex = s.substring(2 * i, 2 * i + 2);
//     if (byteInHex.startsWith('0')) {
//       byteInHex = byteInHex.substring(1);
//     }
//     final result = int.tryParse(byteInHex, radix: 16);
//     if (result == null) {
//       throw StateError('Not valid hexadecimal bytes: $s');
//     }
//     return result;
//   });
// }
//
// String _toHex(List<int> bytes) {
//   return bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
// }
//
// class CipherPage extends StatefulWidget {
//   const CipherPage({Key? key}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() {
//     return _CipherPageState();
//   }
// }
//
// class _CipherPageState extends State<CipherPage> {
//   static final _chacha20Poly1305 = Chacha20.poly1305Aead();
//
//   Cipher _cipher = _chacha20Poly1305;
//   final _secretKeyController = TextEditingController(
//       text: "1234567898765431234567898765432112345678987654312345678987654321");
//   final _nonceController =
//       TextEditingController(text: "123456787654123456787654");
//
//   List<int> _clearText = [];
//   final _cipherTextController = TextEditingController();
//   final _macController = TextEditingController();
//   final _decryptedTextController = TextEditingController();
//   Object? _error;
//
//   getPath() async {
//     final permissionStatus = await Permission.storage.status;
//     if (permissionStatus.isDenied) {
//       // Here just ask for the permission for the first time
//       await Permission.storage.request();
//
//       // I noticed that sometimes popup won't show after user press deny
//       // so I do the check once again but now go straight to appSettings
//       if (permissionStatus.isDenied) {
//         await openAppSettings();
//       }
//     } else if (permissionStatus.isPermanentlyDenied) {
//       // Here open app settings for user to manually enable permission in case
//       // where permission was permanently denied
//       await openAppSettings();
//     } else {
//       // Do stuff that require permission here
//     }
//     appDocumentsDir = (await getExternalStorageDirectory())!;
//     print("appDocumentsDir: $appDocumentsDir");
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     getPath();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final error = _error;
//     final cipher = _cipher;
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Container(
//             constraints: const BoxConstraints(maxWidth: 500),
//             padding: const EdgeInsets.all(20),
//             child: ListView(
//               children: [
//                 const SizedBox(height: 10),
//                 Text('Class: ${cipher.runtimeType}'),
//                 const SizedBox(height: 10),
//                 Row(children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _secretKeyController,
//                       onChanged: (value) {
//                         _encrypt();
//                       },
//                       minLines: 1,
//                       maxLines: 16,
//                       enableInteractiveSelection: true,
//                       decoration: InputDecoration(
//                           labelText:
//                               'Secret key  (${_cipher.secretKeyLength} bytes)'),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () async {
//                       final secretKey = await _cipher.newSecretKey();
//                       final bytes = await secretKey.extractBytes();
//                       _secretKeyController.text = _toHex(bytes);
//                       await _encrypt();
//                     },
//                     child: const Text('Generate'),
//                   ),
//                 ]),
//                 const SizedBox(height: 10),
//                 Row(children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _nonceController,
//                       onChanged: (value) {
//                         _encrypt();
//                       },
//                       minLines: 1,
//                       maxLines: 16,
//                       enableInteractiveSelection: true,
//                       decoration: InputDecoration(
//                           labelText: 'Nonce (${_cipher.nonceLength} bytes)'),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () async {
//                       _nonceController.text = _toHex(_cipher.newNonce());
//                       await _encrypt();
//                     },
//                     child: const Text('Generate'),
//                   ),
//                 ]),
//                 const SizedBox(height: 30),
//                 const Text('Encrypt'),
//                 TextField(
//                   onChanged: (newValue) {
//                     try {
//                       _clearText = utf8.encode(newValue);
//                       _encrypt();
//                     } catch (error) {
//                       setState(() {
//                         _error = error;
//                       });
//                     }
//                   },
//                   minLines: 1,
//                   maxLines: 16,
//                   enableInteractiveSelection: true,
//                   decoration:
//                       const InputDecoration(labelText: 'Cleartext (text)'),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _cipherTextController,
//                   minLines: 1,
//                   maxLines: 16,
//                   enableInteractiveSelection: true,
//                   decoration:
//                       const InputDecoration(labelText: 'Ciphertext (hex)'),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _macController,
//                   minLines: 1,
//                   maxLines: 16,
//                   enableInteractiveSelection: true,
//                   decoration: const InputDecoration(
//                       labelText: 'Message Authentication Code (MAC)'),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: null,
//                   child: const Text('Decrypt'),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _decryptedTextController,
//                   minLines: 1,
//                   maxLines: 16,
//                   enableInteractiveSelection: true,
//                   decoration:
//                       const InputDecoration(labelText: 'Decrypted Text'),
//                 ),
//                 const SizedBox(height: 10),
//                 if (error != null) Text(error.toString()),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     encryptCache20(
//                         inputFile: pickedFile?.path,
//                         outputFile: "${appDocumentsDir.path}/${fileName}.aes");
//                   },
//                   child: Text('encryptCache20'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _pickFile,
//                   child: Text('Pick a File'),
//                 ),
//                 SizedBox(height: 16),
//                 if (pickedFile != null)
//                   Text('Picked file: ${pickedFile!.path}'),
//                 SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> encryptCache20({
//     String? inputFile,
//     String? outputFile,
//   }) async {
//     print("start encryption: ${DateTime.now()}");
//     File _inputFile = File(p.join(pickedFile!.path, inputFile));
//     File _outputFile = File(p.join(pickedFile!.path, outputFile));
//
//     bool _outputFileExists = await _outputFile.exists();
//     bool _inputFileExists = await _inputFile.exists();
//
//     if (!_outputFileExists) {
//       await _outputFile.create();
//     }
//
//     if (!_inputFileExists) {
//       throw Exception("Input file not found.");
//     }
//
//     final _fileContents = _inputFile.readAsBytesSync();
//
//     final cipher = _cipher;
//     final secretBox = await cipher.encrypt(
//       _fileContents,
//       secretKey: SecretKeyData(
//         _fromHex(_secretKeyController.text),
//       ),
//       nonce: _fromHex(_nonceController.text),
//     );
//     _cipherTextController.text = _toHex(secretBox.cipherText);
//     _macController.text = _toHex(secretBox.mac.bytes);
//
//     // final Encrypter _encrypter = Encrypter(Salsa20(_key));
//     //
//     // final Encrypted _encrypted = _encrypter.encryptBytes(
//     //   _fileContents,
//     //   iv: _iv,
//     // );
//
//     var compressedContent;
//
//     File _encryptedFile = await _outputFile.writeAsBytes(secretBox.cipherText);
//     print("_encryptedFile: ${_encryptedFile.path}");
//     print("end encryption: ${DateTime.now()}");
//
//     // return _encryptedFile;
//   }
//
//   Future<void> _encrypt() async {
//     try {
//       final cipher = _cipher;
//       final secretBox = await cipher.encrypt(
//         _clearText,
//         secretKey: SecretKeyData(
//           _fromHex(_secretKeyController.text),
//         ),
//         nonce: _fromHex(_nonceController.text),
//       );
//       _cipherTextController.text = _toHex(secretBox.cipherText);
//       _macController.text = _toHex(secretBox.mac.bytes);
//       setState(() {
//         _error = null;
//       });
//     } catch (error, stackTrace) {
//       setState(() {
//         _error = '$error\n\n$stackTrace';
//         _cipherTextController.text = '';
//         _macController.text = '';
//       });
//       return;
//     }
//   }
//
//   File? pickedFile;
//   late final Directory appDocumentsDir;
//   String extension = "";
//   String fileName = "";
//
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//
//     if (result != null) {
//       setState(() {
//         pickedFile = File(result.files.single.path!);
//         extension = getFileExtension(pickedFile!.path);
//         print("extestion: $extension");
//         fileName = getFileName(pickedFile!.path);
//
//         print('File name: $fileName');
//       });
//     } else {
//       // User canceled the file picking
//     }
//   }
//
//   String getFileExtension(String filePath) {
//     RegExp regExp = RegExp(r'\.([a-zA-Z0-9]+)$');
//     Match? match = regExp.firstMatch(filePath);
//
//     return match?.group(1) ??
//         ''; // Returns an empty string if no match is found
//   }
//
//   String getFileName(String filePath) {
//     return p.basename(filePath);
//   }
//
// // Future<void> _decrypt() async {
// //   try {
// //     final cipher = _cipher;
// //     final decryptedText = await cipher.decrypt(
// //       EncryptedMessage(
// //         _fromHex(_cipherTextController.text),
// //         mac: Mac(_fromHex(_macController.text)),
// //       ),
// //       secretKey: SecretKeyData(
// //         _fromHex(_secretKeyController.text),
// //       ),
// //       nonce: _fromHex(_nonceController.text),
// //     );
// //     _decryptedTextController.text = utf8.decode(decryptedText);
// //     setState(() {
// //       _error = null;
// //     });
// //   } catch (error, stackTrace) {
// //     setState(() {
// //       _error = '$error\n\n$stackTrace';
// //       _decryptedTextController.text = '';
// //     });
// //     return;
// //   }
// // }
// }
