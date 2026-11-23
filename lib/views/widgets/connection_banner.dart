import 'package:flutter/material.dart';

import '../../core/app_localization.dart';
import '../../core/app_theme.dart';
import '../../services/message_sync_service.dart';

// The slim message at the top of Home and Chat.
// It takes no space when there is nothing to say.
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  static const Color _amber = Color(0xFFE09B00);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return ListenableBuilder(
      listenable: Listenable.merge([
        MessageSyncService.connection,
        MessageSyncService.pendingCount,
        MessageSyncService.backOnline,
      ]),
      builder: (context, _) {
        final state = MessageSyncService.connection.value;
        final pending = MessageSyncService.pendingCount.value;
        final back = MessageSyncService.backOnline.value;

        final waiting =
        pending == 1 ? l.waitingOne : l.waitingMany(pending);

        String? text;
        Color color = AppColors.emeraldLight;
        IconData icon = Icons.wifi_rounded;

        if (state == ConnState.offline) {
          text = pending > 0
              ? l.offlineWithPending(waiting)
              : l.offlineNoPending;
          color = AppColors.error;
          icon = Icons.wifi_off_rounded;
        } else if (state == ConnState.connecting) {
          text = pending > 0 ? l.connectingWithPending(waiting) : l.connecting;
          color = _amber;
          icon = Icons.sync_problem_rounded;
        } else if (back) {
          text = pending > 0 ? l.backOnlineSending : l.backOnline;
          icon = pending > 0 ? Icons.sync_rounded : Icons.wifi_rounded;
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: text == null
              ? const SizedBox(width: double.infinity)
              : Container(
            width: double.infinity,
            color: color,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}