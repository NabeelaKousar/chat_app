import 'dart:developer';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static ChatUser? me;

  static User get user => auth.currentUser!;

  // 🔹 Check if user exists
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // 🔹 Get current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((userDoc) {
      if (userDoc.exists) {
        me = ChatUser.fromJson(userDoc.data()!);
        log('✅ My Data: ${userDoc.data()}');
      } else {
        createUser().then((value) => getSelfInfo());
      }
    });
  }

  // 🔹 Create new user in Firestore
  static Future<bool> createUser() async {
    final currentUser = auth.currentUser!;

    final newUser = ChatUser(
      id: currentUser.uid,
      name: currentUser.displayName ?? 'No Name',
      age: 20,
      images:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=387&auto=format&fit=crop',
      isOnline: true,
      about: "Hey there! I'm using Chat App.",
      active: true,
      pushToken: '',
      email: user.email ?? "",
    );

    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .set(newUser.toJson());
    return true;
  }

  // 🔹 Get all users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('email', isNotEqualTo: user.email)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
    String userId,
  ) {
    return firestore
        .collection('messages')
        .where('toId', isEqualTo: userId)
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // 🔹 Update user info
  static Future<bool> updateUserInfo() async {
    try {
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'name': me!.name,
        'about': me!.about,
      });
      return true;
    } catch (e) {
      log('❌ Error while updating user info: $e');
      return false;
    }
  }

  // 🔹 Update profile picture
  static Future<bool> updateProfilePicture(String imageUrl) async {
    try {
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'images': imageUrl,
      });
      return true;
    } catch (e) {
      log('❌ Error while updating profile picture: $e');
      return false;
    }
  }

  // 🔹 Generate Conversation ID
  static String getConversationID(String id1, String id2) =>
      id1.hashCode <= id2.hashCode ? '${id1}$id2' : '${id2}$id1';

  // 🔹 Get all messages between 2 users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatUser user,
  ) {
    return firestore
        .collection(
          'chats/${getConversationID(auth.currentUser!.uid, user.id)}/messages',
        )
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // 🔹 Send a new message
  static Future<void> sendMessage(ChatUser user, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
      msg: msg,
      read: '',
      toId: user.id,
      type: MsgType.text,
      fromId: auth.currentUser!.uid,
      sent: time,
    );

    final ref = firestore.collection(
      'chats/${getConversationID(auth.currentUser!.uid, user.id)}/messages',
    );

    await ref.doc(message.sent).set(message.toJson());
    //update read status if messages
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.fromId, message.toId)}/message/')
        .doc(message.sent)
        .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});
  }
  static Future<void> getLastMessage(Message message) async {}

}
