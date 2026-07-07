import 'package:flutter/material.dart';
import 'log_store.dart';
import 'log_page.dart';
import 'product_display.dart';
import 'barcode_service.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  TextEditingController barcodeController = TextEditingController();
  Map<String, dynamic>? foodData;
  String? errorMessage;
  bool loading = false;
  String? lastBarcode;

  Future<void> fetchFoodData(String barcode) async {
    if (barcode.isEmpty) {
      setState(() {
        errorMessage = "Please enter a barcode number";
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      foodData = null;
    });

    try {
      final data = await BarcodeService.fetchProductData(barcode);
      setState(() {
        foodData = data;
        loading = false;
        lastBarcode = barcode;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  void _saveToLog() {
    if (foodData == null || lastBarcode == null) return;

    LogStore.instance.add(LogEntry(
      barcode: lastBarcode!,
      name: foodData!['name'] ?? 'Unknown',
      calories: (foodData!['calories'] is num)
          ? (foodData!['calories'] as num).toDouble()
          : double.tryParse(foodData!['calories']?.toString() ?? ''),
      proteins: (foodData!['proteins'] is num)
          ? (foodData!['proteins'] as num).toDouble()
          : double.tryParse(foodData!['proteins']?.toString() ?? ''),
      fats: (foodData!['fats'] is num)
          ? (foodData!['fats'] as num).toDouble()
          : double.tryParse(foodData!['fats']?.toString() ?? ''),
      carbs: (foodData!['carbs'] is num)
          ? (foodData!['carbs'] as num).toDouble()
          : double.tryParse(foodData!['carbs']?.toString() ?? ''),
      sugar: (foodData!['sugar'] is num)
          ? (foodData!['sugar'] as num).toDouble()
          : double.tryParse(foodData!['sugar']?.toString() ?? ''),
      ingredients: foodData!['ingredients']?.toString(),
    ));

    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LogPage()));
    }
  }

  void _resetForm() {
    setState(() {
      barcodeController.clear();
      foodData = null;
      errorMessage = null;
      loading = false;
      lastBarcode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manual Barcode Entry"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (foodData != null && !loading) {
      return Column(
        children: [
          Expanded(
            child: ProductDetailsDisplay(foodData: foodData!),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Search Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveToLog,
                    icon: const Icon(Icons.check),
                    label: const Text("Save & View Log"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1abc9c),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: barcodeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter Barcode",
              hintText: "Scan or type barcode number",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              fetchFoodData(barcodeController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1abc9c),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text("Search", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 20),
          if (loading)
            const CircularProgressIndicator()
          else if (errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red.shade800),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }
}

