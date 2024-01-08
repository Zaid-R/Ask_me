// ignore_for_file: use_build_context_synchronously

import 'package:ask_me2/utils/local_data.dart';
import 'package:ask_me2/pages/admin_pages/admin_page.dart';
import 'package:ask_me2/pages/expert_pages/expert_page.dart';
import 'package:ask_me2/pages/user_pages/user_page.dart';
import 'dart:io';
import 'package:ask_me2/utils/tools.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/transition.dart';

enum AuthMode { logIn, signUp }

class Auth extends ChangeNotifier {
  bool isLoading = false;
  bool isExpert = true;
  bool isCodeSent = false;
  bool emailNotExist = false;
  bool isFrogotButtonLoading = false;
  bool isCodePassed = false;
  bool isSignUp = false;
  String email = '';
  String code = '';
  Map<String, dynamic> authData = {};
  int radioGroupValue = 0;
  AuthMode _authMode = AuthMode.logIn;
  DateTime birthDate = DateTime.now();
  PlatformFile? pickedFile;

  void addAuthData(String key, dynamic value) {
    authData[key] = value;
    notifyListeners();
  }

  void clearForgotPasswordData(){
    isCodePassed = false;
    isCodeSent = false;
    isFrogotButtonLoading = false;
    emailNotExist =false;
    notifyListeners();
  }

  void setEmailNotExist(bool value){
    emailNotExist = value;
    notifyListeners();
  }

  void setIsCodePassed(bool value){
    isCodePassed = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setAuthData(Map<String,dynamic> data){
    authData = data;
    notifyListeners();
  }

  void setCode(String value) {
    code = value;
    notifyListeners();
  }

  void setIsFrogotButtonLoading(bool value) {
    isFrogotButtonLoading = value;
    notifyListeners();
  }

  void setIsCodeSent(bool value) {
    isCodeSent = value;
    notifyListeners();
  }

  void clearAuthData() {
    authData = {};
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
    if (_authMode == AuthMode.logIn) {
      _authMode = AuthMode.signUp;
      isSignUp = true;
    } else {
      _authMode = AuthMode.logIn;
      isSignUp = false;
    }
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
  void authenticate(BuildContext context) async {
    try {
      bool isLogin = _authMode == AuthMode.logIn;
      //SignUp expert
      if (isExpert) {
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

          showMyDialog(
            'في حال تم قبولك, سنرسل لك ايميل من أجل توثيق حسابك خلال 24 ساعة',
            context,
          );

          setPickedFile(null);
          setRadioGroupValue(0);
        } else {
          var verifiedCollection =
              expertsCollection.doc('verified').collection('experts');
          bool isAdmin = authData['ID'] == '0000';
          if (!isAdmin) {
            Map<String, dynamic>? expert =
                (await verifiedCollection.doc(authData['ID']).get()).data();
            bool isIdExist = expert != null;

            if (!isIdExist) {
              showMyDialog('معرف المستخدم غير صحيح', context);
              return;
            } else if (isIdExist) {
              bool isPasswordCorrect =
                  expert['password'] == authData['password'];
              if (!isPasswordCorrect) {
                showMyDialog('كلمة السر غير صحيحة', context);
                return;
              } else if (isIdExist && isPasswordCorrect) {
                writeID(authData['ID']);
                writeName(expert['first name'] + ' ' + expert['last name']);
                clearAuthData();
                Navigator.pushReplacement(
                    context,
                    CustomPageRoute(
                      builder: (_) => const ExpertPage(),
                    ));
              }
            }
          } else {
            Map<String, dynamic>? adminData = (await FirebaseFirestore.instance
                    .collection('admin')
                    .doc('admin')
                    .get())
                .data();
            bool isAdminPassword = adminData!['password']
                    .toString()
                    .compareTo(authData['password']) ==
                0;

            if (isAdminPassword) {
              writeID(authData['ID']);
              writeName(adminData['name']);
              clearAuthData();
              Navigator.pushReplacement(
                  context,
                  CustomPageRoute(
                    builder: (_) => const AdminPage(),
                  ));
            } else {
              showMyDialog('كلمة السر غير صحيحة', context);
              return;
            }
          }
        }
      } else {
        if (isLogin) {
          //1. check email
          final userData = await getUser(authData['email'],false);
          if (userData != null) {
            bool isPasswordCorrect =
                userData['password'] == authData['password'];
            if(userData['isSuspended']){
              showMyDialog('حسابك معطل', context);
              return;
            }
            else if (isPasswordCorrect) {
              writeEmial(authData['email']);
              writeName(userData['first name'] + ' ' + userData['last name']);
              clearAuthData();
              Navigator.pushReplacement(
                  context,
                  CustomPageRoute(
                    builder: (_) => const UserPage(),
                  ));
            } else {
              showMyDialog(
                'كلمة السر غير صحيحة',
                context,
              );
              return;
            }
          } else {
            showMyDialog(
              'الايميل غير موجود',
              context,
            );
            return;
          }
        } else {
          var user = await usersCollection.doc(authData['email']).get();
          bool isEmailExist = user.exists;
          if (isEmailExist) {
            showMyDialog(
              'الايميل مُستخدم مسبقاً',
              context,
            );
            return;
          } else {
            if (DateTime.now().difference(birthDate).inDays / 365 < 16) {
              showMyDialog(
                'يجب أن يكون عمرك 16 عام على الأقل',
                context,
              );
              return;
            }

            writeEmial(authData['email']);
            writeName(authData['first name'] + ' ' + authData['last name']);
            addAuthData(
                'birth date', DateFormat('yyyy-MM-dd').format(birthDate));
            addAuthData('askedQuestions', []);
            usersCollection.doc(authData['email']).set(authData);
            clearAuthData();
            Navigator.pushReplacement(
                context,
                CustomPageRoute(
                  builder: (_) => const UserPage(),
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
