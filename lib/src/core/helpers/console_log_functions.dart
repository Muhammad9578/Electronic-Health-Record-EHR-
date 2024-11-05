import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'enums.dart';

void logError([String? message = "..."]) {
  _debugLog("${_getColorCode(LogColor.red)}❌ $message");
}

void logSuccess([String? message = "..."]) {
  _debugLog("${_getColorCode(LogColor.green)}✅ $message");
}

void logWarning([String? message = "..."]) {
  _debugLog("${_getColorCode(LogColor.yellow)}⚠️ $message");
}

void logInfo([String? message = "..."]) {
  _debugLog("${_getColorCode(LogColor.blue)}ℹ️ $message");
}

void logDebug([String? message = "..."]) {
  _debugLog("${_getColorCode(LogColor.purple)}🔍 $message");
}

void logTrace([String? message = "..."]) {
  _debugLog("${_getColorCode(LogColor.cyan)}🔷 $message");
}

void logJSON({String? message = "Object:", dynamic object}) {
  _debugLog(
      "${_getColorCode(LogColor.purple)} $message ${const JsonEncoder.withIndent('  ').convert(object)}");
}

void logAnimatedText([String? message = "..."]) {
  _debugLog(
      "${_getColorCode(LogColor.yellow)} ${_getColorCode(LogColor.animated)}🪄 $message");
}

void _debugLog(Object? object) {
  if (kDebugMode) {
    log("$object");
  }
}

String _getColorCode(LogColor color) {
  switch (color) {
    case LogColor.red:
      return "\u001b[1;31m";
    case LogColor.green:
      return "\u001b[1;32m";
    case LogColor.yellow:
      return "\u001b[1;33m";
    case LogColor.blue:
      return "\u001b[1;34m";
    case LogColor.purple:
      return "\u001b[1;35m";
    case LogColor.cyan:
      return "\u001b[1;36m";
    case LogColor.gray:
      return "\u001b[1;30m";
    case LogColor.animated:
      return "\u001b[1;38;5;208m";
    default:
      return "\u001b[1;34m";
  }
}
