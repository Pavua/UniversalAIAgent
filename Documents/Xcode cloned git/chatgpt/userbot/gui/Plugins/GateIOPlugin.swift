import Foundation

/// Плагин для Gate.io биржи
class GateIOPlugin: ExchangePlugin {
    let name = "Gate.io"
    let supportedTimeframes: [Timeframe] = Timeframe.allCases
    
    init() {}
    
    func fetchHistory(symbol: String, timeframe: Timeframe) async throws -> [(Date, Double)] {
        // TODO: Реализовать через REST API
        return []
    }
    
    func startStream(symbol: String, timeframe: Timeframe) -> AsyncStream<(Date, Double)> {
        AsyncStream { continuation in
            // TODO: Реализовать WebSocket подключение
            continuation.finish()
        }
    }
    
    func websocketURL(for symbol: String) -> URL? {
        return URL(string: "wss://api.gateio.ws/ws/v4/")
    }
    
    func subscriptionMessage(for symbol: String) -> String? {
        let subscription: [String: Any] = [
            "method": "ticker.subscribe",
            "params": [symbol.uppercased()],
            "id": 1
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: subscription),
              let message = String(data: data, encoding: .utf8) else {
            return nil
        }
        return message
    }
    
    func parsePrice(from message: String) -> Double? {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = json["result"] as? [String: Any],
              let priceString = result["last"] as? String else {
            return nil
        }
        return Double(priceString)
    }
}