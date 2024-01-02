import 'package:flutter/material.dart';

import '../../utils.dart';
import '../../widgets/all_questions_stream.dart';

class MyQuestions extends StatelessWidget {
  const MyQuestions({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: buildOfflineWidget(
            onlineWidget: AllQuestionsStream(
          isUser: true,
        )),
      ),
    );
  }
}
