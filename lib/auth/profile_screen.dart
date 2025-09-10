import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../models/chat_user.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  get picker => null;
  //late Size mq;

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text('Profile Screen')),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.auth.signOut().then((value) async {
                await googleSignIn.signOut().then((value) {
                  //for hiding progress dialog
                  Navigator.pop(context);
                  //for replacing home screen with login screen
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                });
              });

              // Navigate to login screen (replace with your login screen)
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (_) => LoginScreen()),
              // );
            },
            icon: Icon(Icons.logout),
            label: Text('logout'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: Image.file(
                              File(_image!),
                              width: mq.height * .2,
                              height: mq.height * .2,
                              fit: BoxFit.cover,
                            ),
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: CachedNetworkImage(
                              width: mq.height * .2,
                              height: mq.height * .2,
                              fit: BoxFit.fill,
                              imageUrl: widget.user.images,
                              errorWidget:
                                  (context, url, error) => CircleAvatar(
                                    child: Icon(CupertinoIcons.person),
                                  ),
                            ),
                          ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),

                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(width: mq.width, height: mq.height * .05),
                  TextFormField(
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.add_comment_rounded,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg.Happy Singh',
                      label: Text('Name'), // ✅ yeh correct hai
                    ),
                  ),
                  SizedBox(width: mq.width, height: mq.height * .05),
                  //name input field
                  TextFormField(
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.info_outline, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg.Feelings happy',
                      label: Text('Name'), // ✅ yeh correct hai
                    ),
                  ),

                  SizedBox(width: mq.width, height: mq.height * .05),
                  //about input field
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: StadiumBorder(),
                      minimumSize: Size(mq.width * .4, mq.height * .06),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        APIs.updateUserInfo().then((value) {
                          if (value) {
                            Dialogs.showSnackbar(
                              context,
                              'Profile Updated Successfully!',
                            );
                          } else {
                            Dialogs.showSnackbar(
                              context,
                              'Something went wrong!',
                            );
                          }
                        });
                      }
                    },
                    icon: Icon(Icons.edit, size: 28, color: Colors.white),
                    label: Text(
                      'UPDATE',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: mq.height * .03,
            bottom: mq.height * .05,
          ),
          children: [
            Text(
              'Pick profile picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: mq.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker Picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      log('image path:${image} --MimeType:${image.mimeType}');
                      setState(() {
                        _image = image.path;
                      });
                      Navigator.pop(context);
                    }
                  },

                  child: Image.asset('images/gallery.png'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker Picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      log('image path:${image} --MimeType:${image.mimeType}');
                      setState(() {
                        _image = image.path;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('images/camera.png'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
