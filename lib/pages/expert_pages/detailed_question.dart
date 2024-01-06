// ignore_for_file: use_build_context_synchronously

import 'package:ask_me2/providers/admin_provider.dart';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../local_data.dart';
import '../../widgets/video_preview.dart';

class DetailedQuestionPage extends StatelessWidget {
  final String questionId;
  final String? catId;
  final bool isCategoryDisplayed;

  const DetailedQuestionPage(
      {super.key,
      required this.questionId,
      required this.catId,
      this.isCategoryDisplayed = false});

  @override
  Widget build(BuildContext context) {
    final answerFormKey = GlobalKey<FormState>();

    final reportFromKey = GlobalKey<FormState>();

    final stream = FirebaseFirestore.instance
        .collection('questions')
        .doc(catId ?? expertCategory)
        .collection('questions')
        .doc(questionId);

    // Function to submit the answer
    void submitAnswer(BuildContext context, String answerText) async {
      if (!answerFormKey.currentState!.validate()) return;
      answerFormKey.currentState!.save();
      // Document ID for the answer
      String answerDocId = '$expertCategory$questionId';

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
          .doc(expertCategory)
          .collection('questions')
          .doc(questionId)
          .update({'answerId': answerDocId});
    }

    void submitReport(BuildContext context, String reportText) async {
      if (!reportFromKey.currentState!.validate()) return;
      reportFromKey.currentState!.save();

      // Document ID for the report
      String reportDocId = '$expertCategory$questionId';

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
          .doc(expertCategory)
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

    Widget buildButton(
        {required Function()? onPressed,
        required String label,
        required BuildContext context,
        required bool isAnswer,
        ButtonStyle? buttonStyle}) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ElevatedButton(
          style: buttonStyle ?? buildButtonStyle(condition:isAnswer),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      );
    }

    Padding buildResponse({required String docId, required bool isAnswer}) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: buildDecoration(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isAnswer ? 'الجواب' : 'التقرير',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection(isAnswer ? 'answers' : 'reports')
                        .doc(docId)
                        .get(),
                    builder: (_, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Text(snapshot.data!.data()!['body'],textDirection: TextDirection.rtl,);
                    }),
              ],
            ),
            color: isAnswer ? Colors.green[100]! : Colors.red[100]!),
      );
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
                                const SnackBar(
                                  content: Text('تم تقديم التقرير بنجاح'),
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

    // Function to show the answer dialog
    void showAnswerDialog(BuildContext context) {
      TextEditingController answerController = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'كتابة الجواب',
              textAlign: TextAlign.end,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text Field
                Form(
                  key: answerFormKey,
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
                              submitAnswer(
                                  context, answerController.text.trim());
                              context.read<AdminProvider>().setIsLoading(false);
                              Navigator.pop(context);
                              // Show a snack bar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إرسال الإجابة'),
                                ),
                              );
                            }
                          },
                          label: 'إرسال',
                          context: context,
                          isAnswer: true);
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
        body: buildOfflineWidget(
          onlineWidget: StreamBuilder(
              stream: stream.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                Map<String, dynamic> data = snapshot.data!.data()!;
                DateTime originalDate = DateTime.parse(data['date']);
                return SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (readID() == adminId)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: buildButton(
                                onPressed: () => stream
                                    .update({'isHidden': !data['isHidden']}),
                                label:
                                    '${data['isHidden'] ? 'إظهار' : 'إخفاء'} السؤال',
                                context: context,
                                buttonStyle: buildButtonStyle(
                                  condition: false,
                                  color: !data['isHidden']
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
                                data['title'],
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              if (!(data['isAnonymous'] as bool))
                                FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(data['email'])
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
                        buildDecoration(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  data['body'],
                                  style: const TextStyle(fontSize: 16),
                                  textDirection: TextDirection.rtl,
                                ),
                                if (data['image url'] != null ||
                                    data['video url'] != null)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                //TODO: work on loadingBuilder of Image.network()
                                if (data['image url'] != null)
                                  Image.network(data['image url']),
                                if (data['video url'] != null)
                                  VideoPreviewer(url: data['video url']),
                              ],
                            ),
                            color: Colors.grey[300]!),
                        //Answer button and report button
                        if (data['answerId'] == null &&
                            data['reportId'] == null &&
                            readID() != null &&
                            readID() != adminId)
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
                        if (data['answerId'] != null)
                          buildResponse(
                              docId: data['answerId'], isAnswer: true),
                        //if isCategoryDisplayed that means this question is invoked from AllQuestionsStream
                        //so the report should be displayed also for the user in the list of his questions
                        if (data['reportId'] != null &&
                            (readID() != null || isCategoryDisplayed))
                          buildResponse(
                              docId: data['reportId'], isAnswer: false)
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
