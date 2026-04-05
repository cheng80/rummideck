import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../resources/asset_paths.dart';
import '../resources/sound_manager.dart';
import '../services/game_settings.dart';

/// 설정 화면.
class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  late double _bgmVolume;
  late double _sfxVolume;
  late bool _bgmMuted;
  late bool _sfxMuted;
  late bool _keepScreenOn;

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
      _keepScreenOn = GameSettings.keepScreenOn;
    });
  }

  void _applyKeepScreenOn() {
    if (GameSettings.keepScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        titleTextStyle: const TextStyle(
          fontFamily: AssetPaths.fontAngduIpsul140,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          const _SectionTitle(title: '화면'),
          _MuteSwitch(
            label: '화면 꺼짐 방지',
            value: _keepScreenOn,
            onChanged: (v) {
              setState(() {
                _keepScreenOn = v;
                GameSettings.keepScreenOn = v;
                _applyKeepScreenOn();
              });
            },
          ),
          const _SectionTitle(title: '사운드'),
          _VolumeSlider(
            label: 'BGM 볼륨',
            value: _bgmVolume,
            enabled: !_bgmMuted,
            onChanged: (v) {
              setState(() {
                _bgmVolume = v;
                GameSettings.bgmVolume = v;
                SoundManager.applyBgmVolume();
              });
            },
          ),
          _MuteSwitch(
            label: 'BGM 음소거',
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
          _VolumeSlider(
            label: '효과음 볼륨',
            value: _sfxVolume,
            enabled: !_sfxMuted,
            onChanged: (v) {
              setState(() {
                _sfxVolume = v;
                GameSettings.sfxVolume = v;
              });
            },
          ),
          _MuteSwitch(
            label: '효과음 음소거',
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: AssetPaths.fontAngduIpsul140,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: AssetPaths.fontAngduIpsul140,
          fontSize: 16,
        ),
      ),
      subtitle: Slider(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}

class _MuteSwitch extends StatelessWidget {
  const _MuteSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: AssetPaths.fontAngduIpsul140,
          fontSize: 16,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
