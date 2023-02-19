import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'package:to_do/screens/signup_screen.dart';
import 'package:to_do/screens/task_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Please Login'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {

                  var email = emailController.text.trim();
                  var password = passwordController.text.trim();

                  if(email.isEmpty || password.isEmpty)
                    {
                      Fluttertoast.showToast(msg: 'Please fill the fields');
                      return;
                    }

                  // request to firebase auth
                  ProgressDialog progressDialog = ProgressDialog(
                    context,
                    title: const Text('Logging In'),
                    message: const Text('Please Wait'),
                  );

                  progressDialog.show();

                  try{

                    FirebaseAuth auth = FirebaseAuth.instance;

                    UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);

                    if(userCredential.user != null)
                      {
                        progressDialog.dismiss();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
                          return TaskListScreen();
                        }));

                      }


                  }
                  on FirebaseAuthException catch(e)
                  {
                    progressDialog.dismiss();
                    if(e.code == 'user-not-found')
                      {
                        Fluttertoast.showToast(msg: 'User Not Found');
                      }
                    else if(e.code == 'wrong-password')
                      {
                        Fluttertoast.showToast(msg: 'Wrong Password');
                      }
                  }
                  catch(e)
                  {
                    Fluttertoast.showToast(msg: 'Something Went Wrong');
                    progressDialog.dismiss();
                  }

                },
                child: const Text('Login'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not Register Yet !'),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return SignupScreen();
                      }));
                    },
                    child: Text('Register Now'),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
