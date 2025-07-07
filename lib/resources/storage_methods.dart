import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final SupabaseClient _storage = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImagetoStorage(String childname, Uint8List file,bool isPost) async {
    final String uid = _auth.currentUser!.uid;

    // Path inside the bucket (folder structure): uid/image.jpg
    String filePath = '$uid/image.jpg';

    if(isPost){
      filePath='$uid/${Uuid().v1()}.jpg';
    }

    // Use the `childname` as the BUCKET NAME
    final response = await _storage.storage
        .from(childname)
        .uploadBinary(
          filePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final String downloadUrl = _storage.storage
        .from(childname)
        .getPublicUrl(filePath);
    return downloadUrl;
  }
}
