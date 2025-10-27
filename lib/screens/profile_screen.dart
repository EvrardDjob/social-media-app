import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/resources/auth_methods.dart';
import 'package:social_media_app/resources/firestore_methods.dart';
import 'package:social_media_app/screens/edit_profile_screen.dart'; 
import 'package:social_media_app/screens/login_screen.dart';
import 'package:social_media_app/utils/colors.dart';
import 'package:social_media_app/utils/utils.dart';
import 'package:social_media_app/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int followings = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      postLen = postSnap.docs.length;
      followers = userSnap.data()!['followers'].length;
      followings = userSnap.data()!['following'].length;
      isFollowing = userSnap.data()!['followers'].contains(
        FirebaseAuth.instance.currentUser!.uid,
      );
      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: const CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData['username']),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(userData['photoUrl']),
                        radius: 60,
                      ),

                      SizedBox(height: 20),

                      Text(
                        userData['username'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        userData['bio'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildStatColumn(postLen, 'posts'),
                          buildStatColumn(followers, 'followers'),
                          buildStatColumn(followings, 'following'),
                        ],
                      ),

                      SizedBox(height: 20),

                      // ✅ MODIFIÉ : Ajout du bouton Edit Profile
                      FirebaseAuth.instance.currentUser!.uid == widget.uid
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Bouton Edit Profile
                                Expanded(
                                  child: FollowButton(
                                    backGroundColor: mobileBackgroundColor,
                                    borderColor: Colors.grey,
                                    text: 'Edit Profile',
                                    textColor: primaryColor,
                                    function: () async {
                                      // Navigation vers l'écran d'édition
                                      final result = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditProfileScreen(
                                            uid: widget.uid,
                                            currentUsername: userData['username'],
                                            currentBio: userData['bio'],
                                            currentPhotoUrl: userData['photoUrl'],
                                          ),
                                        ),
                                      );
                                      
                                      // Si le profil a été mis à jour, recharge les données
                                      if (result == true) {
                                        getData();
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                // Bouton Sign Out
                                Expanded(
                                  child: FollowButton(
                                    backGroundColor: mobileBackgroundColor,
                                    borderColor: Colors.grey,
                                    text: 'Sign Out',
                                    textColor: primaryColor,
                                    function: () async {
                                      await AuthMethods().signOut();
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : isFollowing
                              ? FollowButton(
                                  backGroundColor: Colors.white,
                                  borderColor: Colors.grey,
                                  text: 'Unfollow',
                                  textColor: Colors.black,
                                  function: () async {
                                    await FirestoreMethods().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      userData['uid'],
                                    );
                                    setState(() {
                                      isFollowing = false;
                                      followers--;
                                    });
                                  },
                                )
                              : FollowButton(
                                  backGroundColor: Colors.blue,
                                  borderColor: Colors.blue,
                                  text: 'Follow',
                                  textColor: primaryColor,
                                  function: () async {
                                    await FirestoreMethods().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      userData['uid'],
                                    );
                                    setState(() {
                                      isFollowing = true;
                                      followers++;
                                    });
                                  },
                                ),
                    ],
                  ),
                ),

                const Divider(),

                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];
                        return Container(
                          child: Image(
                            image: NetworkImage(snap['postUrl']),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
