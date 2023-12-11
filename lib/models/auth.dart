// ignore_for_file: use_build_context_synchronously

import 'package:ask_me2/loacalData.dart';
import 'package:ask_me2/pages/admin_pages/admin_page.dart';
import 'package:ask_me2/pages/expert_pages/expert_page.dart';
import 'package:ask_me2/pages/user_pages/categories.dart';
import 'package:ask_me2/test_page.dart';
import 'dart:io';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum AuthMode { logIn, signUp }

class Auth extends ChangeNotifier {
  bool isLoading = false;
  bool isExpert = true;
  Map<String, dynamic> authData = {};
  int radioGroupValue = 1;
  AuthMode authMode = AuthMode.logIn;
  DateTime birthDate = DateTime.now();
  File? image;

  void addAuthData(String key, dynamic value) {
    authData[key] = value;
    notifyListeners();
  }

  void selectImage(BuildContext context) async {
    var x = await pickImage(ImageSource.gallery, context);
    image = x == null ? null : File(x.path);
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
  }

  void setIsExpert(bool value) {
    isExpert = value;
    notifyListeners();
  }

  void setIsLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  Future<void> authenticate(BuildContext context) async {
    try {
      bool isLogin = authMode == AuthMode.logIn;
      //SignUp expert
      if (isExpert) {
        var expertxCollection =
            FirebaseFirestore.instance.collection('experts');
        if (!isLogin) {
          String? lastIdInTheField = (await expertxCollection.get())
              .docs
              .map((doc) => doc.id)
              .toList()
              .where((id) => id.startsWith('$radioGroupValue'))
              .lastOrNull;

          var id = lastIdInTheField == null
              ? '${radioGroupValue}000'
              : (int.parse(lastIdInTheField) + 1).toString();
          // Create a storage reference from our app
          final storageRef = FirebaseStorage.instance.ref();

          // Create a reference to "mountains.jpg"
          // final degreeRef = storageRef.child("$id.jpg");

          //Create a reference to 'images/mountains.jpg'
          final mountainImagesRef = storageRef.child("degrees/$id.jpg");
          mountainImagesRef.putFile(image!);

          addAuthData('degree url', await mountainImagesRef.getDownloadURL());

          addAuthData('verification', 0);

          await expertxCollection.doc(id).set(authData);

          showErrorDialog(
              'We will send an email to you when your account get verified :)',
              context,
              false);

          image = null;
        } else {
          bool isAdmin = authData['ID'] == '0000';
          if (!isAdmin) {
            bool isIdExist = (await expertxCollection.get())
                .docs
                .where((element) => element.id == authData['ID'])
                .isNotEmpty;
            bool isPasswordCorrect =
                (await expertxCollection.doc(authData['ID']).get())
                        .data()!['password'] ==
                    authData['password'];

            if (!isIdExist) {
              showErrorDialog('This Id is not existed', context, true);
            } else if (!isPasswordCorrect) {
              showErrorDialog('The password is wrong', context, true);
            } else if (isIdExist && isPasswordCorrect) {
              writeID(authData['ID']);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExpertPage(),
                  ));
            }
          } else {
            bool isAdminPassword = (await FirebaseFirestore.instance
                        .collection('admin')
                        .doc('admin')
                        .get())
                    .data()!['password']
                    .toString()
                    .compareTo(authData['password']) ==
                0;

            if (isAdminPassword) {
              writeID(authData['ID']);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminPage(),
                  ));
            } else {
              showErrorDialog('The password is wrong', context, true);
            }
          }
        }
      } else {
        var usersCollection = FirebaseFirestore.instance.collection('users');
        if (isLogin) {
          //1. check email
          var user = (await usersCollection.get())
              .docs
              .where(
                (element) => element['email'] == authData['email'],
              )
              .firstOrNull
              ?.data();
          if (user != null) {
            bool isPasswordCorrect = user['password'] == authData['password'];
            if (isPasswordCorrect) {
              writeEmial(authData['email']);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoriesPage(),
                  ));
            } else {
              showErrorDialog('The password is wrong', context, true);
            }
          } else {
            showErrorDialog('This email is not existed', context, true);
          }
        } else {
          var user = await usersCollection.doc(authData['email']).get();
          bool isEmailExist = user.exists;
          if (isEmailExist) {
            showErrorDialog('This email is already existed', context, true);
          } else {
            if (DateTime.now().difference(birthDate).inDays / 365 < 16) {
              showErrorDialog('You should be 16 years old at least to sign up',
                  context, true);
              return;
            }

            writeEmial(authData['email']);
            addAuthData(
                'birth date', DateFormat('yyyy-MM-dd').format(birthDate));
            usersCollection.doc(authData['email']).set(authData);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoriesPage(),
                ));
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
