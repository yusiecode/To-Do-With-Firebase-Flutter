import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:to_do/models/task_model.dart';

class UpdateTaskScreen extends StatefulWidget {
  final TaskModel task;

  const UpdateTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  _UpdateTaskScreenState createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  var nameController = TextEditingController();

  @override
  void initState() {

    super.initState();
    nameController.text = widget.task.taskName;      // to pass the task name to the name controller
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Add Task',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                var taskName = nameController.text.trim();
                if(taskName.isEmpty)
                  {
                    Fluttertoast.showToast(msg: 'Please Provide Task Name');
                    return;
                  }

                User? user = FirebaseAuth.instance.currentUser;

                if(user != null)
                  {
                    DatabaseReference taskRef = FirebaseDatabase.instance.reference()
                        .child('tasks')
                        .child(user!.uid)
                        .child(widget.task.taskId);

                    await taskRef.update({'taskName':taskName});
                  }
              },
              child: Text('Update'),
            ),
          ],
        ),
      )
    );
  }
}
