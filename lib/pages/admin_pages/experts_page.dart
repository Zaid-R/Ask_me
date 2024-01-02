// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:ask_me2/models/admin_provider.dart';
import 'package:ask_me2/pages/admin_pages/expert_details.dart';
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
    tabController = TabController(length: 2, vsync: this,); // Number of tabs
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
          backgroundColor: Colors.white,
          title: TabBar(
            indicatorColor: themeColor,
            controller: tabController,
            tabs: const [
              Tab(text: 'الخبراء الجدد',),
              Tab(text: 'الخبراء المسجلين'),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: const [
            NewComerList(), // Your first page widget
            VerifiedList(), // Your second page widget
          ],
        ));
  }
}

class NewComerList extends StatelessWidget {
  const NewComerList({super.key});
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

        return experts.isEmpty
            ? buildEmptyMessage('لا يوجد خبراء جدد')
            : ListView.builder(
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
                                  await _getSpecialization(expert.id[0]);
                              context.read<AdminProvider>().setIsLoading(false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExpertDetailsPage(
                                      specialization: specialization,
                                      isVerified: false,
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
}

Future<String> _getSpecialization(String specId) async {
  return (await FirebaseFirestore.instance
          .collection('specializations')
          .doc(specId)
          .get())
      .data()!['name'];
}

class VerifiedList extends StatelessWidget {
  const VerifiedList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          textAlign: TextAlign.right,
          // controller: _searchController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'ابحث باستخدام معرف المستخدم',
          ),
          onChanged: context.read<AdminProvider>().setSearchQuery,
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
              // Check if the search query is empty or if the expert ID contains the search query
              return Consumer<AdminProvider>(
                builder: (_, provider, __) {
                  if (provider.searchQuery.isEmpty ||
                      expert.id.contains(provider.searchQuery)) {
                    Map<String, dynamic> data = expert.data();
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
                          String specialization =
                              await _getSpecialization(expert.id[0]);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExpertDetailsPage(
                                    specialization: specialization,
                                    isVerified: true,
                                    expertId: expert.id)),
                          );
                        },
                      ),
                    );
                  } else {
                    return buildEmptyMessage(
                        'لا يوجد خبير بهذا المعرف'); // Skip if it doesn't match the search
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
