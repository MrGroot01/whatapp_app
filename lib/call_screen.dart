import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final Color color;
  final String phone;
  final String countryCode;
  final bool video; // true = start with the camera on

  const CallScreen({
    super.key,
    required this.name,
    required this.color,
    this.phone = '',
    this.countryCode = '+91',
    this.video = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  static const Color _panel = Color(0xCC17201D);
  static const Color _buttonBg = Color(0x26FFFFFF);
  static const Color _endRed = Color(0xFFF0145A);

  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  bool _cameraOn = false; // the user wants the camera on
  bool _cameraReady = false; // the preview is running
  bool _starting = false; // the camera is being opened right now
  bool _front = true; // front (selfie) or back camera
  bool _muted = false;
  bool _speaker = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // video call button -> open the camera straight away
    if (widget.video) {
      _cameraOn = true;
      _startCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // release the camera when the app goes to the background,
  // and open it again when the user comes back
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final c = _controller;
      if (c != null && c.value.isInitialized) _stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraOn && _controller == null && !_starting) _startCamera();
    }
  }

  // ---------- CAMERA ----------
  Future<void> _startCamera() async {
    if (_starting) return;
    _starting = true;

    try {
      if (_cameras.isEmpty) _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _cameraFailed('No camera found on this device');
        return;
      }

      final wanted =
      _front ? CameraLensDirection.front : CameraLensDirection.back;
      final camera = _cameras.firstWhere(
            (c) => c.lensDirection == wanted,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();

      // the user left the screen or switched the camera off meanwhile
      if (!mounted || !_cameraOn) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _cameraReady = true;
      });
    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.code} ${e.description}');
      _cameraFailed(
        e.code.startsWith('CameraAccess')
            ? 'Camera permission denied. Allow it in the app settings.'
            : 'Could not open the camera',
      );
    } catch (e) {
      debugPrint('Camera error: $e');
      _cameraFailed('Could not open the camera');
    } finally {
      _starting = false;
    }
  }

  Future<void> _stopCamera() async {
    final c = _controller;
    if (mounted) {
      setState(() {
        _controller = null;
        _cameraReady = false;
      });
    }
    await c?.dispose();
  }

  void _cameraFailed(String message) {
    if (!mounted) return;
    setState(() {
      _cameraOn = false;
      _cameraReady = false;
    });
    _snack(message);
  }

  Future<void> _toggleCamera() async {
    if (_cameraOn) {
      setState(() => _cameraOn = false);
      await _stopCamera();
    } else {
      setState(() => _cameraOn = true);
      await _startCamera();
    }
  }

  Future<void> _flipCamera() async {
    if (!_cameraOn || _starting) return;
    _front = !_front;
    await _stopCamera();
    await _startCamera();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ---------- UI PIECES ----------
  // the camera picture fills the whole screen (no stretching)
  Widget _buildCameraBackground() {
    final c = _controller!;
    final size = MediaQuery.of(context).size;

    var scale = size.aspectRatio * c.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return ClipRect(
      child: SizedBox.expand(
        child: Transform.scale(
          scale: scale,
          child: Center(child: CameraPreview(c)),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return Material(
      color: _buttonBg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final number = widget.phone.isEmpty
        ? ''
        : '${widget.countryCode} ${widget.phone}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _roundIcon(Icons.close_fullscreen, () => Navigator.pop(context)),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (number.isNotEmpty)
                  Text(
                    number,
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 15,
                    ),
                  ),
                Text(
                  _cameraOn ? 'Video calling...' : 'Calling...',
                  style: const TextStyle(
                    color: Color(0xB3FFFFFF),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          _roundIcon(
            Icons.person_add_alt_1,
                () => _snack('Adding people is coming soon'),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    Color? background,
  }) {
    final bg = background ?? (active ? Colors.white : _buttonBg);
    final fg = background != null
        ? Colors.white
        : (active ? const Color(0xFF111B21) : Colors.white);

    return SizedBox(
      width: 84,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: bg,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 58,
                height: 58,
                child: Icon(icon, color: fg, size: 26),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _controlButton(
                icon: Icons.volume_up,
                label: 'Speaker',
                active: _speaker,
                onTap: () => setState(() => _speaker = !_speaker),
              ),
              _controlButton(
                icon: _cameraOn ? Icons.videocam : Icons.videocam_off,
                label: 'Video',
                active: _cameraOn,
                onTap: _toggleCamera,
              ),
              _controlButton(
                icon: Icons.mic_off,
                label: 'Mute',
                active: _muted,
                onTap: () => setState(() => _muted = !_muted),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_cameraOn)
                _controlButton(
                  icon: Icons.flip_camera_android,
                  label: 'Flip',
                  onTap: _flipCamera,
                )
              else
                _controlButton(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () => _snack('More options are coming soon'),
                ),
              _controlButton(
                icon: Icons.ios_share,
                label: 'Share',
                onTap: () => _snack('Sharing is coming soon'),
              ),
              _controlButton(
                icon: Icons.call_end,
                label: 'End',
                background: _endRed,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showVideo = _cameraOn && _cameraReady && _controller != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // BACKGROUND: your camera, or the dark green gradient
          if (showVideo)
            _buildCameraBackground()
          else
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0E4D3E), Color(0xFF06140F)],
                ),
              ),
            ),

          // dark shade over the camera, so the white text can be read
          if (showVideo)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x99000000),
                      Color(0x00000000),
                      Color(0x99000000),
                    ],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: showVideo
                      ? const SizedBox.shrink()
                      : _buildAvatar(),
                ),
                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}