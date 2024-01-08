// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:ask_me2/providers/admin_provider.dart';
import 'package:ask_me2/pages/admin_pages/expert_details.dart';
import 'package:ask_me2/utils/tools.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../utils/transition.dart';

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
    tabController = TabController(
      length: 2,
      vsync: this,
    ); // Number of tabs
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
              Tab(
                text: 'الخبراء الجدد',
              ),
              Tab(text: 'الخبراء المسجلين'),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: const [
            _NewComerList(), // Your first page widget
            _VerifiedList(), // Your second page widget
          ],
        ));
  }
}

class _NewComerList extends StatelessWidget {
  const _NewComerList({super.key});
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
                                CustomPageRoute(
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

class _VerifiedList extends StatelessWidget {
  const _VerifiedList({super.key});

  @override
  Widget build(BuildContext context) {
    //you don't have to use buildOfflineWidget() here since you reach this page from MyDrawer where buildOfflineWidget() is used
    return SafeArea(
      child: Scaffold(
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
              return circularIndicator;
            }

            return Consumer<AdminProvider>(
              builder: (_, provider, __) {
                final experts = snapshot.data!.docs
                    .where((element) =>
                        provider.searchQuery.isEmpty ||
                        element.id.contains(provider.searchQuery))
                    .toList();
                return experts.isEmpty
                    ? buildEmptyMessage('لا يوجد خبير بهذا المعرف')
                    : ListView.builder(
                        itemCount: experts.length,
                        itemBuilder: (context, index) {
                          final expert = experts[index];
                          // Check if the search query is empty or if the expert ID contains the search query

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
                                  CustomPageRoute(
                                      //TODO: you can pass expert as a stream instead of isVerified and expertId, and shortcuting the code inside  ExpertDetailsPage
                                      builder: (context) => ExpertDetailsPage(
                                          specialization: specialization,
                                          isVerified: true,
                                          expertId: expert.id)),
                                );
                              },
                            ),
                          );
                        },
                      );
              },
            );
          },
        ),
      ),
    );
  }
}
