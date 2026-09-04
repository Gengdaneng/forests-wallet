import XCTest
@testable import ForestsWallet

final class TokenTests: XCTestCase {
    func testPRDBrandHex() {
        XCTAssertEqual(FWPalette.spruce700, 0x173D35)
        XCTAssertEqual(FWPalette.leaf200, 0xD8EDD5)
        XCTAssertEqual(FWPalette.honey500, 0xF3C968)
        XCTAssertEqual(FWPalette.paper100, 0xFBF7ED)
        XCTAssertEqual(FWPalette.berry600, 0xBE3E2B)
        XCTAssertEqual(FWPalette.clay600, 0x8C6A50)
    }

    func testTouchFloors() {
        XCTAssertGreaterThanOrEqual(FWSpace.touchMin, 44)
        XCTAssertGreaterThanOrEqual(FWSpace.touchParent, 48)
        XCTAssertGreaterThanOrEqual(FWSpace.touchChild, 54)
        XCTAssertGreaterThanOrEqual(FWControlSize.parent.touch, 44)
        XCTAssertGreaterThanOrEqual(FWControlSize.child.touch, 44)
        XCTAssertGreaterThanOrEqual(FWControlSize.small.touch, 44)
    }

    func testRadiiMatchSystem() {
        XCTAssertEqual(FWRadius.cardParent, 16)
        XCTAssertEqual(FWRadius.cardChild, 24)
        XCTAssertEqual(FWRadius.cell, 10)
        XCTAssertEqual(FWSpace.sidebarWidth, 280)
        XCTAssertEqual(FWSpace.maxChildColumn, 720)
    }

    func testSpendCategoriesAreTheSix() {
        XCTAssertEqual(SpendCategory.all.map(\.id), ["food", "toy", "game", "book", "gift", "other"])
        XCTAssertEqual(SpendCategory.all.map(\.emoji), ["🍦", "🧸", "🎮", "📚", "🎁", "❓"])
    }
}

final class MoneyFormatTests: XCTestCase {
    func testCentsBecomeWholeYuan() {
        XCTAssertEqual(MoneyFormat.yuan(8700), "87")
        XCTAssertEqual(MoneyFormat.yuan(0), "0")
        XCTAssertEqual(MoneyFormat.yuan(-2000), "20")
        XCTAssertEqual(MoneyFormat.yuanNumber(40000), 400)
    }

    func testDirectionSigns() {
        XCTAssertEqual(MoneyDirection.income.sign, "+")
        XCTAssertEqual(MoneyDirection.spend.sign, "−")
        XCTAssertEqual(MoneyDirection.correction.sign, "±")
        XCTAssertEqual(MoneyDirection.flat.sign, "")
    }
}

@MainActor
final class SampleStoreTests: XCTestCase {
    func testLaunchParentSkipsPairing() {
        let store = SampleWalletStore.fromLaunchArguments(["-FWRoleParent"])
        XCTAssertEqual(store.role, .parent)
        XCTAssertEqual(store.balanceCents, 8700)
    }

    func testLaunchChildSkipsWelcomePairing() {
        let store = SampleWalletStore.fromLaunchArguments(["-FWRoleChild"])
        XCTAssertEqual(store.role, .child)
        XCTAssertTrue(store.hasSeenChildWelcome)
    }

    func testPairingAcceptsSampleCode() async {
        let store = SampleWalletStore(launchRole: .unpaired)
        XCTAssertNil(store.role)
        let rejected = await store.pairChild(code: "000000")
        XCTAssertFalse(rejected)
        XCTAssertNil(store.role)
        let accepted = await store.pairChild(code: SampleData.pairingCode)
        XCTAssertTrue(accepted)
        XCTAssertEqual(store.role, .child)
        XCTAssertFalse(store.hasSeenChildWelcome)
    }

    func testParentWriteUpdatesBalanceAndChildCannotWrite() {
        let parent = SampleWalletStore(launchRole: .parent)
        let before = parent.balanceCents
        XCTAssertTrue(parent.recordEntry(direction: .income, yuan: 5, reason: "帮忙搬水", categoryID: nil))
        XCTAssertEqual(parent.balanceCents, before + 500)
        XCTAssertEqual(parent.transactions.first?.reason, "帮忙搬水")
        XCTAssertEqual(parent.transactions.first?.direction, .income)

        XCTAssertTrue(parent.recordEntry(direction: .spend, yuan: 15, reason: "买冰淇淋", categoryID: "food"))
        XCTAssertEqual(parent.balanceCents, before + 500 - 1500)
        XCTAssertEqual(parent.transactions.first?.categoryID, "food")

        let child = SampleWalletStore(launchRole: .child)
        let childBefore = child.balanceCents
        XCTAssertFalse(child.recordEntry(direction: .income, yuan: 10, reason: "不该成功", categoryID: nil))
        XCTAssertEqual(child.balanceCents, childBefore)
        XCTAssertEqual(child.lastRecordRejectedReason, "儿童端不能记账")
    }

    func testOfflineRejectsWrites() {
        let store = SampleWalletStore.fromLaunchArguments(["-FWRoleParent", "-FWOffline"])
        XCTAssertFalse(store.isOnline)
        let before = store.balanceCents
        XCTAssertFalse(store.recordEntry(direction: .income, yuan: 2, reason: "x", categoryID: nil))
        XCTAssertEqual(store.balanceCents, before)
        XCTAssertEqual(store.lastRecordRejectedReason, "没有写入任何记录 —— 记账必须联网")
    }

    func testBoardToggleSkipsFuture() {
        let store = SampleWalletStore(launchRole: .parent)
        XCTAssertEqual(store.board[0].days[3], .unlogged)
        store.toggleBoardCell(row: 0, day: 3)
        XCTAssertEqual(store.board[0].days[3], .done)
        store.toggleBoardCell(row: 0, day: 3)
        XCTAssertEqual(store.board[0].days[3], .unlogged)
        store.toggleBoardCell(row: 0, day: 6)
        XCTAssertEqual(store.board[0].days[6], .future)
    }

    func testSettlementWritesOnce() {
        let store = SampleWalletStore(launchRole: .parent)
        store.board = store.board.map { item in
            var copy = item
            copy.days = Array(repeating: .done, count: 7)
            return copy
        }
        let before = store.balanceCents
        let expected = store.snapshot.settlementTotalCents
        XCTAssertGreaterThan(expected, 0)
        store.confirmSettlement()
        XCTAssertTrue(store.settledThisWeek)
        XCTAssertEqual(store.balanceCents, before + expected)
        store.confirmSettlement()
        XCTAssertEqual(store.balanceCents, before + expected)
    }
}
