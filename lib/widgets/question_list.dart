// ignore_for_file: use_build_context_synchronously
import 'package:ask_me2/local_data.dart';
import 'package:ask_me2/widgets/all_questions_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils.dart';

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
    return readID() == adminId
        ?const AllQuestionsStream(isUser: false) 
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('questions')
                .doc(widget.categoryId ?? expertCategory)
                .collection('questions')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                  snapshot.data!.docs.where((question) {
                bool isAnswered = question['answerId'] != null;
                bool isReported = question['reportId'] != null;
                bool expertCondition = !isAnswered && !isReported;

                bool userCondition =
                    !isReported && !question['isHidden'] && isAnswered;
                
                return readID() != null ? expertCondition : userCondition;
              }).toList();

              return docs.isEmpty
                  ? buildEmptyMessage(readID() != null
                      ? 'لا يوجد أسئلة بحاجة إلى إجابة'
                      : 'لم تتم إجابة أي سؤال حتى الآن')
                  : ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> question = docs[index].data();
                        return buildQuestionTitleCard(
                            title: question['title'],
                            context: context,
                            questionId: docs[index].id,
                            color: readEmail() != null
                                ? null
                                : question['isHidden']
                                    ? hiddenQuestionColor
                                    : null,
                                    catId:widget.categoryId ?? expertCategory );
                      },
                    );
            });
  }
}
