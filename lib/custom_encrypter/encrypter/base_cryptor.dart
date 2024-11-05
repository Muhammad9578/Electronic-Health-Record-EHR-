import 'dart:io';

/// BaseFileCryptor
abstract class BaseFileCryptor {
  /// [inputFile] input file name
  ///
  /// [outputFile] encrypted file name
  ///
  /// After encryption returns encrypted [File] instance
  Future<File> encryptAES({String? inputFile, String? outputFile});

  /// [inputFile] encrypted file name
  ///
  /// [outputFile] output file name
  ///
  /// After decryption returns decrypted [File] instance
  Future<File> decryptAES({String? inputFile, String? outputFile});

  /// [inputFile] input file name
  ///
  /// [outputFile] encrypted file name
  ///
  /// After encryption returns encrypted [File] instance
  Future<File> encryptSalsa20({String? inputFile, String? outputFile});

  /// [inputFile] encrypted file name
  ///
  /// [outputFile] output file name
  ///
  /// After decryption returns decrypted [File] instance
  Future<File> decryptSalsa20({String? inputFile, String? outputFile});

  Future<File> encryptXor({String? inputFile, String? outputFile});

  Future<File> decryptXor({String? inputFile, String? outputFile});

  /// Encrypt given [Uint8List] data.
  ///
  /// After encryption returns encrypted [Uint8List]
// Uint8List encryptUint8List({Uint8List? data});

  /// Decrypt given [Uint8List] data.
  ///
  /// After decryption returns decrypted [Uint8List]
// Uint8List decryptUint8List({Uint8List? data});
}
