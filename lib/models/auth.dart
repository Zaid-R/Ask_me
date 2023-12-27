// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:ask_me2/loacalData.dart';
import 'package:ask_me2/pages/admin_pages/admin_page.dart';
import 'package:ask_me2/pages/expert_pages/expert_page.dart';
import 'package:ask_me2/pages/user_pages/categories.dart';
import 'package:ask_me2/pages/user_pages/home_page.dart';
import 'dart:io';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AuthMode { logIn, signUp }

class Auth extends ChangeNotifier {
  bool isLoading = false;
  bool isExpert = true;
  Map<String, dynamic> authData = {};
  int radioGroupValue = 0;
  AuthMode authMode = AuthMode.logIn;
  DateTime birthDate = DateTime.now();
  PlatformFile? pickedFile;

  void addAuthData(String key, dynamic value) {
    authData[key] = value;
    notifyListeners();
  }


  void setBirthDate(DateTime value) {
    birthDate = value;
    notifyListeners();
  }

  void setPickedFile(PlatformFile? file) {
    pickedFile = file;
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
  
  //TODO: why you make return type bool or null ??
  Future<bool?> authenticate(BuildContext context) async {
    try {
      bool isLogin = authMode == AuthMode.logIn;
      //SignUp expert
      if (isExpert) {
        var expertsCollection =
            FirebaseFirestore.instance.collection('experts');
        if (!isLogin) {
          String? lastIdInTheField = (await expertsCollection
                  .doc('new comers')
                  .collection('experts')
                  .get())
              .docs
              .map((doc) => doc.id)
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
          final mountainImagesRef =
              storageRef.child("degrees/new comers/$id.pdf");
          final uploadTask = mountainImagesRef.putFile(File(pickedFile!.path!));

          addAuthData(
              'degree url',
              await (await uploadTask.whenComplete(() {}))
                  .ref
                  .getDownloadURL());

          addAuthData('isSuspended', false);

          await expertsCollection
              .doc('new comers')
              .collection('experts')
              .doc(id)
              .set(authData);

          showErrorDialog(
            'في حال تم قبولك, سنرسل لك ايميل من أجل توثيق حسابك خلال 24 ساعة',
            context,
          );

          setPickedFile(null);
          return true;
        } else {
          var verifiedCollection =
              expertsCollection.doc('verified').collection('experts');
          bool isAdmin = authData['ID'] == '0000';
          if (!isAdmin) {
            Map<String,dynamic>? expert = (await verifiedCollection.doc(authData['ID']).get()).data();
            bool isIdExist = expert!=null;

            if (!isIdExist) {
              showErrorDialog('معرف المستخدم غير صحيح', context);
            } else if (isIdExist) {
              if(expert['isSuspended']){
                showErrorDialog('تم إيقاف حسابك', context);
                return false;
              }
              bool isPasswordCorrect =
                  expert['password'] ==
                      authData['password'];
              if (!isPasswordCorrect) {
                showErrorDialog('كلمة السر غير صحيحة', context);
              } else if (isIdExist && isPasswordCorrect) {
                writeID(authData['ID']);
                writeName(expert['last name']+expert['first name']);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpertPage(),
                    ));
              }
            }
          } else {
            Map<String, dynamic>? adminData = (await FirebaseFirestore.instance
                        .collection('admin')
                        .doc('admin')
                        .get()).data();
            bool isAdminPassword = 
                    adminData!['password']
                    .toString()
                    .compareTo(authData['password']) ==
                0;

            if (isAdminPassword) {
              writeID(authData['ID']);
              writeName(adminData['name']);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminPage(),
                  ));
            } else {
              showErrorDialog('كلمة السر غير صحيحة', context);
            }
          }
        }
      } else {
        var usersCollection = FirebaseFirestore.instance.collection('users');
        if (isLogin) {
          //1. check email
          Map<String, dynamic>? userData = (await usersCollection.get())
              .docs
              .where(
                (element) => element['email'] == authData['email'],
              )
              .firstOrNull
              ?.data();
          if (userData != null) {
            bool isPasswordCorrect = userData['password'] == authData['password'];
            if (isPasswordCorrect) {
              writeEmial(authData['email']);
              writeName(userData['last name']+userData['first name']);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserPage(),
                  ));
            } else {
              showErrorDialog(
                'كلمة السر غير صحيحة',
                context,
              );
            }
          } else {
            showErrorDialog(
              'الايميل غير موجود',
              context,
            );
          }
        } else {
          var user = await usersCollection.doc(authData['email']).get();
          bool isEmailExist = user.exists;
          if (isEmailExist) {
            showErrorDialog(
              'الايميل مُستخدم مسبقاً',
              context,
            );
          } else {
            if (DateTime.now().difference(birthDate).inDays / 365 < 16) {
              showErrorDialog(
                'يجب أن يكون عمرك 16 عام على الأقل',
                context,
              );
              return null;
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
    return null;
  }
}
