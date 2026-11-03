import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputProvider extends ChangeNotifier {
  // language the mic understands. null = phone default.
  // Examples: 'en_IN' (Indian English), 'hi_IN' (Hindi), 'kn_IN' (Kannada)
  static const String? speechLocale = 'en_IN';

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _ready = false;
  bool _listening = false;
  bool _heardWords = false;
  bool _disposed = false;
  String _textBeforeMic = ''; // what was typed before pressing the mic

  // the screen sets these two
  void Function(String text)? onText; // put this text in the message box
  void Function(String message)? onMessage; // show this message (snack bar)

  bool get listening => _listening;

  Future<bool> _init() async {
    if (_ready) return true;
    _ready = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );
    return _ready;
  }

  void _onStatus(String status) {
    if (_disposed) return;
    if ((status == 'notListening' || status == 'done') && _listening) {
      _listening = false;
      notifyListeners();
    }
  }

  void _onError(SpeechRecognitionError e) {
    if (_disposed) return;
    debugPrint('Speech error: ${e.errorMsg}');
    _listening = false;
    notifyListeners();

    if (e.errorMsg == 'error_speech_timeout' ||
        e.errorMsg == 'error_no_match') {
      // only complain if nothing was heard
      if (!_heardWords) {
        onMessage?.call(
          "I didn't hear anything. Tap the mic and speak clearly.",
        );
      }
    } else if (e.errorMsg == 'error_permission') {
      onMessage?.call('Please allow the microphone permission for this app');
    } else if (e.errorMsg == 'error_network' ||
        e.errorMsg == 'error_network_timeout' ||
        e.errorMsg == 'error_language_unavailable' ||
        e.errorMsg == 'error_language_not_supported') {
      onMessage?.call(
        'Voice error: ${e.errorMsg}\n'
            'Download your language in the phone settings '
            '(Offline speech recognition), or type your message.',
      );
    } else {
      onMessage?.call('Speech error: ${e.errorMsg}');
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    // a late result after the chat was closed must not touch the screen
    if (_disposed) return;

    final words = result.recognizedWords.trim();
    if (words.isEmpty) return;

    _heardWords = true;
    final full = _textBeforeMic.isEmpty ? words : '$_textBeforeMic $words';
    onText?.call(full);
  }

  // tap the mic: start listening. currentText = what is already typed.
  Future<void> start(String currentText) async {
    final ok = await _init();
    if (!ok) {
      onMessage?.call(
        'Microphone permission is needed. Allow it in the app settings.',
      );
      return;
    }
    if (_disposed) return;

    _textBeforeMic = currentText.trim();
    _heardWords = false;
    _listening = true;
    notifyListeners();

    await _speech.listen(
      onResult: _onResult,
      listenOptions: stt.SpeechListenOptions(
        localeId: speechLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  // stop: keep the text in the box so you can edit it or send it
  Future<void> stop() async {
    if (!_listening) return;
    await _speech.stop();
    if (_disposed) return;
    _listening = false;
    notifyListeners();
  }

  // cancel: throw away what was heard
  Future<void> cancel() async {
    await _speech.cancel();
    if (_disposed) return;
    onText?.call(_textBeforeMic);
    _listening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    // the screen is closing: nothing may be typed or shown any more
    onText = null;
    onMessage = null;
    _speech.cancel();
    super.dispose();
  }
}