import 'dart:ui';
import 'package:ask_me2/firebase_options.dart';
import 'package:ask_me2/loacalData.dart';
import 'package:ask_me2/models/admin_provider.dart';
import 'package:ask_me2/models/auth.dart';
import 'package:ask_me2/pages/admin_pages/admin_page.dart';
import 'package:ask_me2/pages/auth_page.dart';
import 'package:ask_me2/pages/user_pages/categories.dart';
import 'package:ask_me2/pages/user_pages/question_form.dart';
import 'package:ask_me2/test_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    GetStorage.init(),
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    )
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(create: (_) => Auth()),
        ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider())
      ],
      child: MaterialApp(
        //to hide scroll bar of listViews
        scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            titleTextStyle: TextStyle(fontSize: 22, color: Colors.white),
          ),
          useMaterial3: true,
        ),
        home: TestPage()
        // readEmail() != null
        //     ? CategoriesPage()
        //     : readID() == '0000'
        //         ? const AdminPage()
        //         : readID() != null
        //             ? const TestPage(title: 'Expert Page Test')
        //             : CategoriesPage(),
      ),
    );
  }
}
