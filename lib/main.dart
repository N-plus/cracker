import 'package:flutter/material.dart';

void main() {
  runApp(const CrackerApp());
}

class CrackerApp extends StatefulWidget {
  const CrackerApp({super.key});

  @override
  State<CrackerApp> createState() => _CrackerAppState();
}

class _CrackerAppState extends State<CrackerApp> {
  CrackerType _selected = CrackerType.normal;

  Future<void> _openSelector(BuildContext context) async {
    final result = await Navigator.of(context).push<CrackerType>(
      MaterialPageRoute(
        builder: (_) => CrackerSelectionPage(current: _selected),
      ),
    );
    if (result != null) {
      setState(() => _selected = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cracker Experience',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: CrackerExperiencePage(
        type: _selected,
        onSelectPressed: _openSelector,
      ),
    );
  }
}

class CrackerExperiencePage extends StatelessWidget {
  const CrackerExperiencePage({
    super.key,
    required this.type,
    required this.onSelectPressed,
  });

  final CrackerType type;
  final void Function(BuildContext) onSelectPressed;

  @override
  Widget build(BuildContext context) {
    final style = type.style;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF2E0), Color(0xFFFFE2C6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final centerX = constraints.maxWidth / 2;
                return Stack(
                  children: [
                    Align(
                      alignment: const Alignment(0, -0.2),
                      child: CrackerPreview(style: style),
                    ),
                    Positioned(
                      left: centerX - 2,
                      right: centerX - 2,
                      top: constraints.maxHeight * 0.45,
                      bottom: constraints.maxHeight * 0.18,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 120,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '引っ張って！',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onPanUpdate: (_) {},
                            onPanStart: (_) {},
                            onPanEnd: (_) {},
                            child: const PullKnob(),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 40,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'つまみをドラッグしてクラッカーを準備。\n後からアニメーションを追加できます。',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => onSelectPressed(context),
                            icon: const Icon(Icons.celebration_outlined),
                            label: const Text('クラッカー変更'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CrackerPreview extends StatelessWidget {
  const CrackerPreview({super.key, required this.style});

  final _CrackerStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 140,
          height: 90,
          decoration: BoxDecoration(
            color: style.baseColor,
            gradient: style.gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              style.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.shade600,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PullKnob extends StatelessWidget {
  const PullKnob({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.shade400,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.keyboard_double_arrow_up_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class CrackerSelectionPage extends StatelessWidget {
  CrackerSelectionPage({super.key, required this.current});

  final CrackerType current;

  final List<_CrackerOption> _options = [
    _CrackerOption(type: CrackerType.normal, isLocked: false),
    _CrackerOption(type: CrackerType.gold, isLocked: false),
    _CrackerOption(type: CrackerType.rainbow, isLocked: true),
    _CrackerOption(type: CrackerType.animal, isLocked: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('クラッカーを選択'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: _options
            .map(
              (option) => _CrackerTile(
                option: option,
                isSelected: current == option.type,
                onTap: option.isLocked
                    ? null
                    : () => Navigator.of(context).pop(option.type),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CrackerTile extends StatelessWidget {
  const _CrackerTile({
    required this.option,
    required this.isSelected,
    this.onTap,
  });

  final _CrackerOption option;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = option.type.style;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: style.gradient ??
                  LinearGradient(
                    colors: [style.baseColor, style.baseColor.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white70, width: 2),
                      ),
                      child: const Icon(
                        Icons.celebration,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    if (option.isLocked)
                      const Icon(Icons.lock, color: Colors.white)
                    else if (isSelected)
                      const Icon(Icons.check_circle, color: Colors.white)
                    else
                      const SizedBox.shrink(),
                  ],
                ),
                const Spacer(),
                Text(
                  style.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  option.isLocked ? 'ロック中' : 'タップして選択',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (option.isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CrackerOption {
  const _CrackerOption({
    required this.type,
    required this.isLocked,
  });

  final CrackerType type;
  final bool isLocked;
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
          baseColor: Colors.amber.shade500,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD56F), Color(0xFFFFB347)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case CrackerType.rainbow:
        return const _CrackerStyle(
          label: '虹',
          baseColor: Color(0xFF9B6CF7),
          gradient: LinearGradient(
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
            colors: [Color(0xFF7AE8C5), Color(0xFF2AC4A2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
    }
  }
}

class _CrackerStyle {
  const _CrackerStyle({
    required this.label,
    required this.baseColor,
    this.gradient,
  });

  final String label;
  final Color baseColor;
  final Gradient? gradient;
}
