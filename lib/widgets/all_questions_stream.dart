import 'package:ask_me2/local_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class AllQuestionsStream extends StatelessWidget {
  bool isUser;
  AllQuestionsStream({
    super.key,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('questions').snapshots(),
        builder: (context, baseCollection) {
          if (!baseCollection.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              children: baseCollection.data!.docs
                  .map((e) => StreamBuilder(
                      stream: e.reference.snapshots(),
                      builder: (context, categorySnapshots) {
                        if (!categorySnapshots.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
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
                                  docs = questionCollections.data!.docs;

                              return Column(
                                children: (isUser?docs.where((element) {
                                  final data = element.data();
                                  return !data['isHidden']&&data['email']==readEmail();
                                }) : docs).map((question) {
                                  Map<String, dynamic> data = question.data();
                                  return data.isEmpty
                                      ? Container()
                                      : buildQuestionTitleCard(
                                          title: data['title'],
                                          context: context,
                                          questionId: question.id,
                                          catId: categorySnapshots.data!.id,
                                          color: data['isHidden']
                                              ? hiddenQuestionColor
                                              : data['answerId'] != null
                                                  ? answerColor
                                                  : data['reportId'] != null
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
