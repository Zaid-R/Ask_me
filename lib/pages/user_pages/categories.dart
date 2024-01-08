import 'package:ask_me2/utils/local_data.dart';
import 'package:ask_me2/pages/auth_page.dart';
import 'package:ask_me2/utils/tools.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/transition.dart';
import '../../widgets/offlineWidget.dart';
import 'category.dart';

class CategoriesPage extends StatelessWidget {
  CategoriesPage({super.key});


  //TODO: move these photos to Firebase
  final List<String> imagesPaths = [
    'assets/religion.jpeg',
    'assets/fixing.jpeg',
    'assets/mechanic.jpeg',
    'assets/health.jpeg',
    'assets/tech.jpeg',
    'assets/social.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
          return SafeArea(
            child: OfflineWidget(
          onlineWidget: Scaffold(
                resizeToAvoidBottomInset: false,
                floatingActionButton: readEmail() == null
                    ? ElevatedButton(
                        style: buildSelectButtonStyle().copyWith(
                          shape: const MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(25)),
                            ),
                          ),
                        ),
                        child: Text(
                          'تسجيل دخول',
                          style: buildSelectButtonTextStyle()
                              .copyWith(color: Colors.black87),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              CustomPageRoute(
                                  builder: (_) => const AuthPage()));
                        },
                      )
                    : Container(),
                appBar: readEmail() == null
                    ? AppBar(
                        title: const Text(
                          'الرئيسية',
                        ),
                      )
                    : null,
                body: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('specializations')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } 
                      final titles = snapshot.data!.docs;
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: titles.length,
                          itemBuilder: (context, index) {
                            final title = titles[index].data()['name'];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to a different page when an item is clicked
                                Navigator.push(
                                  context,
                                  CustomPageRoute(
                                    builder: (context) => Category(
                                      id: titles[index].id,
                                      title: title,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13.0),
                                  border: Border.all(),
                                  color: themeColor.withOpacity(0.3),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(),
                                          image: DecorationImage(
                                              image:
                                                  AssetImage(imagesPaths[index]),
                                              fit: BoxFit.cover),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 5),
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                  },
                ),
              ),
            ),
          );
  }
}
