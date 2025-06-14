import Foundation
import GRDB

/// Результат поиска: ID сообщения и фрагмент с подсветкой
struct SearchResult {
    let messageID: UUID
    let snippet: String
}

/// Сервис для полнотекстового поиска историй чатов через FTS5
final class HistorySearchService {
    static let shared = HistorySearchService()
    private let dbQueue: DatabaseQueue

    private init() {
        // Путь в Application Support
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbURL = folder.appendingPathComponent("HistorySearch.sqlite")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        dbQueue = try! DatabaseQueue(path: dbURL.path)
        try? createFTSTables()
    }

    private func createFTSTables() throws {
        try dbQueue.write { db in
            try db.create(virtualTable: "message_fts", using: FTS5()) { t in
                t.column("content")
            }
            // TODO: добавить триггеры синхронизации SwiftData → message_fts
        }
    }

    /// Поиск сообщений по запросу, возвращает ID и сниппет
    func search(_ query: String) -> [SearchResult] {
        do {
            return try dbQueue.read { db in
                let rows = try Row.fetchAll(db,
                    sql: "SELECT rowid AS rowid, snippet(message_fts, '<b>', '</b>') AS snippet FROM message_fts WHERE message_fts MATCH ?",
                    arguments: [query])
                return rows.compactMap { row in
                    // TODO: отображать реальный UUID, здесь заглушка
                    let id = UUID()
                    let snippet: String = row["snippet"]
                    return SearchResult(messageID: id, snippet: snippet)
                }
            }
        } catch {
            return []
        }
    }

    /// Полная реиндексация массива сообщений
    func reindexAll(messages: [Message]) throws {
        try dbQueue.write { db in
            try db.execute(sql: "DELETE FROM message_fts")
            for msg in messages {
                try db.execute(sql: "INSERT INTO message_fts(rowid, content) VALUES(?, ?)", arguments: [msg.id.uuidString, msg.content])
            }
        }
    }
} 