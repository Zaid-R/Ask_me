import 'package:ask_me2/models/question.dart';
import 'package:ask_me2/utils/local_data.dart';
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

                List<String> answerIds = answers.data!.docs
                    .where((answer) => answer.get('expertId') == readID())
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
