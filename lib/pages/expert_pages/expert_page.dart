import '../../models/menu_item.dart';
import '../../utils/my_drawer.dart';
import '../../pages/expert_pages/answers.dart';
import '../../widgets/question_list.dart';
import '../../pages/expert_pages/reports.dart';
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
