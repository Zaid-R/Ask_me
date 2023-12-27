import 'package:ask_me2/loacalData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

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
                            e['reportId'] != null &&
                            reports.data!.docs
                                    .firstWhere((element) =>
                                        element.id == e['reportId'])
                                    .data()['expertId'] ==
                                readID())
                        .toList();

                return docs.isEmpty?buildEmptyMessage('لم تقم بالإبلاغ عن أي سؤال'): ListView.builder(
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