// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ToDo List',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: TodoList(),
//     );
//   }
// }

// class TodoList extends StatefulWidget {
//   @override
//   _TodoListState createState() => _TodoListState();
// }

// class _TodoListState extends State<TodoList> {
//   TextEditingController _titleController = TextEditingController();
//   TextEditingController _descriptionController = TextEditingController();
//   int _priority = 1;
//   CollectionReference _todosCollection =
//       FirebaseFirestore.instance.collection('todos');
//   List<DocumentSnapshot> _searchResults = [];

//   Future<void> _addTodo() async {
//     if (_titleController.text.isNotEmpty &&
//         _descriptionController.text.isNotEmpty) {
//       await _todosCollection.add({
//         'title': _titleController.text,
//         'description': _descriptionController.text,
//         'status': 'not_started',
//         'priority': _priority,
//       });
//       _titleController.clear();
//       _descriptionController.clear();
//     }
//   }

//   Future<void> _editTodo(DocumentSnapshot todoDoc, String newTitle,
//       String newDescription, String newStatus, int newPriority) async {
//     await todoDoc.reference.update({
//       'title': newTitle,
//       'description': newDescription,
//       'status': newStatus,
//       'priority': newPriority
//     });
//   }

//   Future<void> _deleteTodo(DocumentSnapshot todoDoc) async {
//     await todoDoc.reference.delete();
//   }

//   Future<void> _updateTodoStatus(
//       DocumentSnapshot todoDoc, String status) async {
//     Map<String, dynamic> todoData = todoDoc.data() as Map<String, dynamic>;
//     await todoDoc.reference.update({'status': status});
//   }

//   Widget todoListView(QuerySnapshot snapshot, String status) {
//     List<DocumentSnapshot> todos = snapshot.docs
//         .where(
//             (doc) => (doc.data() as Map<String, dynamic>)['status'] == status)
//         .toList();

//     todos.sort((a, b) => ((a.data() as Map<String, dynamic>)['priority'] as int)
//         .compareTo((b.data() as Map<String, dynamic>)['priority'] as int));

//     return ListView.builder(
//       itemCount: todos.length,
//       itemBuilder: (context, index) {
//         DocumentSnapshot todoDoc = todos[index];
//         Map<String, dynamic> todoData = todoDoc.data() as Map<String, dynamic>;
//         return ListTile(
//           title: Text(todoData['title']),
//           subtitle: Text(todoData['description']),
//           trailing: todoData['status'] == 'done'
//               ? null
//               : Checkbox(
//                   value: todoData['status'] == 'in_progress',
//                   onChanged: (bool? newValue) async {
//                     if (newValue == true) {
//                       await _updateTodoStatus(todoDoc, 'in_progress');
//                     } else {
//                       await _updateTodoStatus(todoDoc, 'not_started');
//                     }
//                   }),
//           onTap: () async {
//             TextEditingController _editTitleController =
//                 TextEditingController(text: todoData['title']);
//             TextEditingController _editDescriptionController =
//                 TextEditingController(text: todoData['description']);
//             int priority = todoData['priority'];
//             await showDialog(
//               context: context,
//               builder: (context) {
//                 String status = todoData['status'];
//                 return StatefulBuilder(
//                   builder: (context, setState) {
//                     return AlertDialog(
//                       title: Text('Edit Task'),
//                       content: SingleChildScrollView(
//                         child: ListBody(
//                           children: <Widget>[
//                             TextField(
//                                 controller: _editTitleController,
//                                 decoration: InputDecoration(hintText: 'Title')),
//                             TextField(
//                                 controller: _editDescriptionController,
//                                 decoration:
//                                     InputDecoration(hintText: 'Description')),
//                             SizedBox(height: 16),
//                             Text('Priority:'),
//                             DropdownButton<int>(
//                                 value: priority,
//                                 items: [1, 2, 3]
//                                     .map<DropdownMenuItem<int>>((int value) {
//                                   return DropdownMenuItem<int>(
//                                     value: value,
//                                     child: Text(value.toString()),
//                                   );
//                                 }).toList(),
//                                 onChanged: (int? newValue) {
//                                   setState(() {
//                                     priority = newValue!;
//                                   });
//                                 }),
//                             SizedBox(height: 16),
//                             Text('Status:'),
//                             RadioListTile(
//                                 title: Text('Not Started'),
//                                 value: 'not_started',
//                                 groupValue: status,
//                                 onChanged: (String? value) {
//                                   setState(() {
//                                     status = value!;
//                                   });
//                                 }),
//                             RadioListTile(
//                                 title: Text('In Progress'),
//                                 value: 'in_progress',
//                                 groupValue: status,
//                                 onChanged: (String? value) {
//                                   setState(() {
//                                     status = value!;
//                                   });
//                                 }),
//                             RadioListTile(
//                                 title: Text('Done'),
//                                 value: 'done',
//                                 groupValue: status,
//                                 onChanged: (String? value) {
//                                   setState(() {
//                                     status = value!;
//                                   });
//                                 }),
//                           ],
//                         ),
//                       ),
//                       actions: <Widget>[
//                         TextButton(
//                             child: Text('Cancel'),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             }),
//                         TextButton(
//                             child: Text('Delete'),
//                             style: TextButton.styleFrom(primary: Colors.red),
//                             onPressed: () async {
//                               await _deleteTodo(todoDoc);
//                               Navigator.of(context).pop();
//                             }),
//                         TextButton(
//                             child: Text('Submit'),
//                             onPressed: () async {
//                               await _editTodo(
//                                   todoDoc,
//                                   _editTitleController.text,
//                                   _editDescriptionController.text,
//                                   status,
//                                   priority);
//                               Navigator.of(context).pop();
//                             }),
//                       ],
//                     );
//                   },
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

// // Add the following search function
//   Future<List<DocumentSnapshot>> _searchTodos(String query) async {
//     final snapshot = await _todosCollection
//         .where('title', isGreaterThanOrEqualTo: query)
//         .where('title', isLessThanOrEqualTo: query + '\uf8ff')
//         .get();
//     return snapshot.docs;
//   }

// // Add the following search view
//   Widget searchListView(List<DocumentSnapshot> todos) {
//     return ListView.builder(
//       itemCount: todos.length,
//       itemBuilder: (context, index) {
//         DocumentSnapshot todoDoc = todos[index];
//         Map<String, dynamic> todoData = todoDoc.data() as Map<String, dynamic>;
//         return ListTile(
//           title: Text(todoData['title']),
//           subtitle: Text(todoData['description']),
//           trailing: todoData['status'] == 'done'
//               ? null
//               : Checkbox(
//                   value: todoData['status'] == 'in_progress',
//                   onChanged: (bool? newValue) async {
//                     if (newValue == true) {
//                       await _updateTodoStatus(todoDoc, 'in_progress');
//                     } else {
//                       await _updateTodoStatus(todoDoc, 'not_started');
//                     }
//                   }),
//           onTap: () async {
//             TextEditingController _editTitleController =
//                 TextEditingController(text: todoData['title']);
//             TextEditingController _editDescriptionController =
//                 TextEditingController(text: todoData['description']);
//             int priority = todoData['priority'];
//             await showDialog(
//               context: context,
//               builder: (context) {
//                 String status = todoData['status'];
//                 return StatefulBuilder(
//                   builder: (context, setState) {
//                     return AlertDialog(
//                       title: Text('Edit Task'),
//                       content: SingleChildScrollView(
//                         child: ListBody(
//                           children: <Widget>[
//                             TextField(
//                                 controller: _editTitleController,
//                                 decoration: InputDecoration(hintText: 'Title')),
//                             TextField(
//                                 controller: _editDescriptionController,
//                                 decoration:
//                                     InputDecoration(hintText: 'Description')),
//                             SizedBox(height: 16),
//                             Text('Priority:'),
//                             DropdownButton<int>(
//                                 value: priority,
//                                 items: [1, 2, 3]
//                                     .map<DropdownMenuItem<int>>((int value) {
//                                   return DropdownMenuItem<int>(
//                                     value: value,
//                                     child: Text(value.toString()),
//                                   );
//                                 }).toList(),
//                                 onChanged: (int? newValue) {
//                                   setState(() {
//                                     priority = newValue!;
//                                   });
//                                 }),
//                             SizedBox(height: 16),
//                             Text('Status:'),
//                             RadioListTile(
//                                 title: Text('Not Started'),
//                                 value: 'not_started',
//                                 groupValue: status,
//                                 onChanged: (String? value) {
//                                   setState(() {
//                                     status = value!;
//                                   });
//                                 }),
//                             RadioListTile(
//                                 title: Text('In Progress'),
//                                 value: 'in_progress',
//                                 groupValue: status,
//                                 onChanged: (String? value) {
//                                   setState(() {
//                                     status = value!;
//                                   });
//                                 }),
//                             RadioListTile(
//                                 title: Text('Done'),
//                                 value: 'done',
//                                 groupValue: status,
//                                 onChanged: (String? value) {
//                                   setState(() {
//                                     status = value!;
//                                   });
//                                 }),
//                           ],
//                         ),
//                       ),
//                       actions: <Widget>[
//                         TextButton(
//                             child: Text('Cancel'),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             }),
//                         TextButton(
//                             child: Text('Delete'),
//                             style: TextButton.styleFrom(primary: Colors.red),
//                             onPressed: () async {
//                               await _deleteTodo(todoDoc);
//                               Navigator.of(context).pop();
//                             }),
//                         TextButton(
//                             child: Text('Submit'),
//                             onPressed: () async {
//                               await _editTodo(
//                                   todoDoc,
//                                   _editTitleController.text,
//                                   _editDescriptionController.text,
//                                   status,
//                                   priority);
//                               Navigator.of(context).pop();
//                             }),
//                       ],
//                     );
//                   },
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('ToDo List'),
//           bottom: TabBar(tabs: [
//             Tab(text: 'Not Started'),
//             Tab(text: 'In Progress'),
//             Tab(text: 'Done'),
//             Tab(text: 'Search'), // Add the new 'Search' tab
//           ]),
//         ),
//         body: TabBarView(children: [
//           StreamBuilder<QuerySnapshot>(
//             stream: _todosCollection.snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               }
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }
//               return todoListView(snapshot.data!, 'not_started');
//             },
//           ),
//           StreamBuilder<QuerySnapshot>(
//             stream: _todosCollection.snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               }
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }
//               return todoListView(snapshot.data!, 'in_progress');
//             },
//           ),
//           StreamBuilder<QuerySnapshot>(
//             stream: _todosCollection.snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               }
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }
//               return todoListView(snapshot.data!, 'done');
//             },
//           ),
//           // Add the new 'Search' view
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   onChanged: (String query) async {
//                     List<DocumentSnapshot> todos = await _searchTodos(query);
//                     setState(() {
//                       _searchResults = todos;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Search',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: searchListView(_searchResults),
//               ),
//             ],
//           ),
//         ]),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             await showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: Text('New Task'),
//                   content: SingleChildScrollView(
//                     child: ListBody(
//                       children: <Widget>[
//                         TextField(
//                           controller: _titleController,
//                           decoration: InputDecoration(hintText: 'Title'),
//                         ),
//                         TextField(
//                           controller: _descriptionController,
//                           decoration: InputDecoration(hintText: 'Description'),
//                         ),
//                         SizedBox(height: 16),
//                         Text('Priority:'),
//                         DropdownButton<int>(
//                           value: _priority,
//                           items:
//                               [1, 2, 3].map<DropdownMenuItem<int>>((int value) {
//                             return DropdownMenuItem<int>(
//                               value: value,
//                               child: Text(value.toString()),
//                             );
//                           }).toList(),
//                           onChanged: (int? newValue) {
//                             setState(() {
//                               _priority = newValue!;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   actions: <Widget>[
//                     TextButton(
//                       child: Text('Cancel'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                     TextButton(
//                       child: Text('Submit'),
//                       onPressed: () {
//                         _addTodo();
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//           child: Icon(Icons.add),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: SignIn()));
}

class SignIn extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ToDoList(),
                      ),
                    );
                  } catch (e) {
                    print('Error: $e');
                  }
                },
                child: Text('Sign In'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ToDoList(),
                      ),
                    );
                  } catch (e) {
                    print('Error: $e');
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _todosCollection =
      FirebaseFirestore.instance.collection('todos');
  final _auth = FirebaseAuth.instance;
  int _priority = 1;
  List<DocumentSnapshot> _searchResults = [];

  CollectionReference get _userTodosCollection {
    return _todosCollection.doc(_auth.currentUser!.uid).collection('todos');
  }

  Future<void> _addTodo() async {
    await _userTodosCollection.add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'status': 'not_started',
      'priority': _priority,
    });
    _titleController.clear();
    _descriptionController.clear();
  }

  Future<void> _editTodo(DocumentSnapshot todoDoc, String title,
      String description, String status, int priority) async {
    await _userTodosCollection.doc(todoDoc.id).update({
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
    });
  }

  Future<void> _deleteTodo(DocumentSnapshot todoDoc) async {
    await _userTodosCollection.doc(todoDoc.id).delete();
  }

  Future<void> _updateTodoStatus(DocumentSnapshot todoDoc, String status) async {
    await _userTodosCollection.doc(todoDoc.id).update({'status': status});
  }

    Widget todoListView(QuerySnapshot snapshot, String statusFilter) {
    List<DocumentSnapshot> todos = snapshot.docs
        .where((doc) => doc.get('status') == statusFilter)
        .toList();

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        DocumentSnapshot todo = todos[index];
        return ListTile(
          title: Text(todo.get('title')),
          subtitle: Text(todo.get('description')),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteTodo(todo);
            },
          ),
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) {
                TextEditingController titleController =
                    TextEditingController(text: todo.get('title'));
                TextEditingController descriptionController =
                    TextEditingController(text: todo.get('description'));

                return AlertDialog(
                  title: Text('Edit ToDo'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(labelText: 'Title'),
                        ),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _editTodo(todo, titleController.text,
                            descriptionController.text, todo.get('status'), todo.get('priority'));
                        Navigator.of(context).pop();
                      },
                      child: Text('Save'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ToDo List'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Not Started'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
              Tab(text: 'All'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _userTodosCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return todoListView(snapshot.data!, 'not_started');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _userTodosCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return todoListView(snapshot.data!, 'in_progress');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _userTodosCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return todoListView(snapshot.data!, 'completed');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _userTodosCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return todoListView(snapshot.data!, '');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('New ToDo'),
                  content: SingleChildScrollView(
                    child: Column(
                                            mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(labelText: 'Title'),
                        ),
                        TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                        ),
                        DropdownButtonFormField(
                          value: _priority,
                          onChanged: (int? value) {
                            setState(() {
                              _priority = value!;
                            });
                          },
                          items: List.generate(3, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text('Priority ${(index + 1)}'),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _addTodo();
                        Navigator.of(context).pop();
                      },
                      child: Text('Add'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

