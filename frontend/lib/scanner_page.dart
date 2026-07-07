import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'log_store.dart';
import 'log_page.dart';
import 'barcode_service.dart';
import 'product_display.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool scanned = false;
  bool loading = false;
  String? lastBarcode;
  Map<String, dynamic>? productData;

  Future<void> sendBarcode(String barcode) async {
    setState(() {
      loading = true;
      productData = null;
    });

    try {
      final data = await BarcodeService.fetchProductData(barcode);
      setState(() {
        productData = data;
        loading = false;
        lastBarcode = barcode;
      });
    } catch (e) {
      setState(() {
        loading = false;
        scanned = false;
      });
      _showErrorDialog('Error', e.toString());
    }
  }

  void _saveToLog() {
    if (productData == null) return;

    final barcode = lastBarcode ?? 'Unknown';
    LogStore.instance.add(LogEntry(
      barcode: barcode,
      name: productData!['name'] ?? 'Unknown',
      calories: (productData!['calories'] is num)
          ? (productData!['calories'] as num).toDouble()
          : double.tryParse(productData!['calories']?.toString() ?? ''),
      proteins: (productData!['proteins'] is num)
          ? (productData!['proteins'] as num).toDouble()
          : double.tryParse(productData!['proteins']?.toString() ?? ''),
      fats: (productData!['fats'] is num)
          ? (productData!['fats'] as num).toDouble()
          : double.tryParse(productData!['fats']?.toString() ?? ''),
      carbs: (productData!['carbs'] is num)
          ? (productData!['carbs'] as num).toDouble()
          : double.tryParse(productData!['carbs']?.toString() ?? ''),
      sugar: (productData!['sugar'] is num)
          ? (productData!['sugar'] as num).toDouble()
          : double.tryParse(productData!['sugar']?.toString() ?? ''),
      ingredients: productData!['ingredients']?.toString(),
    ));

    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LogPage()));
    }
  }

  void _resetScanner() {
    setState(() {
      scanned = false;
      productData = null;
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                scanned = false;
              });
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Barcode"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : productData != null
              ? Column(
                  children: [
                    Expanded(
                      child: ProductDetailsDisplay(foodData: productData!),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _resetScanner,
                              icon: const Icon(Icons.refresh),
                              label: const Text("Scan Again"),
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
                )
              : Stack(
                  children: [
                    MobileScanner(
                      onDetect: (barcodeCapture) {
                        if (scanned) return;
                        if (barcodeCapture.barcodes.isEmpty) return;

                        final barcode = barcodeCapture.barcodes.first;
                        final String? code = barcode.rawValue;

                        if (code != null) {
                          setState(() {
                            scanned = true;
                          });
                          lastBarcode = code;
                          sendBarcode(code);
                        }
                      },
                    ),
                    _buildScannerOverlay(),
                  ],
                ),
    );
  }
}

Widget _buildScannerOverlay() {
  return IgnorePointer(
    child: Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
          ),
        ),
        Center(
          child: Container(
            width: 320,
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.greenAccent, width: 2),
              color: Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AnimatedScanLine(),
            ),
          ),
        ),
      ],
    ),
  );
}

class AnimatedScanLine extends StatefulWidget {
  const AnimatedScanLine({super.key});

  @override
  State<AnimatedScanLine> createState() => _AnimatedScanLineState();
}

class _AnimatedScanLineState extends State<AnimatedScanLine> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanLinePainter(progress: _ctrl.value),
        );
      },
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double progress;
  _ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, Colors.greenAccent.withValues(alpha: 0.9), Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final y = size.height * progress;
    canvas.drawRect(Rect.fromLTWH(0, y - 2, size.width, 4), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) => oldDelegate.progress != progress;
}
