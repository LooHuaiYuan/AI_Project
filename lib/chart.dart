import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'ApiService.dart';
import 'Expense.dart';

class ExpenseChartPage extends StatefulWidget {
  @override
  State<ExpenseChartPage> createState() => _ExpenseChartPageState();
}

class _ExpenseChartPageState extends State<ExpenseChartPage> {
  ApiService api = ApiService();

  Map<String, double> calculateCategoryTotals(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.totalPrice;
    }
    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
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
          final categoryTotals = calculateCategoryTotals(expenses);

          // Calculate total expenses and percentages
          final totalExpenses = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
          final chartSections = _createChartSections(categoryTotals, totalExpenses);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expense Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: chartSections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 4,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: categoryTotals.length,
                    itemBuilder: (context, index) {
                      final category = categoryTotals.keys.elementAt(index);
                      final total = categoryTotals[category]!;
                      final percentage = (total / totalExpenses) * 100;

                      return _buildCategoryRow(category, percentage, total, _getCategoryColor(index));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryRow(String category, double percentage, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text('$category (${percentage.toStringAsFixed(2)}%)'),
          ),
          Text('RM ${amount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createChartSections(Map<String, double> categoryTotals, double totalExpenses) {
    final colors = [Colors.yellow, Colors.red, Colors.blue, Colors.green, Colors.purple];

    return categoryTotals.entries.mapIndexed((index, entry) {
      final double? value = double.tryParse(entry.value.toString()); // Ensure value is explicitly a double
      final percentage = (value! / totalExpenses) * 100;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
      );
    }).toList();
  }


  Color _getCategoryColor(int index) {
    final colors = [Colors.yellow, Colors.red, Colors.blue, Colors.green, Colors.purple];
    return colors[index % colors.length];
  }
}

extension MapIndexed<K, V> on Iterable<MapEntry<K, V>> {
  List<T> mapIndexed<T>(T Function(int index, MapEntry<K, V> entry) f) {
    var index = 0;
    return map((e) => f(index++, e)).toList();
  }
}

