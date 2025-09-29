import 'app_config.dart';

/// Resolves relative image URLs by prefixing the API base URL.
/// Returns the original URL if it is already absolute (http/https) or a data URI.
String? resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  final lower = url.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://') || lower.startsWith('data:')) {
    return url;
  }
  final base = AppConfig.apiBaseUrl;
  if (url.startsWith('/')) {
    return '$base$url';
  }
  return '$base/$url';
}
