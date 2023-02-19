import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  var taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Task'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(
                  hintText: 'Add Task',
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              ElevatedButton(
                onPressed: () async {
                  String taskName = taskController.text.trim();

                  if(taskName.isEmpty)
                    {
                      Fluttertoast.showToast(msg: 'Please Name It');
                      return;   // it means don't execute more code below this
                    }


                  User? user = FirebaseAuth.instance.currentUser;
                  if(user != null)
                    {
                      String uid = user.uid;
                      int dt = DateTime.now().millisecondsSinceEpoch;

                      DatabaseReference taskRef = FirebaseDatabase.instance.reference().child('tasks').child(uid);  // to reference till uid
                      String taskId = taskRef.push().key;  // key will generate random unique task it

                      await taskRef.child(taskId).set({   // to provide map i.e data
                        'dt' : dt,
                        'taskName': taskName,
                        'taskId': taskId,
                      });

                    }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ));
  }
}
