class Admin {
  static const String id = '0000';
  late String name;
  late String password;

  Admin.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    password = json['password'];
  }
}