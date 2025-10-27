import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/resources/storage_methods.dart';
import 'package:social_media_app/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    return model.User.fromSnap(snap);
  }

  //sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String userName,
    required String bio,
    required Uint8List file,
  }) async {
    String res = 'Some error occured';

    if (file == null) {
      return 'Please select a profile image.';
    }

    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          userName.isNotEmpty &&
          bio.isNotEmpty) {
        //register the user and return the UserCredential containing uid
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // print(credential.user!.uid);
        
        // stock le profil dans cloudinary et récupère son Url publique
        String photoUrl = await StorageMethods().uploadImagetoStorage(
          "profilepics",
          file,
          false,
        );

        model.User user = model.User(
          email: email,
          uid: credential.user!.uid,
          photoUrl: photoUrl,
          username: userName,
          bio: bio,
          followers: [],
          following: [],
        );

        //store the user in database
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toJson());
        res = 'Success';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = "The email address is badly formatted.";
      } else if (err.code == 'email-already-in-use') {
        res = "This email is already registered.";
      } else if (err.code == 'weak-password') {
        res = "Password should be at least 6 characters.";
      } else {
        res = err.message!;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some Error Occurred';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = 'Success';
      } else {
        res = 'Please enter all the fields';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        res = "No user found with this email.";
      } else if (err.code == 'wrong-password') {
        res = "Incorrect password.";
      } else {
        res = err.message!;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async{
    await _auth.signOut();
  }
}
