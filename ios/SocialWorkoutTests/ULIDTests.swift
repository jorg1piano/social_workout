import XCTest

@testable import SocialWorkout

final class ULIDTests: XCTestCase {
    func testIDsSatisfyTheSchemaConstraint() {
        // schema.sql: CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30)
        for prefix in [IDPrefix.app, .user] {
            let id = ULID.newID(prefix)
            XCTAssertEqual(id.count, 30)
            XCTAssertTrue(id.hasPrefix(prefix.rawValue))
        }
    }

    func testUsesOnlyCrockfordBase32() {
        let allowed = CharacterSet(charactersIn: "0123456789ABCDEFGHJKMNPQRSTVWXYZ")
        let body = String(ULID.newID().dropFirst(4))
        XCTAssertTrue(body.unicodeScalars.allSatisfy(allowed.contains))
    }

    func testIDsSortInCreationOrder() {
        // The model leans on `ORDER BY id` being chronological, so IDs minted
        // back to back — inside one startWorkout transaction, say — must sort
        // in the order they were created even within a single millisecond.
        let ids = (0..<500).map { _ in ULID.newID() }
        XCTAssertEqual(ids, ids.sorted(), "ULIDs are not monotonically increasing")
        XCTAssertEqual(Set(ids).count, ids.count, "ULIDs collided")
    }

    func testTimestampRoundTrips() throws {
        let moment = Date(timeIntervalSince1970: 1_700_000_000)
        let id = IDPrefix.app.rawValue + ULID.generate(now: moment)
        let decoded = try XCTUnwrap(ULID.timestamp(of: id))
        XCTAssertEqual(decoded.timeIntervalSince1970, moment.timeIntervalSince1970, accuracy: 0.001)
    }

    func testTimestampRejectsMalformedIDs() {
        XCTAssertNil(ULID.timestamp(of: "not-a-ulid"))
    }
}
