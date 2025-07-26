import 'package:flutter/material.dart';
import 'walikelas/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walikelas App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      
      // Routes configuration
      initialRoute: '/',
      routes: {
        '/': (context) => const WalikelasMainScreen(),
        '/home': (context) => const WalikelasMainScreen(),
      },
      
      // Optional: Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const WalikelasMainScreen(),
        );
      },
    );
  }
}