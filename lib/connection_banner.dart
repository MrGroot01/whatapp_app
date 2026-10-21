import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'message_sync_service.dart';

// The slim message at the top of Home and Chat.
// It takes no space when there is nothing to say.
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  static const Color _red = Color(0xFFD94B4B);
  static const Color _amber = Color(0xFFE09B00);

  @override
  Widget build(BuildContext context) {
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

        final waiting = pending == 1
            ? '1 message is waiting to be sent.'
            : '$pending messages are waiting to be sent.';

        String? text;
        Color color = AppColors.emeraldLight;
        IconData icon = Icons.wifi_rounded;

        if (state == ConnState.offline) {
          text = pending > 0
              ? 'You are offline. $waiting'
              : 'You are offline. Please turn on your internet connection.';
          color = _red;
          icon = Icons.wifi_off_rounded;
        } else if (state == ConnState.connecting) {
          text = pending > 0 ? 'Connecting... $waiting' : 'Connecting...';
          color = _amber;
          icon = Icons.sync_problem_rounded;
        } else if (back) {
          text = pending > 0
              ? 'Back online. Sending your messages...'
              : 'You are back online.';
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