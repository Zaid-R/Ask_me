import 'package:get_storage/get_storage.dart';

  final _box = GetStorage();
  String? readEmail()=> _box.read('Email');
  String? readID()=> _box.read('ID');

  void writeEmial(String email)=> _box.write('Email', email);
  void writeID(String id)=> _box.write('ID', id);
 
  void removeData(){ 
    _box.remove('ID');
    _box.remove('Email');
  }