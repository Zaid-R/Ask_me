import 'package:ask_me2/pages/admin_pages/user_details.dart';
import 'package:ask_me2/utils/tools.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/transition.dart';

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshots) {
          if (!snapshots.hasData) {
            return circularIndicator;
          }
          final users = snapshots.data!.docs;

          return users.isEmpty
              ? buildEmptyMessage('لا يوجد مستخدمين')
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    // Check if the search query is empty or if the expert ID contains the search query

                    Map<String, dynamic> data = user.data();
                    return Card(
                      color: data['isSuspended']
                          ? Colors.red[200]
                          : Colors.green[200],
                      child: ListTile(
                        title: Text(
                          '${data['first name']} ${data['last name']}',
                          textAlign: TextAlign.right,
                        ),
                        onTap: () async {
                          Navigator.push(
                            context,
                            CustomPageRoute(
                                builder: (context) => UserDetailsPage(
                                    userStream: user.reference)),
                          );
                        },
                      ),
                    );
                  });
        });
  }
}
