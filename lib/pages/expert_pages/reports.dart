import 'package:ask_me2/models/question.dart';
import 'package:ask_me2/utils/local_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/tools.dart';

class ReprotList extends StatelessWidget {
  const ReprotList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('reports').snapshots(),
        builder: (context, reports) {
          if (!reports.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('questions')
                  .doc(expertCategory)
                  .collection('questions')
                  .snapshots(),
              builder: (context, questions) {
                if (!questions.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<String> reportIds = reports.data!.docs
                    .where((report) => report.get('expertId') == readID())
                    .map((e) => e.id)
                    .toList();

                List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                    questions.data!.docs
                        .where((doc) {
                          final question = Question.fromJson(doc.data(), doc.id);
                          return question.hasReport &&reportIds.contains(question.reportId);
                        })
                        .toList();

                return docs.isEmpty
                    ? buildEmptyMessage('لم تقم بالإبلاغ عن أي سؤال')
                    : ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> question = docs[index].data();
                          return buildQuestionTitleCard(
                              title: question['title'],
                              context: context,
                              questionId: docs[index].id,
                              color:question['isHidden']
                                  ? hiddenQuestionColor
                                  : reportColor);
                        });
              });
        });
  }
}
