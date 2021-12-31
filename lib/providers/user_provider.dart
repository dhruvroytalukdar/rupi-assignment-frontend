import 'package:flutter/material.dart';
import 'package:rupiassignment1/models/user_model.dart';

class UserProvider extends ChangeNotifier{
  User? _user;

  User? get getUser => _user;

  void createUser(Map<String, dynamic> data){
    _user = User.fromJson(data);
    notifyListeners();
  }

  void updateImageURL(String? url){
    _user!.imageURL = url;
    notifyListeners();
  }

  void deleteImage(){
    _user!.imageURL = null;
    notifyListeners();
  }

  void deleteUser(){
    _user = null;
    notifyListeners();
  }
}