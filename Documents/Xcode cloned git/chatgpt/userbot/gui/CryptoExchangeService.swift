import Combine
import Foundation

struct PricePoint {
    let price: Double
    let timestamp: Date
}

enum ConnectionStatus {
    case connected, disconnected, reconnecting
}

@MainActor
class CryptoExchangeService: ObservableObject {
    @Published var currentPrice: Double = 0.0
    @Published var priceHistory: [PricePoint] = []
    @Published var errorMessage: String? = nil
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var lastUpdateTime: Date = Date()
    
    private var websocketTask: URLSessionWebSocketTask?
    private let pluginManager = PluginManager.shared
    private var currentExchange: String = "okx"
    private var currentSymbol: String = "BTCUSDT"
    
    private var reconnectTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5

    func startPriceStream(exchange: String, symbol: String) {
        currentExchange = exchange
        currentSymbol = symbol
        connectWebSocket(for: exchange, symbol: symbol)
    }
    
    func stopPriceStream() async {
        websocketTask?.cancel()
        websocketTask = nil
        connectionStatus = .disconnected
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        reconnectAttempts = 0
    }
    
    private func connectWebSocket(for exchange: String, symbol: String) {
        guard let plugin = pluginManager.getPlugin(for: exchange) else {
            errorMessage = "Плагин для биржи \(exchange) не найден"
            connectionStatus = .disconnected
            return
        }
        
        guard let url = plugin.websocketURL(for: symbol) else {
            errorMessage = "Не удалось создать WebSocket URL для \(symbol) на \(exchange)"
            connectionStatus = .disconnected
            return
        }
        
        // Disconnect existing connection
        websocketTask?.cancel()
        
        errorMessage = nil
        connectionStatus = .reconnecting
        
        websocketTask = URLSession.shared.webSocketTask(with: url)
        websocketTask?.resume()
        
        // Send subscription message
        if let subscribeMessage = plugin.subscriptionMessage(for: symbol) {
            websocketTask?.send(.string(subscribeMessage)) { [weak self] error in
                Task { @MainActor in
                    if let error = error {
                        self?.errorMessage = "Ошибка подписки: \(error.localizedDescription)"
                        self?.connectionStatus = .disconnected
                        self?.scheduleReconnect()
                    }
                }
            }
        }
        
        connectionStatus = .connected
        reconnectAttempts = 0
        
        receiveMessage()
    }
    
    private func scheduleReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else {
            errorMessage = "Превышено максимальное количество попыток переподключения"
            connectionStatus = .disconnected
            return
        }
        
        reconnectAttempts += 1
        let delay = min(pow(2.0, Double(reconnectAttempts)), 30.0) // Exponential backoff, max 30s
        
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.startPriceStream(exchange: self.currentExchange, symbol: self.currentSymbol)
            }
        }
    }
    
    private func receiveMessage() {
        websocketTask?.receive { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let text):
                        self.handleWebSocketMessage(text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            self.handleWebSocketMessage(text)
                        }
                    @unknown default:
                        break
                    }
                    self.receiveMessage() // Continue receiving
                    
                case .failure(let error):
                    self.errorMessage = "WebSocket ошибка: \(error.localizedDescription)"
                    self.connectionStatus = .disconnected
                    self.scheduleReconnect()
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ text: String) {
        guard let plugin = pluginManager.getPlugin(for: currentExchange) else { return }
        
        if let price = plugin.parsePrice(from: text) {
            currentPrice = price
            lastUpdateTime = Date()
            
            // Add to history with sliding window
            priceHistory.append(PricePoint(price: price, timestamp: Date()))
            if priceHistory.count > 100 {
                priceHistory.removeFirst()
            }
        }
    }
    
    deinit {
        Task { @MainActor in
            await stopPriceStream()
        }
    }
}

// Legacy compatibility - will be removed
enum CryptoExchange: String, CaseIterable, Identifiable {
    case okx = "OKX"
    case gateio = "Gate.io"
    case binance = "Binance"
    
    var id: String { rawValue }
}

enum Timeframe: String, CaseIterable, Identifiable {
    case oneMinute = "1m"
    case fiveMinutes = "5m"
    case oneHour = "1H"
    case oneDay = "1D"
    
    var id: String { rawValue }
}
