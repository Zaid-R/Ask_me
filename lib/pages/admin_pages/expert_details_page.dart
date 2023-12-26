// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ask_me2/models/admin_provider.dart';
import 'package:ask_me2/utils.dart';

class ExpertDetailsPage extends StatefulWidget {
  final String? expertId;
  const ExpertDetailsPage({
    super.key,
    this.expertId,
  });

  @override
  State<ExpertDetailsPage> createState() => _ExpertDetailsPageState();
}

Map<int, String> map = {
  0: 'Not verified',
  1: 'Enabled',
  2: 'Disabled',
};

class _ExpertDetailsPageState extends State<ExpertDetailsPage> {
  late int groupValue;
  @override
  void initState() {
    super.initState();
    groupValue = context.read<AdminProvider>().verificationValue;
  }
  @override
  Widget build(BuildContext context) {
    int verificationValue = context.select<AdminProvider,int>((p)=>p.verificationValue);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text('Expert Details'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('experts')
            .doc(widget.expertId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularIndicator;
          }

          var expert = snapshot.data!.data() as Map<String, dynamic>;

          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Degree image:'),
                  CachedNetworkImage(
                    imageUrl: expert['degree url'],
                    placeholder: (context, url) => circularIndicator,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  Text('Name: ${expert['first name']} ${expert['last name']}'),
                  Text('ID: ${snapshot.data!.id}'),
                  Text('Email: ${expert['email']}'),
                  Text('Password: ${expert['password']}'),
                  Text('Phone Number: ${expert['phoneNumber']}'),
                  Text('Activation : ${map[verificationValue]}'),
                  ElevatedButton(
                    style: buildSelectButtonStyle(),
                    onPressed: () {
                      _changeVerification(context, snapshot.data!.id);
                    },
                    child: Text(
                      'Change Verification',
                      style: buildSelectButtonTextStyle(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _changeVerification(
      BuildContext context, String expertId) async {
    showDialog(
        context: context,
        builder: (ctx1) => StatefulBuilder(builder: (ctx2, stateFunction) {
              return Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...map.keys.map((key) {
                      return Material(
                        child: RadioListTile(
                          activeColor: Colors.blue,
                          title: Text(map[key]!),
                          value: key,
                          groupValue: groupValue,
                          onChanged: (newId) {
                            stateFunction(()=>groupValue = newId!);
                          },
                        ),
                      );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              context
                                .read<AdminProvider>()
                                .setVerificationValue(groupValue);
                              await FirebaseFirestore.instance
                                  .collection('experts')
                                  .doc(expertId)
                                  .update({
                                'verification': groupValue,
                              });
                              ScaffoldMessenger.of(ctx2)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text('Verification updated successfully!'),
                              ));
                              Navigator.pop(ctx2);
                            },
                            child: const Text('Update')),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(ctx2),
                            child: const Text('Close'))
                      ],
                    )
                  ],
                ),
              );
            }));
  }
}
