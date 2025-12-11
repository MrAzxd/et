import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminImageUploadScreen extends StatefulWidget {
  const AdminImageUploadScreen({super.key});

  @override
  State<AdminImageUploadScreen> createState() => _AdminImageUploadScreenState();
}

class _AdminImageUploadScreenState extends State<AdminImageUploadScreen> {
  Uint8List? webImage;
  XFile? pickedFile;
  String userId = FirebaseAuth.instance.currentUser?.uid ?? "admin";

  bool isUploading = false;
  final ImagePicker picker = ImagePicker();
  final TextEditingController urlController = TextEditingController();

  // ============================
  // PICK IMAGE (WEB + MOBILE SAFE)
  // ============================
  Future<void> pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        webImage = result.files.single.bytes;
        pickedFile = null;
        setState(() {});
      }
    } else {
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (file != null) {
        pickedFile = file;
        webImage = null;
        setState(() {});
      }
    }
  }

  // ============================
  // UPLOAD IMAGE
  // ============================
  Future<void> uploadImage() async {
    if (webImage == null && pickedFile == null && urlController.text.isEmpty) {
      debugPrint("No image selected");
      return;
    }

    setState(() => isUploading = true);

    String downloadUrl = "";
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      // ✅ Check user login
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      String userId = user.uid;

      // ✅ Change path to authorized folder
      String imagePath = "product_images/$userId/$fileName.jpg";

      final ref = FirebaseStorage.instance.ref(imagePath);

      // WEB UPLOAD
      if (kIsWeb && webImage != null) {
        UploadTask task = ref.putData(webImage!);
        TaskSnapshot snapshot = await task;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }
      // MOBILE UPLOAD
      else if (!kIsWeb && pickedFile != null) {
        Uint8List bytes = await pickedFile!.readAsBytes();
        UploadTask task = ref.putData(bytes);
        TaskSnapshot snapshot = await task;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }
      // URL UPLOAD
      else if (urlController.text.isNotEmpty) {
        downloadUrl = urlController.text.trim();
      }

      // ✅ Save to Firestore
      await FirebaseFirestore.instance.collection("home_slider").add({
        "image": downloadUrl,
        "path": imagePath,
        "created_at": Timestamp.now(),
        "userId": userId,
      });

      webImage = null;
      pickedFile = null;
      urlController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Image Uploaded Successfully")),
      );

      debugPrint("Image uploaded: $downloadUrl");
    } catch (e) {
      debugPrint("Upload failed: $e");

      String msg = e.toString();

      // ✅ Show friendly messages
      if (msg.contains("not authorized") || msg.contains("permission")) {
        msg = "Permission denied. Please update Firebase Storage Rules.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Upload failed: $msg")));
    } finally {
      setState(() => isUploading = false);
    }
  }

  // ============================
  // DELETE
  // ============================
  Future<void> deleteImage(String docId, String imagePath) async {
    try {
      await FirebaseStorage.instance.ref(imagePath).delete();

      await FirebaseFirestore.instance
          .collection("home_slider")
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Image Deleted")));
      debugPrint("Image deleted: $docId");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Delete failed: $e")));
      debugPrint("Delete failed: $e");
    }
  }

  // ============================
  // UPDATE
  // ============================
  Future<void> updateImage(String docId, String oldPath) async {
    Uint8List? newBytes;

    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        newBytes = result.files.single.bytes;
      }
    } else {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        newBytes = await file.readAsBytes();
      }
    }

    if (newBytes == null) return;

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    String newPath = "slider_images/$fileName.jpg";
    final ref = FirebaseStorage.instance.ref(newPath);

    try {
      UploadTask task = ref.putData(newBytes);
      TaskSnapshot snapshot = await task;
      String newUrl = await snapshot.ref.getDownloadURL();

      await FirebaseStorage.instance.ref(oldPath).delete();

      await FirebaseFirestore.instance
          .collection("home_slider")
          .doc(docId)
          .update({"image": newUrl, "path": newPath});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Image Updated")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Update failed: $e")));
      debugPrint("Update failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Slider Images")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // PICK + PREVIEW
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: webImage != null
                    ? Image.memory(webImage!, fit: BoxFit.cover)
                    : pickedFile != null
                        ? const Center(child: Text("✅ Image Selected"))
                        : const Center(child: Text("Tap to Pick Image")),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: "Image URL (Optional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: uploadImage,
                    child: const Text("Upload Image"),
                  ),

            const SizedBox(height: 30),

            // IMAGE LIST
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("home_slider")
                  .orderBy("created_at", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index];

                    String docId = data.id;
                    String imgUrl = data["image"];
                    String path = data["path"];

                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          imgUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: const Text("Slider Image"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => updateImage(docId, path),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteImage(docId, path),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
