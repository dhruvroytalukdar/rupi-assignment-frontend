import 'package:flutter/material.dart';

class TokenProvider with ChangeNotifier{
  String? _accessToken;
  String? _refreshToken;

  String? get getAccess => _accessToken;
  String? get getRefresh => _refreshToken;

  void storeTokens(String? refresh,String? access){
    _accessToken = access;
    _refreshToken = refresh!;
    notifyListeners();
  }

  void updateAcess(String? access){
    _accessToken = access;
    notifyListeners();
  }

  void deleteToken(){
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }
}