import 'dart:convert';
import 'package:bluerum/core/network/lemmy_api_client.dart';

/// Centralized helper to format exceptions and API errors to a clean, user-friendly string.
/// Sanitizes [FormatException] to avoid leaking raw HTML/JSON blocks to the user interface.
String formatError(Object error) {
  if (error is LemmyApiException) {
    final msg = error.message.trim();
    if (msg.isEmpty) return 'An API error occurred. Please try again.';

    // Check if the message itself is a stringified JSON block or map representation
    if (msg.startsWith('{') && msg.endsWith('}')) {
      try {
        final cleanMsg = _tryExtractErrorMessage(msg);
        if (cleanMsg != null) return cleanMsg;
      } catch (_) {}
    }
    
    // Strip common "LemmyApiException: " if callers pass toString().
    return msg.replaceFirst(RegExp(r'^LemmyApiException:\s*'), '');
  }

  final raw = error.toString();

  // If it's a FormatException (which typically contains the raw response body)
  if (error is FormatException || raw.contains('FormatException')) {
    return 'Invalid server response. Please try again later.';
  }

  if (raw.contains('SocketException') ||
      raw.contains('ClientException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('Connection failed')) {
    return 'Connection failed. Check your network and try again.';
  }
  if (raw.contains('TimeoutException') || raw.contains('timed out')) {
    return 'Request timed out. Please try again.';
  }

  final cleaned = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
  if (cleaned.isEmpty) return 'Something went wrong. Please try again.';
  return cleaned;
}

String? _tryExtractErrorMessage(String msg) {
  // Try parsing as JSON first
  try {
    final parsed = jsonDecode(msg);
    if (parsed is Map) {
      if (parsed.containsKey('message')) return parsed['message']?.toString();
      if (parsed.containsKey('error')) return parsed['error']?.toString();
    }
  } catch (_) {}

  // Handle Dart's Map.toString() format: "{key: value, key2: value2}"
  final messageMatch = RegExp(r'(?:message|error):\s*([^,}]+)').firstMatch(msg);
  if (messageMatch != null) {
    return messageMatch.group(1)?.trim();
  }
  
  return null;
}
