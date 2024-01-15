// ignore_for_file: public_member_api_docs, sort_constructors_first
class NewComerExpert {
  late String degreeUrl;
  late String email;
  late String firstName;
  late String lastName;
  late String phoneNumber;
  late String password;
  late String id;

  NewComerExpert.fromJson(Map<String, dynamic> json,String id) {

    degreeUrl = json['degree url'];
    email = json['email'];
    firstName = json['first name'];
    lastName = json['last name'];
    phoneNumber = json['phoneNumber'];
    password = json['password'];
    // ignore: prefer_initializing_formals
    this.id = id;
  }

}

class VerifiedExpert extends NewComerExpert {
  late bool isSuspended;

  VerifiedExpert.fromJson(Map<String, dynamic> json,String id) : super.fromJson(json,id) {
    isSuspended = json['isSuspended'];
  }
}
