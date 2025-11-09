import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(File imageFile, String shopId) async {
    try {
      final originalBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(originalBytes);
      if (image == null) throw Exception('Invalid image');

      // Target max size: 500 KB (500,000 bytes)
      const int targetMaxSize = 500000;
      int quality = 85; // Start with good quality
      List<int> compressed;

      do {
        compressed = img.encodeJpg(image, quality: quality);
        if (compressed.length <= targetMaxSize || quality <= 30) break;
        quality -= 10; // Reduce quality step-by-step
      } while (true);

      // Optional: Resize only if still too big after quality reduction
      if (compressed.length > targetMaxSize) {
        final int maxDimension = 1200; // Safe max for display
        final bool scaleWidth = image.width > image.height;
        final int newSize = scaleWidth
            ? (maxDimension * image.width / image.height).round()
            : maxDimension;

        final resized = scaleWidth
            ? img.copyResize(image, width: maxDimension)
            : img.copyResize(image, height: maxDimension);

        compressed = img.encodeJpg(resized, quality: 70);
      }

      final fileName = '${const Uuid().v4()}.jpg';
      final ref =
          _storage.ref().child('products').child(shopId).child(fileName);

      final uploadTask = ref.putData(
        Uint8List.fromList(compressed),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
