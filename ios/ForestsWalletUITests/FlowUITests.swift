import XCTest

final class FlowUITests: XCTestCase {
    private var screenshotDir: URL {
        let raw = ProcessInfo.processInfo.environment["FW_SCREENSHOT_DIR"]
            ?? NSTemporaryDirectory() + "fw-ios-ui-foundation-screenshots"
        let url = URL(fileURLWithPath: raw, isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testParentHomeNavigationAndEntry() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-FWRoleParent"]
        app.launch()

        let homeTitle = app.staticTexts["Forrest 的账本"].firstMatch
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 10))
        assertUnclipped(homeTitle, in: app)
        saveScreenshot(app, name: "parent-iphone-home")

        app.buttons["加进来"].tap()
        XCTAssertTrue(app.staticTexts["加进来多少"].waitForExistence(timeout: 5))
        saveScreenshot(app, name: "parent-iphone-entry")
        app.buttons["1"].tap()
        app.buttons["确认记录"].tap()
        XCTAssertTrue(app.buttons["记下来"].waitForExistence(timeout: 5))
        app.buttons["都跳过，直接记"].tap()
        XCTAssertTrue(app.staticTexts["已记录"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["已记录 · 没有任何真实资金移动"].exists)
        app.buttons["回首页"].tap()
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5))

        app.buttons["看板"].tap()
        XCTAssertTrue(app.staticTexts["本周看板"].firstMatch.waitForExistence(timeout: 5))
        saveScreenshot(app, name: "parent-iphone-board")

        app.buttons["记录"].tap()
        XCTAssertTrue(app.staticTexts["全部记录"].firstMatch.waitForExistence(timeout: 5))
        saveScreenshot(app, name: "parent-iphone-history")

        app.buttons["设置"].tap()
        XCTAssertTrue(app.staticTexts["设置"].firstMatch.waitForExistence(timeout: 5))
        saveScreenshot(app, name: "parent-iphone-settings")
    }

    func testParentBootstrap() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-FWUnpaired"]
        app.launch()
        if UIDevice.current.userInterfaceIdiom == .pad {
            throw XCTSkip("Bootstrap is the iPhone unpaired path")
        }
        XCTAssertTrue(app.buttons["注册为家长"].waitForExistence(timeout: 10))
        saveScreenshot(app, name: "parent-iphone-bootstrap")
        app.buttons["注册为家长"].tap()
        XCTAssertTrue(app.staticTexts["Forrest 的账本"].firstMatch.waitForExistence(timeout: 5))
    }

    func testChildHomeAndDetailScreens() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-FWRoleChild"]
        app.launch()

        let title = app.staticTexts["我的钱"].firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        assertUnclipped(title, in: app)
        saveScreenshot(app, name: idiomPrefix() + "-child-home")

        if app.buttons["本周看板"].waitForExistence(timeout: 2) {
            app.buttons["本周看板"].tap()
        } else {
            app.buttons["看板"].tap()
        }
        XCTAssertTrue(app.staticTexts["本周看板"].firstMatch.waitForExistence(timeout: 5))
        saveScreenshot(app, name: idiomPrefix() + "-child-board")

        app.buttons["规则"].tap()
        XCTAssertTrue(app.staticTexts["规则"].firstMatch.waitForExistence(timeout: 5))
        saveScreenshot(app, name: idiomPrefix() + "-child-rules")

        if app.buttons["全部流水"].waitForExistence(timeout: 1) {
            app.buttons["全部流水"].tap()
        } else {
            app.buttons["流水"].tap()
        }
        XCTAssertTrue(app.staticTexts["全部流水"].firstMatch.waitForExistence(timeout: 5))
        saveScreenshot(app, name: idiomPrefix() + "-child-ledger")

        if app.buttons["已实现的心愿"].waitForExistence(timeout: 1) {
            app.buttons["已实现的心愿"].tap()
        } else {
            app.buttons["心愿"].tap()
        }
        XCTAssertTrue(app.staticTexts["已实现的心愿"].firstMatch.waitForExistence(timeout: 5))
        saveScreenshot(app, name: idiomPrefix() + "-child-wishes")
    }

    func testIPadBothOrientationsUnclipped() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("iPad only")
        }
        let app = XCUIApplication()
        app.launchArguments = ["-FWRoleChild"]
        app.launch()
        XCTAssertTrue(app.staticTexts["我的钱"].firstMatch.waitForExistence(timeout: 10))

        XCUIDevice.shared.orientation = .landscapeLeft
        waitBriefly()
        assertUnclipped(app.staticTexts["我的钱"].firstMatch, in: app)
        saveScreenshot(app, name: "child-ipad-landscape")

        XCUIDevice.shared.orientation = .portrait
        waitBriefly()
        assertUnclipped(app.staticTexts["我的钱"].firstMatch, in: app)
        saveScreenshot(app, name: "child-ipad-portrait")
    }

    func testChildPairing() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("Child pairing is the iPad unpaired path")
        }
        let app = XCUIApplication()
        app.launchArguments = ["-FWUnpaired"]
        app.launch()
        XCTAssertTrue(app.staticTexts["请输入爸爸给你的 6 位数字"].waitForExistence(timeout: 10))
        saveScreenshot(app, name: "child-ipad-pairing")
        for digit in ["4", "8", "2", "9", "1", "7"] {
            app.buttons[digit].tap()
        }
        app.buttons["开始看"].tap()
        XCTAssertTrue(app.staticTexts["这是你的账本"].waitForExistence(timeout: 5))
        saveScreenshot(app, name: "child-ipad-welcome")
        app.buttons["开始看"].tap()
        XCTAssertTrue(app.staticTexts["我的钱"].firstMatch.waitForExistence(timeout: 5))
    }

    private func saveScreenshot(_ app: XCUIApplication, name: String) {
        let shot = app.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let url = screenshotDir.appendingPathComponent("\(name).png")
        try? shot.pngRepresentation.write(to: url)
    }

    private func assertUnclipped(_ element: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(element.exists)
        let window = app.windows.element(boundBy: 0).frame
        let frame = element.frame
        XCTAssertFalse(frame.isEmpty)
        XCTAssertTrue(window.insetBy(dx: -1, dy: -1).contains(frame), "clipped: \(frame) vs window \(window)")
    }

    private func idiomPrefix() -> String {
        UIDevice.current.userInterfaceIdiom == .pad ? "child-ipad" : "parent-iphone"
    }

    private func waitBriefly() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.6))
    }
}
