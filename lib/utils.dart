import 'package:flutter/foundation.dart';

/*
tools without UI
*/

/// check the current platform
class OS {
  bool android = false;
  bool ios = false;
  bool linux = false;
  bool windows = false;
  bool macos = false;
  bool web = kIsWeb;

  static bool isMobile([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return true;
    }
    return false;
  }

  static bool isWeb([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return true;
    return false;
  }

  /// return forceValue if not null otherwise right boolean
  static bool isDesktop([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return true;
    }
    return false;
  }

  static bool isAndroid([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) return true;
    return false;
  }

  static bool isIOS([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.iOS) return true;
    return false;
  }

  static bool isLinux([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.linux) return true;
    return false;
  }

  static bool isWindows([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.windows) return true;
    return false;
  }
}
