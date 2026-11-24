import 'package:flutter/foundation.dart';

import '../core/app_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// One language the mic can listen to.
class VoiceLanguage {
  final String id;
  final String name; // shown in English
  final String nativeName; // shown in its own script
  final String short; // two letters for the small chip

  const VoiceLanguage({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.short,
  });
}

class VoiceInputProvider extends ChangeNotifier {
  // the languages the user can choose from
  static const List<VoiceLanguage> languages = [
    VoiceLanguage(
      id: 'en_IN',
      name: 'English',
      nativeName: 'English (India)',
      short: 'EN',
    ),
    VoiceLanguage(
      id: 'kn_IN',
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      short: 'KN',
    ),
    VoiceLanguage(
      id: 'hi_IN',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      short: 'HI',
    ),
  ];

  // the last chosen language is remembered while the app is open,
  // so opening another chat keeps it
  static String _lastLocale = 'en_IN';

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _ready = false;
  bool _listening = false;
  bool _heardWords = false;
  bool _disposed = false;
  String _localeId = _lastLocale;
  String _textBeforeMic = ''; // what was typed before pressing the mic

  // the screen sets these two
  void Function(String text)? onText; // put this text in the message box
  void Function(String message)? onMessage; // show this message (snack bar)

  bool get listening => _listening;
  String get localeId => _localeId;

  VoiceLanguage get language => languages.firstWhere(
        (l) => l.id == _localeId,
    orElse: () => languages.first,
  );

  // ---------- CHOOSE THE LANGUAGE ----------
  Future<void> changeLanguage(String id, String currentText) async {
    if (id == _localeId) return;

    final wasListening = _listening;
    if (wasListening) {
      await _speech.stop();
      if (_disposed) return;
      _listening = false;
    }

    _localeId = id;
    _lastLocale = id;
    notifyListeners();

    if (wasListening) {
      await start(currentText);
    }
  }

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

    final l = AppText.l;

    if (e.errorMsg == 'error_speech_timeout' ||
        e.errorMsg == 'error_no_match') {
      // only complain if nothing was heard
      if (!_heardWords) {
        onMessage?.call(l.voiceNoSpeech(language.name));
      }
    } else if (e.errorMsg == 'error_permission') {
      onMessage?.call(l.micPermission);
    } else if (e.errorMsg == 'error_language_unavailable' ||
        e.errorMsg == 'error_language_not_supported') {
      onMessage?.call(l.voiceLangNotReady(language.name));
    } else if (e.errorMsg == 'error_network' ||
        e.errorMsg == 'error_network_timeout') {
      onMessage?.call(l.voiceNetworkError(e.errorMsg, language.name));
    } else {
      onMessage?.call(l.speechError(e.errorMsg));
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
      onMessage?.call(AppText.l.micPermissionNeeded);
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
        localeId: _localeId,
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