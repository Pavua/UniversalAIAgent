import Foundation

/// Менеджер плагинов для бирж
class PluginManager {
    static let shared = PluginManager()
    
    private var plugins: [String: ExchangePlugin] = [:]
    
    private init() {
        registerDefaultPlugins()
    }
    
    private func registerDefaultPlugins() {
        plugins["okx"] = OKXPlugin()
        plugins["gateio"] = GateIOPlugin()
        plugins["binance"] = BinancePlugin()
    }
    
    func getPlugin(for exchange: String) -> ExchangePlugin? {
        return plugins[exchange.lowercased()]
    }
    
    func registerPlugin(_ plugin: ExchangePlugin, for exchange: String) {
        plugins[exchange.lowercased()] = plugin
    }
    
    func availableExchanges() -> [String] {
        return Array(plugins.keys)
    }
}

protocol ExchangePlugin {
    var name: String { get }
    func websocketURL(for symbol: String) -> URL?
    func subscriptionMessage(for symbol: String) -> String?
    func parsePrice(from message: String) -> Double?
}

// Базовая реализация для Binance
class BinancePlugin: ExchangePlugin {
    let name = "Binance"
    
    func websocketURL(for symbol: String) -> URL? {
        let lowerSymbol = symbol.lowercased()
        return URL(string: "wss://stream.binance.com:9443/ws/\(lowerSymbol)@ticker")
    }
    
    func subscriptionMessage(for symbol: String) -> String? {
        // Binance не требует дополнительных сообщений подписки для ticker streams
        return nil
    }
    
    func parsePrice(from message: String) -> Double? {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let priceString = json["c"] as? String,
              let price = Double(priceString) else {
            return nil
        }
        return price
    }
}
