import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  String description;
  bool isCompleted;

  Task({
    required this.title,
    this.description = '',
    this.isCompleted = false,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 208, 7, 243), // Change the primary color to your desired color
        
        scaffoldBackgroundColor: Colors.grey[100], // Set the background color
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.indigo, // Change button color
            onPrimary: Colors.white, // Change text color
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.indigo, // Change text button color
          ),
        ),
      ),
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      tasks = taskList.map((taskString) {
        final taskMap = taskString.split('|');
        return Task(
          title: taskMap[0],
          description: taskMap[1],
          isCompleted: taskMap[2] == 'true',
        );
      }).toList();
      setState(() {});
    }
  }

  void saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = tasks.map((task) {
      return '${task.title}|${task.description}|${task.isCompleted}';
    }).toList();
    prefs.setStringList('tasks', taskList);
  }

  void addTask(Task task) {
    tasks.add(task);
    saveTasks();
    setState(() {});
  }

  void editTask(int index, Task task) {
    tasks[index] = task;
    saveTasks();
    setState(() {});
  }

  void toggleTaskCompletion(int index) {
    tasks[index].isCompleted = !tasks[index].isCompleted;
    saveTasks();
    setState(() {});
  }

  void deleteTask(int index) {
    tasks.removeAt(index);
    saveTasks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: TaskListWidget(
        tasks: tasks,
        toggleTaskCompletion: toggleTaskCompletion,
        deleteTask: deleteTask,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskFormScreen(
                addTask: addTask,
                isEditing: false,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final Function(int) toggleTaskCompletion;
  final Function(int) deleteTask;

  TaskListWidget({
    required this.tasks,
    required this.toggleTaskCompletion,
    required this.deleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          subtitle: Text(
            task.description,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          trailing: Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              toggleTaskCompletion(index);
            },
          ),
          onLongPress: () {
            deleteTask(index);
          },
        );
      },
    );
  }
}

class TaskFormScreen extends StatefulWidget {
  final Function(Task) addTask;
  final bool isEditing;
  final Task task;
  final int index;

  TaskFormScreen({
    required this.addTask,
    required this.isEditing,
    Task? task,
    int index = -1,
  }) : this.task = task ?? Task(title: ''), this.index = index;

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      titleController.text = widget.task.title;
      descriptionController.text = widget.task.description;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveTask() {
    final title = titleController.text;
    final description = descriptionController.text;
    final task = Task(title: title, description: description);

    if (widget.isEditing) {
      widget.addTask(task);
    } else {
      widget.addTask(task);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveTask,
              child: Text(widget.isEditing ? 'Save Changes' : 'Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
