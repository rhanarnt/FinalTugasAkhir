class Product {
  final int id;
  final String name;
  final String category;
  final int price;
  final double stock;
  final double minStock;
  final String unit;
  final String status; // 'tersedia', 'sedang', 'kritis'

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.minStock = 0,
    this.unit = 'kg',
    this.status = 'tersedia',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final stockRaw = json['stock'] ?? json['current_stock'] ?? 0;
    final minStockRaw = json['min_stock'] ?? json['stok_minimum'] ?? 0;
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      price: json['price'] as int,
      stock:
          stockRaw is num
              ? stockRaw.toDouble()
              : double.tryParse(stockRaw.toString()) ?? 0,
      minStock:
          minStockRaw is num
              ? minStockRaw.toDouble()
              : double.tryParse(minStockRaw.toString()) ?? 0,
      unit: (json['unit'] as String?) ?? 'kg',
      status: json['status'] as String? ?? 'tersedia',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'min_stock': minStock,
      'unit': unit,
      'status': status,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? category,
    int? price,
    double? stock,
    double? minStock,
    String? unit,
    String? status,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      status: status ?? this.status,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, stock: $stock)';
}
