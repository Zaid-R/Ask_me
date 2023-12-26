import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier{
  int drawerId=0;
  int verificationValue = 0;
  bool isLoading = false;

  void setIsLoading(bool value){
    isLoading =value;
    notifyListeners();
  }
  void setSelectedDrawerId(int value){
    drawerId = value;
    notifyListeners();
  }

  void setVerificationValue(int value){
    verificationValue = value;
    notifyListeners();
  }
}