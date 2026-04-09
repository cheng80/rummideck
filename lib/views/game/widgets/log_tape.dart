import 'package:flutter/material.dart';

import '../../../logic/run/run_log_entry.dart';
import '../game_common.dart';

/// 최근 제출 로그 테이프.
class LogTape extends StatelessWidget {
  const LogTape({super.key, required this.logs, this.compact = false});

  final List<RunLogEntry> logs;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const SizedBox.shrink();
    }

    return SubPanelSurface(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final log in logs)
            Text(
              log.message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white54,
                fontSize: compact ? 9 : 11,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }
}
