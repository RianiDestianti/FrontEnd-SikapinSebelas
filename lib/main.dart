import 'package:flutter/material.dart';
import 'screens/walikelas/home.dart';
import 'navigation/button.dart'; 

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
      
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionScreen(), 
        '/walikelas': (context) => const WalikelasMainScreen(), 
        '/kaprog': (context) => const KaprogMainScreen(), 
      },
      
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const RoleSelectionScreen(),
        );
      },
    );
  }
}