import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/add_post_screen.dart';
import 'package:social_media_app/screens/feed_screen.dart';
import 'package:social_media_app/screens/profile_screen.dart';
import 'package:social_media_app/screens/search_screen.dart';

const webScreenSize = 600;

//Maintenant c'est une fonction qui prend un callback
List<Widget> getHomeScreenItems(VoidCallback navigateToFeed) {
  return [
    const FeedScreen(),
    const SearchScreen(),
    AddPostScreen(onPostSuccess: navigateToFeed), // On passe le callback
    const Text('notif'),
    ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
  ];
}
