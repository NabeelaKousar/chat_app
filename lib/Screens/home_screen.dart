
import 'package:chat_app/auth/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../auth/login_screen.dart';
import '../models/chat_user.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class HomeScreen extends StatefulWidget {
  late final ChatUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  List<ChatUser> _searchList = [];
  bool _isSearching =false;

  late Size mq;
  @override
  void initState() {
    super.initState();
    _getSelfInfo();
  }

  void _getSelfInfo() async {
    final userData = await APIs.firestore
        .collection('users')
        .doc(APIs.auth.currentUser!.uid)
        .get();

    APIs.me = ChatUser.fromJson(userData.data()!);

    print("✅ APIs.me loaded: ${APIs.me!.name}");
    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on & back button is pressed then close search
        // or else simple close current screen on back click
        onWillPop: (){
            if(_isSearching){
              setState(() {
                _isSearching=!_isSearching;
              });
              return Future.value(false);
            }else{
              return Future.value(true);
            }

        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue, // AppBar background color set
            leading: Icon(CupertinoIcons.home, color: Colors.white),
            title: _isSearching?
                TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Name,Email,..',
                  ),
                  autofocus: true,
                  style: TextStyle(fontSize: 17,letterSpacing: 0.5),
                  onChanged: (val) {
                    _searchList.clear();
                    for (var i in _list) {
                      if (i.name.toLowerCase().contains(val.toLowerCase())) {
                        _searchList.add(i);
                      }
                    }
                    setState(() {
                      _searchList;
                    }); // Refresh UI after search
                  },
                ): Text('Chatting App', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                onPressed: () {
                  _isSearching =!_isSearching;
                },
                icon: Icon(_isSearching? CupertinoIcons.clear_circled_solid:Icons.search, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(user:widget.user,),
                    ),
                  );
                },
                icon: Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: FloatingActionButton(
              backgroundColor: Colors.blue, // FAB background
              onPressed: () async {
                await APIs.auth.signOut();
                await googleSignIn.signOut();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Icon(Icons.add_comment_rounded, color: Colors.white),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());

                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  List<ChatUser> list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                  _list = list; // ✅ Ye line add karo

                  if (list.isNotEmpty) {
                    return ListView.builder(
                      padding: EdgeInsets.only(top: mq.height * .01),
                      itemCount: _isSearching ? _searchList.length : list.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user: _isSearching ? _searchList[index] : list[index],
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        'No Connection Found',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}