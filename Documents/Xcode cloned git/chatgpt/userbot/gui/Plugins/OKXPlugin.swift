import Foundation

/// Плагин для OKX биржи
class OKXPlugin: ExchangePlugin {
    let name = "OKX"
    let exchange: CryptoExchange = .okx
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
        return URL(string: "wss://ws.okx.com:8443/ws/v5/public")
    }
    
    func subscriptionMessage(for symbol: String) -> String? {
        let subscription: [String: Any] = [
            "op": "subscribe",
            "args": [
                [
                    "channel": "tickers",
                    "instId": symbol.uppercased()
                ]
            ]
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
              let dataArray = json["data"] as? [[String: Any]],
              let firstItem = dataArray.first,
              let priceString = firstItem["last"] as? String else {
            return nil
        }
        return Double(priceString)
    }
}
