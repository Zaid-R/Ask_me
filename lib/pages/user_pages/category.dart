// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ask_me2/loacalData.dart';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../expert_pages/detailed_question.dart';
import 'question_form.dart';

class Category extends StatefulWidget {
  final String id;
  final String title;

  const Category({
    super.key,
    required this.id,
    required this.title,
  });

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(17, 138, 178, 1),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('questions')
            .doc(widget.id)
            .collection('questions')
            .snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshots.hasError) {
            return Center(child: Text('Error: ${snapshots.error}'));
          }

          var questions = snapshots.data!.docs;

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> question = questions[index].data();

              // Only display questions that are answered
              if (question['answerId'] != null) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedQuestionPage(
                          questionId:questions[index].id,
                          catId:widget.id
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(question['title']),
                    subtitle: Text(question['body'].split('\n')[0]),
                  ),
                );
              } else {
                return Container(); // Don't show unanswered questions
              }
            },
          );
        },
      ),
      floatingActionButton:readEmail()==null?null:  FloatingActionButton(
        onPressed:()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> QuestionFormPage(categoryId:widget.id,))),
        backgroundColor: themeColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
