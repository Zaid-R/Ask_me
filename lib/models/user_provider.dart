import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  XFile? image;
  PlatformFile? video;
  bool isAnonymous = false;
  int drawerId = 0;
  bool isPaused = false;

  void setIsPaused(bool value){
    isPaused = value;
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
