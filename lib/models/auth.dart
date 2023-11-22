import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

enum AuthMode { logIn, signUp }

class Auth extends ChangeNotifier {
  bool isLoading = false;
  bool isExpert = false;
  int radioGroupValue = 1;
  AuthMode authMode = AuthMode.signUp;
  DateTime birthDate = DateTime.now();
  File? image;

  void selectImage(BuildContext context) async {
    var x = await pickImage(ImageSource.gallery, context);
    image = x == null? null:File(x.path);
    notifyListeners();
  }

  void setBirthDate(DateTime value) {
    birthDate = value;
    notifyListeners();
  }

  void switchAuthMode() {
    authMode = authMode == AuthMode.logIn ? AuthMode.signUp : AuthMode.logIn;
    notifyListeners();
  }

  void setRadioGroupValue(int value) {
    radioGroupValue = value;
    notifyListeners();
    print('radioGroupValue : $radioGroupValue');
  }

  void setIsExpert(bool value) {
    isExpert = value;
    notifyListeners();
  }

  void setIsLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  Future<void> authenticate(
    String email,
    String password,
    String username,
    bool isLogin,
  ) async {
    UserCredential authResult;
    final _auth = FirebaseAuth.instance;
    String Email = email.trim().toLowerCase();
    try {
      isLoading = true;
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: Email, password: password);
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: Email, password: password);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user!.email!)
            .set({
          'username': username,
          'password': password,
          'email': Email,
          'isAdmin': 0,
        });
      }
    } on FirebaseAuthException catch (e) {
      String message = "error Occurred";

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      }
      isLoading = false;
      throw message;
    } catch (e) {
      print(e);
      isLoading = false;
      rethrow;
    }
  }
}
