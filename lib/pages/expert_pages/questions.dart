// ignore_for_file: use_build_context_synchronously

import 'package:ask_me2/loacalData.dart';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/video_preview.dart';

String _categoryId = readID()![0];

class QuestionList extends StatefulWidget {
  const QuestionList({super.key});

  @override
  State<QuestionList> createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('questions')
            .doc(_categoryId)
            .collection('questions')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          List docs = snapshot.data!.docs.map((e) => e['isAnswered']).toList();
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> question = docs[index].data();
              return Card(
                color: Colors.blue[100],
                child: ListTile(
                  title: Text(
                    question['title'],
                    textAlign: TextAlign.end,
                  ),
                  onTap: () {
                    // Navigate to the detailed question page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailedQuestionPage(questionId: docs[index].id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        });
  }
}

// Detailed Question Page
class DetailedQuestionPage extends StatelessWidget {
  final String questionId;
  const DetailedQuestionPage({
    super.key,
    required this.questionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: themeColor,
        title: const Text('السؤال'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('questions')
              .doc(_categoryId)
              .collection('questions')
              .doc(questionId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            Map<String, dynamic> question = snapshot.data!.data()!;
            DateTime originalDate = DateTime.parse(question['date']);
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildQuestionDecoration(
                    color: Colors.blue[100]!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          question['title'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (!question['isAnonymous'])
                          FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(question['email'])
                                  .get(),
                              builder: (_, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                return Text(
                                    '${snapshot.data!['first name']} ${snapshot.data!['last name']}');
                              }),
                        Text(
                          "${originalDate.year}/${originalDate.month}/${originalDate.day}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  buildQuestionDecoration(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            question['body'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (question['image url'] != null ||
                              question['video url'] != null)
                            const SizedBox(
                              height: 10,
                            ),
                          if (question['image url'] != null)
                            Image.network(question['image url']),
                          if (question['video url'] != null)
                            VideoPreviewer(url: question['video url']),
                        ],
                      ),
                      color: Colors.grey[300]!),
                  if (!question['isAnswered'])
                    ElevatedButton(
                      onPressed: () {
                        _showAnswerDialog(context);
                      },
                      child: const Text('Answer'),
                    ),
                  // Answer Text
                  if (question['isAnswered'])
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Answer:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('answers')
                                  .doc(question['answerId'])
                                  .get(),
                              builder: (_, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return Text(snapshot.data!.data()!['body']);
                              }),
                        ],
                      ),
                    )
                ],
              ),
            );
          }),
    );
  }

  // Function to show the answer dialog
  void _showAnswerDialog(BuildContext context) {
    TextEditingController answerController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Answer the Question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text Field
              TextField(
                controller: answerController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Your answer...',
                  errorText: answerController.text.trim().isEmpty
                      ? 'Answer can\'t be empty'
                      : null,
                ),
                maxLines: 3,
              ),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (answerController.text.trim().isNotEmpty) {
                    _submitAnswer(context, answerController.text.trim());

                    // Show a snack bar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Question answered successfully'),
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to submit the answer
  void _submitAnswer(BuildContext context, String answerText) async {
    // Document ID for the answer
    String answerDocId = '$_categoryId$questionId';

    // Data for the answer
    Map<String, dynamic> answerData = {
      'questionId': questionId,
      'expertId': readID(),
      'date': DateTime.now().toString().split('.')[0],
      'body': answerText,
    };

    // Add the answer to the "answers" collection
    await FirebaseFirestore.instance
        .collection('answers')
        .doc(answerDocId)
        .set(answerData);

    // Update the "isAnswered" field for the question
    await FirebaseFirestore.instance
        .collection('questions')
        .doc(_categoryId)
        .collection('questions')
        .doc(questionId)
        .update({'isAnswered': true, 'answerId': answerDocId});

    // Hide the dialog
    Navigator.pop(context);
  }

  Material buildQuestionDecoration(
      {required Widget child, required Color color}) {
    return Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(15),
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(15)),
            child: child));
  }
}
