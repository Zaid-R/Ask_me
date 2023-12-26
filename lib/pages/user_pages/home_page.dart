import 'package:ask_me2/models/menu_item.dart';
import 'package:ask_me2/my_drawer.dart';
import 'package:ask_me2/pages/user_pages/categories.dart';
import 'package:ask_me2/pages/user_pages/profile.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyDrawer(
      listOfPages: [
        MenuItem(
            title: 'الأنواع', icon: Icons.category, child: CategoriesPage()),
        MenuItem(
            title: 'حسابي', icon: Icons.person, child: const ProfilePage()),
      ],
    );
  }
}
