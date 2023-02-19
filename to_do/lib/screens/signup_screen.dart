import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  var fullNameController = TextEditingController();
  var emailController =    TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Please SignUp'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 10,),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 10,),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 10,),

              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 10,),

              ElevatedButton(
                onPressed: () async {
                  var fullName = fullNameController.text.trim();
                  var email = emailController.text.trim();
                  var password = passwordController.text.trim();
                  var confirmPassword = confirmPasswordController.text.trim();

                  if(fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                    {
                      Fluttertoast.showToast(msg: 'Please fill all fields');
                      return;
                    }
                  if(password != confirmPassword)
                    {
                      Fluttertoast.showToast(msg: 'Passwords Does Not Matched');
                      return;
                    }
                  if(password.length < 6)
                    {
                      Fluttertoast.showToast(msg: 'Password must be at least 6 characters');
                      return;
                    }

                  ProgressDialog progressDialog = ProgressDialog(
                    context,
                    title: const Text('Signing Up'),
                    message: const Text('Please Wait'),
                  );

                  // request to firebase auth
                  try {

                    progressDialog.show();

                    FirebaseAuth auth = FirebaseAuth.instance;

                    UserCredential usercredential = await auth
                        .createUserWithEmailAndPassword(
                        email: email, password: password);

                    if (usercredential.user != null) {
                      // store user info in realtime database

                      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users');
                      String uid = usercredential.user!.uid;
                      int dt = DateTime.now().millisecondsSinceEpoch;

                      await userRef.child(uid).set({
                        'fullName' : fullName,
                        'email' : email,
                        'uid' : uid,
                        'dt': dt,
                        'profileImage': '',
                      });

                      Fluttertoast.showToast(msg: 'Success');
                      Navigator.of(context).pop();
                    }
                    else {
                      Fluttertoast.showToast(msg: 'Failed');
                    }

                    progressDialog.dismiss();
                  }
                  on FirebaseAuthException catch(e)
                  {
                    progressDialog.dismiss();
                    if(e.code == 'email-already-in-use')
                      {
                        Fluttertoast.showToast(msg: 'Email already existed');
                      }
                    else if(e.code == 'weak-password')
                      {
                        Fluttertoast.showToast(msg: 'Weak Password');
                      }
                  }
                  catch(e)
                  {
                    progressDialog.dismiss();
                    Fluttertoast.showToast(msg: 'Something went wrong');
                  }
                },
                child: Text('SignUp'),
              ),
            ],
          ),
        ));
  }
}
