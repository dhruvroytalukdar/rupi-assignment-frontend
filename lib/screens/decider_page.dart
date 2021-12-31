import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rupiassignment1/providers/token_provider.dart';
import 'package:rupiassignment1/providers/user_provider.dart';
import 'package:rupiassignment1/screens/home_page.dart';
import 'package:rupiassignment1/screens/login_page.dart';
import 'package:rupiassignment1/utils/constants.dart';
import 'package:provider/provider.dart';

class DeciderPage extends StatelessWidget {
  const DeciderPage({Key? key}) : super(key: key);
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {

    Future<bool> getUserAndToken () async {
      if(await storage.containsKey(key: "token")){
        String? value = await storage.read(key: "token");
        // print("Value ${value}");
        final response = await http.post(Uri.parse("$apiURL/auth/me"),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'token': value!,
            })
        );
        if(response.statusCode == 200){
          // print(jsonDecode(response.body));
          context.read<UserProvider>().createUser(jsonDecode(response.body));
          Map<String,dynamic> data = jsonDecode(response.body);
          context.read<TokenProvider>().storeTokens(value,data["accessToken"]);
          return true;
        }else{
          print("Error here");
        }
      }
      return false;
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: getUserAndToken(),
          builder:(BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return const HomePage();
            }else if(snapshot.hasData && snapshot.data == false){
              return const LoginPage();
            }else{
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 250.0,
                      height: 250.0,
                      child: CircularProgressIndicator(color: Colors.white,),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
