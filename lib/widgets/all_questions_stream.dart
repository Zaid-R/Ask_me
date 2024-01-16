import '../models/question.dart';
import '../utils/local_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/tools.dart';

class AllQuestionsStream extends StatelessWidget {
  final bool isUser;
  final bool isReport;
  const AllQuestionsStream({
    super.key,
    required this.isUser,
    this.isReport = false,
  });

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('questions').snapshots(),
        builder: (context, baseCollection) {
          if (!baseCollection.hasData) {
            return circularIndicator;
          }
          return SingleChildScrollView(
            child: Column(
              children: baseCollection.data!.docs
                  .map((e) => StreamBuilder(
                      stream: e.reference.snapshots(),
                      builder: (context, categorySnapshots) {
                        if (!categorySnapshots.hasData) {
                          return circularIndicator;
                        }

                        return StreamBuilder(
                            stream: categorySnapshots.data!.reference
                                .collection('questions')
                                .snapshots(),
                            builder: (context, questionCollections) {
                              if (!questionCollections.hasData) {
                                return circularIndicator;
                              }
                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  docs = questionCollections.data!.docs
                                      .where((doc) {
                                final question =
                                    Question.fromJson(doc.data(),doc.id);
                                if (isUser) {
                                  //question isn't hidden && user is loged in 
                                  return !question.isHidden &&
                                      question.email == readEmail();
                                } else if (isReport) {
                                  // question has reported
                                  return question.reportId.isNotEmpty;
                                }
                                return true;
                              }).toList();

                              return Column(
                                children: docs.map((doc) {
                                  if(doc.data().isEmpty){
                                    return Container();
                                  }
                                  final question = Question.fromJson(doc.data(),doc.id);
                                  return  buildQuestionTitleCard(
                                          isCategoryDisplayed: true,
                                          title: question.title,
                                          context: context,
                                          questionId: question.id,
                                          catId: categorySnapshots.data!.id,
                                          color: question.isHidden
                                              ? hiddenQuestionColor
                                              : question.answerId.isNotEmpty
                                                  ? answerColor
                                                  : question.reportId.isNotEmpty
                                                      ? reportColor
                                                      : null);
                                }).toList(),
                              );
                            });
                      }))
                  .toList(),
            ),
          );
        });
  }
}
