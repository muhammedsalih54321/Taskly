import 'package:flutter/material.dart';
import 'package:task_list/Ui/Home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
   @override
  void initState() {
    super.initState();
    _navigateotherscreen();
  }
 _navigateotherscreen()async{
  await Future.delayed(Duration(seconds: 3), ()async{

Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));


  });
 
 }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('assets/images/rafiki.png')),
    );
  }
}