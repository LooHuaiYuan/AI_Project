import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
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
                  sections: _createChartSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 4,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildCategoryRow('Food', 71.52, 343.55, Colors.yellow),
                  _buildCategoryRow('Entertainment', 11.83, 56.85, Colors.red),
                  _buildCategoryRow('Shopping', 8.16, 39.20, Colors.blue),
                  _buildCategoryRow('Home', 6.86, 33.00, Colors.green),
                  _buildCategoryRow('Transportation', 1.61, 7.75, Colors.purple),
                ],
              ),
            ),
          ],
        ),
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

  List<PieChartSectionData> _createChartSections() {
    return [
      PieChartSectionData(
        color: Colors.yellow,
        value: 71.52,
        title: '71.5%',
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: 11.83,
        title: '11.8%',
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: 8.16,
        title: '8.2%',
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 6.86,
        title: '6.9%',
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: 1.61,
        title: '1.6%',
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExpenseChartPage(),
  ));
}
