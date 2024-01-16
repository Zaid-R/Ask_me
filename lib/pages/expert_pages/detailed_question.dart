// ignore_for_file: use_build_context_synchronously

import '../../models/question.dart';
import '../../providers/admin_provider.dart';
import '../../utils/tools.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admin.dart';
import '../../utils/local_data.dart';
import '../../widgets/offlineWidget.dart';
import '../../widgets/video_preview.dart';

class DetailedQuestionPage extends StatelessWidget {
  final String questionId;
  final String? catId;
  final bool isCategoryDisplayed;
  final GlobalKey<FormState> _answerFormKey;
  DetailedQuestionPage(
      {super.key,
      required this.questionId,
      required this.catId,
      this.isCategoryDisplayed = false})
      : _answerFormKey = GlobalKey<FormState>();

  Widget buildButton(
      {required Function()? onPressed,
      required String label,
      required BuildContext context,
      required bool isAnswer,
      ButtonStyle? buttonStyle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        style: buttonStyle ?? buildButtonStyle(condition: isAnswer),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  // Function to submit the answer
  void submitAnswer(BuildContext context, String answerText,
      {bool isEdit = false}) async {
    if (!_answerFormKey.currentState!.validate()) return;
    _answerFormKey.currentState!.save();
    final answersCollection = FirebaseFirestore.instance.collection('answers');
    // Document ID for the answer
    String answerDocId = '${readID()![0]}$questionId';

    if (isEdit) {
      await answersCollection.doc(answerDocId).update({'body': answerText});
    } else {
      // Data for the answer
      Map<String, dynamic> answerData = {
        'questionId': questionId,
        'expertId': readID(),
        'date': DateTime.now().toString().split('.')[0],
        'body': answerText,
      };
      // Add the answer to the "answers" collection
      await answersCollection.doc(answerDocId).set(answerData);

      // Update the "answerId" field for the question
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(readID()![0])
          .collection('questions')
          .doc(questionId)
          .update({'answerId': answerDocId});
    }
  }

  // Function to show the answer dialog
  void showAnswerDialog(BuildContext context,
      {bool isEdit = false, String body = ''}) {
    TextEditingController answerController = TextEditingController(text: body);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isEdit ? 'تعديل الجواب' : 'كتابة الجواب',
            textAlign: TextAlign.end,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text Field
              Form(
                key: _answerFormKey,
                child: TextFormField(
                  controller: answerController,
                  textAlign: TextAlign.end,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value != null && value.trim().isEmpty) {
                      return 'لا يمكن أن يكون الجواب فارغاً';
                    }
                    return null;
                  },
                ),
              ),
              // Submit Button

              Consumer<AdminProvider>(builder: (_, provider, __) {
                return provider.isLoading
                    ? const CircularProgressIndicator()
                    : buildButton(
                        onPressed: () {
                          if (answerController.text.trim().isNotEmpty) {
                            context.read<AdminProvider>().setIsLoading(true);
                            submitAnswer(context, answerController.text.trim(),
                                isEdit: isEdit);
                            context.read<AdminProvider>().setIsLoading(false);
                            Navigator.pop(context);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    isEdit
                                        ? 'تم تعديل الإجابة'
                                        : 'تم إرسال الإجابة',
                                    style:
                                        const TextStyle(color: Colors.black)),
                                backgroundColor: Colors.green[400],
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        label: isEdit ? 'تعديل' : 'إرسال',
                        context: context,
                        isAnswer: true);
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportFromKey = GlobalKey<FormState>();

    final questionStream = FirebaseFirestore.instance
        .collection('questions')
        .doc(catId ?? readID()![0])
        .collection('questions')
        .doc(questionId);

    void submitReport(BuildContext context, String reportText) async {
      if (!reportFromKey.currentState!.validate()) return;
      reportFromKey.currentState!.save();

      // Document ID for the report
      String reportDocId = '${readID()![0]}$questionId';

      // Data for the report
      Map<String, dynamic> reportData = {
        'questionId': questionId,
        'expertId': readID(),
        'date': DateTime.now().toString().split('.')[0],
        'body': reportText,
      };

      // Add the report to the "reports" collection
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportDocId)
          .set(reportData);

      // Update the "isReported" field for the question
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(readID()![0])
          .collection('questions')
          .doc(questionId)
          .update({'reportId': reportDocId});

      // Hide the dialog
      Navigator.pop(context);
    }

    Material buildDecoration(
        {required Widget child,
        required Color color,
        bool isWidthInfinity = true}) {
      return Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(15),
          child: Container(
              width: isWidthInfinity ? double.infinity : null,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(15)),
              child: child));
    }

    Padding buildResponse({required String docId, required bool isAnswer}) {
      return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: buildDecoration(
            color: isAnswer ? Colors.green[100]! : Colors.red[100]!,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(isAnswer ? 'answers' : 'reports')
                    .doc(docId)
                    .snapshots(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final body = snapshot.data!.data()!['body'] as String;

                  return Stack(
                    children: [
                      //the answer
                      Container(
                        alignment: Alignment.topRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isAnswer ? 'الجواب' : 'التقرير',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              body,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.end,
                            )
                          ],
                        ),
                      ),

                      //show edit icon if the one who is see the question is expert
                      if (readID() != Admin.id && readID() != null&&isAnswer)
                        Container(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => showAnswerDialog(context,
                                isEdit: true, body: body),
                          ),
                        )
                    ],
                  );
                }),
          ));
    }

    void showReportDialog(BuildContext context) {
      TextEditingController reportController = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'تقديم تقرير',
              textAlign: TextAlign.end,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: reportFromKey,
                  child: TextFormField(
                    controller: reportController,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value != null && value.trim().isEmpty) {
                        return 'لا يمكن أن يكون التقرير فارغاً';
                      }
                      return null;
                    },
                  ),
                ),
                Consumer<AdminProvider>(builder: (_, provider, __) {
                  return provider.isLoading
                      ? const CircularProgressIndicator()
                      : buildButton(
                          onPressed: () {
                            if (reportFromKey.currentState!.validate()) {
                              context.read<AdminProvider>().setIsLoading(true);
                              submitReport(
                                  context, reportController.text.trim());
                              context.read<AdminProvider>().setIsLoading(false);
                              // Hide the dialog
                              Navigator.pop(context);

                              // Show a snack bar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'تم تقديم التقرير بنجاح',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor: Colors.green[400],
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          label: 'إرسال التقرير',
                          context: context,
                          isAnswer: false);
                }),
              ],
            ),
          );
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          title: const Text('السؤال'),
        ),
        body: OfflineWidget(
          onlineWidget: StreamBuilder(
              stream: questionStream.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final question = Question.fromJson(
                    snapshot.data!.data()!, snapshot.data!.id);
                return SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (readID() == Admin.id)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: buildButton(
                                onPressed: () => questionStream
                                    .update({'isHidden': !question.isHidden}),
                                label:
                                    '${question.isHidden ? 'إظهار' : 'إخفاء'} السؤال',
                                context: context,
                                buttonStyle: buildButtonStyle(
                                  condition: false,
                                  color: !question.isHidden
                                      ? Colors.grey
                                      : Colors.green[400],
                                ),
                                isAnswer: false),
                          ),
                        if (isCategoryDisplayed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Center(
                              child: buildDecoration(
                                  child: FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection('specializations')
                                        .doc(catId)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }
                                      return Text(
                                          snapshot.data!.data()!['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ));
                                    },
                                  ),
                                  color: Colors.indigo[300]!,
                                  isWidthInfinity: false),
                            ),
                          ),
                        buildDecoration(
                          color: Colors.blue[100]!,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                question.title,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              if (!question.isAnonymous)
                                FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(question.email)
                                        .get(),
                                    builder: (_, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }
                                      return Text(
                                          '${snapshot.data!['first name']} ${snapshot.data!['last name']}');
                                    }),
                              Text(
                                "${question.date.year}/${question.date.month}/${question.date.day}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        buildDecoration(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  question.body,
                                  style: const TextStyle(fontSize: 16),
                                  textDirection: TextDirection.rtl,
                                ),
                                if (question.imageUrl.isNotEmpty ||
                                    question.videoUrl.isNotEmpty)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                //TODO: work on loadingBuilder of Image.network()
                                if (question.imageUrl.isNotEmpty)
                                  Image.network(question.imageUrl),
                                if (question.videoUrl.isNotEmpty)
                                  VideoPreviewer(url: question.videoUrl),
                              ],
                            ),
                            color: Colors.grey[300]!),
                        //Answer button and report button
                        if (question.answerId.isEmpty &&
                            question.reportId.isEmpty &&
                            readID() != null &&
                            readID() != Admin.id)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildButton(
                                  onPressed: () => showAnswerDialog(context),
                                  label: 'إجابة',
                                  context: context,
                                  isAnswer: true),
                              buildButton(
                                  onPressed: () => showReportDialog(context),
                                  label: 'تقديم تقرير',
                                  context: context,
                                  isAnswer: false),
                            ],
                          ),

                        // Answer Text
                        if (question.hasAnswer)
                          buildResponse(
                              docId: question.answerId, isAnswer: true),
                        //if isCategoryDisplayed that means this question is invoked from AllQuestionsStream
                        //so the report should be displayed also for the user in the list of his questions
                        if (question.hasReport &&
                            (readID() != null || isCategoryDisplayed))
                          buildResponse(
                              docId: question.reportId, isAnswer: false)
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
