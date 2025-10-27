import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class StorageMethods {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _cloudName = 'dv4xgbxi6';
  static const String _uploadPreset = 'flutter_social_media_app_preset';

  Future<String> uploadImagetoStorage(
    String childname,
    Uint8List file,
    bool isPost,
  ) async {

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user');
    }

    try {
      //ON UTILISE l'UID Firebase pour nommer les fichiers
      final String uid = _auth.currentUser!.uid;
      String fileName = isPost ? '${uid}_${Uuid().v1()}' : '${uid}_profile';

      // Upload vers Cloudinary

      // build enpoint to cloudinary
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      // prepare a POST request in MultipartRequest format
      var request = http.MultipartRequest('POST', url);

      // add the image to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file,
          filename: '$fileName.jpg',
        ),
      );


      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = childname; // 'posts' ou 'profilepics'
      request.fields['public_id'] = fileName;

      //Envoie la requête à Cloudinary et attend la réponse.
      final response = await request.send();

      //Lit le corps de la réponse HTTP brute.
      final responseData = await response.stream.toBytes();

      //Convertit le corps de la réponse en une chaîne de caractères (qui est du JSON).
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseString);
        //Retourne l'URL publique générée par Cloudinary (secure_url), qui sera stockée dans Firestore.
        return jsonResponse['secure_url'];
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading to Cloudinary: $e');
    }
  }
}
