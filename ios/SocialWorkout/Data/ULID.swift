import Foundation

/// ID prefixes allowed by the schema's
/// `CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30)`.
enum IDPrefix: String {
    /// System / app-generated rows (seed data, resolved sessions, sets).
    case app = "app-"
    /// Rows the user authored by hand (custom exercises, custom plans).
    case user = "usr-"
}

/// Client-side ULID generator.
///
/// Produces `<prefix><26 char Crockford Base32>` strings that sort
/// lexicographically by creation time and are interchangeable with the Go
/// (`oklog/ulid`) and Dart (`mobile/lib/data/db/ulid.dart`) generators — the
/// whole point of ULIDs here is that any client can mint an ID offline and the
/// server will accept it without a round-trip.
///
/// Format: 48-bit millisecond timestamp (10 chars) + 80-bit randomness
/// (16 chars) = 26 Crockford chars; with the 4-char prefix = 30 total.
enum ULID {
    /// Crockford Base32 — omits I, L, O and U to avoid transcription ambiguity.
    private static let alphabet = Array("0123456789ABCDEFGHJKMNPQRSTVWXYZ")

    private static let lock = NSLock()
    private static var lastTimestamp: Int64 = -1
    /// The 16 base-32 digits of the random component of the last ID minted.
    private static var lastRandom = [UInt8](repeating: 0, count: 16)

    /// Mints a fresh prefixed ULID. Defaults to `app-`; pass `.user` for rows
    /// the person using the app created themselves.
    static func newID(_ prefix: IDPrefix = .app) -> String {
        prefix.rawValue + generate()
    }

    /// The bare 26-character ULID, no prefix.
    static func generate(now: Date = Date()) -> String {
        let timestamp = Int64(now.timeIntervalSince1970 * 1000)
        lock.lock()
        defer { lock.unlock() }

        // Monotonic within a millisecond: increment the random component rather
        // than redrawing it, so two IDs minted in the same millisecond still
        // sort in creation order. Without this, `ORDER BY id` — which the whole
        // model leans on instead of a separate sort key — would be arbitrary
        // for rows written in the same tick, e.g. the sets materialized in a
        // single startWorkout transaction.
        if timestamp == lastTimestamp {
            incrementRandom()
        } else {
            lastTimestamp = timestamp
            lastRandom = (0..<16).map { _ in UInt8.random(in: 0..<32) }
        }

        return encodeTime(timestamp) + String(lastRandom.map { alphabet[Int($0)] })
    }

    /// Recovers the creation time encoded in the first 10 characters of an ID.
    /// Accepts both prefixed (`app-01H…`) and bare ULIDs; returns nil if the
    /// string isn't a well-formed ULID.
    static func timestamp(of id: String) -> Date? {
        let bare = id.count == 30 ? String(id.dropFirst(4)) : id
        guard bare.count == 26 else { return nil }

        var milliseconds: Int64 = 0
        for character in bare.prefix(10) {
            guard let digit = alphabet.firstIndex(of: character) else { return nil }
            milliseconds = milliseconds << 5 | Int64(digit)
        }
        return Date(timeIntervalSince1970: Double(milliseconds) / 1000)
    }

    /// 48 bits of milliseconds as 10 base-32 chars, high-order first. The top
    /// char only carries 3 significant bits (10 × 5 = 50 > 48), so it stays 0
    /// until the year 10889 — same as every other ULID implementation.
    private static func encodeTime(_ milliseconds: Int64) -> String {
        var value = milliseconds
        var characters = [Character](repeating: alphabet[0], count: 10)
        for index in stride(from: 9, through: 0, by: -1) {
            characters[index] = alphabet[Int(value & 0x1F)]
            value >>= 5
        }
        return String(characters)
    }

    /// Adds one to the 80-bit random component, carrying across base-32 digits.
    /// Overflow (all digits at max — a 1-in-2^80 event) simply wraps.
    private static func incrementRandom() {
        for index in stride(from: 15, through: 0, by: -1) {
            if lastRandom[index] < 31 {
                lastRandom[index] += 1
                return
            }
            lastRandom[index] = 0
        }
    }
}
