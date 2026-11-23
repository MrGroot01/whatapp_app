class MediaEntry {
  final String id;
  final String kind;
  final DateTime time;
  final bool isMe;
  final String imageBase64;
  final String url;
  final String title;

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