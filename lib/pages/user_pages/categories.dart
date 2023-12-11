import 'package:ask_me2/loacalData.dart';
import 'package:ask_me2/pages/auth_page.dart';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'category.dart';

class CategoriesPage extends StatelessWidget {
  final List<Color> listOfItemsColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.blueAccent,
  ];

  CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth: 170,
        leading: readEmail() == null
            ? ElevatedButton(
                style: buildSelectButtonStyle().copyWith(
                    shape: const MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(25),
                                topRight: Radius.circular(25))))),
                child: Text(
                  'Log in/Sign up',
                  style: buildSelectButtonTextStyle()
                      .copyWith(color: Colors.black87),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AuthPage())),
              )
            : Container(),
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('specializations')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var titles = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: listOfItemsColors.length,
                itemBuilder: (context, index) {
                  var title = titles[index].data()['name'];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to a different page when an item is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Category(
                            id: titles[index].id,
                            title: title,
                            color: listOfItemsColors[index],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: listOfItemsColors[index],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
