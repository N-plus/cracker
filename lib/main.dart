import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CrackerApp());
}

class CrackerApp extends StatefulWidget {
  const CrackerApp({super.key});

  @override
  State<CrackerApp> createState() => _CrackerAppState();
}

class _CrackerAppState extends State<CrackerApp> {
  CrackerType _selectedType = CrackerType.normal;

  void _openSelector(BuildContext context) async {
    final selection = await Navigator.of(context).push<CrackerType>(
      MaterialPageRoute(
        builder: (context) => CrackerSelectorPage(current: _selectedType),
      ),
    );
    if (selection != null && selection != _selectedType) {
      setState(() {
        _selectedType = selection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pull Cracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: CrackerExperiencePage(
        type: _selectedType,
        onSelectPressed: _openSelector,
      ),
    );
  }
}

class CrackerExperiencePage extends StatefulWidget {
  const CrackerExperiencePage({
    super.key,
    required this.type,
    required this.onSelectPressed,
  });

  final CrackerType type;
  final void Function(BuildContext) onSelectPressed;

  @override
  State<CrackerExperiencePage> createState() => _CrackerExperiencePageState();
}

class _CrackerExperiencePageState extends State<CrackerExperiencePage>
    with TickerProviderStateMixin {
  static const double _maxPull = 200;
  static const double _fireThreshold = 140;
  double _pullDistance = 0;
  late AnimationController _returnController;
  late Animation<double> _returnAnimation;
  double _returnFrom = 0;
  late AnimationController _confettiController;
  List<_ConfettiPiece> _confetti = [];

  @override
  void initState() {
    super.initState();
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _returnAnimation = CurvedAnimation(
      parent: _returnController,
      curve: Curves.elasticOut,
    )..addListener(() {
        setState(() {
          _pullDistance = _returnFrom * (1 - _returnAnimation.value);
        });
      });

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _returnController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _pullDistance = (_pullDistance - details.delta.dy).clamp(0, _maxPull);
    });
    if (_pullDistance >= _fireThreshold) {
      _fireCracker();
    }
  }

  void _handleDragEnd([DragEndDetails? _]) {
    _animateBackToRest();
  }

  void _animateBackToRest() {
    _returnFrom = _pullDistance;
    _returnController
      ..reset()
      ..forward();
  }

  void _fireCracker() {
    if (_confettiController.isAnimating) return;
    HapticFeedback.mediumImpact();
    // ignore: avoid_print
    print('PAN!');
    _spawnConfetti();
    _confettiController
      ..reset()
      ..forward();
    setState(() {
      _pullDistance = 0;
    });
  }

  void _spawnConfetti() {
    final random = Random();
    _confetti = List.generate(24, (index) {
      final color = _confettiPalette[index % _confettiPalette.length];
      return _ConfettiPiece(
        color: color,
        left: random.nextDouble(),
        size: random.nextDouble() * 12 + 8,
        sway: random.nextDouble() * 16 + 8,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final wobble = sin(_pullDistance / 12) * (_pullDistance / 20 + 2);
    final verticalWobble = cos(_pullDistance / 18) * 4;
    final pullProgress = _pullDistance / _maxPull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('クラッカーで遊ぼう'),
        actions: [
          IconButton(
            onPressed: () => widget.onSelectPressed(context),
            icon: const Icon(Icons.celebration_outlined),
            tooltip: 'クラッカーを選ぶ',
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final centerX = constraints.maxWidth / 2;
          final baseY = constraints.maxHeight * 0.35 + verticalWobble;
          final handleY = constraints.maxHeight * 0.8 - _pullDistance;
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BackgroundPainter(),
                ),
              ),
              if (_confetti.isNotEmpty)
                ..._confetti.map((piece) {
                  final progress = _confettiController.value;
                  final y = (-50 + progress * constraints.maxHeight) +
                      sin(progress * pi * 2) * 8;
                  final x =
                      (piece.left * constraints.maxWidth) + sin(progress * pi) * piece.sway;
                  final opacity = 1 - progress;
                  return Positioned(
                    left: x,
                    top: y,
                    child: Opacity(
                      opacity: opacity.clamp(0, 1),
                      child: Container(
                        width: piece.size,
                        height: piece.size * 1.3,
                        decoration: BoxDecoration(
                          color: piece.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                }),
              Positioned(
                left: centerX - 32 + wobble,
                top: baseY,
                child: _CrackerBody(type: widget.type, pullProgress: pullProgress),
              ),
              Positioned(
                left: centerX - 2,
                top: baseY + 80,
                bottom: constraints.maxHeight * 0.1,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                left: centerX - 22,
                top: handleY,
                child: GestureDetector(
                  onVerticalDragUpdate: _handleDragUpdate,
                  onVerticalDragEnd: _handleDragEnd,
                  onVerticalDragCancel: _handleDragEnd,
                  child: _PullHandle(pullAmount: _pullDistance),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 24,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PullMeter(value: pullProgress),
                    const SizedBox(height: 12),
                    const Text(
                      'つまみを上にドラッグするとクラッカーが揺れます。\n引っ張って発射させよう！',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _PullHandle extends StatelessWidget {
  const _PullHandle({required this.pullAmount});

  final double pullAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 4,
          height: pullAmount,
          decoration: BoxDecoration(
            color: Colors.grey.shade500,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.orange.shade400,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.keyboard_double_arrow_up_rounded,
              color: Colors.white),
        ),
      ],
    );
  }
}

class _CrackerBody extends StatelessWidget {
  const _CrackerBody({required this.type, required this.pullProgress});

  final CrackerType type;
  final double pullProgress;

  @override
  Widget build(BuildContext context) {
    final style = type.style;
    final tilt = (pullProgress - 0.5) * 0.2;
    return Transform.rotate(
      angle: tilt,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              color: style.baseColor,
              gradient: style.gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                style.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class CrackerSelectorPage extends StatelessWidget {
  const CrackerSelectorPage({super.key, required this.current});

  final CrackerType current;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('クラッカーを選択'),
      ),
      body: ListView(
        children: CrackerType.values
            .map(
              (type) => ListTile(
                leading: CircleAvatar(backgroundColor: type.style.baseColor),
                title: Text(type.style.label),
                trailing:
                    current == type ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () => Navigator.of(context).pop(type),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PullMeter extends StatelessWidget {
  const _PullMeter({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 12,
        backgroundColor: Colors.grey.shade200,
        color: Colors.orange.shade400,
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF5E6), Color(0xFFFFE4C7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, paint);

    final circlePaint = Paint()..color = Colors.white.withOpacity(0.3);
    for (var i = 0; i < 18; i++) {
      final random = Random(i * 7);
      final radius = random.nextDouble() * 32 + 16;
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(dx, dy), radius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum CrackerType { normal, gold, rainbow, animal }

extension on CrackerType {
  _CrackerStyle get style {
    switch (this) {
      case CrackerType.normal:
        return _CrackerStyle(
          label: '通常',
          baseColor: Colors.red.shade400,
        );
      case CrackerType.gold:
        return _CrackerStyle(
          label: '金',
          baseColor: Colors.amber.shade600,
          gradient: LinearGradient(
            colors: [Colors.amber.shade700, Colors.amber.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case CrackerType.rainbow:
        return _CrackerStyle(
          label: '虹',
          baseColor: Colors.purple,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF5F6D),
              Color(0xFFFFC371),
              Color(0xFF40C9FF),
              Color(0xFFA17FE0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case CrackerType.animal:
        return _CrackerStyle(
          label: '動物',
          baseColor: Colors.teal.shade400,
          gradient: const LinearGradient(
            colors: [Color(0xFF6DC8F3), Color(0xFF73A1F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
    }
  }
}

class _CrackerStyle {
  _CrackerStyle({
    required this.label,
    required this.baseColor,
    this.gradient,
  });

  final String label;
  final Color baseColor;
  final Gradient? gradient;
}

class _ConfettiPiece {
  _ConfettiPiece({
    required this.color,
    required this.left,
    required this.size,
    required this.sway,
  });

  final Color color;
  final double left;
  final double size;
  final double sway;
}

const _confettiPalette = [
  Color(0xFFF94144),
  Color(0xFFF3722C),
  Color(0xFFF8961E),
  Color(0xFF43AA8B),
  Color(0xFF577590),
  Color(0xFF277DA1),
  Color(0xFFD62828),
  Color(0xFF90BE6D),
];
