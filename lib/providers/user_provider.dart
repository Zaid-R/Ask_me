import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  XFile? image;
  PlatformFile? video;
  bool isAnonymous = false;
  int drawerId = 0;
  bool isPaused = true;
  bool isLimitExceeded =false;
  bool isLoading = false;
  List<String> dateList = [];

  void setIsPaused(bool value) {
    isPaused = value;
    notifyListeners();
  }


  void setIsLimitExceeded(bool value) {
    isLimitExceeded = value;
    notifyListeners();
  }

  void setIsLoading(bool value){
    isLoading = value;
    notifyListeners();
  }

  void addToDates(String value) {
    dateList.add(value);
    notifyListeners();
  }

  void setDates(List<String> dates) {
    dateList = dates;
    notifyListeners();
  }

  void removeDate(String value) {
    dateList.remove(value);
    notifyListeners();
  }

  void clearDates() {
    dateList.clear();
    notifyListeners();
  }

  void setImage(XFile? selectedImage) {
    image = selectedImage;
    notifyListeners();
  }

  void setIsAnonymous(bool value) {
    isAnonymous = value;
    notifyListeners();
  }

  void setVideo(PlatformFile? selectedVideo) {
    video = selectedVideo;
    notifyListeners();
  }

  void setSelectedDrawerId(int value) {
    drawerId = value;
    notifyListeners();
  }
}
