import 'package:ai_project/ApiService.dart';
import 'package:ai_project/chart.dart';
import 'package:ai_project/scan.dart';
import 'package:flutter/material.dart';

import 'Expense.dart';

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

    // Use a Future.delayed to navigate after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index == 1) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ScannerApp()),
        );
      } else if (index == 2) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ExpenseChartPage()),
        );
      }
    });
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
  Future<List<Expense>> fetchData() async {
    final apiService = ApiService(
      baseUrl:
      'https://script.google.com/macros/s/AKfycbyVFFW2gQIUmegll0Z28RFUSK9VJPBc3PLh09YvotVIzCmt7zaIPHsq4n0KAQ2jUHV6aQ/exec',
    );
    try {
      final rawData = await apiService.get('');
      print(rawData); // Debugging: Check the raw data structure

      // Ensure rawData is treated as a List<dynamic>
      final data = (rawData as List<dynamic>)
          .map((item) {
        // Each item is a List<dynamic> with a known structure
        final list = item as List<dynamic>;
        return Expense(
          category: list[0] as String,
          totalPrice: (list[1] as num).toDouble(), // Ensure double conversion
          date: DateTime.parse(list[2] as String),
        );
      })
          .toList();

      return data;
    } catch (e) {
      print('Error fetching data: $e');
      return [];
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
      body: FutureBuilder<List<Expense>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data available."));
          }

          final expenses = snapshot.data!;

          // Group expenses by date
          final groupedExpenses = <String, List<Expense>>{};
          for (var expense in expenses) {
            final dateKey = expense.date.toLocal().toString().split(' ')[0]; // Format as 'YYYY-MM-DD'
            groupedExpenses.putIfAbsent(dateKey, () => []).add(expense);
          }

          // Calculate total expense
          final totalExpense = expenses.fold<double>(
            0.0,
                (sum, expense) => sum + expense.totalPrice,
          );

          return Column(
            children: [
              // Balance Summary
              Container(
                color: Colors.yellow[700],
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Expenses\n${totalExpense.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      "Income\n0",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      "Balance\n${(-totalExpense).toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),

              // Grouped List of Expenses
              Expanded(
                child: ListView.builder(
                  itemCount: groupedExpenses.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedExpenses.keys.elementAt(index);
                    final dateExpenses = groupedExpenses[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        _buildDateHeader(dateKey, 11),
                        // List of Expenses for the Date
                        ...dateExpenses.map(
                              (expense) => _buildExpenseItem(
                            expense.category,
                            "-${expense.totalPrice.toStringAsFixed(2)}",
                            "assets/icons/food.png", // Adjust icon as needed
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onItemTapped(2);
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
