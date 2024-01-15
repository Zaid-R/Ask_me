// ignore_for_file: use_build_context_synchronously, must_be_immutable

import '../../models/expert.dart';
import '../../providers/admin_provider.dart';
import '../../pages/admin_pages/expert_details.dart';
import '../../utils/tools.dart';
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
      stream:
          expertsCollection.doc('new comers').collection('experts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final experts = snapshot.data!.docs;

        return experts.isEmpty
            ? buildEmptyMessage('لا يوجد خبراء جدد')
            : ListView.builder(
                itemCount: experts.length,
                itemBuilder: (context, index) {
                  final newComer = NewComerExpert.fromJson(experts[index].data(),experts[index].id);
                  return Card(
                    color: Colors.indigo[200],
                    child: ListTile(
                      title: Text(
                        '${newComer.firstName} ${newComer.lastName}',
                        textAlign: TextAlign.right,
                      ),
                      onTap: isLoading
                          ? null
                          : () async {
                              context.read<AdminProvider>().setIsLoading(true);
                              String specialization =
                                  await _getSpecialization(newComer.id[0]);
                              context.read<AdminProvider>().setIsLoading(false);
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                  builder: (_) => ExpertDetailsPage(
                                      specialization: specialization,
                                      isVerified: false,
                                      expertId: newComer.id),
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
      .data()!['name'] as String;
}

class _VerifiedList extends StatelessWidget {
  const _VerifiedList();

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
          stream: expertsCollection
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
                          final verifiedExpert =
                              VerifiedExpert.fromJson(experts[index].data(),experts[index].id);
                          // Check if the search query is empty or if the expert ID contains the search query

                          return Card(
                            color: verifiedExpert.isSuspended
                                ? Colors.red[200]
                                : Colors.green[200],
                            child: ListTile(
                              title: Text(
                                '${verifiedExpert.firstName} ${verifiedExpert.lastName}',
                                textAlign: TextAlign.right,
                              ),
                              onTap: () async {
                                String specialization =
                                    await _getSpecialization(verifiedExpert.id[0]);
                                Navigator.push(
                                  context,
                                  CustomPageRoute(
                                      builder: (context) => ExpertDetailsPage(
                                          specialization: specialization,
                                          isVerified: true,
                                          expertId: verifiedExpert.id)),
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
