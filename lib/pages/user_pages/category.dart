// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ask_me2/local_data.dart';
import 'package:ask_me2/widgets/question_list.dart';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_provider.dart';
import '../expert_pages/detailed_question.dart';
import 'question_form.dart';

class Category extends StatefulWidget {
  final String id;
  final String title;

  const Category({
    super.key,
    required this.id,
    required this.title,
  });

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: buildOfflineWidget(
          isOfflineWidgetWithScaffold: true,
          onlineWidget: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
            ),
        
          ),
          body: QuestionList(categoryId: widget.id),
          floatingActionButton: readEmail() == null
              ? null
              : Consumer<UserProvider>(builder: (_, provider, __) {
                  return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(readEmail())
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
        
                        final dates =
                            (userSnapshot.data!.get('askedQuestions') as List)
                                .map((e) => e as String)
                                .toList();
                        if (dates.length == 3) {
                          provider.setDates(dates);
        
                          dates.forEach((date) {
                            if (DateTime.now()
                                    .difference(DateTime.parse(date))
                                    .inHours >=
                                24) {
                              provider.removeDate(date);
                            }
                          });
        
                          if (provider.dates.length < dates.length) {
                            updateUser(provider.dates);
                          }
                        }
                        bool isLimitExceeded = dates.length == 3;
                        return FloatingActionButton(
                          onPressed: () {
                            if (isLimitExceeded) {
                              showMyDialog(
                                  'لقد قمت بإرسال ثلاثة أسئلة في هذا اليوم وهو الحد الأقصى',
                                  context);
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => QuestionFormPage(
                                          categoryId: widget.id,
                                        )));
                          },
                          backgroundColor:
                              isLimitExceeded ? Colors.grey : themeColor,
                          child: Icon(
                            isLimitExceeded ? Icons.timer : Icons.add,
                            color: isLimitExceeded ? Colors.black : null,
                          ),
                        );
                      });
                }),
        ),
      ),
    );
  }

  void updateUser(List<String> dates) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(readEmail())
        .update({'askedQuestions': dates});
  }
}
