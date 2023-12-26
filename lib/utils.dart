// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const Color themeColor = Color.fromRGBO(17, 138, 178, 1);
const Color buttonColor = Color.fromRGBO(178, 57, 17, 1);

Widget circularIndicator = const Center(
  child: CircularProgressIndicator(),
);

Future<XFile?> pickImage( BuildContext context) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
  if (file != null) {
    return file;
  }
  return null;
}

Future<PlatformFile?> selectFile(bool isPdf,BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return null;
    String fileName = result.files.first.name;
    if (isPdf) {
      if (!fileName.contains('.pdf')) {
        showErrorDialog('pdf يجب أن يكون الملف من نوع', context);
        return null;
      }
    } else {
      if (!fileName.contains('.mp4')) {
        showErrorDialog('ممنوع تحميل ملف آخر غير الفيديو', context);
        return null;
      }
    }
    return result.files.first;
  }

ElevatedButton buildMyElevatedButton(Function() function, String label) {
  return ElevatedButton(
    style: buildSelectButtonStyle(),
      onPressed: function,
      child: Text(
        label,
        style: buildSelectButtonTextStyle(),
      ));
}

TextStyle buildSelectButtonTextStyle() {
  return const TextStyle(fontSize: 16, color: Colors.black);
}

ButtonStyle buildSelectButtonStyle() {
  return ElevatedButton.styleFrom(
      side: const BorderSide(width: 2, color: buttonColor),
      elevation: 3,
      backgroundColor: Colors.blue);
}

void showErrorDialog(String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            content: Text(message,style: const TextStyle(fontSize: 18),),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'اغلاق',
                ),
              )
            ],
          ));
}
