import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifications_tut/UI/Home_page.dart';

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

  _navigateotherscreen() async {
    await Future.delayed(Duration(seconds:6), () async {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/rafiki.png',
            height: 100.h,
            width: 100.w,
          ),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Taskly',
                textStyle: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600,
                ),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 4,
            pause: const Duration(seconds: 2),
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
          )
        ],
      )),
      floatingActionButton: Center(
        child: Column( mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Created By',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
             Text(                                                                            
              'Salih',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
