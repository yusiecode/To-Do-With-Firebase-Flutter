import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do/screens/add_task_screen.dart';
import 'package:to_do/screens/login_screen.dart';
import 'package:to_do/screens/profile_screen.dart';
import 'package:to_do/screens/update_task_screen.dart';

import '../models/task_model.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {

  User? user;
  DatabaseReference? taskRef;

  @override
  void initState() {              // to initialize this

    user = FirebaseAuth.instance.currentUser;
    if(user != null)
      {
        taskRef = FirebaseDatabase.instance.reference().child('tasks').child(user!.uid);  // we reached to the user id
      }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return ProfileScreen();
                }));
              },
              icon: Icon(Icons.person)),

          IconButton(
              onPressed: (){
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    title: Text('Confirmation !!!'),
                    content: Text('Are You Sure to Logout'),
                    actions: [
                      TextButton(onPressed: (){
                        Navigator.of(context).pop();
                      }, child: Text('No')),
                      TextButton(onPressed: (){
                        Navigator.of(context).pop();

                        FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
                          return LoginScreen();
                        }));


                      }, child: Text('Yes')),
                    ],

                  );
                });

              },
              icon: Icon(Icons.logout)),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return AddTaskScreen();
          }));
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(  // continuously listening to database
        stream: taskRef != null ? taskRef!.onValue : null,
        builder: (context, snapshot){
          if(snapshot.hasData && !snapshot.hasError)
            {
              var event = snapshot.data as Event;
              var snapshot2 = event.snapshot.value;

              if(snapshot2 == null)
                {
                  return const Center(child: Text('No Task added yet!'),);
                }

              Map<String, dynamic> map = Map<String, dynamic>.from(snapshot2);

              var tasks = <TaskModel>[];

              for(var taskMap in map.values)
                {
                  TaskModel taskModel = TaskModel.fromMap(Map<String,dynamic>.from(taskMap));   // fromMap la map pakar de
                  
                  tasks.add(taskModel);
                }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: tasks.length,
                    itemBuilder: (context, index){

                    TaskModel task = tasks[index];   // da mong yaw task raochat ko

                    return Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2,),
                      ),
                      child: Column(

                        children: [
                          Text(task.taskName),
                          Text(getHumanReadableDate(task.dt )),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(onPressed: (){
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text('Are you sure to delete!'),
                                    actions: [
                                      TextButton(onPressed: (){
                                        Navigator.of(context).pop();

                                      }, child: const Text('No')),
                                      TextButton(onPressed: () async {


                                        if(taskRef != null)
                                          {
                                            await taskRef!.child(task.taskId).remove();
                                          }
                                        Navigator.of(context).pop();
                                      }, child: const Text('Yes')),
                                    ],
                                  );
                                });
                              }, icon: Icon(Icons.delete)),


                              IconButton(onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return UpdateTaskScreen(task:task);
                                }));
                              }, icon: Icon(Icons.edit)),
                            ],
                          )

                        ],
                      ),
                    );
                }),
              );

            }
          else
            {
              return const Center(child: CircularProgressIndicator(),);
            }
        },
      ),
    );
  }

  // intl package = internationalization
  String getHumanReadableDate(int dt)
  {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt);
    return DateFormat('dd MMM yyy').format(dateTime);
  }
}
