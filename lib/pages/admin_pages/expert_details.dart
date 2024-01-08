// final String pdfUrl;
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:ask_me2/providers/admin_provider.dart';
import 'package:ask_me2/utils/tools.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:provider/provider.dart';

import '../../utils/transition.dart';
import '../../widgets/offlineWidget.dart';

CollectionReference<Map<String, dynamic>> _allExpertsCollection =
    FirebaseFirestore.instance.collection('experts');


class ExpertDetailsPage extends StatelessWidget {
  final String expertId;
  final bool isVerified;
  final String specialization;
  const ExpertDetailsPage({
    super.key,
    required this.specialization,
    required this.expertId,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoading =
        context.select<AdminProvider, bool>((provider) => provider.isLoading);
    String docId = isVerified ? 'verified' : 'new comers';
    return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          title: const Text('بيانات الخبير'),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('experts')
                .doc(docId)
                .collection('experts')
                .doc(expertId)
                .snapshots(),
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
                    ),
                    Text(
                      'التخصص: $specialization',
                      style: infoStyle,
                    ),
                    Text('${data['email']} :الايميل', style: infoStyle),
                    Text('${data['phoneNumber']} :رقم الهاتف',
                        style: infoStyle),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Colors.indigoAccent[400])),
                      onPressed: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            builder: (context) =>
                                PDFViewerPage(pdfUrl: data['degree url']),
                          ),
                        );
                      },
                      child: const Text(
                        'عرض الشهادة',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    if (isVerified)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  style: buildButtonStyle(
                                      condition: data['isSuspended']),
                                  onPressed: () async {
                                    context
                                        .read<AdminProvider>()
                                        .setIsLoading(true);
                                    await FirebaseFirestore.instance
                                        .collection('experts')
                                        .doc(docId)
                                        .collection('experts')
                                        .doc(expertId)
                                        .update({
                                      'isSuspended': !data['isSuspended']
                                    });
                                    context
                                        .read<AdminProvider>()
                                        .setIsLoading(false);
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
                    if (!isVerified)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.red[400])),
                                  onPressed: () async {
                                    context
                                        .read<AdminProvider>()
                                        .setIsLoading(true);
                                    deleteNewComer();
                                    await getOldReference().delete();
                                    context
                                        .read<AdminProvider>()
                                        .setIsLoading(false);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'رفض',
                                    style: TextStyle(color: Colors.white),
                                  )),
                          isLoading
                              ? const CircularProgressIndicator()
                              : buildMyElevatedButton(() async {
                                  context
                                      .read<AdminProvider>()
                                      .setIsLoading(true);
                                  String newId = await moveToVerified(data);
                                  sendEmail(
                                    to: data['email'],
                                    subject: 'Ask Me تم قبولك كخبير في تطبيق',
                                    text: '''
            Ask Me تم قبولك كخبير في تطبيق
             $newId معرف المستخدم الخاص بك هو 
             ______________
             مدير البرنامج صهيب أبو قرع
                                  ''',
                                  );
                                  deleteNewComer();
                                  context
                                      .read<AdminProvider>()
                                      .setIsLoading(false);
                                  Navigator.pop(context);
                                }, 'إرسال ايميل التسجيل'),
                        ],
                      )
                  ]
                      .map((e) => Column(
                            children: e is! Row
                                ? [
                                    e,
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
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
            
            }));
  }

  Reference getOldReference() {
    return FirebaseStorage.instance
        .ref()
        .child('degrees/new comers/$expertId.pdf');
  }

  Future<String?> _moveDegree(String newId) async {
    // Construct paths for the old and new locations
    String newPath = 'degrees/verified/$newId.pdf';

    try {
      // Get the file reference from the old location
      Reference oldReference = getOldReference();

      // Download the file to a temporary local file
      File tempFile = File('${Directory.systemTemp.path}/$newId.pdf');
      await oldReference.writeToFile(tempFile);

      // Delete the file from the old location
      await oldReference.delete();

      // Upload the file to the new location
      return (await FirebaseStorage.instance
              .ref()
              .child(newPath)
              .putFile(tempFile))
          .ref
          .getDownloadURL();
    } catch (e) {
      print('Error authorizing expert: $e');
    }
    return null;
  }

  Future<String> moveToVerified(Map<String, dynamic> data) async {
    //add to verified collection
    CollectionReference<Map<String, dynamic>> verifiedCollection =
        _allExpertsCollection.doc('verified').collection('experts');
    String? lastIdInTheField = (await verifiedCollection.get())
        .docs
        .map((doc) => doc.id)
        .where((id) => id.startsWith(expertId[0]))
        .lastOrNull;

    String newId = lastIdInTheField == null
        ? '${expertId[0]}000'
        : (int.parse(lastIdInTheField) + 1).toString();

    data['degree url'] = (await _moveDegree(newId))!;

    verifiedCollection.doc(newId).set(data);
    return newId;
  }

  void deleteNewComer() async {
    await Future.wait([
      _allExpertsCollection
          .doc('new comers')
          .collection('experts')
          .doc(expertId)
          .delete(),
      getOldReference().delete(),
    ]);
  }
}

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;

  const PDFViewerPage({super.key, required this.pdfUrl});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  Future<PDFDocument> _loadPDF() async {
    return await PDFDocument.fromURL(widget.pdfUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الدرجة العلمية'),
        ),
        body: OfflineWidget(
          onlineWidget: FutureBuilder(
            future: _loadPDF(),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                return PDFViewer(document: snapshot.data!);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
