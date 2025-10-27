import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/resources/storage_methods.dart';
import 'package:social_media_app/utils/colors.dart';
import 'package:social_media_app/utils/utils.dart';
import 'package:social_media_app/widgets/text_field_input.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;
  final String currentUsername;
  final String currentBio;
  final String currentPhotoUrl;

  const EditProfileScreen({
    super.key,
    required this.uid,
    required this.currentUsername,
    required this.currentBio,
    required this.currentPhotoUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.currentUsername;
    _bioController.text = widget.currentBio;
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String photoUrl = widget.currentPhotoUrl;

      // Si une nouvelle image a été sélectionnée, on l'upload
      if (_image != null) {
        photoUrl = await StorageMethods().uploadImagetoStorage(
          "profilepics",
          _image!,
          false,
        );
      }

      // Mise à jour dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
            'username': _usernameController.text,
            'bio': _bioController.text,
            'photoUrl': photoUrl,
          });

      // Mise à jour des posts (username et photo de profil)
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      for (var doc in postsSnapshot.docs) {
        await doc.reference.update({
          'username': _usernameController.text,
          'profileImage': photoUrl,
        });
      }

      setState(() {
        _isLoading = false;
      });

      showSnackBar('Profile updated successfully!', context);
      Navigator.of(
        context,
      ).pop(true); // Retourne true pour indiquer la mise à jour
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar('Error: ${e.toString()}', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Edit Profile'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : updateProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Photo de profil
                    Stack(
                      children: [
                        _image != null
                            ? CircleAvatar(
                                radius: 64,
                                backgroundImage: MemoryImage(_image!),
                              )
                            : CircleAvatar(
                                radius: 64,
                                backgroundImage: NetworkImage(
                                  widget.currentPhotoUrl,
                                ),
                              ),
                        Positioned(
                          bottom: -10,
                          left: 80,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Username
                    TextFieldInput(
                      textEditingController: _usernameController,
                      hintText: 'Username',
                      textInputType: TextInputType.text,
                    ),

                    const SizedBox(height: 24),

                    // Bio
                    TextFieldInput(
                      textEditingController: _bioController,
                      hintText: 'Bio',
                      textInputType: TextInputType.text,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
