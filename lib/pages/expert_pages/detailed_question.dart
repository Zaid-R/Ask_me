// ignore_for_file: use_build_context_synchronously

import 'package:ask_me2/models/admin_provider.dart';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../local_data.dart';
import '../../widgets/video_preview.dart';

class DetailedQuestionPage extends StatefulWidget {
  final String questionId;
  final String? catId;
  const DetailedQuestionPage({
    super.key,
    required this.questionId,
    required this.catId,
  });

  @override
  State<DetailedQuestionPage> createState() => _DetailedQuestionPageState();
}

class _DetailedQuestionPageState extends State<DetailedQuestionPage> {
  final _answerFormKey = GlobalKey<FormState>();
  final _reportFromKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('السؤال'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('questions')
              .doc(widget.catId ?? expertCategory)
              .collection('questions')
              .doc(widget.questionId)
              .snapshots(),
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
                    if(readID() == adminId)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: buildButton(
                          onPressed: () => FirebaseFirestore.instance
                              .collection('questions')
                              .doc(widget.catId ?? expertCategory)
                              .collection('questions')
                              .doc(widget.questionId)
                              .update({'isHidden': !data['isHidden']}),
                          label: '${data['isHidden'] ? 'إظهار' : 'إخفاء'} السؤال',
                          context: context,
                          buttonStyle: buildButtonStyle(
                            false,
                            color: !data['isHidden']
                                ? Colors.grey
                                : Colors.green[400],
                          ),
                          isAnswer: false),
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
                        readID() != null&&readID()!=adminId)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildButton(
                              onPressed: () => _showAnswerDialog(context),
                              label: 'إجابة',
                              context: context,
                              isAnswer: true),
                          buildButton(
                              onPressed: () => _showReportDialog(context),
                              label: 'تقديم تقرير',
                              context: context,
                              isAnswer: false),
                        ],
                      ),

                    // Answer Text
                    if (data['answerId'] != null)
                      buildResponse(docId: data['answerId'], isAnswer: true),
                    if (data['reportId'] != null && readID() != null)
                      buildResponse(docId: data['reportId'], isAnswer: false)
                  ],
                ),
              ),
            );
          }),
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
                    return Text(snapshot.data!.data()!['body']);
                  }),
            ],
          ),
          color: isAnswer ? Colors.green[100]! : Colors.red[100]!),
    );
  }

  void _showReportDialog(BuildContext context) {
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
                key: _reportFromKey,
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
                        onPressed: () async {
                          if (_reportFromKey.currentState!.validate()) {
                            context.read<AdminProvider>().setIsLoading(true);
                            await _submitReport(
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

  Future<void> _submitReport(BuildContext context, String reportText) async {
    if (!_reportFromKey.currentState!.validate()) return;
    _reportFromKey.currentState!.save();

    // Document ID for the report
    String reportDocId = '$expertCategory${widget.questionId}';

    // Data for the report
    Map<String, dynamic> reportData = {
      'questionId': widget.questionId,
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
        .doc(widget.questionId)
        .update({'reportId': reportDocId});

    // Hide the dialog
    Navigator.pop(context);
  }

  // Function to show the answer dialog
  void _showAnswerDialog(BuildContext context) {
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
                        onPressed: () async {
                          if (answerController.text.trim().isNotEmpty) {
                            context.read<AdminProvider>().setIsLoading(true);
                            await _submitAnswer(
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

  Widget buildButton(
      {required Function()? onPressed,
      required String label,
      required BuildContext context,
      required bool isAnswer,
      ButtonStyle? buttonStyle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        style: buttonStyle ?? buildButtonStyle(isAnswer),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  // Function to submit the answer
  Future<void> _submitAnswer(BuildContext context, String answerText) async {
    if (!_answerFormKey.currentState!.validate()) return;
    _answerFormKey.currentState!.save();
    // Document ID for the answer
    String answerDocId = '$expertCategory${widget.questionId}';

    // Data for the answer
    Map<String, dynamic> answerData = {
      'questionId': widget.questionId,
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
        .doc(widget.questionId)
        .update({'answerId': answerDocId});
  }

  Material buildDecoration({required Widget child, required Color color}) {
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
