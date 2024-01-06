// ignore_for_file: use_build_context_synchronously

import 'package:ask_me2/providers/user_provider.dart';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDetailsPage extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> userStream;
  const UserDetailsPage({
    super.key,
    required this.userStream,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoading =
        context.select<UserProvider, bool>((provider) => provider.isLoading);
    return Scaffold(
      backgroundColor: Colors.blue[50],
        appBar: AppBar(
          title: const Text('بيانات المستخدم'),
        ),
      body: StreamBuilder(
        stream: userStream.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularIndicator;
          }
          Map<String, dynamic> data = snapshot.data!.data()!;
      
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  ' الاسم: ${data['first name']} ${data['last name']}',
                  style: infoStyle,
                  textDirection: TextDirection.rtl,
                ),
                Text('${data['email']} :الايميل', style: infoStyle),
                Text('${data['phoneNumber']} :رقم الهاتف', style: infoStyle),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style:
                                buildButtonStyle(condition: data['isSuspended']),
                            onPressed: () async {
                              context.read<UserProvider>().setIsLoading(true);
                              await userStream
                                  .update({'isSuspended': !data['isSuspended']});
                              context.read<UserProvider>().setIsLoading(false);
                            },
                            child: Text(
                              data['isSuspended']
                                  ? 'تفعيل الحساب'
                                  : 'تعطيل الحساب',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          ),
                  ],
                ),
              ]
                  .map((e) => Column(
                        children: e is! Row
                            ? [
                                e,
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    thickness: 2,
                                  ),
                                )
                              ]
                            : [e],
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
