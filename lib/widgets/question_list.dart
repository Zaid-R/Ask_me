// ignore_for_file: use_build_context_synchronously
import '../models/question.dart';
import '../utils/local_data.dart';
import '../widgets/all_questions_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/admin.dart';
import '../utils/tools.dart';

class QuestionList extends StatefulWidget {
  final String? categoryId;
  const QuestionList({
    super.key,
    this.categoryId,
  });

  @override
  State<QuestionList> createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  @override
  Widget build(BuildContext context) {
    return readID() == Admin.id
        ? const AllQuestionsStream(isUser: false)
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('questions')
                .doc(widget.categoryId ?? readID()![0])
                .collection('questions')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularIndicator;
              }

              List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                  snapshot.data!.docs.where((doc) {
                final question = Question.fromJson(doc.data(),doc.id);
                bool expertCondition = !question.hasAnswer && !question.hasReport;

                bool userCondition =
                    !question.hasReport && !question.isHidden && question.hasAnswer;

                return readID() != null ? expertCondition : userCondition;
              }).toList();

              return docs.isEmpty
                  ? buildEmptyMessage(readID() != null
                      ? 'لا يوجد أسئلة بحاجة إلى إجابة'
                      : 'لم تتم إجابة أي سؤال حتى الآن')
                  : ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final question = Question.fromJson(docs[index].data(),docs[index].id);
                        return buildQuestionTitleCard(
                            title: question.title,
                            context: context,
                            questionId: question.id,
                            color: readEmail() != null
                                ? null
                                : question.isHidden
                                    ? hiddenQuestionColor
                                    : null,
                            catId: widget.categoryId ?? readID()![0]);
                      },
                    );
            },
          );
  }
}
