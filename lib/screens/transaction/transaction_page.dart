import 'package:finalproject/theme/colors.dart';
import 'package:finalproject/theme/text_styles.dart';
import 'package:flutter/material.dart';

import 'transaction_controller.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late final TransactionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransactionController();
    _controller.loadProducts().catchError((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal memuat data produk'),
          backgroundColor: AppColors.statusError,
        ),
      );
    });
  }

  void _addToCart() {
    final error = _controller.addToCart();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.statusError),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_controller.selectedProduct} ditambahkan ke keranjang',
        ),
        backgroundColor: AppColors.statusSuccess,
      ),
    );
  }

  Future<void> _submitAllTransactions() async {
    final result = await _controller.submitAllTransactions();

    if (!mounted) return;

    if (result['status'] == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    final successCount = result['successCount'] as int;
    final totalCount = result['totalCount'] as int;
    final firstError = result['error'] as String?;

    if (firstError != null && successCount < totalCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ $successCount/$totalCount Stock In berhasil. Error: $firstError',
          ),
          backgroundColor: AppColors.statusError,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ $successCount Stock In berhasil disimpan dan stok terupdate!',
          ),
          backgroundColor: AppColors.statusSuccess,
        ),
      );
    }
  }

  void _showAddProductDialog() {
    final newProductNameController = TextEditingController();
    final newPriceController = TextEditingController();
    final newStockController = TextEditingController();
    const unitOptionsByType = {
      'Bahan': ['kg'],
      'Barang': ['pcs'],
    };
    String selectedProductType = 'Bahan';
    String selectedUnit = unitOptionsByType['Bahan']!.first;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                                Text(
                                  'Jenis Kategori',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: selectedProductType,
                                  items:
                                      ['Bahan', 'Barang']
                                          .map(
                                            (type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(type),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setStateDialog(() {
                                      selectedProductType = value;
                                      selectedUnit =
                                          unitOptionsByType[value]!.first;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Pilih jenis kategori',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.bgLight,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Satuan',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: selectedUnit,
                                  items:
                                      unitOptionsByType[selectedProductType]!
                                          .map(
                                            (unit) => DropdownMenuItem(
                                              value: unit,
                                              child: Text(unit),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setStateDialog(() {
                                      selectedUnit = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Pilih satuan',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.bgLight,
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                const SizedBox(height: 16),
                                Text(
                                  'Stok Awal',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: newStockController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan jumlah stok awal',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.bgLight,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          side: BorderSide(
                                            color: AppColors.textSecondary,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Batal',
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final productName =
                                              newProductNameController.text
                                                  .trim();
                                          final category = selectedProductType;
                                          final priceText =
                                              newPriceController.text.trim();
                                          final stockText =
                                              newStockController.text.trim();

                                          if (productName.isEmpty ||
                                              category.isEmpty ||
                                              priceText.isEmpty ||
                                              stockText.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Semua field harus diisi',
                                                ),
                                                backgroundColor:
                                                    AppColors.statusError,
                                              ),
                                            );
                                            return;
                                          }

                                          final priceInt =
                                              int.tryParse(priceText) ?? 0;
                                          if (priceInt <= 0) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Harga harus lebih dari 0',
                                                ),
                                                backgroundColor:
                                                    AppColors.statusError,
                                              ),
                                            );
                                            return;
                                          }

                                          final stockInt =
                                              int.tryParse(stockText) ?? -1;
                                          if (stockInt < 0) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Stok awal tidak boleh negatif',
                                                ),
                                                backgroundColor:
                                                    AppColors.statusError,
                                              ),
                                            );
                                            return;
                                          }

                                          final result = await _controller
                                              .createProduct(
                                                productName: productName,
                                                category: category,
                                                price: priceInt,
                                                initialStock: stockInt,
                                                unit: selectedUnit,
                                                productType:
                                                    selectedProductType,
                                              );

                                          if (!mounted) return;

                                          if (result['status'] == 'success') {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Produk "$productName" berhasil ditambahkan',
                                                ),
                                                backgroundColor:
                                                    AppColors.statusSuccess,
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  result['message'] ??
                                                      'Gagal menambahkan produk',
                                                ),
                                                backgroundColor:
                                                    AppColors.statusError,
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryBrown,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Simpan',
                                          style: AppTextStyles.labelLarge
                                              .copyWith(color: Colors.white),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgLight,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBrown,
            elevation: 0,
            title: Text(
              ' Stock In',
              style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
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
                        Text(
                          'Produk',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _controller.selectedProduct,
                          decoration: InputDecoration(
                            hintText: 'Pilih produk',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: AppColors.bgLight,
                          ),
                          items:
                              _controller.products
                                  .map(
                                    (product) => DropdownMenuItem(
                                      value: product,
                                      child: Text(product),
                                    ),
                                  )
                                  .toList(),
                          onChanged: _controller.setSelectedProduct,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Jumlah',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller.quantityController,
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
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showAddProductDialog,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Tambah Produk Baru'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: AppColors.secondaryBlue),
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
                  if (_controller.cartItems.isNotEmpty) ...[
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
                                'Keranjang (${_controller.cartItems.length})',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: _controller.clearCart,
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _controller.cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _controller.cartItems[index];
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
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Rp ${item.unitPrice} / unit',
                                                style: AppTextStyles.labelSmall
                                                    .copyWith(
                                                      color:
                                                          AppColors
                                                              .textSecondary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Rp ${item.totalPrice}',
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
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
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap:
                                                  () => _controller
                                                      .updateQuantity(
                                                        index,
                                                        item.quantity - 1,
                                                      ),
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
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(width: 12),
                                            GestureDetector(
                                              onTap:
                                                  () => _controller
                                                      .updateQuantity(
                                                        index,
                                                        item.quantity + 1,
                                                      ),
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
                                        GestureDetector(
                                          onTap:
                                              () => _controller.removeFromCart(
                                                index,
                                              ),
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
                                'Rp ${_controller.totalPrice}',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.primaryBrown,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tanggal Stock In',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    _controller.selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null &&
                                  picked != _controller.selectedDate) {
                                _controller.setSelectedDate(picked);
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
                                    _controller.selectedDate != null
                                        ? '${_controller.selectedDate!.day}/${_controller.selectedDate!.month}/${_controller.selectedDate!.year}'
                                        : 'Pilih tanggal',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _controller.isLoading
                                      ? null
                                      : _submitAllTransactions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBrown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon:
                                  _controller.isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Icon(Icons.check_circle),
                              label: Text(
                                _controller.isLoading
                                    ? 'Menyimpan...'
                                    : 'Simpan Stock In',
                                style: AppTextStyles.labelLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Riwayat Stock In (${_controller.transactions.length})',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_controller.transactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 64,
                              color: AppColors.grey300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada Stock In',
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
                      itemCount: _controller.transactions.length,
                      itemBuilder: (context, index) {
                        final tx = _controller.transactions[index];
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
            currentIndex: _controller.selectedIndex,
            onTap: (index) {
              _controller.setSelectedIndex(index);
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
                case 5:
                  Navigator.of(context).pushNamed('/settings');
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
                label: 'Stock In',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up_outlined),
                label: 'Prediksi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined),
                label: 'Laporan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: 'Pengaturan',
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
