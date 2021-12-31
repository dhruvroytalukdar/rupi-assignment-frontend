import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rupiassignment1/providers/token_provider.dart';
import 'package:rupiassignment1/providers/user_provider.dart';
import 'package:rupiassignment1/screens/decider_page.dart';
import 'package:rupiassignment1/screens/home_page.dart';
import 'package:rupiassignment1/screens/login_page.dart';
import 'package:rupiassignment1/screens/register_page.dart';

void main() {
  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (_)=>UserProvider()),
        ChangeNotifierProvider(create: (_)=>TokenProvider()),
      ],
      child: MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/decider',
      routes: {
        '/home': (context) => const HomePage(),
        '/decider':(context)=> const DeciderPage(),
        '/login':(context) => const LoginPage(),
        '/register':(context) => const RegisterPage(),
      },
    );
  }
}