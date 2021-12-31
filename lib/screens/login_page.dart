import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rupiassignment1/providers/token_provider.dart';
import 'package:rupiassignment1/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:rupiassignment1/utils/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String? _email = "";
  String? _password = "";
  bool _loading = false;

  final storage = const FlutterSecureStorage();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    logInUser() async {
      setState(() {
        _loading = true;
      });
      final response = await http.post(Uri.parse("$apiURL/auth/login"),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': _email!,
            'password':_password!
          })
      );
      if(response.statusCode == 200){
        context.read<UserProvider>().createUser(jsonDecode(response.body));
        Map<String,dynamic> data = jsonDecode(response.body);
        context.read<TokenProvider>().storeTokens(data["refreshToken"], data["accessToken"]);
        await storage.write(key: "token", value: data["refreshToken"]);
        setState(() {
          _loading = false;
        });
        Navigator.pushReplacementNamed(context, '/home');
      }else if(response.statusCode == 400 || response.statusCode == 403){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)["message"]),),);
        setState(() {
          _loading = false;
        });
      }else{
        print("Error");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title:const Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Text("Login Page"),
        ),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("LogIn",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 15.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: "Enter your email"),
                            validator: (value){
                              if(value == null || value.isEmpty) {
                                return "Please enter an email";
                              }
                            },
                            onSaved: (val) => setState(() {
                              _email = val;
                            }),
                          ),
                          const SizedBox(
                            height: 35.0,
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(labelText: "Enter your password"),
                            validator: (value){
                              if(value == null || value.isEmpty) {
                                return "Please enter an password";
                              }
                            },
                            onSaved: (val) => setState(() {
                              _password = val;
                            }),
                          ),
                          const SizedBox(
                            height: 35.0,
                          ),
                          !_loading?Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height:45.0,
                                child: ElevatedButton(
                                    child: const Text(
                                        "Submit"
                                      ,style: TextStyle(fontSize: 20.0),
                                    )
                                    ,onPressed: (){
                                      final form = _formKey.currentState;
                                      if(form!.validate()){
                                        form.save();
                                        logInUser();
                                      }
                                    }
                                ),
                              ),
                              const SizedBox(
                                height: 25.0,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height:45.0,
                                child: TextButton(
                                    child: const Text(
                                      "Don't have an account?"
                                      ,style: TextStyle(fontSize: 20.0),
                                    )
                                    ,onPressed: (){
                                  Navigator.pushReplacementNamed(context, '/register');
                                }),
                              )
                            ],
                          ):const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
