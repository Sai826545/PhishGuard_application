import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';

final mapHotspotsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/dashboard/map-hotspots');
  final items = response.data['data'] as List<dynamic>;
  return items.map((e) => e as Map<String, dynamic>).toList();
});

class ScamMapWidget extends ConsumerStatefulWidget {
  const ScamMapWidget({super.key});

  @override
  ConsumerState<ScamMapWidget> createState() => _ScamMapWidgetState();
}

class _ScamMapWidgetState extends ConsumerState<ScamMapWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Map<String, dynamic>? _selectedHotspot;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotspotsAsync = ref.watch(mapHotspotsProvider);

    return PGCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Live Threat Radar (India)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'LIVE FEED',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Map Canvas Section
          hotspotsAsync.when(
            loading: () => const SizedBox(
              height: 280,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            error: (_, __) => const SizedBox(
              height: 280,
              child: Center(
                child: Text(
                  'Failed to connect to Live Threat radar.',
                  style: TextStyle(color: AppColors.textDisabled, fontSize: 13),
                ),
              ),
            ),
            data: (hotspots) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final mapWidth = constraints.maxWidth;
                  const mapHeight = 280.0;

                  // Map geolocations to visual canvas coordinates relative to mapHeight and mapWidth
                  final visualHotspots = hotspots.map((h) {
                    final city = h['city'] as String;
                    double xRatio = 0.5;
                    double yRatio = 0.5;

                    switch (city.toUpperCase()) {
                      case 'DELHI':
                        xRatio = 0.46;
                        yRatio = 0.28;
                        break;
                      case 'MUMBAI':
                        xRatio = 0.35;
                        yRatio = 0.56;
                        break;
                      case 'JAMTARA':
                        xRatio = 0.72;
                        yRatio = 0.44;
                        break;
                      case 'BENGALURU':
                        xRatio = 0.45;
                        yRatio = 0.75;
                        break;
                      case 'HYDERABAD':
                        xRatio = 0.48;
                        yRatio = 0.61;
                        break;
                    }

                    return {
                      ...h,
                      'x': xRatio * mapWidth,
                      'y': yRatio * mapHeight,
                    };
                  }).toList();

                  return Stack(
                    children: [
                      // Stylized Dark Space Map background
                      GestureDetector(
                        onTap: () => setState(() => _selectedHotspot = null),
                        child: Container(
                          height: mapHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF070B14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: CustomPaint(
                            painter: _IndiaMapPainter(
                              hotspots: visualHotspots,
                            ),
                          ),
                        ),
                      ),

                      // Pulse Animations & Interactive Hotspot Buttons
                      ...visualHotspots.map((hotspot) {
                        final double x = hotspot['x'] as double;
                        final double y = hotspot['y'] as double;
                        final String severity = hotspot['severity'] as String? ?? 'MEDIUM';
                        final color = severity.toUpperCase() == 'CRITICAL'
                            ? AppColors.danger
                            : severity.toUpperCase() == 'HIGH'
                                ? AppColors.warning
                                : AppColors.accent;

                        return Positioned(
                          left: x - 20,
                          top: y - 20,
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, _) {
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedHotspot = hotspot),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Glowing pulse rings
                                      Container(
                                        width: 12 + (_pulseController.value * 22),
                                        height: 12 + (_pulseController.value * 22),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color.withOpacity((1.0 - _pulseController.value) * 0.4),
                                        ),
                                      ),
                                      // Inner pulsing solid ring
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color.withOpacity(0.2),
                                          border: Border.all(color: color, width: 1.5),
                                        ),
                                      ),
                                      // Core glowing dot
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),

                      // Glassmorphic Detail Dialog Card
                      if (_selectedHotspot != null)
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xEC0E162A), // Dark translucent
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.severityColor(_selectedHotspot!['severity']).withOpacity(0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '📍 ${_selectedHotspot!['city']}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SeverityChip(severity: _selectedHotspot!['severity']),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Top Threat: ${_selectedHotspot!['topScam']}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Active Threat Volume: ${_selectedHotspot!['threatCount']} reported cases',
                                        style: const TextStyle(
                                          color: AppColors.textDisabled,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 16),
                                  onPressed: () => setState(() => _selectedHotspot = null),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw stylized network geometric lines representing India's borders and safe nodes
class _IndiaMapPainter extends CustomPainter {
  final List<Map<String, dynamic>> hotspots;

  _IndiaMapPainter({required this.hotspots});

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = AppColors.border.withOpacity(0.12)
      ..strokeWidth = 1.0;

    // 1. Draw subtle background coordinate radar grids
    for (double i = 20; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintGrid);
    }
    for (double j = 20; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paintGrid);
    }

    // 2. Draw abstract stylized outline nodes of India
    final outlinePaint = Paint()
      ..color = AppColors.border.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final outlinePath = Path();
    // Start at North node (Delhi)
    final pNorth = Offset(size.width * 0.46, size.height * 0.28);
    final pWest = Offset(size.width * 0.35, size.height * 0.56);
    final pSouth = Offset(size.width * 0.45, size.height * 0.75);
    final pEast = Offset(size.width * 0.72, size.height * 0.44);
    final pCentral = Offset(size.width * 0.48, size.height * 0.61);

    // Additional contour nodes to map out India's geometric frame
    final pKashmir = Offset(size.width * 0.45, size.height * 0.08);
    final pGujarat = Offset(size.width * 0.24, size.height * 0.48);
    final pAssam = Offset(size.width * 0.88, size.height * 0.38);
    final pKanyakumari = Offset(size.width * 0.47, size.height * 0.90);

    // Draw stylized borders
    outlinePath.moveTo(pKashmir.dx, pKashmir.dy);
    outlinePath.lineTo(pNorth.dx, pNorth.dy);
    outlinePath.lineTo(pGujarat.dx, pGujarat.dy);
    outlinePath.lineTo(pWest.dx, pWest.dy);
    outlinePath.lineTo(pSouth.dx, pSouth.dy);
    outlinePath.lineTo(pKanyakumari.dx, pKanyakumari.dy);
    outlinePath.lineTo(pEast.dx, pEast.dy);
    outlinePath.lineTo(pAssam.dx, pAssam.dy);
    outlinePath.lineTo(pNorth.dx, pNorth.dy);
    outlinePath.close();

    canvas.drawPath(outlinePath, outlinePaint);

    // 3. Draw high-tech vector data trunks connecting nodes
    final linePaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Glow effect connecting lines
    void drawSafeTrunk(Offset start, Offset end) {
      linePaint.shader = LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.02),
          AppColors.primary.withOpacity(0.25),
          AppColors.primary.withOpacity(0.02),
        ],
      ).createShader(Rect.fromPoints(start, end));
      canvas.drawLine(start, end, linePaint);
    }

    drawSafeTrunk(pNorth, pCentral);
    drawSafeTrunk(pWest, pCentral);
    drawSafeTrunk(pSouth, pCentral);
    drawSafeTrunk(pEast, pCentral);
    drawSafeTrunk(pNorth, pEast);
    drawSafeTrunk(pWest, pSouth);
  }

  @override
  bool shouldRepaint(_IndiaMapPainter old) => false;
}
