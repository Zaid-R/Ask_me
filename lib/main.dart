import 'dart:ui';
import 'package:ask_me2/firebase_options.dart';
import 'package:ask_me2/models/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/auth_page.dart';

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
  await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
  runApp(const MyApp());

  // runApp(FutureBuilder(
  //     future: Firebase.initializeApp(
  //       options: DefaultFirebaseOptions.currentPlatform,
  //     ),
  //     builder: (_, snapshot) {
  //       return snapshot.hasData
  //           ? const MyApp()
  //           : const MaterialApp(
  //               debugShowCheckedModeBanner: false,
  //               home: Scaffold(
  //                 body: Center(
  //                   child: CircularProgressIndicator(),
  //                 ),
  //               ),
  //             );
  //     }));
  /*
    }
    catch(e){
      print('Motherfucking error is : ${e.toString()}');
    }
    */
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Auth(),
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
        home: const AuthPage(),
      ),
    );
  }
}
