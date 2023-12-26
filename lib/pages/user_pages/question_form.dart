// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:ask_me2/loacalData.dart';
import 'package:ask_me2/widgets/video_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:ask_me2/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user_provider.dart';

class QuestionFormPage extends StatelessWidget {
  final String categoryId;
  QuestionFormPage({
    super.key,
    required this.categoryId,
  });

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('كتابة سؤال جديد'),
        backgroundColor: const Color.fromRGBO(17, 138, 178, 1),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              _buildTextField(_titleController, 'العنوان'),
              const SizedBox(height: 16.0),
              _buildTextField(_bodyController, 'السؤال', maxLines: 5),
              const SizedBox(height: 16.0),
              _buildAnonymousCheckbox(),
              _buildPreviewers(),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildTextField(TextEditingController controller, String lable,
      {int maxLines = 1}) {
    return TextField(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        controller: controller,
        decoration: _buildTextFieldDecoration(lable),
        maxLines: maxLines);
  }

  InputDecoration _buildTextFieldDecoration(String lable) {
    return InputDecoration(
        labelText: lable,
        labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: themeColor, width: 3)),
        floatingLabelAlignment: FloatingLabelAlignment.center,
        floatingLabelBehavior: FloatingLabelBehavior.always);
  }

  Widget _buildPreviewers() {
    bool isUploadImageAllowed = !['1','2','6'].contains(categoryId);
    bool isUploadVideoAllowed = ['3', '2'].contains(categoryId);
    bool isBothAllowed = isUploadImageAllowed && isUploadVideoAllowed;

    void _saveQuestionToDatabase(BuildContext context,
        {required bool isAnonymous,XFile? image, PlatformFile? video,}) async {
      if (_titleController.text.trim().isEmpty) {
        showErrorDialog('يجب كتابة عنوان مختصر يشير إلى محتوى السؤال', context);
        return;
      } else if (_bodyController.text.trim().isEmpty) {
        showErrorDialog('لا يمكن أن يكون السؤال فارغ', context);
        return;
      }
      // Create a new question document
      Map<String, dynamic> questionData = {
        'title': _titleController.text,
        'body': _bodyController.text,
        'date': DateTime.now().toString(),
        'email': readEmail(),
        'isAnswered': false,
        'isAnonymous': isAnonymous
      };

      var categoryCollection = FirebaseFirestore.instance
          .collection('questions')
          .doc(categoryId)
          .collection('questions');
      String questionId =
          ((await categoryCollection.get()).docs.length + 1).toString();
      if (isUploadImageAllowed) {
        if (image == null) {
          questionData['image url'] = null;
        } else {
          final uploadTask = FirebaseStorage.instance
              .ref()
              .child('questions/$categoryId/$questionId/${image.name}')
              .putFile(File(image.path));

          questionData['image url'] =
              await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
        }
      }

      if (isUploadVideoAllowed) {
        if (video == null) {
          questionData['video url'] = null;
        } else {
          final uploadTask = FirebaseStorage.instance
              .ref()
              .child('questions/$categoryId/$questionId/${video.name}')
              .putFile(File(video.path!));

          questionData['video url'] =
              await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
        }
      }
      // Save the question to the database

      categoryCollection.doc(questionId).set(questionData);

      _titleController.clear();
      _bodyController.clear();
      context.read<UserProvider>().setVideo(null);
      context.read<UserProvider>().setImage(null);

    }

    return Consumer<UserProvider>(builder: (context, provider, __) {
            Widget buildButtons() {
              ElevatedButton addVideoButton = buildMyElevatedButton(() async {
                PlatformFile? selectedVideo = await selectFile(false, context);

                if (selectedVideo != null && provider.video != null) {
                  provider.setVideo(null);
                }
                if (selectedVideo != null) {
                  provider.setVideo(selectedVideo);
                }
                if (selectedVideo != null && provider.image != null) {
                  provider.setImage(null);
                }
              }, 'إضافة فيديو');

              ElevatedButton addImageButton = buildMyElevatedButton(() async {
                XFile? selectedImage = await pickImage(context);
                if (selectedImage != null && provider.video != null) {
                  provider.setVideo(null);
                }
                if (selectedImage != null) {
                  provider.setImage(selectedImage);
                }
              }, 'إضافة صورة');

              if (isBothAllowed) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [addVideoButton, addImageButton],
                );
              } else if (isUploadImageAllowed) {
                return addImageButton;
              } else if(isUploadVideoAllowed){
                return addVideoButton;
              }
              return Container();
            }

            Widget buildLogic() {
              if (isBothAllowed) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildVideoPreview(provider.video, context),
                    _buildImagePreview(provider.image, context)
                  ],
                );
              } else if (isUploadVideoAllowed) {
                return _buildVideoPreview(provider.video,context);
              } else if(isUploadImageAllowed){
                return _buildImagePreview(provider.image, context);
              }
              return Container();
            }

            return Column(
              crossAxisAlignment: isBothAllowed
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.end,
              children: [
                buildButtons(),
                const SizedBox(
                  height: 10,
                ),
                buildLogic(),
                buildMyElevatedButton(
                    () => _saveQuestionToDatabase(context,isAnonymous: provider.isAnonymous,
                        image: provider.image, video: provider.video),
                    'انشر'),
              ],
            );
          });
  }

  Widget _buildAnonymousCheckbox() {
  return Consumer<UserProvider>(builder: (_,provider,__){
    return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      const Text('إخفاء الهوية'),
      Checkbox(
        value: provider.isAnonymous,
        onChanged: (value) {
            provider.setIsAnonymous(value ?? false);
        },
      )
    ],
  );
  });
  
}

  Widget _buildVideoPreview(PlatformFile? video, BuildContext context) {
    return video != null
        ? Container(
            height: 160,
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                const VideoPreviewer(),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // Remove the selected video
                      context.read<UserProvider>().setVideo(null);
                    },
                  ),
                ),
              ],
            ))
        : Container();
  }

  Widget _buildImagePreview(XFile? image, BuildContext context) {
    return image != null
        ? Container(
            height: 160,
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: Image.memory(
                    File(image.path).readAsBytesSync(),
                    width: 150.0,
                    height: 130.0,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // Remove the selected image
                      context.read<UserProvider>().setImage(null);
                    },
                  ),
                ),
              ],
            ))
        : Container();
  }
}