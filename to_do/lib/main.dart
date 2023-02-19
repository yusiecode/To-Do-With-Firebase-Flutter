import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:to_do/screens/landing_screen.dart';
import 'package:to_do/screens/splash_screen.dart';
import 'package:to_do/screens/task_list_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? const SplashScreen()
          : const TaskListScreen(),
    );
  }
}

