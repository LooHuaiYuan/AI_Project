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
      ),
    );
  }
}

class MoneyTrackerPage extends StatelessWidget {

  ApiService api = new ApiService(baseUrl: "https://script.google.com/macros/s/AKfycbyVFFW2gQIUmegll0Z28RFUSK9VJPBc3PLh09YvotVIzCmt7zaIPHsq4n0KAQ2jUHV6aQ/exec");

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
        future: api.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data available."));
          }

          final expenses = snapshot.data!;

          // Group expenses by date and calculate daily totals
          final groupedExpenses = <String, List<Expense>>{};
          final dailyTotals = <String, double>{};
          for (var expense in expenses) {
            final dateKey = expense.date.toLocal().toString().split(' ')[0]; // Format as 'YYYY-MM-DD'
            groupedExpenses.putIfAbsent(dateKey, () => []).add(expense);
            dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + expense.totalPrice;
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
                    final dailyTotal = dailyTotals[dateKey]!;


                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        _buildDateHeaderWithTotal(dateKey, dailyTotal),
                        // List of Expenses for the Date
                        ...dateExpenses.map(
                              (expense) => _buildExpenseItem(
                            expense.category,
                            "-${expense.totalPrice.toStringAsFixed(2)}",
                            "assets/icons/${expense.category}.png", // Adjust icon as needed
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
    );
  }

  Widget _buildDateHeaderWithTotal(String date, double dailyTotal) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Date: $date",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "Total: ${dailyTotal.toStringAsFixed(2)}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }


  Widget _buildExpenseItem(String category, String amount, String iconPath) {
    var width = 48.0;
    var height = 48.0;
    if(category == "Entertainment"){
      width = 28;
      height = 28;
    }
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.pink[100],
        child: Image.asset('assets/icons/$category.png',
            width: width, height: height
        ), // Add your local icon assets
      ),
      title: Text(category, style: TextStyle(fontSize: 16)),
      trailing: Text(amount, style: TextStyle(fontSize: 16, color: Colors.red)),
    );
  }
}
