import 'dart:js_interop';

import 'package:dashboard_core/dashboard_core.dart';

@JS('window.Telegram.WebApp')
external JSObject? get _telegramWebApp;

@JS('window.moneyTherapistLockTelegramSwipe')
external JSFunction? get _lockTelegramSwipeFunction;

class TelegramUser {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? languageCode;

  const TelegramUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.languageCode,
  });

  String get displayName {
    if (firstName != null && firstName!.trim().isNotEmpty) {
      return firstName!;
    }

    if (username != null && username!.trim().isNotEmpty) {
      return '@$username';
    }

    return 'Admin';
  }
}

class TelegramWebApp {
  TelegramWebApp._();

  static final TelegramWebApp instance = TelegramWebApp._();

  JSObject? _webApp;

  bool get isAvailable => _webApp != null;

  void init() {
    try {
      _webApp = _telegramWebApp;

      if (_webApp == null) return;

      _call('ready');
      _call('expand');
      _call('disableVerticalSwipes');
      _call('enableClosingConfirmation');
      _lockTelegramSwipe();
    } catch (_) {
      _webApp = null;
    }
  }

  String get colorScheme {
    try {
      if (_webApp == null) return 'light';
      final value = _getProperty(_webApp!, 'colorScheme');
      return value?.toString() ?? 'light';
    } catch (_) {
      return 'light';
    }
  }

  bool get isDarkMode => colorScheme.toLowerCase() == 'dark';

  String get initData {
    try {
      if (_webApp == null) return '';
      final value = _getProperty(_webApp!, 'initData');
      return value?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  TelegramUser? get user {
    try {
      if (_webApp == null) return null;

      final unsafe = _getProperty(_webApp!, 'initDataUnsafe');
      if (unsafe == null) return null;

      final rawUser = _getProperty(unsafe as JSObject, 'user');
      if (rawUser == null) return null;

      final userObject = rawUser as JSObject;

      return TelegramUser(
        id: _getInt(userObject, 'id'),
        firstName: _getString(userObject, 'first_name'),
        lastName: _getString(userObject, 'last_name'),
        username: _getString(userObject, 'username'),
        languageCode: _getString(userObject, 'language_code'),
      );
    } catch (_) {
      return null;
    }
  }

  void hapticImpact() {
    try {
      if (_webApp == null) return;

      final haptic = _getProperty(_webApp!, 'HapticFeedback');
      if (haptic == null) return;

      _callMethod(haptic as JSObject, 'impactOccurred', ['medium']);
    } catch (_) {}
  }

  void hapticSuccess() {
    try {
      if (_webApp == null) return;

      final haptic = _getProperty(_webApp!, 'HapticFeedback');
      if (haptic == null) return;

      _callMethod(haptic as JSObject, 'notificationOccurred', ['success']);
    } catch (_) {}
  }

  void hapticError() {
    try {
      if (_webApp == null) return;

      final haptic = _getProperty(_webApp!, 'HapticFeedback');
      if (haptic == null) return;

      _callMethod(haptic as JSObject, 'notificationOccurred', ['error']);
    } catch (_) {}
  }

  void close() {
    _call('close');
  }

  void expand() {
    _call('expand');
    _lockTelegramSwipe();
  }

  void _call(String method) {
    try {
      if (_webApp == null) return;
      _callMethod(_webApp!, method, []);
    } catch (_) {}
  }

  void _lockTelegramSwipe() {
    try {
      _lockTelegramSwipeFunction?.callAsFunction();
    } catch (_) {}
  }

  String? _getString(JSObject object, String key) {
    try {
      final value = _getProperty(object, key);
      return value?.toString();
    } catch (_) {
      return null;
    }
  }

  int? _getInt(JSObject object, String key) {
    try {
      final value = _getProperty(object, key);
      if (value == null) return null;

      return int.tryParse(value.toString());
    } catch (_) {
      return null;
    }
  }
}

class TelegramWebAppContext implements TelegramContext {
  final TelegramWebApp webApp;

  const TelegramWebAppContext(this.webApp);

  @override
  String get initData => webApp.initData;

  @override
  bool get isDarkMode => webApp.isDarkMode;

  @override
  TelegramUserData? get user {
    final appUser = webApp.user;
    final id = appUser?.id;
    if (appUser == null || id == null) return null;

    return TelegramUserData(
      id: id,
      firstName: appUser.firstName,
      lastName: appUser.lastName,
      username: appUser.username,
    );
  }
}

extension _JSObjectHelpers on JSObject {
  external JSAny? operator [](String key);
}

JSAny? _getProperty(JSObject object, String key) {
  return object[key];
}

void _callMethod(JSObject object, String method, List<Object?> args) {
  final function = object[method];

  if (function == null) return;

  if (args.isEmpty) {
    (function as JSFunction).callAsFunction(object);
    return;
  }

  if (args.length == 1) {
    (function as JSFunction).callAsFunction(object, args[0].jsify());
    return;
  }

  if (args.length == 2) {
    (function as JSFunction).callAsFunction(
      object,
      args[0].jsify(),
      args[1].jsify(),
    );
    return;
  }

  throw UnsupportedError('Only up to 2 JS arguments are supported.');
}
