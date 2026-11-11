// One shared item from a chat: a photo, a document or a link.
// It is plain data: no Firebase code and no screen code in here.
class MediaEntry {
  final String id;
  final String kind; // 'image', 'file' or 'link'
  final DateTime time;
  final bool isMe;
  final String imageBase64; // photos are stored inside the database
  final String url; // document / old photo address, or the link itself
  final String title; // file name, or the text of the message with the link

  const MediaEntry({
    required this.id,
    required this.kind,
    required this.time,
    required this.isMe,
    this.imageBase64 = '',
    this.url = '',
    this.title = '',
  });
}