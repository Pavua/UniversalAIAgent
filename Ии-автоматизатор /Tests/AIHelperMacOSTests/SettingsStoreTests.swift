import XCTest
@testable import AIHelperMacOS

final class SettingsStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Сброс настроек перед каждым тестом
        UserDefaults.standard.removeObject(forKey: "llmSettings")
    }

    func testDefaultValues() {
        let store = SettingsStore()
        XCTAssertTrue(store.useLocalFirst)
        XCTAssertFalse(store.manualOverride)
        XCTAssertEqual(store.apiKey, "")
        XCTAssertNil(store.selectedLocalModelPath)
    }

    func testPersistSettings() {
        let store = SettingsStore()
        store.useLocalFirst = false
        store.manualOverride = true
        store.selectedLocalModelPath = "/tmp/model.gguf"
        // Загружаем новое хранилище
        let newStore = SettingsStore()
        XCTAssertEqual(newStore.useLocalFirst, false)
        XCTAssertEqual(newStore.manualOverride, true)
        XCTAssertEqual(newStore.selectedLocalModelPath, "/tmp/model.gguf")
    }
} 