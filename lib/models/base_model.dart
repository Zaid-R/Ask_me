class _Base {
  late String body;
  late String date;
  late String expertId;
  late String questionId;

  _Base.fromJson(Map<String, dynamic> json) {
    body = json['body'];
    date = json['date'];
    expertId = json['expertId'];
    questionId = json['questionId'];
  }
}

class Answer extends _Base {
  Answer.fromJson(super.json) : super.fromJson();
}

class Report extends _Base {
  Report.fromJson(super.json) : super.fromJson();
}
