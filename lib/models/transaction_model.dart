class Transaction {
  final int id;
  final String productName;
  final String category;
  final int quantity;
  final int unitPrice;
  final int totalPrice;
  final DateTime date;

  Transaction({
    required this.id,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      productName: json['product_name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'] as int,
      totalPrice: json['total_price'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'category': category,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'date': date.toIso8601String(),
    };
  }

  Transaction copyWith({
    int? id,
    String? productName,
    String? category,
    int? quantity,
    int? unitPrice,
    int? totalPrice,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      date: date ?? this.date,
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, product: $productName, qty: $quantity, date: $date)';
}
