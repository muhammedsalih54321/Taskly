import 'dart:ui';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:notifications_tut/notification/notification.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';

DateTime scheduleTime = DateTime.now();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // List of active tasks and completed tasks
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _completedTasks = [];

  // List to store multiple selected times
  List<TimeOfDay> _selectedTimes = [];

  // Hive boxes
  final _taskBox = Hive.box('shopping_box');
  final _completedBox = Hive.box('completed_box');

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize timezone
    _refreshTasks(); // Load both active and completed tasks
  }

  // Refresh Tasks List
  void _refreshTasks() {
    setState(() {
      _tasks = _taskBox.keys.map((key) {
        final value = _taskBox.get(key);
        return {
          "key": key,
          "Title": value["Title"],
          "Times": value["Times"] ?? []
        };
      }).toList();

      _completedTasks = _completedBox.keys.map((key) {
        final value = _completedBox.get(key);
        return {"key": key, "Title": value["Title"], "Time": value["Time"]};
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

  // Time Picker
  TimeOfDay timeOfDay = TimeOfDay.now();

  Future<void> _scheduleNotification(String title, TimeOfDay pickedTime) async {
    final now = DateTime.now();
    final scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      scheduleTime.isBefore(now)
          ? scheduleTime.add(const Duration(days: 1))
          : scheduleTime,
      tz.local,
    );

    // Generate a unique ID for each notification
    int uniqueId = now.millisecondsSinceEpoch.remainder(100000) +
        pickedTime.hour * 100 +
        pickedTime.minute;

    NotificationService.scheduleNotification(
      uniqueId, // Unique ID for each notification
      "Task Reminder",
      title,
      scheduledDate,
    );
  }

  Future<void> _showMyDialog() async {
    _taskController.clear();
    _timeController.clear();
    _selectedTimes.clear(); // Clear any previously selected times
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(
                'Create New Task',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 300.w,
                      height: 80.h,
                      child: TextFormField( style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                                   
                        controller: _taskController,
                        decoration: InputDecoration(
                          labelText: 'Type your Task',
                          labelStyle:GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black) ,
                          border: OutlineInputBorder(),
                        ),
                        validator: (task) {
                          if (task == null || task.isEmpty) {
                            return 'Enter your task';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            _selectedTimes.add(pickedTime);
                          });
                        }
                      },
                      child: Container(
                        height: 50.h,
                        width: double.infinity.w,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(13.r)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            Icon(
                              BootstrapIcons.clock,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 25.w,
                            ),
                            Text(
                              "Add Reminder Time",
                              style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ..._selectedTimes.map((time) => Text(
                          "Reminder at: ${time.format(context)}",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                  ],
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _taskController.clear();
                    _timeController.clear();
                    _selectedTimes.clear();
                  },
                  child: Container(
                    height: 40.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(13.r)),
                    child: Center(
                        child: Text(
                      "Cancle",
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    )),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (formKey.currentState!.validate() &&
                        _selectedTimes.isNotEmpty) {
                      _createTask({
                        "Title": _taskController.text,
                        "Times": _selectedTimes
                            .map((time) => time.format(context))
                            .toList(),
                      });

                      for (final time in _selectedTimes) {
                        _scheduleNotification(
                          _taskController.text,
                          time,
                        );
                      }

                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    height: 40.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Center(
                        child: Text(
                      "Create Task",
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    )),
                  ),
                ),
              ],
            );
          },
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
            _buildTaskList(),
            _buildCompletedList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return _tasks.isEmpty
        ? SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 300.h,
                ),
                Center(
                    child: Text('No Tasks Available',
                        style: TextStyle(fontSize: 18))),
                SizedBox(
                  height: 250.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: FloatingActionButton(
                        onPressed: _showMyDialog,
                        child: const Icon(Icons.add, color: Colors.white),
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Stack(
            children: [
              ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (_, index) {
                  final task = _tasks[index];
                  final times = task['Times'] ?? [];

                  return Card(
                    child: Dismissible(
                      key: ValueKey(task['key']),
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.done,
                            color: Colors.white, size: 30),
                      ),
                      direction: DismissDirection.startToEnd, //
                      onDismissed: (_) => _moveToCompleted(task['key']),
                      child: ListTile(
                        title: Text(
                          task['Title'],
                          style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reminder Time:  ',
                              style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            ...times
                                .map((time) => Text(
                                      time,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: FloatingActionButton(
                          onPressed: _showMyDialog,
                          child: const Icon(Icons.add, color: Colors.white),
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
  }

  Widget _buildCompletedList() {
    return // Completed Tasks
        _completedTasks.isEmpty
            ? Column(
                children: [
                  SizedBox(
                    height: 300.h,
                  ),
                  const Center(
                      child: Text('No Completed Tasks',
                          style: TextStyle(fontSize: 18))),
                ],
              )
            : ListView.builder(
                itemCount: _completedTasks.length,
                itemBuilder: (_, index) {
                  final completed = _completedTasks[index];

                  return Card(
                    child: Dismissible(
                      key: ValueKey(completed['key']),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 30),
                      ),
                      direction: DismissDirection.endToStart, // Swipe to delete
                      onDismissed: (_) {
                        _deleteCompletedTask(
                            completed['key']); // Delete task on swipe
                      },
                      child: Stack(
                        children: [
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  completed['Title'],
                                  style: GoogleFonts.poppins(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                                Icon(
                                  Icons.done,
                                  color: Colors.green,
                                )
                              ],
                            ),
                          ),
                          ClipRRect(
                            child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                child: Container(
                                  height: 60.h,
                                  width: double.infinity.w,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      ),child: Center(child:Text(
                                  'Completed',
                                  style: GoogleFonts.poppins(
                                     
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                ) ,),
                                ),),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}
