// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:flutter/material.dart';

// class QuestionService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Stream controller for questions
//   final BehaviorSubject<List<QuerySnapshot>> _questionsController =
//       BehaviorSubject<List<QuerySnapshot>>();

//   // Combine streams from different collections
//   // Stream<List<QuerySnapshot>> get questionsStream =>
//   //   Rx.combineLatest<List<QuerySnapshot>, List<QuerySnapshot>>(
//   //     [
//   //       _getQuestionsStream('category1'),
//   //       _getQuestionsStream('category2'),
//   //     ],
//   //     (List<QuerySnapshot<Object?>> list) => list,
//   //   );
//   // Function to get questions stream for a specific category
//   Stream<QuerySnapshot> _getQuestionsStream(String category) {
//     return _firestore
//         .collection('questions')
//         .doc(category)
//         .collection('questions')
//         .snapshots();
//   }

//   // Close the stream controller when not needed
//   void dispose() {
//     _questionsController.close();
//   }
// }

// // Usage in your widget
// class YourWidget extends StatelessWidget {
//   final QuestionService _questionService = QuestionService();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<QuerySnapshot>>(
//       stream: _questionService.questionsStream,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         }

//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }

//         // Process and display questions from all categories
//         List<QuerySnapshot> questionSnapshots = snapshot.data ?? [];
//         List<QueryDocumentSnapshot> allQuestions = [];

//         for (var questionSnapshot in questionSnapshots) {
//           allQuestions.addAll(questionSnapshot.docs);
//         }

//         // Now you can use 'allQuestions' to display the questions
//         return ListView.builder(
//           itemCount: allQuestions.length,
//           itemBuilder: (context, index) {
//             var question = allQuestions[index].data();
//             return ListTile(
//               title: Text(question['title']),
//               // Add more widgets to display other question details
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _questionService.dispose();
//     super.dispose();
//   }
// }
