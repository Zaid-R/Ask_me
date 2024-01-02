import 'dart:ui';
import 'package:ask_me2/firebase_options.dart';
import 'package:ask_me2/local_data.dart';
import 'package:ask_me2/models/admin_provider.dart';
import 'package:ask_me2/models/auth.dart';
import 'package:ask_me2/pages/admin_pages/admin_page.dart';
import 'package:ask_me2/pages/expert_pages/expert_page.dart';
import 'package:ask_me2/pages/user_pages/categories.dart';
import 'package:ask_me2/pages/user_pages/user_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'models/user_provider.dart';
import 'utils.dart';

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
    // .then((value) => FirebaseFirestore.instance
    //         .collection('experts')
    //         .doc('verified')
    //         .get()
    //         .then((verified) {
    //       verified.reference.collection('experts').get().then((experts) {
    //         final data = experts.docs[0].data();

    //         verified.reference.collection('experts').doc('3000').set(data);
    //         verified.reference.collection('experts').doc('3000000').delete();
    //       });
    //     }))
    //     .then(
    //   (value) => FirebaseFirestore.instance.collection('questions').get().then(
    //         (value) => value.docs.forEach(
    //           (element) => element.reference
    //               .collection('questions')
    //               .get()
    //               .then((value) => value.docs.forEach((element) {
    //                     element.reference.update({'isHidden': false});
    //                   })),
    //         ),
    //       ),
    // ),
  ]);

  // writeEmial('alhumam.122@gmail.com');
  // writeName('يوسف زغول');

  // writeID(adminId);
  // writeName('صهيب أبو قرع');
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
            home: buildOfflineWidget(
                onlineWidget: readEmail() != null
                    ? const UserPage()
                    : readID() == adminId
                        ? const AdminPage()
                        : readID() != null
                            ? const ExpertPage()
                            : CategoriesPage())));
  }
}
