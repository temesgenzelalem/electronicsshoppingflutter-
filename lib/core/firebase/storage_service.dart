import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload user avatar
  Future<String?> uploadUserAvatar(String userId, XFile image) async {
    try {
      final ref = _storage.ref().child(
          'users/$userId/avatar/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(File(image.path));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Upload product image
  Future<String?> uploadProductImage(String productId, XFile image,
      {int index = 0}) async {
    try {
      final ref = _storage.ref().child('products/$productId/images/$index.jpg');
      final uploadTask = ref.putFile(File(image.path));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Upload review image
  Future<String?> uploadReviewImage(String reviewId, XFile image,
      {int index = 0}) async {
    try {
      final ref = _storage.ref().child('reviews/$reviewId/images/$index.jpg');
      final uploadTask = ref.putFile(File(image.path));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Handle error
    }
  }

  // Get download URL
  Future<String?> getDownloadURL(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
