// lib/app.dart
import 'package:flutter/material.dart';
import 'screens/debug/debug_page.dart';
import 'screens/login/login_page.dart';
import 'screens/dashboard/dashboard_page.dart';
// Import other screens as needed

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart College App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/debug': (context) => DebugCreationPage(),
        '/dashboard': (context) => DashboardPage(),
        // Add more routes here as your app grows
      },
    );
  }
}
