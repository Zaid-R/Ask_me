import 'package:ask_me2/loacalData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

class AnswerList extends StatelessWidget {
  const AnswerList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('answers').snapshots(),
        builder: (context, answers) {
          if (!answers.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('questions')
                  .doc(categoryId)
                  .collection('questions')
                  .snapshots(),
              builder: (context, questions) {
                if (!questions.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                    questions.data!.docs
                        .where((e) =>
                            e['answerId'] != null &&
                            answers.data!.docs
                                    .firstWhere((element) =>
                                        element.id == e['answerId'])
                                    .data()['expertId'] ==
                                readID())
                        .toList();

                return docs.isEmpty?buildEmptyMessage('لا يوجد لديك إجابات'): ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> question = docs[index].data();
                      return buildQuestionTitleCard(
                          question, context, docs, index);
                    });
              });
        });
  }
}
