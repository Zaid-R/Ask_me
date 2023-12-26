// ignore_for_file: use_build_context_synchronously

import 'package:ask_me2/models/admin_provider.dart';
import 'package:ask_me2/pages/admin_pages/expert_details_page.dart';
import 'package:ask_me2/pages/admin_pages/new_comer.dart';
import 'package:ask_me2/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ExpertListPage extends StatefulWidget {
  @override
  State<ExpertListPage> createState() => _ExpertListPageState();
}

class _ExpertListPageState extends State<ExpertListPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this); // Number of tabs
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TabBar(
            indicatorColor: themeColor,
            controller: tabController,
            tabs: const [
              Tab(text: 'الخبراء الجدد'),
              Tab(text: 'الخبراء المسجلين'),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            NewComers(), // Your first page widget
            Verified(), // Your second page widget
          ],
        ));
  }
}

class NewComers extends StatelessWidget {
  NewComers({super.key});
  @override
  Widget build(BuildContext context) {
    bool isLoading =
        context.select<AdminProvider, bool>((provider) => provider.isLoading);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('experts')
          .doc('new comers')
          .collection('experts')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var experts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: experts.length,
          itemBuilder: (context, index) {
            var expert = experts[index];
            var data = expert.data();
            return Card(
              color: Colors.indigo[200],
              child: ListTile(
                title: Text(
                  '${data['first name']} ${data['last name']}',
                  textAlign: TextAlign.right,
                ),
                onTap: isLoading
                    ? null
                    : () async {
                        context.read<AdminProvider>().setIsLoading(true);
                        String specialization =
                            await getSpecialization(expert.id[0]);
                        context.read<AdminProvider>().setIsLoading(false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewComer(
                                specialization: specialization,
                                data: data,
                                expertId: expert.id),
                          ),
                        );
                      },
              ),
            );
          },
        );
      },
    );
  }

  Future<String> getSpecialization(String specId) async {
    return (await FirebaseFirestore.instance
            .collection('specializations')
            .doc(specId)
            .get())
        .data()!['name'];
  }
}

class Verified extends StatelessWidget {
  Verified({super.key});
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          textAlign: TextAlign.right,
          controller: _searchController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'ابحث باستخدام معرف المستخدم',
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('experts')
            .doc('verified')
            .collection('experts')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var experts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: experts.length,
            itemBuilder: (context, index) {
              var expert = experts[index];
              if (expert.id.contains(_searchController.text)) {
                var data = expert.data();
                return Card(
                  color: Colors.green[200],
                  child: ListTile(
                    title: Text(
                      '${data['first name']} ${data['last name']}',
                      textAlign: TextAlign.right,
                    ),
                    onTap: () {
                      context.read<AdminProvider>().setVerificationValue(
                          int.parse(data['verification'].toString()));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpertDetailsPage(
                            expertId: expert.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Container(); // Skip if it doesn't match the search
              }
            },
          );
        },
      ),
    );
  }
}
