import 'package:ask_me2/models/admin_provider.dart';
import 'package:ask_me2/pages/admin_pages/expert_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ExpertListPage extends StatefulWidget {
  @override
  State<ExpertListPage> createState() => _ExpertListPageState();
}

class _ExpertListPageState extends State<ExpertListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by Expert ID',
          ),
          // onChanged:(value)=> setState(() {
          //   _searchController.text = value;
          // }),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('experts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child:  CircularProgressIndicator());
          }
      
          var experts = snapshot.data!.docs;
      
          return ListView.builder(
            itemCount: experts.length,
            itemBuilder: (context, index) {
              var expert = experts[index];
              if (expert.id.contains(_searchController.text)) {
                var data =expert.data();
                return ListTile(
                  title: Text('${data['first name']} ${data['last name']}'),
                  onTap: () {
                    context.read<AdminProvider>().setVerificationValue(int.parse(data['verification'].toString()));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ExpertDetailsPage(expertId: expert.id,),
                      ),
                    );
                  },
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

  bool _matchesSearch(String id) {
    String searchTerm = _searchController.text;
    return id.contains(searchTerm);
  }
}
