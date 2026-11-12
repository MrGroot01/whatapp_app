import '../status_service.dart';

class StatusEntry {
  final StatusContact contact;
  final List<StatusItem> items; // active statuses, oldest first

  const StatusEntry(this.contact, this.items);

  // how many of them I have not seen yet
  int get unseen =>
      items.where((i) => !i.seenBy(StatusService.myUid)).length;

  // time of the newest status (used to sort the list)
  int get latest => items.last.createdAt;
}