import 'package:flutter/material.dart';

/// 디버그 전용: 타일 크기 계측 래퍼.
class DebugMeasuredTile extends StatefulWidget {
  const DebugMeasuredTile({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  State<DebugMeasuredTile> createState() => _DebugMeasuredTileState();
}

class _DebugMeasuredTileState extends State<DebugMeasuredTile> {
  final GlobalKey _measureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _logAfterFrame();
  }

  @override
  void didUpdateWidget(covariant DebugMeasuredTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _logAfterFrame();
  }

  void _logAfterFrame() {}

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _measureKey,
      child: widget.child,
    );
  }
}
