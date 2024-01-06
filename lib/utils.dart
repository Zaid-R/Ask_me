// ignore_for_file: use_build_context_synchronously

import 'package:ask_me2/local_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'pages/expert_pages/detailed_question.dart';

const Color themeColor = Color.fromRGBO(17, 138, 178, 1);
const Color buttonColor = Color.fromRGBO(178, 57, 17, 1);
const Color answerColor = Color.fromARGB(255, 165, 214, 167);
const Color reportColor = Color.fromARGB(255, 239, 154, 154);
const TextStyle infoStyle =
    TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
const String adminId = '0000';
const Color hiddenQuestionColor = Color.fromARGB(255, 189, 189, 189);
final expertsCollection = FirebaseFirestore.instance.collection('experts');
final usersCollection = FirebaseFirestore.instance.collection('users');
String expertCategory = readID()![0];

Widget circularIndicator = const Center(
  child: CircularProgressIndicator(),
);

ButtonStyle buildButtonStyle({required bool condition, Color? color}) {
  return ButtonStyle(
    elevation: const MaterialStatePropertyAll(10),
    backgroundColor: MaterialStatePropertyAll(
        color ?? (condition ? Colors.green[400] : Colors.red[600])),
  );
}

Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getUser(
    String email, bool isExpert) async {
  return (await (isExpert
          ? expertsCollection.doc('verified').collection('experts').get()
          : usersCollection.get()))
      .docs
      .where(
        (element) =>
            (isExpert ? element.data()['email'] as String : element.id) ==
            email,
      )
      .firstOrNull;
}

void sendEmail(
    {required String to, required String subject, required String text}) async {
  final smtpServer = gmail('srrz0315@gmail.com', 'fpvopqdmvrbxiifd');

  // Create the email message
  final message = Message()
    ..from = const Address('srrz0315@gmail.com', 'Sohaib Abo Garae')
    ..recipients.add(to)
    ..subject = subject
    ..text = text;

  try {
    // Send the email
    await send(message, smtpServer);
  } catch (e) {
    print('Error sending email: $e');
  }
}

Center buildEmptyMessage(String text) {
  return Center(
    child: Text(
      text,
      style: const TextStyle(fontSize: 20),
    ),
  );
}

Future<XFile?> pickImage(BuildContext context) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
  if (file != null) {
    return file;
  }
  return null;
}

Card buildQuestionTitleCard(
    {required String title,
    required BuildContext context,
    required String questionId,
    String? catId,
    Color? color,
    bool isCategoryDisplayed = false}) {
  return Card(
    color: color ?? Colors.blue[100],
    child: ListTile(
      title: Text(
        title,
        textAlign: TextAlign.end,
      ),
      onTap: () {
        // Navigate to the detailed question page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedQuestionPage(
              questionId: questionId,
              catId: catId,
              isCategoryDisplayed: isCategoryDisplayed,
            ),
          ),
        );
      },
    ),
  );
}

Future<PlatformFile?> selectFile(bool isPdf, BuildContext context) async {
  final result = await FilePicker.platform.pickFiles();
  if (result == null) return null;
  String fileName = result.files.first.name;
  if (isPdf) {
    if (!fileName.contains('.pdf')) {
      showMyDialog('pdf يجب أن يكون الملف من نوع', context);
      return null;
    }
  } else {
    if (!fileName.contains('.mp4')) {
      showMyDialog('ممنوع تحميل ملف آخر غير الفيديو', context);
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

void showMyDialog(String message, BuildContext context,
    {Color? color, bool isButtonHidden = false}) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
            content: Text(
              message,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 18, color: color),
            ),
            actions: isButtonHidden
                ? null
                : [
                    Center(
                      child: ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(themeColor)),
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'اغلاق',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
          ));
}
