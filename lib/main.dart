import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notifications_tut/Provider/Task_provider.dart';
import 'package:notifications_tut/UI/Splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'notification/notification.dart'; // Ensure you have a properly implemented NotificationService

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('shopping_box');
  await Hive.openBox('completed_box');
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init(); // Initialize notification service
  tz.initializeTimeZones(); // Initialize timezone data

    runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(390, 845),
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: SplashScreen(),
          );
        });
  }
}
