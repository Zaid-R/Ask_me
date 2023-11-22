import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImage(ImageSource source, BuildContext context) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return file;
  }
  // ignore: use_build_context_synchronously
  // showDialog(
  //     context: context,
  //     builder: (ctx) {
  //       return Column(
  //         children: [
  //           const AlertDialog(
  //             content: Text('No Image is selected !'),
  //           ),
  //           ElevatedButton(
  //               onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
  //         ],
  //       );
  //     });
    return null;
}
