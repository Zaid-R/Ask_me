import '../../models/question.dart';
import '../../utils/local_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/tools.dart';

class AnswerList extends StatelessWidget {
  const AnswerList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('answers').snapshots(),
        builder: (context, answers) {
          if (!answers.hasData) {
            return circularIndicator;
          }

          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('questions')
                  .doc(expertCategory)
                  .collection('questions')
                  .snapshots(),
              builder: (context, questions) {
                if (!questions.hasData) {
                  return circularIndicator;
                }

                List<String> answerIds = answers.data!.docs
                    .where((answer) => answer.get('expertId').toString() == readID())
                    .map((e) => e.id)
                    .toList();

                List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                    questions.data!.docs
                        .where((doc) {
                          final question = Question.fromJson(doc.data(),doc.id);
                          return question.hasAnswer &&answerIds.contains(question.answerId);
                        })
                        .toList();

                return docs.isEmpty
                    ? buildEmptyMessage('لا يوجد لديك إجابات')
                    : ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final question = Question.fromJson(docs[index].data(),docs[index].id);
                          return buildQuestionTitleCard(
                              title: question.title,
                              context: context,
                              questionId: question.id,
                              color: question.isHidden
                                  ? hiddenQuestionColor
                                  : answerColor);
                        });
              });
        });
  }
}
