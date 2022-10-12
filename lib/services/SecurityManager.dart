import 'package:encrypt/encrypt.dart';

/// This service class encrypts and decrypts user credentials
class SecurityManager {

  Encrypted encrypt(String str){
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(str, iv: iv);
    return encrypted;
  }

  String decrypt(String str){
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt16(str, iv: iv);
    return decrypted;
  }
}