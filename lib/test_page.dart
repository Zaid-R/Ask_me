// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  TestPage({
    super.key,
  });

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextField(
          controller: myController,
          onTap: () {
            
          },
          onChanged: (value) {
            myController.addListener();
            print(myController.selection.baseOffset);
            print('controller text : ${myController.text}');
            print('value : $value');
            print('_______________');
            
          },
        ),
      ),
    );
  }
}
