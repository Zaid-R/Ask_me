import 'package:flutter/material.dart';

class QuestionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const QuestionDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data['title']),
        backgroundColor: const Color.fromRGBO(17, 138, 178, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['title'],
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Date: ${data['date']}',
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Email: ${data['email']}',
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: data['hasImages']
                    ? Column(
                        children: data['body']
                            .toString()
                            .split('*')
                            .map((e) => Text(e))
                            .toList(),
                      )
                    : Text(
                        data['body'],
                        style: const TextStyle(fontSize: 16.0),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
