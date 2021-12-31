import 'package:rupiassignment1/utils/constants.dart';

class User{
  String name;
  String email;
  String password;
  String? imageURL;

  User({required this.name,required this.email,required this.password,required this.imageURL});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['user']['email'],
      password: json['user']['password'],
      name: json['user']['name'],
      imageURL: json['user']['imageURL'] != null ? json['user']['imageURL'] : null,
    );
  }
}