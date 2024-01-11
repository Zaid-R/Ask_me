class User{
  late List<String> askedQuestions;
  late String birthDate;
  late String firstName;
  late String lastName;
  late String password;
  late String email;
  late String phoneNumber;
  late bool isSuspended;

  User.fromJson(Map<String,dynamic> json){
    askedQuestions = json['askedQuestions'];
    birthDate = json['birthDate'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    password = json['password'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    isSuspended = json['isSuspended'];
  }
}