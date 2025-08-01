import 'package:flutter/material.dart';
import 'package:skoring/introduction/onboarding.dart';
import 'package:skoring/screens/kaprog/siswa.dart';
import 'package:skoring/screens/walikelas/home.dart';
import 'package:skoring/navigation/button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/introduction',
      routes: {
        '/introduction': (context) => const IntroductionScreen(),
        '/role': (context) => const RoleSelectionScreen(),
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
