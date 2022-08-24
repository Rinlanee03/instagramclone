import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramclone/resources/auth_methods.dart';
import 'package:instagramclone/resources/firestore_methods.dart';
import 'package:instagramclone/screens/login_screen.dart';
import 'package:instagramclone/utils/colors.dart';
import 'package:instagramclone/utils/utils.dart';
import 'package:instagramclone/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
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
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);

      setState(() {});
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'],
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(
                              userData['photoUrl'],
                            ),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (FirebaseAuth.instance.currentUser!.uid == widget.uid) FollowButton(
                                        text : 'Follow',
                                        backgroundColor: mobileBackgroundColor,
                                        textColor: primaryColor,
                                        borderColor: Colors.grey,
                                        function: ()  async{
                                          await AuthMethods().signOut();
                                          Navigator.of(context)
                                            .pushReplacement(
                                              MaterialPageRoute(builder: (context) =>
                                                const LoginScreen()  
                                              )
                                            );
                                        },
                                      ) else isFollowing
                                        ? FollowButton(
                                          backgroundColor: Colors.white, 
                                          borderColor: Colors.grey,
                                           text: 'Unfollow', 
                                           textColor: Colors.black,
                                           function: () async {
                                            await FireStoreMethods().
                                              followUser(
                                                FirebaseAuth.instance
                                                  .currentUser!.uid, 
                                                userData['uid'],
                                              );
                                              setState(() {
                                                isFollowing = false;
                                                followers--;
                                              });
                                           },
                                      )
                                      : FollowButton(
                                        backgroundColor: Colors.blue,
                                         borderColor: Colors.blue, 
                                         text: 'Follow', 
                                         textColor: Colors.white,
                                         function: () async {},
                                    )
                                  ],
                                )
                              ]
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
        );
  }
}
