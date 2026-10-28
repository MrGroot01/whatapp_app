import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'status_service.dart';
import 'status_widgets.dart';

// Full-screen status viewer (like WhatsApp):
//  - progress bars at the top, one per status
//  - tap the right side = next, tap the left side = previous
//  - press and hold = pause
//  - my own statuses show "seen by" and can be deleted
class StatusViewerScreen extends StatefulWidget {
  final String ownerUid;
  final String ownerName;
  final Color color;
  final List<StatusItem> items;
  final bool isMine;
  final int startIndex;

  const StatusViewerScreen({
    super.key,
    required this.ownerUid,
    required this.ownerName,
    required this.color,
    required this.items,
    required this.isMine,
    this.startIndex = 0,
  });

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen>
    with SingleTickerProviderStateMixin {
  // how long each status is shown
  static const Duration _perStatus = Duration(seconds: 5);

  late final AnimationController _ctrl;
  late List<StatusItem> _items;
  StreamSubscription<List<StatusItem>>? _sub;

  int _index = 0;
  Uint8List? _bytes;
  bool _loadingImage = false;
  bool _holding = false;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();

    _items = List.of(widget.items);
    _index = widget.startIndex.clamp(0, _items.length - 1).toInt();

    _ctrl = AnimationController(vsync: this, duration: _perStatus)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      });

    // my own statuses: keep the "seen by" numbers live
    if (widget.isMine) {
      _sub = StatusService.watch(widget.ownerUid).listen(_onMineChanged);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _show(_index));
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onMineChanged(List<StatusItem> all) {
    if (!mounted) return;
    final active = StatusService.active(all);
    if (active.isEmpty) {
      Navigator.of(context).maybePop();
      return;
    }

    final currentId = _items[_index].id;
    final newIndex = active.indexWhere((i) => i.id == currentId);

    setState(() {
      _items = active;
      if (newIndex >= 0) _index = newIndex;
    });

    // the status I was looking at was deleted: show the next one
    if (newIndex < 0) _show(_index.clamp(0, active.length - 1).toInt());
  }

  Future<void> _show(int i) async {
    if (!mounted || _items.isEmpty) return;

    _ctrl.stop();
    _ctrl.value = 0;

    final item = _items[i];
    setState(() {
      _index = i;
      _bytes = null;
      _loadingImage = item.isImage;
    });

    // tell the owner that I have seen it
    if (!widget.isMine && !item.seenBy(StatusService.myUid)) {
      unawaited(StatusService.markSeen(item.ownerUid, item.id));
    }

    if (item.isImage) {
      final data = await StatusService.loadImage(item.ownerUid, item.id);
      if (!mounted || _index != i) return;

      Uint8List? bytes;
      if (data != null && data.isNotEmpty) {
        try {
          bytes = base64Decode(data);
        } catch (_) {
          bytes = null;
        }
      }
      setState(() {
        _bytes = bytes;
        _loadingImage = false;
      });
    }

    _startTimer();
  }

  void _startTimer() {
    if (_holding || _sheetOpen || !mounted) return;
    _ctrl.forward();
  }

  void _next() {
    if (_index < _items.length - 1) {
      _show(_index + 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _prev() => _show(_index > 0 ? _index - 1 : 0);

  Future<void> _showViewers() async {
    final item = _items[_index];

    _sheetOpen = true;
    _ctrl.stop();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Viewed by ${item.viewers.length}',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete status',
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFD94B4B),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      StatusService.delete(item.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (item.viewers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No views yet',
                    style: TextStyle(color: AppColors.textSoft, fontSize: 16),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final v in item.viewers)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: StatusAvatar(
                            uid: v.uid,
                            name: v.name,
                            color: AppColors.emerald,
                            radius: 20,
                          ),
                          title: Text(
                            v.name,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            StatusService.timeAgo(v.at),
                            style: const TextStyle(color: AppColors.textSoft),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    _sheetOpen = false;
    if (mounted) _startTimer();
  }

  Widget _buildContent(StatusItem item) {
    if (!item.isImage) {
      return Container(
        color: Color(item.bgColor),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 96),
        child: Text(
          item.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: _loadingImage
          ? const CircularProgressIndicator(color: Colors.white)
          : _bytes != null
          ? Image.memory(_bytes!, fit: BoxFit.contain, gaplessPlayback: true)
          : const Text(
        'Could not load this photo',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  Widget _buildProgressBars() {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          children: List.generate(_items.length, (i) {
            final value = i < _index ? 1.0 : (i == _index ? _ctrl.value : 0.0);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 3,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_index];
    final title = widget.isMine ? 'My status' : widget.ownerName;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildContent(item),

          // tap left = previous, tap right = next, hold = pause
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (details) {
                final width = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < width / 3) {
                  _prev();
                } else {
                  _next();
                }
              },
              onLongPressStart: (_) {
                _holding = true;
                _ctrl.stop();
              },
              onLongPressEnd: (_) {
                _holding = false;
                _startTimer();
              },
            ),
          ),

          // top: progress bars + name
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x99000000), Color(0x00000000)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildProgressBars(),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          StatusAvatar(
                            uid: widget.ownerUid,
                            name: widget.ownerName,
                            color: widget.color,
                            radius: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  StatusService.timeAgo(item.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // photo caption
          if (item.isImage && item.caption.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: widget.isMine ? 64 : 0,
              child: Container(
                color: const Color(0x99000000),
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  12 + (widget.isMine ? 0 : MediaQuery.of(context).padding.bottom),
                ),
                child: Text(
                  item.caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),

          // my own status: "seen by"
          if (widget.isMine)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Center(
                  child: TextButton.icon(
                    onPressed: _showViewers,
                    icon: const Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.white,
                    ),
                    label: Text(
                      '${item.viewers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}