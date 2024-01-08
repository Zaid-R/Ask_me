// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ask_me2/pages/admin_pages/users_page.dart';
import 'package:flutter/material.dart';

import 'package:ask_me2/models/menu_item.dart';
import 'package:ask_me2/utils/my_drawer.dart';
import 'package:ask_me2/pages/admin_pages/experts_page.dart';

import '../../widgets/all_questions_stream.dart';
import '../../widgets/question_list.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({
    super.key,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return MyDrawer(listOfPages: [
      MenuItem(
        title: 'الخبراء',
        icon: Icons.person_pin,
        child: ExpertListPage(),
      ),
      MenuItem(
          title: 'الأسئلة',
          icon: Icons.question_answer_outlined,
          child: const QuestionList()),
      MenuItem(
          title: 'البلاغات',
          icon: Icons.report_outlined,
          child: const AllQuestionsStream(
            isUser: false,
            isReport: true,
          )),
      MenuItem(
        title: 'المستخدمين',
        icon: Icons.person,
        child: const UserList(),
      )
    ]);
  }
}
