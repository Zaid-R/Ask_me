import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const Color themeColor = Color.fromRGBO(17, 138, 178, 1);
const Color buttonColor = Color.fromRGBO(178, 57, 17, 1);
Widget circularIndicator = const Center(
  child: CircularProgressIndicator(),
);

Future<XFile?> pickImage(ImageSource source, BuildContext context) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return file;
  }
  return null;
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

void showErrorDialog(String message, BuildContext context, bool isError) {
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: isError ? const Text('An error occurred') : null,
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Okay',
                ),
              )
            ],
          ));
}
