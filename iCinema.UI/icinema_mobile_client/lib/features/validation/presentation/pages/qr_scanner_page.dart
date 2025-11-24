import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/validation_cubit.dart';
import '../../data/models/validation_result.dart';
import '../widgets/validation_result_dialog.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final code = barcode.rawValue;

    if (code != null && code.isNotEmpty) {
      setState(() => _isProcessing = true);
      context.read<ValidationCubit>().validateTicket(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ValidationCubit, ValidationState>(
      listener: (context, state) {
        if (state is ValidationSuccess) {
          _controller.stop();
          _showResultDialog(context, state.result);
        } else if (state is ValidationError) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Skeniraj QR kod'),
          actions: [
            IconButton(
              icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
              onPressed: () async {
                await _controller.toggleTorch();
                setState(() {
                  _isTorchOn = !_isTorchOn;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: () => _controller.switchCamera(),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
            // Overlay with scanning frame
            CustomPaint(
              painter: ScannerOverlay(),
              child: Container(),
            ),
            // Instructions
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pozicionirajte QR kod unutar okvira',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Loading indicator
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, ValidationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ValidationResultDialog(
        result: result,
        onClose: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
        onScanAnother: () {
          Navigator.of(ctx).pop();
          setState(() => _isProcessing = false);
          _controller.start();
          context.read<ValidationCubit>().startScanning();
        },
      ),
    );
  }
}

// Custom painter for scanner overlay
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );

    // Draw overlay with cutout
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(16)))
          ..close(),
      ),
      paint,
    );

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const bracketLength = 30.0;

    // Top-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top + bracketLength),
      Offset(scanArea.left, scanArea.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left + bracketLength, scanArea.top),
      bracketPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(scanArea.right - bracketLength, scanArea.top),
      Offset(scanArea.right, scanArea.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right, scanArea.top + bracketLength),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom - bracketLength),
      Offset(scanArea.left, scanArea.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left + bracketLength, scanArea.bottom),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(scanArea.right - bracketLength, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom - bracketLength),
      Offset(scanArea.right, scanArea.bottom),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
