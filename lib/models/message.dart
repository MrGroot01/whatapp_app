

class Message {
  final String id;
  final String text;
  final bool isMe;
  final String senderId;
  final DateTime time;
  final int status;
  final String type;
  final String url;
  final String
  imageBase64;
  final String fileName;
  final bool forwarded;
  final String replyToId; // the message this one replies to
  final String replyText; // short preview of that message
  final String replySenderId; // who wrote that message
  final Map<String, String> reactions; // account id -> emoji
  final String contactUid; // shared contact: account id
  final String contactName;
  final String contactPhone;
  final String contactCountryCode;
  final int expireAtMs; // disappearing messages: 0 = never disappears

  Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.senderId,
    required this.time,
    this.status = 0,
    this.type = 'text',
    this.url = '',
    this.imageBase64 = '',
    this.fileName = '',
    this.forwarded = false,
    this.replyToId = '',
    this.replyText = '',
    this.replySenderId = '',
    this.reactions = const {},
    this.contactUid = '',
    this.contactName = '',
    this.contactPhone = '',
    this.contactCountryCode = '',
    this.expireAtMs = 0,
  });

  factory Message.fromMap(String id, Map<dynamic, dynamic> data, String myUid) {
    final ts = data['timeMs'];
    final st = data['status'];

    final reactions = <String, String>{};
    final rawReactions = data['reactions'];
    if (rawReactions is Map) {
      rawReactions.forEach((key, value) {
        if (value != null) reactions[key.toString()] = value.toString();
      });
    }

    final sender = (data['senderId'] ?? '').toString();

    return Message(
      id: id,
      text: (data['text'] ?? '').toString(),
      isMe: sender == myUid,
      senderId: sender,
      time: DateTime.fromMillisecondsSinceEpoch(
        ts is num ? ts.toInt() : DateTime.now().millisecondsSinceEpoch,
      ),
      status: st is num ? st.toInt() : 0,
      type: (data['type'] ?? 'text').toString(),
      url: (data['url'] ?? '').toString(),
      imageBase64: (data['imageBase64'] ?? '').toString(),
      fileName: (data['fileName'] ?? '').toString(),
      forwarded: data['forwarded'] == true,
      replyToId: (data['replyToId'] ?? '').toString(),
      replyText: (data['replyText'] ?? '').toString(),
      replySenderId: (data['replySenderId'] ?? '').toString(),
      reactions: reactions,
      contactUid: (data['contactUid'] ?? '').toString(),
      contactName: (data['contactName'] ?? '').toString(),
      contactPhone: (data['contactPhone'] ?? '').toString(),
      contactCountryCode: (data['contactCountryCode'] ?? '').toString(),
      expireAtMs: data['expireAtMs'] is num
          ? (data['expireAtMs'] as num).toInt()
          : 0,
    );
  }
}