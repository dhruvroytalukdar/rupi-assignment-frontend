import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rupiassignment1/providers/token_provider.dart';
import 'package:http/http.dart' as http;
import 'package:rupiassignment1/providers/user_provider.dart';
import 'package:rupiassignment1/utils/constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  String? _email = "";
  String? _password = "";
  String? _name = "";
  bool _loading = false;
  final storage = const FlutterSecureStorage();

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    registerUser() async {
      setState(() {
        _loading = true;
      });
      final response = await http.post(Uri.parse("$apiURL/auth/register"),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': _email!,
            'password':_password!,
            'name':_name!,
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
      }else if(response.statusCode == 400){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)["message"]),),);
      }else{
        print("Error");
      }
      setState(() {
        _loading = false;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title:const Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Text("Register Page"),
        ),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top:100.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Register",
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
                          decoration: const InputDecoration(labelText: "Enter your name"),
                          validator: (value){
                            if(value == null || value.isEmpty) {
                              return "Please enter a name";
                            }
                          },
                          onSaved: (val) => setState(() {
                            _name = val;
                          }),
                        ),
                        const SizedBox(
                          height: 35.0,
                        ),
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
                        !_loading ? Column(
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
                                      registerUser();
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
                                    "Already have an account?"
                                    ,style: TextStyle(fontSize: 20.0),
                                  )
                                  ,onPressed: (){
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                              ),
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
        ),
      ),
    );
  }
}
