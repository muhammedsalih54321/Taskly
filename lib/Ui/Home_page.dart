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
  final Task = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isswitched1 = false;
  onchange1(bool newvalue1) {
    setState(() {
      isswitched1 = newvalue1;
    });
  }

  List<Map<String, dynamic>> _items = [];

  final _shoppingBox = Hive.box('shopping_box');
  @override
  void initState() {
    super.initState();
    _refreshItems(); // Load data when app starts
  }

  // Get all items from the database
 void _refreshItems() {
  final data = _shoppingBox.keys.map((key) {
    final value = _shoppingBox.get(key);
    return {
      "key": key,
      "Title": value["Title"], // Correct key name
      "Date": value['Date'],
      "Time": value['Time']
    };
  }).toList();

  setState(() {
    _items = data.reversed.toList();
    // we use "reversed" to sort items in order from the latest to the oldest
  });
}

  // Create new item
  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    _refreshItems(); // update the UI
  }

  TimeOfDay timeOfDay = TimeOfDay.now();
  TimeOfDay DateOfDay = TimeOfDay.now();
 
  void Showtimepicker() {
    showTimePicker(context: context, initialTime: timeOfDay).then((onValue) {
      setState(() {
        timeOfDay = onValue!;
        print('hello$timeOfDay');
      });
    });
  }

  Future<void> _showdatepicker() async {
    await showDatePicker(
        initialDate: DateTime.now(),
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100)).then((value) {
          setState(() {
            DateOfDay!=value;
            print('hellooo$DateOfDay');
          });
        },);
         
  }

    Future<void> _showMyDialog() async {
    bool localSwitchState = false; // Local state for the switch
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(
                'Create New Task',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Container(
                        width: 250.w,
                        height: 80.h,
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          controller: Task,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF262626)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF262626)),
                            ),
                            labelText: 'Type your Task',
                            labelStyle: GoogleFonts.poppins(
                              color: Color(0xFF7C7C7C),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              height: 0.10,
                            ),
                          ),
                          validator: (task) {
                            if (task!.isEmpty) {
                              return 'Enter your task';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(children: [
                        GestureDetector(
                            onTap: () {
                              Showtimepicker();
                            },
                            child: Icon(BootstrapIcons.clock,
                                color: Colors.black)),
                        SizedBox(width: 30.w),
                        GestureDetector(
                            onTap: () {
                              _showdatepicker();
                            },
                            child: Icon(BootstrapIcons.calendar,
                                color: Colors.black)),
                      ]),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(BootstrapIcons.bell, color: Colors.black),
                          SizedBox(width: 10.w),
                          Text(
                            'Notifications',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          Switch(
                            activeTrackColor: Color(0xFF2B68E4),
                            activeColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Color(0xFF1B1B1B),
                            value: localSwitchState,
                            onChanged: (newValue) {
                              setDialogState(() {
                                localSwitchState = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
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
                      _createItem({
                        "Title": Task.text,
                        "Date": '',
                        "Time": '',
                      });
                    }
                    Navigator.of(context).pop();
                    Task.clear();
                  },
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
      length: 2, // Number of tabs
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
            // Tasks Screen
            Container(
                color: Colors.amber,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: _items.isEmpty
          ? const Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 30),
              ),
            )
          : ListView.builder(
              // the list of items
              itemCount: _items.length,
              itemBuilder: (_, index) {
                final currentItem = _items[index];
                return Card(
                  color: Colors.orange.shade100,
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                      title: Text(currentItem['Title']),
                      // subtitle: Text(currentItem['quantity'].toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit button
                          // IconButton(
                          //     icon: const Icon(Icons.edit),
                          //     onPressed: () =>
                          //         _showForm(context, currentItem['key'])),
                          // // Delete button
                          // IconButton(
                          //   icon: const Icon(Icons.delete),
                          //   onPressed: () => _deleteItem(currentItem['key']),
                          // ),
                        ],
                      )),
                );
              }),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 600.h, left: 300.w),
                            child: FloatingActionButton(
                              onPressed: () {
                                _showMyDialog();
                              },
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.black,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )),
            // Completed Screen
            Container(
              color: Colors.greenAccent,
              child: Center(
                child: Text(
                  'Completed Screen',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
