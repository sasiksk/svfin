import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseFileUploader {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadFileToFirebase(File file) async {
    try {
      await _storage.ref('uploads/${file.path.split('/').last}').putFile(file);
      print('File uploaded to Firebase Storage');
    } catch (e) {
      print('Failed to upload file: $e');
    }
  }
}
