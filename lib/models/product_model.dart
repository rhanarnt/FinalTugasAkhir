class Product {
  final int id;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String unit;
  final String status; // 'tersedia', 'rendah', 'kritis'

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.unit = 'kg',
    this.status = 'tersedia',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      price: json['price'] as int,
      stock: json['stock'] as int,
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
      'unit': unit,
      'status': status,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? category,
    int? price,
    int? stock,
    String? unit,
    String? status,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      status: status ?? this.status,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, stock: $stock)';
}
