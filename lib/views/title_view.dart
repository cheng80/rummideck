import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_config.dart';
import '../resources/asset_paths.dart';
import '../resources/sound_manager.dart';
import '../vm/game_session_provider.dart';
import 'game/battle_theme.dart';

const _seedOptions = [
  'MVP-001',
  'MVP-002',
  'MVP-003',
  'MVP-004',
  'MVP-005',
  'BOSS-TEST',
  'DEBUG-42',
];

/// 타이틀 화면.
class TitleView extends ConsumerStatefulWidget {
  const TitleView({super.key});

  @override
  ConsumerState<TitleView> createState() => _TitleViewState();
}

class _TitleViewState extends ConsumerState<TitleView> {
  String? _selectedSeed;
  bool _playbookDebugStart = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _StarryBackground(),
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Text(
                    AppConfig.gameTitle,
                    style: TextStyle(
                      fontFamily: AssetPaths.fontAngduIpsul140,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 6,
                    ),
                  ),
                  Text(
                    AppConfig.gameTitleSub,
                    style: TextStyle(
                      fontFamily: AssetPaths.fontAngduIpsul140,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: AppColors.titleGold,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: AppColors.titleGold.withValues(alpha: 0.5),
                          blurRadius: 24,
                        ),
                        const Shadow(
                          color: AppColors.titleOrange,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  _SeedSelector(
                    selected: _selectedSeed,
                    onChanged: (seed) => setState(() => _selectedSeed = seed),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    _PlaybookDebugCheckbox(
                      value: _playbookDebugStart,
                      onChanged: (v) =>
                          setState(() => _playbookDebugStart = v ?? false),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: _selectedSeed == null ? 0.4 : 1,
                    child: _RoundButton(
                      label: context.tr('startGame'),
                      color: AppColors.titleBlue,
                      onPressed: () {
                        final seed = _selectedSeed;
                        if (seed == null) {
                          return;
                        }
                        SoundManager.playSfx(AssetPaths.sfxBtnSnd);
                        ref.read(selectedSeedProvider.notifier).state = seed;
                        ref.read(playbookDebugStartProvider.notifier).state =
                            kDebugMode && _playbookDebugStart;
                        context.go(RoutePaths.game);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _RoundButton(
                    label: context.tr('settings'),
                    color: AppColors.titlePurple,
                    onPressed: () {
                      SoundManager.playSfx(AssetPaths.sfxBtnSnd);
                      context.push(RoutePaths.setting);
                    },
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeedSelector extends StatelessWidget {
  const _SeedSelector({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Text(
            '시드 선택',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          isExpanded: true,
          dropdownColor: AppColors.titleDropdown,
          icon: const Icon(Icons.expand_more, color: Colors.white70),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
          items: [
            for (final seed in _seedOptions)
              DropdownMenuItem(
                value: seed,
                child: Text('Seed: $seed'),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

class _PlaybookDebugCheckbox extends StatelessWidget {
  const _PlaybookDebugCheckbox({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.titleBlue,
              checkColor: Colors.white,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '플레이북(그리디) 상태로 시작 → 스테이지 2 전투',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const width = 260.0;
    const height = 68.0;
    const fontSize = 32.0;
    final darkerColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0),
        )
        .toColor();

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, darkerColor],
          ),
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: darkerColor.withValues(alpha: 0.6),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: darkerColor.withValues(alpha: 0.5),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 16,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AssetPaths.fontAngduIpsul140,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 6,
              shadows: [
                Shadow(
                  color: darkerColor.withValues(alpha: 0.8),
                  offset: const Offset(1, 1),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarryBackground extends StatefulWidget {
  const _StarryBackground();

  @override
  State<_StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<_StarryBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _StarPainter(_controller.value),
        );
      },
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.time);
  final double time;

  static final List<_Star> _stars = _generateStars(100);

  static List<_Star> _generateStars(int count) {
    final rng = Random(42);
    return List.generate(count, (_) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: rng.nextDouble() * 1.6 + 0.3,
        speed: rng.nextDouble() * 2.0 + 0.5,
        offset: rng.nextDouble() * 2 * pi,
        colorIndex: rng.nextInt(4),
      );
    });
  }

  static const _colors = [
    Colors.white,
    AppColors.titleStarCyan,
    AppColors.titleStarYellow,
    AppColors.titleStarPink,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.titleBgDark,
          AppColors.titleBgMid,
          AppColors.titleBgLight,
          AppColors.titleBgMid,
          AppColors.titleBgDark,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    for (final star in _stars) {
      final t = time * 2 * pi;
      final twinkle = sin(t * star.speed + star.offset);
      final alpha = (0.4 + twinkle * 0.4).clamp(0.05, 1.0);
      final color = _colors[star.colorIndex];
      final paint = Paint()..color = color.withValues(alpha: alpha);
      final cx = star.x * size.width;
      final cy = star.y * size.height;
      canvas.drawCircle(Offset(cx, cy), star.radius, paint);

      if (star.radius > 1.2) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: alpha * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(cx, cy), star.radius * 2.5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => oldDelegate.time != time;
}

class _Star {
  final double x, y, radius, speed, offset;
  final int colorIndex;

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.offset,
    required this.colorIndex,
  });
}
