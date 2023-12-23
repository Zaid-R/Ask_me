// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ask_me2/loacalData.dart';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'question_details.dart';
import 'question_form.dart';

class Category extends StatefulWidget {
  final String id;
  final String title;
  final Color color;

  const Category({
    super.key,
    required this.id,
    required this.title,
    required this.color,
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
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<QueryDocumentSnapshot> questions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              var question = questions[index].data() as Map<String, dynamic>;

              // Only display questions that are answered
              if (question['isAnswered'] == true) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionDetailsPage(
                          data:question
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
