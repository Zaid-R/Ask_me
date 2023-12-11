import 'package:get_storage/get_storage.dart';

  final _box = GetStorage();
  String? readEmail()=> _box.read('Email');
  String? readID()=> _box.read('ID');
  ///0=> user
  ///1=> expert
  ///2=> admin
  int? readUserType()=> _box.read('UserType');
  bool? readIsLogedin()=> _box.read('Login');

  void writeEmial(String email)=> _box.write('Email', email);
  void writeID(String id)=> _box.write('ID', id);
  // void writeUserType(int userType)=>_box.write('UserType', userType);
  // void writeIsLogedin(bool isLogedin)=>_box.write('Login', isLogedin);

  //
  void removeData(){ 
    _box.remove('ID');
    _box.remove('Email');
    // _box.remove('UserType');
  }