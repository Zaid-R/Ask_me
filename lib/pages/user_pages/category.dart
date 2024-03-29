// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import '../../utils/local_data.dart';
import '../../pages/auth_page.dart';
import '../../widgets/question_list.dart';
import '../../utils/tools.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../utils/transition.dart';
import '../../widgets/offlineWidget.dart';
import 'question_form.dart';

class Category extends StatelessWidget {
  final String id;
  final String title;

  const Category({
    super.key,
    required this.id,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Stack(
      children: [
        SafeArea(
          child: OfflineWidget(
            //isOfflineWidgetWithScaffold: true,
            onlineWidget: Scaffold(
              appBar: AppBar(
                title: Text(
                  title,
                ),
              ),
              body: QuestionList(categoryId: id),
              floatingActionButton: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(readEmail())
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return FloatingActionButton(
                      onPressed: () async {
                        if (readEmail() == null) {
                          displaySnackBar(context,
                              text: 'يجب أن تقوم بتسجيل الدخول',
                              snackBarColor: Colors.red[400]);

                          userProvider.setIsSnackBarShowing(true);
                          await Future.delayed(const Duration(seconds: 2));
                          userProvider.setIsSnackBarShowing(false);
                          while (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          Navigator.pushReplacement(
                              context,
                              CustomPageRoute(
                                  builder: (_) => const AuthPage()));
                        } else {
                          final dates =
                              (userSnapshot.data!.get('askedQuestions') as List)
                                  .map((e) => e.toString())
                                  .toList();
                          final tempo = <String>[];
                          if (dates.length == 3) {
                            userProvider.setDates(dates);

                            for (final date in userProvider.dateList) {
                              if (DateTime.now()
                                      .difference(DateTime.parse(date))
                                      .inHours >=
                                  24) {
                                tempo.add(date);
                              }
                            }

                            if (tempo.isNotEmpty) {
                              for (final element in tempo) {
                                userProvider.removeDate(element);
                              }
                              updateUser(userProvider.dateList);
                            }
                          }
                          userProvider.setIsLimitExceeded(dates.length == 3);
                          if (userProvider.isLimitExceeded) {
                            showMyDialog(
                                'لقد قمت بإرسال ثلاثة أسئلة في هذا اليوم وهو الحد الأقصى',
                                context);
                            return;
                          }
                          Navigator.push(
                              context,
                              CustomPageRoute(
                                  builder: (_) => QuestionFormPage(
                                        categoryId: id,
                                      )));
                        }
                      },
                      backgroundColor: userProvider.isLimitExceeded
                          ? Colors.grey
                          : themeColor,
                      child: Icon(
                        userProvider.isLimitExceeded ? Icons.timer : Icons.add,
                        color:
                            userProvider.isLimitExceeded ? Colors.black : null,
                      ),
                    );
                  }),
            ),
          ),
        ),
        if (userProvider.isSnackBarShowing)
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
          )
      ],
    );
  }

  void updateUser(List<String> dates) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(readEmail())
        .update({'askedQuestions': dates});
  }
}
