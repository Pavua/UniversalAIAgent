import Foundation
#if canImport(Sentry)
import Sentry
#endif

/// Сервис для сбора телеметрии и ошибок
final class TelemetryService {
    static let shared = TelemetryService()
    private init() {}

    /// Инициализация SDK телеметрии (Sentry DSN)
    func setup(dsn: String) {
        #if canImport(Sentry)
        SentrySDK.start { options in
            options.dsn = dsn
            options.debug = true // для отладки
        }
        #endif
    }

    /// Захват ошибки
    func capture(error: Error) {
        #if canImport(Sentry)
        SentrySDK.capture(error: error)
        #endif
    }

    /// Захват события с сообщением
    func capture(message: String) {
        #if canImport(Sentry)
        SentrySDK.capture(message: message)
        #endif
    }
} 