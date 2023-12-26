import 'package:get_storage/get_storage.dart';

  final _box = GetStorage();
  String? readEmail()=> _box.read('Email');
  String? readID()=> _box.read('ID');
  String readName()=> _box.read('name');

  void writeEmial(String email)=> _box.write('Email', email);
  void writeID(String id)=> _box.write('ID', id);
  void writeName(String name)=> _box.write('name', name);
 
  void removeData(){ 
    _box.remove('ID');
    _box.remove('Email');
    _box.remove('name');
  }