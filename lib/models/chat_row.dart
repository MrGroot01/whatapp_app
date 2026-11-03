import '../group_service.dart';
import 'contact.dart';

class ChatRow {
  final GroupItem? group;
  final Contact? contact;
  final int timeMs;

  const ChatRow({this.group, this.contact, required this.timeMs});

  String get name => group?.name ?? contact?.name ?? '';
}