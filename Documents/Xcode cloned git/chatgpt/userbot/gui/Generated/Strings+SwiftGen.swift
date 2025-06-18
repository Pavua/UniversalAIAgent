// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
enum L10n {
    /// Answer
    static let answer = L10n.tr("Localizable", "answer", fallback: "Answer")
    /// API HASH
    static let apiHash = L10n.tr("Localizable", "api_hash", fallback: "API HASH")
    /// API ID
    static let apiId = L10n.tr("Localizable", "api_id", fallback: "API ID")
    /// Appearance
    static let appearance = L10n.tr("Localizable", "appearance", fallback: "Appearance")
    /// Bot Token (optional)
    static let botTokenOptional = L10n.tr("Localizable", "bot_token_optional", fallback: "Bot Token (optional)")
    /// Cancel
    static let cancel = L10n.tr("Localizable", "cancel", fallback: "Cancel")
    /// Dark Mode
    static let darkMode = L10n.tr("Localizable", "dark_mode", fallback: "Dark Mode")
    /// Generate
    static let generate = L10n.tr("Localizable", "generate", fallback: "Generate")
    /// LLM Services
    static let llmServices = L10n.tr("Localizable", "llm_services", fallback: "LLM Services")
    /// LMStudio URL
    static let lmStudioUrl = L10n.tr("Localizable", "lm_studio_url", fallback: "LMStudio URL")
    /// Messages per Day
    static let messagesPerDay = L10n.tr("Localizable", "messages_per_day", fallback: "Messages per Day")
    /// No chats available
    static let noChatsMessage = L10n.tr("Localizable", "no_chats_message", fallback: "No chats available")
    /// OpenAI API Key
    static let openaiApiKey = L10n.tr("Localizable", "openai_api_key", fallback: "OpenAI API Key")
    /// Prompt
    static let prompt = L10n.tr("Localizable", "prompt", fallback: "Prompt")
    /// Search Chats
    static let searchChats = L10n.tr("Localizable", "search_chats", fallback: "Search Chats")
    /// Select a chat
    static let selectChat = L10n.tr("Localizable", "select_chat", fallback: "Select a chat")
    /// Analytics
    static let tabAnalytics = L10n.tr("Localizable", "tab_analytics", fallback: "Analytics")
    /// Crypto
    static let tabCrypto = L10n.tr("Localizable", "tab_crypto", fallback: "Crypto")
    /// Fine-Tune
    static let tabFinetune = L10n.tr("Localizable", "tab_finetune", fallback: "Fine-Tune")
    /// LMStudio
    static let tabLmstudio = L10n.tr("Localizable", "tab_lmstudio", fallback: "LMStudio")
    /// Local LLM
    static let tabLocalLlm = L10n.tr("Localizable", "tab_local_llm", fallback: "Local LLM")
    /// OpenAI
    static let tabOpenai = L10n.tr("Localizable", "tab_openai", fallback: "OpenAI")
    /// Settings
    static let tabSettings = L10n.tr("Localizable", "tab_settings", fallback: "Settings")
    /// Telegram
    static let tabTelegram = L10n.tr("Localizable", "tab_telegram", fallback: "Telegram")
    /// Telegram Credentials
    static let telegramCredentials = L10n.tr("Localizable", "telegram_credentials", fallback: "Telegram Credentials")
}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
    private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
        let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: BundleToken.self)
        #endif
    }()
}

// swiftlint:enable convenience_type
