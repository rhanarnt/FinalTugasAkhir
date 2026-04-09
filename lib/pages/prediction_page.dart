import 'package:flutter/material.dart';
import '../services/ml_service.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({Key? key}) : super(key: key);

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _predictionResult;

  final _tahunController = TextEditingController(text: '2024');
  final _bulanController = TextEditingController(text: '4');
  final _hariController = TextEditingController(text: '4');
  final _hariDalamMingguController = TextEditingController(text: '3');

  @override
  void initState() {
    super.initState();
    _checkAPIHealth();
  }

  Future<void> _checkAPIHealth() async {
    final isHealthy = await MLService.healthCheck();
    if (!isHealthy) {
      setState(() {
        _errorMessage = 'API tidak tersedia. Pastikan server Python sudah berjalan.';
      });
    }
  }

  Future<void> _predict() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _predictionResult = null;
    });

    try {
      final result = await MLService.prediksiStok(
        tahun: int.parse(_tahunController.text),
        bulan: int.parse(_bulanController.text),
        hari: int.parse(_hariController.text),
        hariDalamMinggu: int.parse(_hariDalamMingguController.text),
        hariMinggu: int.parse(_hariDalamMingguController.text),
        hargaSatuanUpdate: 50000,
        totalHargaUpdate: 250000,
        produkEncoded: 2,
        namaProdukEncoded: 2,
        kategoriProdukEncoded: 1,
      );

      setState(() {
        if (result['status'] == 'success') {
          _predictionResult = result;
          _errorMessage = null;
        } else {
          _errorMessage = result['message'] ?? 'Prediksi gagal';
          _predictionResult = null;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _predictionResult = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prediksi Permintaan Stok')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            TextField(controller: _tahunController, decoration: const InputDecoration(labelText: 'Tahun')),
            TextField(controller: _bulanController, decoration: const InputDecoration(labelText: 'Bulan')),
            TextField(controller: _hariController, decoration: const InputDecoration(labelText: 'Hari')),
            TextField(controller: _hariDalamMingguController, decoration: const InputDecoration(labelText: 'Hari Minggu')),
            const SizedBox(height: 20.0),
            ElevatedButton(onPressed: _isLoading ? null : _predict, style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)), child: _isLoading ? const CircularProgressIndicator() : const Text('PREDIKSI')),
            const SizedBox(height: 20.0),
            if (_predictionResult != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('HASIL PREDIKSI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12.0),
                      Text('Jumlah Unit: ${_predictionResult!['prediksi']['jumlah_unit']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('Nilai Raw: ${_predictionResult!['prediksi']['nilai_raw']}'),
                      const Divider(),
                      Text('R² Score: ${_predictionResult!['model_accuracy']['r2_score']}'),
                      Text('MAE: ${_predictionResult!['model_accuracy']['mae']}'),
                      Text('RMSE: ${_predictionResult!['model_accuracy']['rmse']}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tahunController.dispose();
    _bulanController.dispose();
    _hariController.dispose();
    _hariDalamMingguController.dispose();
    super.dispose();
  }
}
