class PredictionRequest {
  final String tanggal;
  final String produk;
  final String kategori;
  final int harga;

  PredictionRequest({
    required this.tanggal,
    required this.produk,
    required this.kategori,
    required this.harga,
  });

  Map<String, dynamic> toJson() => {
    'tanggal': tanggal,
    'produk': produk,
    'kategori': kategori,
    'harga': harga,
  };
}

class PredictionResult {
  final String status;
  final int? jumlahUnit;
  final double? nilaiRaw;
  final int? estimasiTotalHarga;
  final double? akurasiR2;
  final double? errorMae;
  final String? message;

  PredictionResult({
    required this.status,
    this.jumlahUnit,
    this.nilaiRaw,
    this.estimasiTotalHarga,
    this.akurasiR2,
    this.errorMae,
    this.message,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      status: json['status'] ?? 'error',
      jumlahUnit: json['prediksi']?['jumlah_unit'],
      nilaiRaw: (json['prediksi']?['nilai_raw'] ?? 0).toDouble(),
      estimasiTotalHarga: json['prediksi']?['estimasi_total_harga'],
      akurasiR2: (json['model_info']?['akurasi_r2'] ?? 0).toDouble(),
      errorMae: (json['model_info']?['error_mae'] ?? 0).toDouble(),
      message: json['message'],
    );
  }

  bool get isSuccess => status == 'success';
}

class PredictionHistory {
  final String tanggal;
  final String produk;
  final String kategori;
  final int harga;
  final int prediksi;
  final DateTime timestamp;

  PredictionHistory({
    required this.tanggal,
    required this.produk,
    required this.kategori,
    required this.harga,
    required this.prediksi,
    required this.timestamp,
  });
}
