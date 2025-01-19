import 'package:ai_project/ApiService.dart';
import 'package:ai_project/chart.dart';
import 'package:ai_project/scan.dart';
import 'package:flutter/material.dart';

void main() => runApp(MoneyTrackerApp());

class MoneyTrackerApp extends StatefulWidget {
  @override
  State<MoneyTrackerApp> createState() => _MoneyTrackerAppState();
}

class _MoneyTrackerAppState extends State<MoneyTrackerApp> {
  int _currentIndex = 0; // Move _currentIndex here for proper state management

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to the appropriate page
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ScannerApp()));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ExpenseChartPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MoneyTrackerPage(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class MoneyTrackerPage extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  MoneyTrackerPage({required this.currentIndex, required this.onItemTapped});

  /// Fetches data from the database
  Future<Map<String, dynamic>> fetchData() async {
    final apiService = ApiService(
      baseUrl:
      'https://script.google.com/macros/s/AKfycbyYoxXPEZmgXIdS63wpKXpgQXkoyD1pf_jxAFCXbOALxsGi5ij6bnigsn_dSk3XeWaV/exec',
    );
    try {
      final data = await apiService.get('');
      // Check if the response is a list
      if (data is List && data.isNotEmpty) {
        return Map<String, dynamic>.from(data.first); // Return the first item
      } else {
        throw Exception('Unexpected data format or empty list');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return {};
    }
  }

  /// Calculates the total expenses from the fetched data
  double calculateTotalExpense(List<dynamic> items) {
    return items.fold<double>(
      0.0,
          (total, item) => total + double.tryParse(item['amount'] ?? '0.0')!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: Text("Money Tracker", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data available."));
          }

          final data = snapshot.data!;
          final category = data['category'] ?? 'Unknown';
          final totalPrice = data['totalPrice'] ?? 0.0;
          final date = data['date'] ?? 'Unknown';

          return Column(
            children: [
              // Balance Summary
              Container(
                color: Colors.yellow[700],
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Expenses\n${totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                    Text("Income\n0",
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                    Text("Balance\n${(-totalPrice).toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                  ],
                ),
              ),
              // Expense List
              Expanded(
                child: ListView(
                  children: [
                    _buildDateHeader(date, totalPrice),
                    _buildExpenseItem(category, "-${totalPrice.toStringAsFixed(2)}", "assets/icons/food.png"),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add action for FAB
        },
        backgroundColor: Colors.yellow[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onItemTapped,
        selectedItemColor: Colors.yellow[700],
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Records"),
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ""), // Placeholder for FAB
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDateHeader(String date, double expenses) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Expenses: $expenses", style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(String category, String amount, String iconPath) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.pink[100],
        child: Image.asset('assets/icons/food.png', width: 48, height: 48), // Add your local icon assets
      ),
      title: Text(category, style: TextStyle(fontSize: 16)),
      trailing: Text(amount, style: TextStyle(fontSize: 16, color: Colors.red)),
    );
  }
}
