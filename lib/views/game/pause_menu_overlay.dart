import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_config.dart';
import '../../game/sample_game.dart';
import '../../resources/asset_paths.dart';
import '../../resources/sound_manager.dart';
import '../../services/game_settings.dart';

class PauseMenuOverlay extends StatefulWidget {
  const PauseMenuOverlay({super.key, required this.game, required this.seedText});
  final SampleGame game;
  final String seedText;

  @override
  State<PauseMenuOverlay> createState() => _PauseMenuOverlayState();
}

class _PauseMenuOverlayState extends State<PauseMenuOverlay> {
  late double _bgmVolume;
  late double _sfxVolume;
  late bool _bgmMuted;
  late bool _sfxMuted;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _bgmVolume = GameSettings.bgmVolume;
      _sfxVolume = GameSettings.sfxVolume;
      _bgmMuted = GameSettings.bgmMuted;
      _sfxMuted = GameSettings.sfxMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontFamily: AssetPaths.fontAngduIpsul140,
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Seed: ${widget.seedText}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(
              'BGM',
              style: TextStyle(
                fontFamily: AssetPaths.fontAngduIpsul140,
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _bgmMuted ? 0.0 : _bgmVolume,
                    onChanged: _bgmMuted
                        ? null
                        : (v) {
                            setState(() {
                              _bgmVolume = v;
                              GameSettings.bgmVolume = v;
                              SoundManager.applyBgmVolume();
                            });
                          },
                  ),
                ),
                Switch(
                  value: _bgmMuted,
                  onChanged: (v) {
                    setState(() {
                      _bgmMuted = v;
                      GameSettings.bgmMuted = v;
                      if (v) {
                        SoundManager.pauseBgm();
                      } else {
                        SoundManager.playBgmIfUnmuted();
                      }
                    });
                  },
                ),
              ],
            ),
            Text(
              '효과음',
              style: TextStyle(
                fontFamily: AssetPaths.fontAngduIpsul140,
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _sfxMuted ? 0.0 : _sfxVolume,
                    onChanged: _sfxMuted
                        ? null
                        : (v) {
                            setState(() {
                              _sfxVolume = v;
                              GameSettings.sfxVolume = v;
                            });
                          },
                  ),
                ),
                Switch(
                  value: _sfxMuted,
                  onChanged: (v) {
                    setState(() {
                      _sfxMuted = v;
                      GameSettings.sfxMuted = v;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  SoundManager.playSfx(AssetPaths.sfxBtnSnd);
                  SoundManager.resumeBgm();
                  widget.game.resumeGame();
                },
                child: const Text('계속하기'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  SoundManager.playSfx(AssetPaths.sfxBtnSnd);
                  SoundManager.stopBgm();
                  context.go(RoutePaths.title);
                },
                child: const Text('나가기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
