import 'dart:ui';
import 'firebase_options.dart';
import 'utils/local_data.dart';
import 'providers/admin_provider.dart';
import 'providers/auth.dart';
import 'pages/admin_pages/admin_page.dart';
import 'pages/expert_pages/expert_page.dart';
import 'pages/user_pages/categories.dart';
import 'pages/user_pages/user_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'models/admin.dart';
import 'providers/user_provider.dart';
import 'utils/tools.dart';
import 'widgets/offlineWidget.dart';

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
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
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
        ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider())
      ],
      child: MaterialApp(
        //to hide scroll bar of listViews
        scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: Colors.grey[350],
              selectionHandleColor: themeColor),
          appBarTheme: const AppBarTheme(
            backgroundColor: themeColor,
            centerTitle: true,
            titleTextStyle: TextStyle(fontSize: 22, color: Colors.white),
          ),
          useMaterial3: true,
        ),
        home: OfflineWidget(
            onlineWidget: readEmail() != null
                ? const UserPage()
                : readID() == Admin.id
                    ? const AdminPage()
                    : readID() != null
                        ? const ExpertPage()
                        : CategoriesPage()),
      ),
    );
  }
}
