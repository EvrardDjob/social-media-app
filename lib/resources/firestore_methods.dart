import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String profileImage,
    String username,
  ) async {
    String res = 'Some error Occurred';
    try {
      String photoUrl = await StorageMethods().uploadImagetoStorage(
        'posts',
        file,
        true,
      );
      String postId = Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        postUrl: photoUrl,
        username: username, 
        postId: postId,
        profileImage: profileImage,
        datePublished: DateTime.now(),
        likes: [],
      );
      await _firestore.collection('posts').doc(postId).set(post.toJson(),);
      res='success';
    } catch (err) {
      res=err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId,String uid,List likes) async{
    try{
      if(likes.contains(uid)){
        await _firestore.collection('posts').doc(postId).update({
          'likes':FieldValue.arrayRemove([uid]),
        });
      } else{
        await _firestore.collection('posts').doc(postId).update({
          'likes':FieldValue.arrayUnion([uid]),
        });
      }
    } catch(e){
      print(e.toString());
    }
  }

  Future<void> postComment(String postId,String text,String uid,String name,String profeilePic) async{
    try{
      if(text.isNotEmpty){
        String commentId=Uuid().v1();
        await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
          'profilePic':profeilePic,
          'name':name,
          'uid':uid,
          'text':text,
          'commentId':commentId,
          'datePublished':DateTime.now(),
        });
      } else{
        print('text is empty');
      }
    } catch(e){
      print(e.toString()); 
    }
  }

  //deleting post
  Future<void> deletePost(String postId) async{
    try{
      await _firestore.collection('posts').doc(postId).delete();
    } catch(e){
      print(e.toString());
    }
  }

  Future<void> followUser(String uid,String followId) async{
    try{
      DocumentSnapshot snap= await _firestore.collection('users').doc(uid).get();
      List following=(snap.data()! as dynamic)['following'];
      if(following.contains(uid)){
        await _firestore.collection('users').doc(followId).update({
          'followers':FieldValue.arrayRemove([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'follwing':FieldValue.arrayRemove([followId]),
        });
      } else{
        await _firestore.collection('users').doc(followId).update({
          'followers':FieldValue.arrayUnion([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'follwing':FieldValue.arrayUnion([followId]),
        });
      }
    } catch(e){
      print(e.toString());
    }
  }
}
