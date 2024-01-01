import 'package:flutter/material.dart';

import '../../widgets/all_questions_stream.dart';

class MyQuestions extends StatelessWidget {
  const MyQuestions({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: AllQuestionsStream(isUser: true,),
      ),
    );
  }
}
