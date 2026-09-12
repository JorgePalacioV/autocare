class Logger {
  static const String _defaultTag = '[AutoCare]';
  static bool _debugMode = true;

  static void setDebugMode(bool debug) {
    _debugMode = debug;
  }

  static void log(String message, {String? tag}) {
    if (_debugMode) {
      final fullTag = tag ?? _defaultTag;
      // ignore: avoid_print
      print('$fullTag $message');
    }
  }

  static void success(String message, {String? tag}) {
    log('✓ $message', tag: tag);
  }

  static void error(String message, {String? tag}) {
    log('✗ $message', tag: tag);
  }

  static void info(String message, {String? tag}) {
    log('ℹ $message', tag: tag);
  }

  static void warning(String message, {String? tag}) {
    log('⚠ $message', tag: tag);
  }
}
