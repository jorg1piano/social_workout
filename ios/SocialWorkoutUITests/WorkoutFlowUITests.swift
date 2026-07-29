import XCTest

/// Drives the app the way a person does: browse the plan, start a session from
/// it, log a set, finish, and find it in history.
///
/// These are the tests that would have caught a screen that compiles but never
/// renders — the unit tests only ever see the repository.
final class WorkoutFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        // Start from the canonical seed so slot names and counts are known.
        app.launchArguments = ["-resetStore"]
        app.launch()
    }

    /// List section headers are uppercased when rendered, so header text is
    /// matched case-insensitively rather than against the literal source string.
    private func staticText(containing fragment: String) -> XCUIElement {
        app.staticTexts
            .containing(NSPredicate(format: "label CONTAINS[c] %@", fragment))
            .firstMatch
    }

    /// SwiftUI lists render rows lazily, so an element below the fold does not
    /// exist until it's scrolled into view.
    private func scrollTo(_ element: XCUIElement, maxSwipes: Int = 12) {
        var swipes = 0
        while !element.exists && swipes < maxSwipes {
            app.swipeUp()
            swipes += 1
        }
    }

    /// Waits for the seed to finish loading on first launch.
    private func waitForLaunch() {
        XCTAssertTrue(
            app.tabBars.buttons["Exercises"].waitForExistence(timeout: 30),
            "app never got past the launch screen")
    }

    func testEveryTabRenders() {
        waitForLaunch()

        for tab in ["Exercises", "Plans", "Run", "History"] {
            app.tabBars.buttons[tab].tap()
            // Generous: each UI test relaunches the app and re-seeds the store,
            // so a simulator under load can take a few seconds per tab.
            XCTAssertTrue(
                app.navigationBars[tab].waitForExistence(timeout: 15),
                "\(tab) tab did not render")
        }
    }

    func testExerciseLibraryIsSeededAndSearchable() {
        waitForLaunch()
        app.tabBars.buttons["Exercises"].tap()

        XCTAssertTrue(app.staticTexts["Bench Press"].waitForExistence(timeout: 5))

        app.searchFields["Search exercises"].tap()
        app.typeText("Squat")
        XCTAssertTrue(app.staticTexts["Squat"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Bench Press"].exists, "search did not filter the list")
    }

    func testPlanShowsItsBlocksAndSwapVariants() {
        waitForLaunch()
        app.tabBars.buttons["Plans"].tap()
        app.buttons["plan-Push Day"].tap()

        XCTAssertTrue(
            app.navigationBars["Push Day"].waitForExistence(timeout: 5),
            "tapping the plan did not open it")
        XCTAssertTrue(
            staticText(containing: "block 1").waitForExistence(timeout: 5),
            "no block header rendered")
        // Push Day's first slot offers Bench Press with an Incline swap.
        XCTAssertTrue(app.staticTexts["default"].exists, "no default variant marked")
        XCTAssertTrue(app.staticTexts["swap 1"].exists, "no swap variant shown")
    }

    func testLegDayShowsASuperset() {
        waitForLaunch()
        app.tabBars.buttons["Plans"].tap()
        app.buttons["plan-Leg Day"].tap()

        XCTAssertTrue(
            staticText(containing: "superset").waitForExistence(timeout: 5),
            "Leg Day should surface its superset block")
    }

    /// The whole point of the app, in one test: plan → session → record.
    func testStartASessionLogASetAndFindItInHistory() {
        waitForLaunch()

        app.tabBars.buttons["Run"].tap()
        // The seed data leaves a Push Day session in progress, so the plan row
        // is addressed by identifier rather than by its (ambiguous) title.
        app.buttons["start-Push Day"].tap()

        let start = app.buttons["Start session"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        start.tap()

        // The session opens with the plan's sets materialized, none completed.
        XCTAssertTrue(app.staticTexts["Elapsed"].waitForExistence(timeout: 10))
        let markDone = app.buttons["Mark set done"].firstMatch
        XCTAssertTrue(markDone.waitForExistence(timeout: 5), "no set rows to log")
        markDone.tap()

        XCTAssertTrue(
            app.buttons["Mark set not done"].firstMatch.waitForExistence(timeout: 5),
            "completing a set did not stick")

        let finish = app.buttons["Finish session"]
        scrollTo(finish)
        finish.tap()
        app.buttons["Finish"].tap()

        // And it reads back on the record side.
        app.tabBars.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5))
        // Newest first, so the session just finished is at the top.
        app.buttons.matching(identifier: "session-row").firstMatch.tap()

        // LabeledContent merges its label and value into one element, so the
        // provenance verdict is matched as a fragment rather than exactly.
        let provenance = staticText(containing: "provenance")
        scrollTo(provenance)
        XCTAssertTrue(provenance.exists, "session detail never showed provenance")
        XCTAssertTrue(
            staticText(containing: "intact").exists,
            "a session started from a live plan should keep its provenance")
    }
}
