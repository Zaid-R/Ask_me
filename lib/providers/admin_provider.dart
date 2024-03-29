import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  int drawerId = 0;
  bool isLoading = false;
  String searchQuery = '';
  bool areQuestionsNotEmpty = false;
  bool isEmptyMessage = false;

  void setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setIsEmptyMessage(bool value){
    isEmptyMessage = value;
    notifyListeners();
  }

  void setAreQuestionsNotEmpty(bool value) {
    areQuestionsNotEmpty = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setSelectedDrawerId(int value) {
    drawerId = value;
    notifyListeners();
  }
}
