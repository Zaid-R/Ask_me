// final String pdfUrl;
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:ask_me2/models/admin_provider.dart';
import 'package:ask_me2/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:provider/provider.dart';

CollectionReference<Map<String, dynamic>> _allExpertsCollection =
    FirebaseFirestore.instance.collection('experts');
TextStyle _infoStyle =
    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

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
          backgroundColor: themeColor,
          centerTitle: true,
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
                      '${data['first name']} ${data['last name']} :الاسم',
                      style: _infoStyle,
                    ),
                    Text(
                      'التخصص: $specialization',
                      style: _infoStyle,
                    ),
                    Text('${data['email']} :الايميل', style: _infoStyle),
                    Text('${data['phoneNumber']} :رقم الهاتف',
                        style: _infoStyle),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Colors.indigoAccent[400])),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
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
                                  style: buildButtonStyle(data['isSuspended']),
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
                                    await deleteNewComer();
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
                                  await sendEmail(
                                    data['email'],
                                    'Ask Me تم قبولك كخبير في تطبيق',
                                    '''
            Ask Me تم قبولك كخبير في تطبيق
             $newId معرف المستخدم الخاص بك هو 
             ______________
             مدير البرنامج صهيب أبو قرع
                                  ''',
                                  );
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

  Future<String?> _moveDegree() async {
    // Construct paths for the old and new locations
    String newPath = 'degrees/verified/$expertId.pdf';

    try {
      // Get the file reference from the old location
      Reference oldReference = getOldReference();

      // Download the file to a temporary local file
      File tempFile = File('${Directory.systemTemp.path}/$expertId.pdf');
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
    //delete from new comers

    await deleteNewComer();

    //add to verified collection
    CollectionReference<Map<String, dynamic>> verifiedCollection =
        _allExpertsCollection.doc('verified').collection('experts');
    String? lastIdInTheField = (await verifiedCollection.get())
        .docs
        .map((doc) => doc.id)
        .where((id) => id.startsWith(expertId[0]))
        .lastOrNull;

    var newId = lastIdInTheField == null
        ? '${expertId[0]}000'
        : (int.parse(lastIdInTheField) + 1).toString();

    data['degree url'] = (await _moveDegree())!;

    verifiedCollection.doc(newId).set(data);
    return newId;
  }

  Future<void> deleteNewComer() async {
    await Future.wait([
      _allExpertsCollection
          .doc('new comers')
          .collection('experts')
          .doc(expertId)
          .delete(),
      getOldReference().delete(),
    ]);
  }

  Future<void> sendEmail(String to, String subject, String text) async {
    final smtpServer = gmail('srrz0315@gmail.com', 'fpvopqdmvrbxiifd');

    // Create the email message
    final message = Message()
      ..from = const Address('srrz0315@gmail.com', 'Sohaib Abo Garae')
      ..recipients.add(to)
      ..subject = subject
      ..text = text;

    try {
      // Send the email
      final sendReport = await send(message, smtpServer);

      print('Message sent: ${sendReport.val('sent')}');
      print('Message failed: ${sendReport.val('failed')}');
    } catch (e) {
      print('Error sending email: $e');
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Degree PDF'),
      ),
      body: FutureBuilder(
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
            print('error : ' + snapshot.error.toString());
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
        },
      ),
    );
  }
}
