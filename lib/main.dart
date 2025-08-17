import 'package:flutter/material.dart';
import 'package:skoring/screens/introduction/onboarding.dart';
import 'package:skoring/screens/kaprog/student.dart';
import 'package:skoring/screens/walikelas/home.dart';
import 'package:skoring/screens/kaprog/report.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skoring App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/introduction',
      routes: {
        '/introduction': (context) => const IntroductionScreen(),
        '/walikelas': (context) => const WalikelasMainScreen(),
        '/kaprog': (context) => const ProgramKeahlianScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const IntroductionScreen(),
        );
      },
    );
  }
}
