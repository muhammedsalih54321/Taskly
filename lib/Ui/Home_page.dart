import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // List of active tasks and completed tasks
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _completedTasks = [];

  // Hive boxes
  final _taskBox = Hive.box('shopping_box');
  final _completedBox = Hive.box('completed_box');

  @override
  void initState() {
    super.initState();
    _refreshTasks(); // Load both active and completed tasks
  }

  // Refresh Tasks List
  void _refreshTasks() {
    setState(() {
      _tasks = _taskBox.keys.map((key) {
        final value = _taskBox.get(key);
        return {"key": key, "Title": value["Title"], "Date": value["Date"], "Time": value["Time"]};
      }).toList();

      _completedTasks = _completedBox.keys.map((key) {
        final value = _completedBox.get(key);
        return {"key": key, "Title": value["Title"], "Date": value["Date"], "Time": value["Time"]};
      }).toList();
    });
  }

  // Add a New Task
  Future<void> _createTask(Map<String, dynamic> newTask) async {
    await _taskBox.add(newTask);
    _refreshTasks();
  }

  // Move Task to Completed
  Future<void> _moveToCompleted(int taskKey) async {
    final task = _taskBox.get(taskKey);

    if (task != null) {
      // Add the task to the 'completed_box'
      await _completedBox.add(task);

      // Remove the task from the 'shopping_box'
      await _taskBox.delete(taskKey);

      _refreshTasks();
    }
  }

  // Delete a Task from Completed
  Future<void> _deleteCompletedTask(int completedKey) async {
    await _completedBox.delete(completedKey);
    _refreshTasks();
  }

  // Date and Time Pickers
  TimeOfDay timeOfDay = TimeOfDay.now();
  DateTime? selectedDate;

  void _showTimePicker() {
    showTimePicker(context: context, initialTime: timeOfDay).then((value) {
      if (value != null) setState(() => timeOfDay = value);
    });
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((value) {
      if (value != null) setState(() => selectedDate = value);
    });
  }

  // Dialog to Add Task
  Future<void> _showAddTaskDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Create New Task',
            style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w500),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _taskController,
                  decoration: const InputDecoration(labelText: 'Task Title', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Enter a task title' : null,
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showTimePicker,
                      child: const Icon(BootstrapIcons.clock),
                    ),
                    SizedBox(width: 20.w),
                    GestureDetector(
                      onTap: _showDatePicker,
                      child: const Icon(BootstrapIcons.calendar),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _createTask({
                    "Title": _taskController.text,
                    "Date": selectedDate?.toString() ?? '',
                    "Time": timeOfDay.format(context),
                  });
                  Navigator.of(context).pop();
                  _taskController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // AppBar color
          title: Text(
            'Taskly',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.black, // Underline for the active tab
            labelColor: Colors.black, // Text color for active tab
            unselectedLabelColor: Colors.black, // Inactive tab color
            labelStyle: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Tasks'),
              Tab(text: 'Completed'),
            ],
          ),
          leading: Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/rafiki.png',
              height: 40.h,
              width: 40.w,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Active Tasks
            _tasks.isEmpty
                ? const Center(child: Text('No Tasks Available', style: TextStyle(fontSize: 18)))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (_, index) {
                      final task = _tasks[index];
                      return Card(
                        child: Dismissible(
                          key: ValueKey(task['key']),
                          background: Container(color: Colors.green),
                          onDismissed: (_) => _moveToCompleted(task['key']),
                          child: ListTile(
                            title: Text(task['Title']),
                            subtitle: Text("Date: ${task['Date']} - Time: ${task['Time']}"),
                          ),
                        ),
                      );
                    },
                  ),

            // Completed Tasks
            _completedTasks.isEmpty
                ? const Center(child: Text('No Completed Tasks', style: TextStyle(fontSize: 18)))
                : ListView.builder(
                    itemCount: _completedTasks.length,
                    itemBuilder: (_, index) {
                      final completed = _completedTasks[index];
                      return Card(
                        child: ListTile(
                          title: Text(completed['Title']),
                          subtitle: Text("Date: ${completed['Date']} - Time: ${completed['Time']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCompletedTask(completed['key']),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
