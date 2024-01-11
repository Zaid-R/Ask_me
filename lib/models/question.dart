class Question{
  late String answerId;
  late String reportId;
  late String body;
  late String imageUrl;
  late String videoUrl;
  late String email;
  late String title;
  late String id;
  late DateTime date;
  late bool isAnonymous;
  late bool isHidden;
  late bool hasAnswer;
  late bool hasReport;

  Question.fromJson(Map<String,dynamic> json,this.id){
    answerId = json['answerId']??'';
    reportId = json['reportId']??'';
    imageUrl = json['image url']??'';
    videoUrl = json['video url']??'';
    body = json['body'];
    date = DateTime.parse( json['date']);
    email = json['email'];
    title = json['title'];
    isAnonymous = json['isAnonymous'];
    isHidden = json['isHidden'];
    hasAnswer = answerId.isNotEmpty;
    hasReport = reportId.isNotEmpty;
  }
}