import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:phishguard_app/features/scanner/presentation/url_scan_screen.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _scanned = true;
    _controller.stop();

    // Scan via API
    ref.read(scanStateProvider.notifier).scan(rawValue, 'QR');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(scanStateProvider, (_, next) {
      if (next is ScanDone) {
        context.go('/scan/result', extra: next.result.toJson());
        ref.read(scanStateProvider.notifier).reset();
        setState(() => _scanned = false);
        _controller.start();
      }
      if (next is ScanFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: AppColors.danger),
        );
        ref.read(scanStateProvider.notifier).reset();
        setState(() => _scanned = false);
        _controller.start();
      }
    });

    final scanState = ref.watch(scanStateProvider);
    final isLoading = scanState is ScanLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(AppStrings.qrScanner),
        actions: [
          // Flash toggle
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              color: _torchOn ? AppColors.warning : AppColors.textSecondary,
            ),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Scan overlay
          _ScanOverlay(),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) ...[
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Analyzing QR code...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ] else ...[
                    const Text(
                      'Point camera at QR code',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rescan button
                    if (_scanned)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _scanned = false);
                          _controller.start();
                        },
                        icon: const Icon(Icons.refresh, color: AppColors.primary),
                        label: const Text('Rescan',
                            style: TextStyle(color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const cutoutSize = 260.0;

    return Stack(
      children: [
        // Dark overlay with cutout
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: cutoutSize,
                  height: cutoutSize,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Corner markers
        Center(
          child: SizedBox(
            width: cutoutSize,
            height: cutoutSize,
            child: Stack(
              children: [
                // Top-left corner
                Positioned(
                  top: 0, left: 0,
                  child: _CornerMarker(isTopLeft: true),
                ),
                // Top-right corner
                Positioned(
                  top: 0, right: 0,
                  child: _CornerMarker(isTopRight: true),
                ),
                // Bottom-left corner
                Positioned(
                  bottom: 0, left: 0,
                  child: _CornerMarker(isBottomLeft: true),
                ),
                // Bottom-right corner
                Positioned(
                  bottom: 0, right: 0,
                  child: _CornerMarker(isBottomRight: true),
                ),

                // Scanning line animation
                _ScanLine(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CornerMarker extends StatelessWidget {
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  const _CornerMarker({
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _CornerPainter(
          isTopLeft: isTopLeft,
          isTopRight: isTopRight,
          isBottomLeft: isBottomLeft,
          isBottomRight: isBottomRight,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTopLeft, isTopRight, isBottomLeft, isBottomRight;

  _CornerPainter({
    required this.isTopLeft,
    required this.isTopRight,
    required this.isBottomLeft,
    required this.isBottomRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isTopLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTopRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (isBottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (isBottomRight) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

class _ScanLine extends StatefulWidget {
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Positioned(
          top: _anim.value * 240,
          left: 10,
          right: 10,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
