import 'package:ask_me2/models/menu_item.dart';
import 'package:ask_me2/my_drawer.dart';
import 'package:ask_me2/pages/expert_pages/answers.dart';
import 'package:ask_me2/pages/questions.dart';
import 'package:ask_me2/pages/expert_pages/reports.dart';
import 'package:flutter/material.dart';

class ExpertPage extends StatelessWidget {
  const ExpertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyDrawer(
      listOfPages: [
        MenuItem(
            title: 'الأسئلة',
            icon: Icons.question_answer_outlined,
            child:  const QuestionList()),
        MenuItem(
            title: 'إجاباتي',
            icon: Icons.lightbulb_outlined,
            child: const AnswerList()),
        MenuItem(
            title: 'بلاغاتي',
            icon: Icons.report_gmailerrorred,
            child: const ReprotList())
      ],
    );
  }
}
