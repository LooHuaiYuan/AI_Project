class Expense {
  final String category;
  final double totalPrice;
  final DateTime date;

  Expense({
    required this.category,
    required this.totalPrice,
    required this.date,
  });

  // Factory method to create an Expense object from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      category: json['category'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  // Method to convert an Expense object to JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'totalPrice': totalPrice,
      'date': date.toIso8601String(),
    };
  }
}
