// ignore_for_file: use_build_context_synchronously
import 'package:ask_me2/loacalData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';
import 'detailed_question.dart';

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
            .doc(categoryId)
            .collection('questions')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (readID() == '0000') {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                snapshot.data!.docs;
            return docs.isEmpty
                ? buildEmptyMessage('لا يوجد أسئلة')
                : ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> question = docs[index].data();

                      Color? color = question['answerId'] != null
                          ? Colors.green[200]
                          : question['reportId'] != null
                              ? Colors.red[200]
                              : null;

                      return buildQuestionTitleCard(
                          question, context, docs, index,
                          color: color);
                    },
                  );
          }
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot
              .data!.docs
              .where((e) => e['answerId'] == null && e['reportId'] == null)
              .toList();
          return docs.isEmpty
              ? buildEmptyMessage('لا يوجد أسئلة بحاجة إلى إجابة')
              : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> question = docs[index].data();
                    return buildQuestionTitleCard(
                        question, context, docs, index);
                  },
                );
        });
  }
}
