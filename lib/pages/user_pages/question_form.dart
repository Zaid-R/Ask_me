import 'dart:io';
import 'package:ask_me2/loacalData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:ask_me2/utils.dart';
import 'package:image_picker/image_picker.dart';

class QuestionFormPage extends StatefulWidget {
  final String id;
  const QuestionFormPage({
    super.key,
    required this.id,
  });

  @override
  _QuestionFormPageState createState() => _QuestionFormPageState();
}

class _QuestionFormPageState extends State<QuestionFormPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  List<Map<String, dynamic>> selectedImages = [];
  int lastImageIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask a Question'),
        backgroundColor: const Color.fromRGBO(17, 138, 178, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: bodyController,
                onChanged: (value){
                  if(lastImageIndex!=-1&&bodyController.text.length-1<lastImageIndex){
                    setState(() {
                      bodyController.text+='*';
                    });
                    showErrorDialog('You have to remove last image to delete text', context, true);
                  }
                },
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Question Body'),
              ),
              const SizedBox(height: 16.0),
              buildMyElevatedButton(() => saveQuestionToDatabase(), 'Submit'),
              const SizedBox(height: 16.0),
              buildMyElevatedButton(() => addImage(), 'Add Image'),
              const SizedBox(height: 16.0),
              buildImagePreview(),
            ],
          ),
        ),
      ),
    );
  }

  void addImage() async {
    var pickedFile = await pickImage(ImageSource.gallery, context);
    if (pickedFile != null) {
      String name = (selectedImages.length + 1).toString();
      setState(() {
        bodyController.text += '*';
        lastImageIndex = bodyController.text.length-1;
        selectedImages.add({
          'photo': File(pickedFile.path),
          'name': name,
          'index':bodyController.text.length-1
        });
        
      });
    }
  }

  Widget buildImagePreview() {
    if (selectedImages.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selected Images:', style: TextStyle(fontSize: 16.0)),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              scrollDirection: Axis.vertical,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                var image = selectedImages[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image.memory(
                            (image['photo'] as File).readAsBytesSync(),
                            width: 100.0,
                            height: 80.0,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Remove the selected image
                                setState(() {
                                  bodyController.text = bodyController.text
                                      .replaceRange(image['index']-1, image['index'], '');
                                  selectedImages.removeAt(index);
                                  lastImageIndex=selectedImages.isEmpty?-1:selectedImages.last['index'];
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Text(
                        image['name'].toString(),
                        style: const TextStyle(fontSize: 15),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  void saveQuestionToDatabase() async {
    // Create a new question document
    Map<String, dynamic> questionData = {
      'title': titleController.text,
      'body': bodyController.text,
      'date': DateTime.now().toString(),
      'email': readEmail(),
      'isAnswered': false,
      'hasImages': selectedImages.isNotEmpty
    };
    var categoryCollection = FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.id)
        .collection('questions');
    String questionId =
        ((await categoryCollection.get()).docs.length + 1).toString();
    // Save the question to the database

    categoryCollection.doc(questionId).set(questionData);

    uploadImages(questionId);
  }

  void uploadImages(String questionId) async {
    final storage = FirebaseStorage.instance;

    for (int i = 0; i < selectedImages.length; i++) {
      var image = selectedImages[i];
      final Reference storageRef = storage
          .ref()
          .child('questions/${widget.id}/$questionId/${image['name']}.jpg');

      storageRef.putFile(image['photo'] as File);
    }

    // Clear the selected images after uploading
    setState(() {
      selectedImages.clear();
    });

    // Navigate back to the previous screen or perform other actions
    Navigator.pop(context);
  }
}
