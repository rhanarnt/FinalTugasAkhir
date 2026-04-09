import 'package:flutter/material.dart';
import 'package:finalproject/theme/colors.dart';
import 'package:finalproject/theme/text_styles.dart';
import 'package:finalproject/models/transaction_model.dart';
import 'package:finalproject/services/ml_service.dart';

class CartItem {
  final String productName;
  final String category;
  final int unitPrice;
  int quantity;

  CartItem({
    required this.productName,
    required this.category,
    required this.unitPrice,
    required this.quantity,
  });

  int get totalPrice => unitPrice * quantity;
}

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late TextEditingController _quantityController;
  DateTime? _selectedDate;
  bool _isLoading = false;
  int _selectedIndex = 2; // Transaction tab

  // Products list (mutable)
  late List<String> products;
  late Map<String, String> productCategories;
  late Map<String, int> productPrices;
  late List<String> categories;

  String? _selectedProduct;
  List<CartItem> cartItems = [];
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    // Initialize products
    products = [
      'Tepung Terigu 1kg',
      'Telur 1kg',
      'Gula Pasir 1kg',
      'Susu Bubuk',
      'Cokelat Bubuk 250gr',
      'Mentega 500gr',
      'Keju Parut 250gr',
      'Baking Powder',
    ];

    productCategories = {
      'Tepung Terigu 1kg': 'Tepung',
      'Telur 1kg': 'Telur',
      'Gula Pasir 1kg': 'Gula',
      'Susu Bubuk': 'Susu',
      'Cokelat Bubuk 250gr': 'Cokelat',
      'Mentega 500gr': 'Mentega',
      'Keju Parut 250gr': 'Keju',
      'Baking Powder': 'Bahan Tambahan',
    };

    productPrices = {
      'Tepung Terigu 1kg': 15000,
      'Telur 1kg': 35000,
      'Gula Pasir 1kg': 20000,
      'Susu Bubuk': 45000,
      'Cokelat Bubuk 250gr': 35000,
      'Mentega 500gr': 50000,
      'Keju Parut 250gr': 40000,
      'Baking Powder': 12000,
    };

    // Extract unique categories
    categories = productCategories.values.toSet().toList();

    _quantityController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_selectedProduct == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih produk dan masukkan jumlah'),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Jumlah harus lebih dari 0'),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    final existingIndex =
        cartItems.indexWhere((item) => item.productName == _selectedProduct);

    setState(() {
      if (existingIndex >= 0) {
        // Update quantity if product already in cart
        cartItems[existingIndex].quantity += quantity;
      } else {
        // Add new item to cart
        cartItems.add(
          CartItem(
            productName: _selectedProduct!,
            category: productCategories[_selectedProduct!]!,
            unitPrice: productPrices[_selectedProduct!]!,
            quantity: quantity,
          ),
        );
      }
      _quantityController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_selectedProduct ditambahkan ke keranjang'),
        backgroundColor: AppColors.statusSuccess,
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
    } else {
      setState(() {
        cartItems[index].quantity = newQuantity;
      });
    }
  }

  int _getTotalPrice() {
    return cartItems.fold(0, (total, item) => total + item.totalPrice);
  }

  void _submitAllTransactions() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Keranjang kosong'),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      for (final item in cartItems) {
        await MLService.saveTransaction(
          productName: item.productName,
          category: item.category,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.totalPrice,
          transactionDate: dateStr,
        );

        // Add to transaction history
        final transaction = Transaction(
          id: transactions.length + 1,
          productName: item.productName,
          category: item.category,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.totalPrice,
          date: _selectedDate ?? DateTime.now(),
        );

        transactions.insert(0, transaction);
      }

      setState(() {
        _isLoading = false;
        cartItems.clear();
        _selectedDate = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('✅ ${transactions.length} transaksi berhasil disimpan!'),
          backgroundColor: AppColors.statusSuccess,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.statusError,
        ),
      );
    }
  }

  void _showAddProductDialog() {
    final TextEditingController newProductNameController =
        TextEditingController();
    final TextEditingController newCategoryController = TextEditingController();
    final TextEditingController newPriceController = TextEditingController();
    String _selectedCategory = categories.isNotEmpty ? categories.first : '';
    bool _createNewCategory = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrown,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Tambah Produk Baru',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          'Nama Produk',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: newProductNameController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan nama produk',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: AppColors.bgLight,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Category Selection
                        Text(
                          'Kategori',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!_createNewCategory)
                          Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedCategory.isNotEmpty
                                    ? _selectedCategory
                                    : null,
                                items: categories
                                    .map((cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setStateDialog(
                                    () => _selectedCategory = value ?? '',
                                  );
                                },
                                decoration: InputDecoration(
                                  hintText: 'Pilih kategori',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.bgLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  setStateDialog(
                                      () => _createNewCategory = true);
                                },
                                child: Text(
                                  '+ Tambah kategori baru',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.secondaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              TextFormField(
                                controller: newCategoryController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan nama kategori baru',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.bgLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  setStateDialog(
                                      () => _createNewCategory = false);
                                  newCategoryController.clear();
                                },
                                child: Text(
                                  '← Kembali ke kategori existing',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),

                        // Price
                        Text(
                          'Harga (Rp)',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: newPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Masukkan harga',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: AppColors.bgLight,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(
                                    color: AppColors.textSecondary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Batal',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final productName =
                                      newProductNameController.text.trim();
                                  final category = _createNewCategory
                                      ? newCategoryController.text.trim()
                                      : _selectedCategory;
                                  final price = newPriceController.text.trim();

                                  if (productName.isEmpty ||
                                      category.isEmpty ||
                                      price.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Semua field harus diisi'),
                                        backgroundColor:
                                            AppColors.statusError,
                                      ),
                                    );
                                    return;
                                  }

                                  final priceInt =
                                      int.tryParse(price) ?? 0;
                                  if (priceInt <= 0) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Harga harus lebih dari 0'),
                                        backgroundColor:
                                            AppColors.statusError,
                                      ),
                                    );
                                    return;
                                  }

                                  // Add new product
                                  setState(() {
                                    products.add(productName);
                                    productCategories[productName] =
                                        category;
                                    productPrices[productName] = priceInt;

                                    // Add new category if created
                                    if (_createNewCategory &&
                                        !categories.contains(category)) {
                                      categories.add(category);
                                    }
                                  });

                                  Navigator.pop(context);

                                  // Show success message
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Produk "$productName" berhasil ditambahkan'),
                                      backgroundColor:
                                          AppColors.statusSuccess,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBrown,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Simpan',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBrown,
        elevation: 0,
        title: Text(
          'Transaksi Penjualan',
          style: AppTextStyles.headlineLarge.copyWith(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form card untuk memilih produk
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.shadowLight],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Produk',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product dropdown
                    Text(
                      'Produk',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedProduct,
                      decoration: InputDecoration(
                        hintText: 'Pilih produk',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: AppColors.bgLight,
                      ),
                      items: products
                          .map((product) => DropdownMenuItem(
                                value: product,
                                child: Text(product),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedProduct = value);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Quantity input
                    Text(
                      'Jumlah',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Masukkan jumlah unit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: AppColors.bgLight,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addToCart,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Tambah ke Keranjang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBrown,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add new product button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showAddProductDialog,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Tambah Produk Baru'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: AppColors.secondaryBlue,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cart section
              if (cartItems.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [AppColors.shadowLight],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Keranjang (${cartItems.length})',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => cartItems.clear());
                            },
                            child: Text(
                              'Hapus Semua',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.statusError,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Cart items list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bgLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.grey300),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rp ${item.unitPrice} / unit',
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Rp ${item.totalPrice}',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: AppColors.statusSuccess,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Quantity controls
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _updateQuantity(index, item.quantity - 1),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryBrown,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          item.quantity.toString(),
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () =>
                                              _updateQuantity(index, item.quantity + 1),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryBrown,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Delete button
                                    GestureDetector(
                                      onTap: () => _removeFromCart(index),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.statusError
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.delete,
                                          color: AppColors.statusError,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Total price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Rp ${_getTotalPrice()}',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.primaryBrown,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Date picker
                      Text(
                        'Tanggal Transaksi',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppColors.primaryBrown,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : 'Pilih tanggal',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitAllTransactions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.check_circle),
                          label: Text(
                            _isLoading ? 'Menyimpan...' : 'Simpan Transaksi',
                            style: AppTextStyles.labelLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Transactions history
              Text(
                'Riwayat Transaksi (${transactions.length})',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              if (transactions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 64, color: AppColors.grey300),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada transaksi',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tx.productName,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Rp ${tx.totalPrice}',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.statusSuccess,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${tx.quantity} unit × Rp ${tx.unitPrice}',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              Navigator.of(context).pushNamed('/dashboard');
              break;
            case 1:
              Navigator.of(context).pushNamed('/products');
              break;
            case 2:
              break;
            case 3:
              Navigator.of(context).pushNamed('/prediction');
              break;
            case 4:
              Navigator.of(context).pushNamed('/reports');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            label: 'Prediksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}
