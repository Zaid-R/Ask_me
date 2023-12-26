// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:ask_me2/models/menu_item.dart';
import 'package:ask_me2/my_drawer.dart';
import 'package:ask_me2/pages/admin_pages/experts_page.dart';
import 'package:ask_me2/pages/admin_pages/reports_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage( {
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
          title: 'الخبراء', icon: Icons.person_pin, child: ExpertListPage()),
      MenuItem(
          title: 'البلاغات',
          icon: Icons.report_outlined,
          child: const Reportspage()),
    ]);
  }
}