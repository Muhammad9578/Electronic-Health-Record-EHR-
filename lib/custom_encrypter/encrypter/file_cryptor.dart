import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:blowfish_ecb/blowfish_ecb.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as p;
import 'package:patient_health_record/custom_encrypter/encrypter/custom_aes_ecb.dart';
import 'package:patient_health_record/src/core/helpers/console_log_functions.dart';
import 'package:xor_encryption/xor_encryption.dart';

import '../../main2.dart';
import '../../src/core/helpers/helpers.dart';
import 'base_cryptor.dart';

/// FileCryptor for encryption and decryption files.
class FileCryptor {
  /// [key] is using for encrypt and decrypt given file
  final String key;

  /// [iv] is Initialization vector encryption times
  final int iv;

  /// [IV] private instance for encryption and decryption
  final IV _iv;

  /// [Key] private instance for encryption and decryption
  final Key _key;

  /// [dir] working directory
  final String dir;

  /// [useCompress] for compressing file as GZip.
  final bool useCompress;

  /// [key] is using for encrypt and decrypt given file
  ///
  /// [iv] is Initialization vector encryption times
  ///
  /// [dir] working directory
  ///
  /// [useCompress] for compressing file as GZip.
  FileCryptor({
    required this.key,
    required this.iv,
    required this.dir,
    this.useCompress = false,
  })  : assert(key.length == 32, "key length must be 32"),
        this._iv = IV.fromLength(iv),
        this._key = Key.fromUtf8(key);

  /// Get current absolute working directory
  String getCurrentDir() => p.absolute(dir);

  @override
  Future<File> encryptAesEcb({
    String? inputFile,
    String? outputFile,
    bool? useCompress,
  }) async {
    bool _useCompress = useCompress == null ? this.useCompress : useCompress;
    File _inputFile = File(p.join(dir, inputFile));
    File _outputFile = File(p.join(dir, outputFile));

    bool _outputFileExists = await _outputFile.exists();
    bool _inputFileExists = await _inputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    if (!_inputFileExists) {
      throw Exception("Input file not found.");
    }

    final _fileContents = _inputFile.readAsBytesSync();

    final Encrypter _encrypter = Encrypter(AES(
      _key,
      mode: AESMode.ecb,
    ));

    final Encrypted _encrypted = _encrypter.encryptBytes(
      _fileContents,
      iv: _iv,
    );

    var compressedContent;

    if (_useCompress) {
      compressedContent = GZipEncoder().encode(_encrypted.bytes.toList())!;
    }

    File _encryptedFile = await _outputFile
        .writeAsBytes(_useCompress ? compressedContent : _encrypted.bytes);

    return _encryptedFile;
  }

  @override
  Future<File> decryptAesEcb({
    String? inputFile,
    String? outputFile,
    bool? useCompress,
  }) async {
    bool _useCompress = useCompress == null ? this.useCompress : useCompress;
    File _inputFile = File(p.join(dir, inputFile));
    File _outputFile = File(p.join(dir, outputFile));

    bool _outputFileExists = await _outputFile.exists();
    bool _inputFileExists = await _inputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    if (!_inputFileExists) {
      throw Exception("Input file not found.");
    }

    final _fileContents = _inputFile.readAsBytesSync();

    var compressedContent;

    if (_useCompress) {
      compressedContent = GZipDecoder().decodeBytes(_fileContents.toList());
    }

    final Encrypter _encrypter = Encrypter(AES(
      _key,
      mode: AESMode.ecb,
    ));

    final _encryptedFile = Encrypted((_useCompress ? compressedContent : _fileContents));
    final _decryptedFile = _encrypter.decryptBytes(_encryptedFile);

    return await _outputFile.writeAsBytes(_decryptedFile);
  }

  Future<File> encryptTwoFish({
    String? inputFile,
    String? outputFile,
    bool? useCompress,
  }) async {
    bool _useCompress = useCompress == null ? this.useCompress : useCompress;
    File _inputFile = File(p.join(dir, inputFile));
    File _outputFile = File(p.join(dir, outputFile));

    bool _outputFileExists = await _outputFile.exists();
    bool _inputFileExists = await _inputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    if (!_inputFileExists) {
      throw Exception("Input file not found.");
    }

    final _fileContents = _inputFile.readAsBytesSync();

    final key = Uint8List.fromList(utf8.encode('mysecretkey1234@')); // 16 bytes key
    final twofish = Twofish(key);

    final plaintext = utf8.encode('Hello, Twofish!');
    // print('Plaintext: ${utf8.decode(plaintext)}');

    final Uint8List ciphertext = twofish.encrypt(_fileContents);
    // print('Ciphertext: $ciphertext');

    var compressedContent;

    if (_useCompress) {
      compressedContent = GZipEncoder().encode(ciphertext.toList())!;
    }

    File _encryptedFile =
        await _outputFile.writeAsBytes(_useCompress ? compressedContent : ciphertext);

    return _encryptedFile;
  }

  @override
  Future<File> decryptTwofish({
    String? inputFile,
    String? outputFile,
    bool? useCompress,
  }) async {
    logInfo("inputFile: $inputFile");
    logInfo("outputFile: $outputFile");
    bool _useCompress = useCompress == null ? this.useCompress : useCompress;
    File _inputFile = File(p.join(dir, inputFile));
    File _outputFile = File(p.join(dir, outputFile));

    bool _outputFileExists = await _outputFile.exists();
    bool _inputFileExists = await _inputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    if (!_inputFileExists) {
      throw Exception("Input file not found.");
    }

    final _fileContents = _inputFile.readAsBytesSync();

    var compressedContent;

    if (_useCompress) {
      compressedContent = GZipDecoder().decodeBytes(_fileContents.toList());
    }

    final key = Uint8List.fromList(utf8.encode('mysecretkey1234@')); // 16 bytes key
    final twofish = Twofish(key);

    final Uint8List decrypted = twofish.decrypt(_fileContents);
    // print('Decrypted: ${utf8.decode(decrypted)}');

    return await _outputFile.writeAsBytes(decrypted);
  }

  Future<File> encryptBlowFish({
    String? inputFile,
    String? outputFile,
    bool? useCompress,
  }) async {
    bool _useCompress = useCompress == null ? this.useCompress : useCompress;
    File _inputFile = File(p.join(dir, inputFile));
    File _outputFile = File(p.join(dir, outputFile));

    bool _outputFileExists = await _outputFile.exists();
    bool _inputFileExists = await _inputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    if (!_inputFileExists) {
      throw Exception("Input file not found.");
    }

    final _fileContents = _inputFile.readAsBytesSync();
    const key = '*Khurram123@!as.';
    // Encode the key and instantiate the codec.

    final blowfish = BlowfishECB(Uint8List.fromList(utf8.encode(key)));

    final ciphertext = blowfish.encode(padPKCS5(_fileContents));

    var compressedContent;

    if (_useCompress) {
      compressedContent = GZipEncoder().encode(ciphertext.toList())!;
    }

    File _encryptedFile =
        await _outputFile.writeAsBytes(_useCompress ? compressedContent : ciphertext);

    return _encryptedFile;
  }

  @override
  Future<File> decryptBlowfish({
    String? inputFile,
    String? outputFile,
    bool? useCompress,
  }) async {
    logInfo("inputFile: $inputFile");
    logInfo("outputFile: $outputFile");
    bool _useCompress = useCompress == null ? this.useCompress : useCompress;
    File _inputFile = File(p.join(dir, inputFile));
    File _outputFile = File(p.join(dir, outputFile));

    bool _outputFileExists = await _outputFile.exists();
    bool _inputFileExists = await _inputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    if (!_inputFileExists) {
      throw Exception("Input file not found.");
    }

    final _fileContents = _inputFile.readAsBytesSync();

    var compressedContent;

    if (_useCompress) {
      compressedContent = GZipDecoder().decodeBytes(_fileContents.toList());
    }

    const key = '*Khurram123@!as.';

    final blowfish = BlowfishECB(Uint8List.fromList(utf8.encode(key)));

    var decryptedData = blowfish.decode(_fileContents);

    decryptedData =
        decryptedData.sublist(0, decryptedData.length - getPKCS5PadCount(decryptedData));
    return await _outputFile.writeAsBytes(decryptedData);
  }

  @override
  Future<Uint8List> encryptAesText({
    required String dataToEncrypt,
  }) async {
    final Encrypter encrypter = Encrypter(AES(
      _key,
      mode: AESMode.ecb,
    ));

    final Encrypted decryptedFile = encrypter.encrypt(dataToEncrypt);

    return decryptedFile.bytes;
  }

  Future<String> decryptAesText({
    required var encryptedText,
  }) async {
    final Encrypter encrypter = Encrypter(AES(
      _key,
      mode: AESMode.ecb,
    ));

    final encryptedFile = Encrypted(encryptedText);
    final String decryptedFile = encrypter.decrypt(encryptedFile, iv: _iv);

    return decryptedFile;
  }

//   ******************  Encryption decryption using SALSA ***************

  @override
  Future<File> decryptSalsa20({
    String? inputFile,
    String? outputFile,
    bool? useCompress,
  }) async {
    bool _useCompress = useCompress == null ? this.useCompress : useCompress;
    File _inputFile = File(p.join(dir, inputFile));
    File _outputFile = File(p.join(dir, outputFile));

    bool _outputFileExists = await _outputFile.exists();
    bool _inputFileExists = await _inputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    if (!_inputFileExists) {
      throw Exception("Input file not found.");
    }

    final _fileContents = _inputFile.readAsBytesSync();

    var compressedContent;

    if (_useCompress) {
      compressedContent = GZipDecoder().decodeBytes(_fileContents.toList());
    }

    final Encrypter _encrypter = Encrypter(Salsa20(_key));

    final _encryptedFile = Encrypted((_useCompress ? compressedContent : _fileContents));
    final _decryptedFile = _encrypter.decryptBytes(_encryptedFile, iv: _iv);

    return await _outputFile.writeAsBytes(_decryptedFile);
  }

  @override
  Future<File> encryptSalsa20({
    String? inputFile,
    String? outputFile,
    bool? useCompress,
  }) async {
    bool _useCompress = useCompress == null ? this.useCompress : useCompress;
    File _inputFile = File(p.join(dir, inputFile));
    File _outputFile = File(p.join(dir, outputFile));

    bool _outputFileExists = await _outputFile.exists();
    bool _inputFileExists = await _inputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    if (!_inputFileExists) {
      throw Exception("Input file not found.");
    }

    final _fileContents = _inputFile.readAsBytesSync();

    final Encrypter _encrypter = Encrypter(Salsa20(_key));

    final Encrypted _encrypted = _encrypter.encryptBytes(
      _fileContents,
      iv: _iv,
    );

    var compressedContent;

    if (_useCompress) {
      compressedContent = GZipEncoder().encode(_encrypted.bytes.toList())!;
    }

    File _encryptedFile = await _outputFile
        .writeAsBytes(_useCompress ? compressedContent : _encrypted.bytes);

    return _encryptedFile;
  }

//   ****************** SALSA ended ***************

//   ****************** XOR started ***************
  @override
  Future<File> encryptXor({
    String? inputFile,
    String? outputFile,
    bool? useCompress,
  }) async {
    bool _useCompress = useCompress == null ? this.useCompress : useCompress;
    File _inputFile = File(p.join(dir, inputFile));
    File _outputFile = File(p.join(dir, outputFile));
    print("dir: ${dir}");
    bool _outputFileExists = await _outputFile.exists();
    bool _inputFileExists = await _inputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    if (!_inputFileExists) {
      throw Exception("Input file not found.");
    }

    final _fileContents = _inputFile.readAsBytesSync();

    final newKey = utf8.encode(key);
    print("key: $key  \n newKey:$newKey ");

    final List<int> encrypted = XorCipher().encrypt(_fileContents, newKey);

    // final List<int> encrypted = await Isolate.run<List<int>>(() {
    //   return XorCipher().encrypt(_fileContents, newKey);
    // });

    // create the port to receive data from
    // final resultPort = ReceivePort();
    // spawn a new isolate and pass down a function that will be used in a new isolate
    // and pass down the result port that will send back the result.
    // you can send any number of arguments.
    // await Isolate.spawn(
    //   _readAndParseJson,
    //   [resultPort.sendPort, _fileContents, newKey],
    // );

    // final List<int> encrypted = await (resultPort.first) as List<int>;

    // print("end isolate");
    var compressedContent;

    if (_useCompress) {
      compressedContent = GZipEncoder().encode(encrypted)!;
    }

    File _encryptedFile =
        await _outputFile.writeAsBytes(_useCompress ? compressedContent : encrypted);

    return _encryptedFile;
  }

  Future<void> _readAndParseJson(List<dynamic> args) async {
    SendPort resultPort = args[0];
    final fileContents = args[1];
    final newKey = args[1];

    List<int> encrypted = XorCipher().encrypt(fileContents, newKey);

    Isolate.exit(resultPort, encrypted);
  }

  @override
  Future<File> decryptXor({
    String? inputFile,
    String? outputFile,
    bool? useCompress,
  }) async {
    bool _useCompress = useCompress == null ? this.useCompress : useCompress;
    File _inputFile = File(p.join(dir, inputFile));
    File _outputFile = File(p.join(dir, outputFile));
    print("_outputFile: ${_outputFile}");

    bool _outputFileExists = await _outputFile.exists();
    bool _inputFileExists = await _inputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    if (!_inputFileExists) {
      throw Exception("Input file not found.");
    }

    final _fileContents = _inputFile.readAsBytesSync();

    var compressedContent;

    if (_useCompress) {
      compressedContent = GZipDecoder().decodeBytes(_fileContents.toList());
    }

    // final Encrypter _encrypter = Encrypter(Salsa20(_key));
    //
    // final _encryptedFile =
    //     Encrypted((_useCompress ? compressedContent : _fileContents));
    // final _decryptedFile = _encrypter.decryptBytes(_encryptedFile, iv: _iv);

    final newKey = utf8.encode(key);
    print("key: $key  \n newKey:$newKey ");

    final decrypted = XorCipher().encrypt(_fileContents, newKey);

    return await _outputFile.writeAsBytes(decrypted);
  }
}
