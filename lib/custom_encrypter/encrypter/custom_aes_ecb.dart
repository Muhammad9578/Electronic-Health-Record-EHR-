import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class AesText {
  static const _Nb = 4; // Block size in 32-bit words
  static const _Nk = 4; // Key size in 32-bit words (4 words for 128-bit key)
  static const _Nr = 10; // Number of rounds (10 for 128-bit key)

  final Uint8List _key;

  AesText(String key) : _key = _createKeyFromString(key);

  Uint8List encrypt(Uint8List input) {
    final paddedInput = _pad(input, _Nb * 4);
    final expandedKey = _expandKey(_key);
    var state = Uint8List.fromList(paddedInput);
    var output = Uint8List(paddedInput.length);

    for (var i = 0; i < paddedInput.length; i += _Nb * 4) {
      var block = state.sublist(i, i + _Nb * 4);
      block = _addRoundKey(block, expandedKey, 0);

      for (var round = 1; round < _Nr; round++) {
        block = _subBytes(block);
        block = _shiftRows(block);
        block = _mixColumns(block);
        block = _addRoundKey(block, expandedKey, round);
      }

      block = _subBytes(block);
      block = _shiftRows(block);
      block = _addRoundKey(block, expandedKey, _Nr);

      for (var j = 0; j < _Nb * 4; j++) {
        output[i + j] = block[j];
      }
    }
    return output;
  }

  Uint8List decrypt(Uint8List input) {
    final expandedKey = _expandKey(_key);
    var state = Uint8List.fromList(input);
    var output = Uint8List(input.length);

    for (var i = 0; i < input.length; i += _Nb * 4) {
      var block = state.sublist(i, i + _Nb * 4);
      block = _addRoundKey(block, expandedKey, _Nr);

      for (var round = _Nr - 1; round > 0; round--) {
        block = _invShiftRows(block);
        block = _invSubBytes(block);
        block = _addRoundKey(block, expandedKey, round);
        block = _invMixColumns(block);
      }

      block = _invShiftRows(block);
      block = _invSubBytes(block);
      block = _addRoundKey(block, expandedKey, 0);

      for (var j = 0; j < _Nb * 4; j++) {
        output[i + j] = block[j];
      }
    }
    return _unpad(output);
  }

  static Uint8List _createKeyFromString(String key) {
    final keyBytes = Uint8List.fromList(utf8.encode(key));
    final keySize = _Nk * 4;
    final keyPadded = Uint8List(keySize);

    for (var i = 0; i < keyBytes.length && i < keySize; i++) {
      keyPadded[i] = keyBytes[i];
    }

    return keyPadded;
  }

  Uint8List _addRoundKey(Uint8List state, Uint8List roundKey, int round) {
    for (var i = 0; i < _Nb * 4; i++) {
      state[i] ^= roundKey[round * _Nb * 4 + i];
    }
    return state;
  }

  Uint8List _subBytes(Uint8List state) {
    for (var i = 0; i < _Nb * 4; i++) {
      state[i] = _sBox(state[i]);
    }
    return state;
  }

  Uint8List _invSubBytes(Uint8List state) {
    for (var i = 0; i < _Nb * 4; i++) {
      state[i] = _invSBox(state[i]);
    }
    return state;
  }

  Uint8List _shiftRows(Uint8List state) {
    final result = Uint8List(_Nb * 4);
    for (var i = 0; i < _Nb; i++) {
      for (var j = 0; j < 4; j++) {
        result[i * 4 + j] = state[((i + j) % 4) * 4 + j];
      }
    }
    return result;
  }

  Uint8List _invShiftRows(Uint8List state) {
    final result = Uint8List(_Nb * 4);
    for (var i = 0; i < _Nb; i++) {
      for (var j = 0; j < 4; j++) {
        result[i * 4 + j] = state[((i - j + 4) % 4) * 4 + j];
      }
    }
    return result;
  }

  Uint8List _mixColumns(Uint8List state) {
    final result = Uint8List(_Nb * 4);
    for (var i = 0; i < _Nb; i++) {
      final t = state[i * 4];
      result[i * 4] = _gfMul(t, 2);
    }
    return result;
  }

  Uint8List _invMixColumns(Uint8List state) {
    final result = Uint8List(_Nb * 4);
    for (var i = 0; i < _Nb; i++) {
      final t = state[i * 4];
      result[i * 4] = _gfMul(t, 14);
    }
    return result;
  }

  int _sBox(int byte) {
    return byte;
  }

  int _invSBox(int byte) {
    return byte;
  }

  int _gfMul(int a, int b) {
    return a * b;
  }

  Uint8List _expandKey(Uint8List key) {
    final expandedKey = Uint8List(_Nb * (_Nr + 1) * 4);
    for (var i = 0; i < _Nk * 4; i++) {
      expandedKey[i] = key[i];
    }
    return expandedKey;
  }

  Uint8List _pad(Uint8List input, int blockSize) {
    final padding = blockSize - (input.length % blockSize);
    final paddedInput = Uint8List(input.length + padding)..setAll(0, input);

    for (var i = input.length; i < paddedInput.length; i++) {
      paddedInput[i] = padding;
    }

    return paddedInput;
  }

  Uint8List _unpad(Uint8List input) {
    final padding = input[input.length - 1];
    return input.sublist(0, input.length - padding);
  }
}

void customAesEncDec({required String key, Uint8List? plaintext}) {
  // Convert String to list of UTF-8 bytes
  List<int> utf8Bytes = utf8.encode(key);

  // Convert list of bytes to Uint8List
  Uint8List uint8list = Uint8List.fromList(utf8Bytes);
  final key1 = uint8list ??
      Uint8List.fromList([
        0x2b,
        0x7e,
        0x15,
        0x16,
        0x28,
        0xae,
        0xd2,
        0xa6,
        0xab,
        0xf7,
        0xcf,
        0x44,
        0x1f,
        0x88,
        0xe8,
        0x99
      ]);
  final Uint8List plaintext1 = Uint8List.fromList([
    0x32,
    0x43,
    0xf6,
    0xa8,
    0x88,
    0x5a,
    0x30,
    0x8d,
    0x31,
    0x31,
    0x98,
    0xa2,
    0xe0,
    0x37,
    0x07,
    0x34
  ]);

  print("plaintext: $plaintext");

  final aes = AesText(key);
  print("aes start encryption: ${DateTime.now()}");
  final ciphertext = aes.encrypt(plaintext!);
  print("aes end encryption: ${DateTime.now()}");
  final decrypted = aes.decrypt(ciphertext);
  print("aes end decryption: ${DateTime.now()}");
  print('Ciphertext: $ciphertext');
  print('Decrypted: $decrypted');
}
