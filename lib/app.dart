import 'package:ai_project/ApiService.dart';
import 'package:ai_project/chart.dart';
import 'package:ai_project/scan.dart';
import 'package:flutter/material.dart';
import 'Expense.dart';
import 'home.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MoneyTrackerPage(),
    ScannerApp(), // Replace this with the scan page
    ExpenseChartPage(), // Replace this with the chart page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _pages[_currentIndex], // Dynamically switch pages
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.yellow[700],
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "Records"),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Scan"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
          ],
        ),
      ),
    );
  }
}
