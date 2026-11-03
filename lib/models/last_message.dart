class LastMessage {
  final String preview;
  final String type;
  final String senderId;
  final int timeMs;
  final int status;
  final int expireAtMs;

  const LastMessage({
    required this.preview,
    required this.type,
    required this.senderId,
    required this.timeMs,
    required this.status,
    required this.expireAtMs,
  });

  factory LastMessage.fromMap(Map<dynamic, dynamic> d) {
    final type = (d['type'] ?? 'text').toString();

    String preview;
    switch (type) {
      case 'image':
        final caption = (d['text'] ?? '').toString().trim();
        preview = caption.isEmpty ? '📷 Photo' : '📷 $caption';
        break;
      case 'file':
        final name = (d['fileName'] ?? d['text'] ?? '').toString();
        preview = '📄 ${name.isEmpty ? 'Document' : name}';
        break;
      case 'contact':
        preview = '👤 ${(d['contactName'] ?? 'Contact').toString()}';
        break;
      default:
        preview = (d['text'] ?? '').toString().replaceAll('\n', ' ');
    }

    final ts = d['timeMs'];
    final st = d['status'];
    final ex = d['expireAtMs'];

    return LastMessage(
      preview: preview,
      type: type,
      senderId: (d['senderId'] ?? '').toString(),
      // a message that is still being saved has no server time yet
      timeMs: ts is num ? ts.toInt() : DateTime.now().millisecondsSinceEpoch,
      status: st is num ? st.toInt() : 0,
      expireAtMs: ex is num ? ex.toInt() : 0,
    );
  }
}