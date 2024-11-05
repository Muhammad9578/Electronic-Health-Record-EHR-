import 'dart:typed_data';
import 'dart:convert';

import 'package:blowfish_ecb/blowfish_ecb.dart';

// Constants used in Twofish
const int ROUNDS = 16;
const int BLOCK_SIZE = 16;
const int MAX_KEY_BITS = 256;

class Twofish {
  final Uint8List _key;
  late Uint8List _expandedKey;

  Twofish(Uint8List key) : _key = key {
    _keyExpansion();
  }

  void _keyExpansion() {
    // Key expansion logic goes here
    // This is a placeholder implementation
    _expandedKey = Uint8List(MAX_KEY_BITS ~/ 8);
    for (int i = 0; i < _key.length; i++) {
      _expandedKey[i] = _key[i];
    }
  }

  Uint8List encrypt(Uint8List plaintext) {
    // Add padding to the plaintext
    int paddingLength = BLOCK_SIZE - (plaintext.length % BLOCK_SIZE);
    Uint8List paddedPlaintext = Uint8List(plaintext.length + paddingLength);
    paddedPlaintext.setAll(0, plaintext);
    for (int i = plaintext.length; i < paddedPlaintext.length; i++) {
      paddedPlaintext[i] = paddingLength;
    }

    Uint8List ciphertext = Uint8List(paddedPlaintext.length);
    for (int i = 0; i < paddedPlaintext.length; i += BLOCK_SIZE) {
      _encryptBlock(paddedPlaintext.sublist(i, i + BLOCK_SIZE), ciphertext, i);
    }
    return ciphertext;
  }

  void _encryptBlock(Uint8List block, Uint8List output, int offset) {
    Uint32List x = Uint32List(4);
    for (int i = 0; i < 4; i++) {
      x[i] = _bytesToInt(block.sublist(i * 4, (i + 1) * 4));
    }

    for (int round = 0; round < ROUNDS; round++) {
      // Twofish encryption round logic
    }

    for (int i = 0; i < 4; i++) {
      _intToBytes(x[i], output, offset + i * 4);
    }
  }

  Uint8List decrypt(Uint8List ciphertext) {
    Uint8List plaintext = Uint8List(ciphertext.length);
    for (int i = 0; i < ciphertext.length; i += BLOCK_SIZE) {
      _decryptBlock(ciphertext.sublist(i, i + BLOCK_SIZE), plaintext, i);
    }

    // Remove padding from the plaintext
    int paddingLength = plaintext[plaintext.length - 1];
    return plaintext.sublist(0, plaintext.length - paddingLength);
  }

  void _decryptBlock(Uint8List block, Uint8List output, int offset) {
    Uint32List x = Uint32List(4);
    for (int i = 0; i < 4; i++) {
      x[i] = _bytesToInt(block.sublist(i * 4, (i + 1) * 4));
    }

    for (int round = ROUNDS - 1; round >= 0; round--) {
      // Twofish decryption round logic
    }

    for (int i = 0; i < 4; i++) {
      _intToBytes(x[i], output, offset + i * 4);
    }
  }

  int _bytesToInt(Uint8List bytes) {
    int result = 0;
    for (int i = 0; i < bytes.length; i++) {
      result = (result << 8) | bytes[i];
    }
    return result;
  }

  void _intToBytes(int value, Uint8List output, int offset) {
    for (int i = 3; i >= 0; i--) {
      output[offset + i] = value & 0xFF;
      value >>= 8;
    }
  }
}

// void main() {
//   final key = Uint8List.fromList(utf8.encode('mysecretkey12345')); // 16 bytes key
//   final twofish = Twofish(key);
//
//   final plaintext = utf8.encode('Hello, Twofish!');
//   print('Plaintext: ${utf8.decode(plaintext)}');
//
//   final ciphertext = twofish.encrypt(Uint8List.fromList(plaintext));
//   print('Ciphertext: $ciphertext');
//
//   final decrypted = twofish.decrypt(ciphertext);
//   print('Decrypted: ${utf8.decode(decrypted)}');
// }

void main() {
  const key = 'assw0rd!Passw0rd';
  const message = 'Hello,';
  // Encode the key and instantiate the codec.
  final blowfish = BlowfishECB(Uint8List.fromList(utf8.encode(key)));

  // Encrypt the input (with padding to fit the 8-bit block size).
  print('Encrypting "$message" with PKCS #5 padding.');
  final encryptedData = blowfish.encode(padPKCS5(utf8.encode(message)));

  // Decrypt the encrypted data.
  print('Decrypting "${hexEncode(encryptedData)}".');
  var decryptedData = blowfish.decode(encryptedData);
  // Remove PKCS5 padding.
  decryptedData =
      decryptedData.sublist(0, decryptedData.length - getPKCS5PadCount(decryptedData));
  print('Got "${utf8.decode(decryptedData)}".');
}

String hexEncode(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

Uint8List padPKCS5(List<int> input) {
  final inputLength = input.length;
  final paddingValue = 8 - (inputLength % 8);
  final outputLength = inputLength + paddingValue;

  final output = Uint8List(outputLength);
  for (var i = 0; i < inputLength; ++i) {
    output[i] = input[i];
  }
  output.fillRange(outputLength - paddingValue, outputLength, paddingValue);

  return output;
}

int getPKCS5PadCount(List<int> input) {
  if (input.length % 8 != 0) {
    throw FormatException('Block size is invalid!', input);
  }

  final count = input.last;
  final paddingStartIndex = input.length - count;
  for (var i = input.length - 1; i >= paddingStartIndex; --i) {
    if (input[i] != count) {
      throw const FormatException('Padding is not valid PKCS5 padding!');
    }
  }

  return count;
}
