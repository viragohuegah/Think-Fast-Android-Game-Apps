import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Flutter's HapticFeedback.
/// No external package needed — uses platform channels.
abstract final class HapticService {
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('[HapticService] error: $e');
    }
  }

  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('[HapticService] error: $e');
    }
  }

  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('[HapticService] error: $e');
    }
  }

  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('[HapticService] error: $e');
    }
  }

  static Future<void> error() async {
    try {
      // Double vibrate pattern for error
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('[HapticService] error: $e');
    }
  }
}
