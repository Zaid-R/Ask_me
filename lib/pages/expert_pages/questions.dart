// ignore_for_file: use_build_context_synchronously
import 'package:ask_me2/loacalData.dart';
import 'package:ask_me2/models/admin_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';

class QuestionList extends StatelessWidget {
   QuestionList({super.key});

  final List<String> _ids = List.generate(6, (index) => (index + 1).toString());
  @override
  Widget build(BuildContext context) {
    return readID() == adminId
        ? Consumer<AdminProvider>(
            builder: (_, provider, __) => provider.isEmptyMessage
                ? buildEmptyMessage('لا يوجد أسئلة')
                : Column(
                    children: 
                        _ids.map((id) => StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('questions')
                                .doc(id.toString())
                                .collection('questions')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  docs = snapshot.data!.docs;
                              provider.setAreQuestionsNotEmpty(
                                  provider.areQuestionsNotEmpty ||
                                      docs.isNotEmpty);
                              
                              if (id == 6 && !provider.areQuestionsNotEmpty) {
                                provider.setIsEmptyMessage(true);
                              }
                              
                              return docs.isEmpty
                                  ? Container()
                                  : ListView.builder(
                                      itemCount: docs.length,
                                      itemBuilder: (context, index) {
                                        Map<String, dynamic> question =
                                            docs[index].data();
                                        //TODO: here where you gonna control the color of questionCard for admin
                                        Color? color =
                                            question['answerId'] != null
                                                ? Colors.green[200]
                                                : question['reportId'] != null
                                                    ? Colors.red[200]
                                                    : null;

                                        return buildQuestionTitleCard(
                                            question, context, docs, index,
                                            color: color);
                                      },
                                    );
                            }))
                        .toList(),
                  ))
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('questions')
                .doc(categoryId)
                .collection('questions')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (readID() == adminId) {
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
