import 'package:ask_me2/local_data.dart';
import 'package:ask_me2/models/admin_provider.dart';
import 'package:ask_me2/models/menu_item.dart';
import 'package:ask_me2/pages/auth_page.dart';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatefulWidget {
  final List<MenuItem> listOfPages;
  const MyDrawer({
    super.key,
    required this.listOfPages,
  });

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  List<MenuItem> convertMapToList(Map<int, MenuItem> map) {
    List<MenuItem> x = [];
    map.forEach((index, item) => x.add(MenuItem(
        title: item.title, icon: item.icon, child: item.child, index: index)));
    return x;
  }

  List<Widget> pages = [];
  @override
  void initState() {
    pages = convertMapToList(widget.listOfPages.asMap())
        .map((item) => buildMenuItem(item))
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int selectedPageId =
        context.select<AdminProvider, int>((provider) => provider.drawerId);
    return SafeArea(
      child:  buildOfflineWidget(
        isOfflineWidgetWithScaffold: true,
        onlineWidget: Scaffold(
          appBar: AppBar(
            backgroundColor: themeColor,
            title: Text(widget.listOfPages[selectedPageId].title),
          ),
          body: widget.listOfPages[selectedPageId].child,
          drawer: Drawer(
            child: Column(
              children: [
                buildDrawerHeader(),
                Container(
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: SingleChildScrollView(
                    child: Column(children: [
                      ...pages,
                      buildMenuItemShape(() {
                        removeData();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AuthPage(),
                            ));
                      },
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                size: 30,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                'تسجيل خروج',
                                style: arabicFontStyle,
                              )
                            ],
                          ))
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle arabicFontStyle =
      GoogleFonts.almarai(fontWeight: FontWeight.w400, fontSize: 20);

  Container buildMenuItemShape(Function()? onTap, Widget child) {
    return Container(
        decoration: const BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20))),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10.0),
        child: InkWell(onTap: onTap, child: child));
  }

  Widget buildMenuItem(MenuItem item) {
    return buildMenuItemShape(() {
      context.read<AdminProvider>().setSelectedDrawerId(item.index!);
      Navigator.pop(context);
    },
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 30,
              color: Colors.black,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              item.title,
              style: arabicFontStyle,
            )
          ],
        ));
  }

  Container buildDrawerHeader(){
    
    return Container(
      color: themeColor,
      width: double.infinity,
      height: 200,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 20.0),
      child: 
          Text(
            readName(),
            style: GoogleFonts.markaziText(fontWeight: FontWeight.w400, fontSize: 30),
          ),
    );
  }
}
