class CacheException implements Exception {
  const CacheException([this.message = 'Cache operation failed']);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}