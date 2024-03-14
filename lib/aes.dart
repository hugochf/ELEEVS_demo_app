import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

// Define the key and IV
String key = '000000J23P000047';
String iv = '420#abA%,ZfE79@M';

// Convert the key and IV to bytes
List<int> keyBytes = utf8.encode(key);
List<int> ivBytes = utf8.encode(iv);

// void main() {
//   print(msgDec('6d5c9d8bb016c12afc8bbaf8dd5fe7e1'));
//   print(msgEnc('7b22636d64223a224d4150227d000000'));
// }

String msgDec(String incommingMsg) {
  List<int> encryptedMessageBytes = hexToBytes(incommingMsg);
  return (msgDecrypt(encryptedMessageBytes, keyBytes, ivBytes));
}

String msgEnc(String incommingMsg) {
  List<int> hexMessageBytes = hexToBytes(incommingMsg);
  return (msgEncrypt(hexMessageBytes, keyBytes, ivBytes));
}

List<int> hexToBytes(String hexString) {
  var result = <int>[];
  for (int i = 0; i < hexString.length; i += 2) {
    result.add(int.parse(hexString.substring(i, i + 2), radix: 16));
  }
  return result;
}

String bytesToHex(List<int> bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

String msgDecrypt(
    List<int> encryptedMessageBytes, List<int> keyBytes, List<int> ivBytes) {
  final key = encrypt.Key(Uint8List.fromList(keyBytes));
  final iv = encrypt.IV(Uint8List.fromList(ivBytes));

  final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: null));
  final decrypted = encrypter.decrypt(
      encrypt.Encrypted(Uint8List.fromList(encryptedMessageBytes)),
      iv: iv);
  return bytesToHex(utf8.encode(decrypted));
}

String msgEncrypt(
    List<int> hexMessageBytes, List<int> keyBytes, List<int> ivBytes) {
  final key = encrypt.Key(Uint8List.fromList(keyBytes));
  final iv = encrypt.IV(Uint8List.fromList(ivBytes));

  final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: null));
  final encrypted =
      encrypter.encryptBytes(Uint8List.fromList(hexMessageBytes), iv: iv);
  return bytesToHex(encrypted.bytes);
}
