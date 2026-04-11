import 'dart:math';

/// Client-side ULID generator.
///
/// Produces `app-<26 char Crockford Base32>` strings that satisfy the
/// schema's `CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30)`
/// constraint and sort lexicographically by creation time. This matches the
/// Go side's `app-` prefix from `github.com/oklog/ulid/v2`.
///
/// Format: 48-bit millisecond timestamp (10 chars) + 80-bit randomness (16
/// chars) = 26 Crockford chars; with the `app-` prefix = 30 chars total.
class Ulid {
  Ulid._();

  /// Crockford Base32 alphabet — omits I, L, O, U to avoid ambiguity.
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  static final Random _random = Random.secure();

  /// Generates a fresh `app-`-prefixed ULID.
  static String generate() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'app-${_encodeTime(now)}${_encodeRandom()}';
  }

  static String _encodeTime(int ms) {
    // 48 bits = 10 base-32 chars. Shift 5 bits at a time, high-order first.
    final chars = List<String>.filled(10, '0');
    var value = ms;
    for (var i = 9; i >= 0; i--) {
      chars[i] = _alphabet[value & 0x1F];
      value >>= 5;
    }
    return chars.join();
  }

  static String _encodeRandom() {
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buffer.write(_alphabet[_random.nextInt(32)]);
    }
    return buffer.toString();
  }
}
