import SwiftUI
import MarkdownUI

struct CryptoView: View {
    @StateObject private var service = CryptoExchangeService()
    @State private var selectedExchange: String = "okx"
    @State private var selectedSymbol: String = "BTCUSDT"

    var body: some View {
        VStack(spacing: 16) {
            // Header with connection status
            HStack {
                Text("Крипто-трекер")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Connection status indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(connectionStatusColor)
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.5), value: service.connectionStatus)
                    
                    Text(connectionStatusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Exchange and symbol selectors
            HStack {
                Picker("Биржа", selection: $selectedExchange) {
                    ForEach(["binance", "okx", "gateio"], id: \.self) { exchange in
                        Text(exchange.uppercased()).tag(exchange)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Символ", selection: $selectedSymbol) {
                    ForEach(["BTCUSDT", "ETHUSDT", "ADAUSDT", "SOLUSDT"], id: \.self) { symbol in
                        Text(symbol).tag(symbol)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Current price display
            VStack(spacing: 8) {
                if service.currentPrice > 0 {
                    Text("$\(service.currentPrice, specifier: "%.4f")")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: service.currentPrice)
                    
                    Text("Обновлено: \(service.lastUpdateTime, formatter: timeFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Загрузка...")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            // Price history list (temporary replacement for Charts)
            if !service.priceHistory.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("История цен (последние 10)")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(service.priceHistory.suffix(10), id: \.timestamp) { point in
                                HStack {
                                    Text(point.timestamp, formatter: timeFormatter)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("$\(point.price, specifier: "%.4f")")
                                        .font(.caption.monospaced())
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .padding()
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(12)
            }
            
            // Error message
            if let error = service.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(LocalizedStringKey("tab_crypto"))
        .onAppear {
            service.startPriceStream(exchange: selectedExchange, symbol: selectedSymbol)
        }
        .onChange(of: selectedExchange) { _, newExchange in
            service.startPriceStream(exchange: newExchange, symbol: selectedSymbol)
        }
        .onChange(of: selectedSymbol) { _, newSymbol in
            service.startPriceStream(exchange: selectedExchange, symbol: newSymbol)
        }
    }
    
    private var connectionStatusColor: Color {
        switch service.connectionStatus {
        case .connected: return .green
        case .disconnected: return .red
        case .reconnecting: return .orange
        }
    }
    
    private var connectionStatusText: String {
        switch service.connectionStatus {
        case .connected: return "Подключено"
        case .disconnected: return "Отключено"
        case .reconnecting: return "Переподключение..."
        }
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
}

#Preview {
    NavigationStack {
        CryptoView()
    }
}
