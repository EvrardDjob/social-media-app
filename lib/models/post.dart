import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String postUrl;
  final String username;
  final String postId;
  final String profileImage;
  final datePublished;
  final likes;

  const Post({
    required this.description,
    required this.uid,
    required this.postUrl,
    required this.username,
    required this.postId,
    required this.profileImage,
    required this.datePublished,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'description': description,
    'uid': uid,
    'postId': postId,
    'profileImage': profileImage,
    'datePublished': datePublished,
    'postUrl': postUrl,
    'likes':likes,
  };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = (snap.data() as Map<String, dynamic>);

    return Post(
      description: snapshot['description'],
      uid: snapshot['uid'],
      postUrl: snapshot['postUrl'],
      username: snapshot['username'],
      postId: snapshot['postId'],
      profileImage: snapshot['profileImage'],
      datePublished: snapshot['datePublished'],
      likes: snapshot['likes'],
    );
  }
}
