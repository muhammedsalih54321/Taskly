import 'dart:ui';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:notifications_tut/Provider/Task_provider.dart';
import 'package:notifications_tut/notification/notification.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
  List<TimeOfDay> _selectedTimes = [];
  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize timezone
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
                      child: TextFormField( maxLines: 2,
                        style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                        controller: _taskController,
                        decoration: InputDecoration(
                          labelText: 'Type your Task',
                          labelStyle: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
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
                      Provider.of<TaskProvider>(context, listen: false).addTask(
                          _taskController.text,
                          _selectedTimes
                              .map((e) => e.format(context))
                              .toList());

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
    return Stack(
      children: [
        Consumer<TaskProvider>(
          builder: (context, provider, child) {
            final tasks = provider.tasks;

            if (tasks.isEmpty) {
              return Center(child: Text("No Tasks Available"));
            }

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];

                return Card(
                  child: Dismissible(
                    key: ValueKey(task.key),
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child:
                          const Icon(Icons.done, color: Colors.white, size: 30),
                    ),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (_) => provider.completeTask(task.key!),
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      subtitle: Text(
                        "Reminder: ${task.times.join(', ')}",
                        style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
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
        Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final completedTasks = provider.completedTasks;

        if (completedTasks.isEmpty) {
          return Center(child: Text("No Completed Tasks"));
        }

        return ListView.builder(
          itemCount: completedTasks.length,
          itemBuilder: (_, index) {
            final task = completedTasks[index];

            return Card(
              child: Dismissible(
                key: ValueKey(task.key),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child:
                      const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => provider.deleteCompletedTask(task.key!),
                child: Stack(
                  children: [
                    ListTile(
                      title: Text(
                        task.title,
                        style: GoogleFonts.poppins(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ),
                    ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        height: 60.h,
                        width: double.infinity.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'Completed',
                            style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
