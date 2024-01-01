import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  XFile? image;
  PlatformFile? video;
  bool isAnonymous = false;
  int drawerId = 0;
  bool isPaused = false;
  bool isLoading = false;
  List<String> dates = [];

  void setIsPaused(bool value) {
    isPaused = value;
    notifyListeners();
  }

  void setIsLoading(bool value){
    isLoading = value;
    notifyListeners();
  }

  void addToDates(String value) {
    dates.add(value);
    notifyListeners();
  }

  void setDates(List<String> dates) {
    this.dates = dates;
    notifyListeners();
  }

  void removeDate(String value) {
    dates.remove(value);
    notifyListeners();
  }

  void clearDates() {
    dates.clear();
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
