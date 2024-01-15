import '../../models/menu_item.dart';
import '../../utils/my_drawer.dart';
import '../../pages/user_pages/categories.dart';
import 'package:flutter/material.dart';

import '../../widgets/all_questions_stream.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyDrawer(
      listOfPages: [
        MenuItem(
            title: 'الرئيسية', icon: Icons.category, child: CategoriesPage()),
        MenuItem(
            title: 'أسئلتي', icon: Icons.question_answer, child: const AllQuestionsStream(isUser: true,)),
      ],
    );
  }
}
