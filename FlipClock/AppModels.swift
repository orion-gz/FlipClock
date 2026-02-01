import SwiftUI
import Cocoa

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case english = "en"
    case korean = "ko"
    
    var id: String { rawValue }
    var displayName: String { self == .english ? "English" : "한국어" }
}

enum ClockFont: String, Codable, CaseIterable, Identifiable {
    case rounded = "Rounded"
    case monospaced = "Monospaced"
    case serif = "Serif"
    case digital = "Digital"
    case system = "System Custom"
    
    var id: String { rawValue }
}

enum BackgroundType: String, Codable, CaseIterable, Identifiable {
    case solid = "Solid"
    case linearGradient = "Linear Gradient"
    case animatedGradient = "Animated Gradient"
    case image = "Image"
    case web = "Website"
    case onlineImage = "Online Image"
    
    var id: String { rawValue }
}

enum MultiMonitorMode: String, Codable, CaseIterable, Identifiable {
    case primary = "Primary Screen"
    case all = "All Screens"
    
    var id: String { rawValue }
}

enum UpdateCheckFrequency: String, Codable, CaseIterable, Identifiable {
    case manual = "Manual"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var id: String { rawValue }
    
    var days: Int {
        switch self {
        case .manual: return 0
        case .daily: return 1
        case .weekly: return 7
        case .monthly: return 30
        }
    }
}

enum DateFormatOption: String, Codable, CaseIterable, Identifiable {
    case full = "full"
    case numericWithDay = "numDay"
    case numeric = "numeric"
    case monthDayYear = "mdy"
    case dayMonthYear = "dmy"
    
    var id: String { rawValue }
    
    func format(for language: AppLanguage) -> String {
        switch self {
        case .full: 
            return "EEEE, MMMM d, yyyy"
        case .numericWithDay: 
            return language == .korean ? "yyyy/MM/dd (EEE)" : "yyyy/MM/dd, EEE"
        case .numeric: 
            return "yyyy/MM/dd"
        case .monthDayYear: 
            return "MMM d, yyyy"
        case .dayMonthYear: 
            return "d MMM yyyy"
        }
    }
}

enum FlipClockTheme: String, CaseIterable, Identifiable, Codable {
    case dark = "Dark"
    case light = "Light"
    case midnight = "Midnight Blue"
    case sunset = "Sunset"
    case forest = "Forest"
    case ocean = "Ocean"
    case rose = "Rose Gold"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var colors: (background: Color, box: Color, text: Color) {
        switch self {
        case .dark: 
            return (.black, Color(white: 0.2), .white)
        case .light: 
            return (.white, Color(white: 0.95), .black)
        case .midnight: 
            return (Color(red: 0.05, green: 0.1, blue: 0.2), Color(red: 0.1, green: 0.2, blue: 0.35), Color(red: 0.6, green: 0.8, blue: 1.0))
        case .sunset: 
            return (Color(red: 0.15, green: 0.05, blue: 0.1), Color(red: 0.3, green: 0.15, blue: 0.2), Color(red: 1.0, green: 0.7, blue: 0.5))
        case .forest: 
            return (Color(red: 0.05, green: 0.15, blue: 0.1), Color(red: 0.1, green: 0.3, blue: 0.2), Color(red: 0.7, green: 0.9, blue: 0.7))
        case .ocean: 
            return (Color(red: 0.0, green: 0.15, blue: 0.25), Color(red: 0.0, green: 0.25, blue: 0.4), Color(red: 0.5, green: 0.9, blue: 1.0))
        case .rose: 
            return (Color(red: 0.2, green: 0.15, blue: 0.15), Color(red: 0.35, green: 0.25, blue: 0.3), Color(red: 1.0, green: 0.75, blue: 0.85))
        case .custom: 
            return (.black, Color(white: 0.2), .white)
        }
    }
}

struct NamedColor: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var red, green, blue, opacity: Double
    
    var color: Color { 
        Color(red: red, green: green, blue: blue, opacity: opacity) 
    }
    
    init(name: String, color: Color) {
        self.name = name
        let ns = NSColor(color).usingColorSpace(.sRGB) ?? .black
        self.red = Double(ns.redComponent)
        self.green = Double(ns.greenComponent)
        self.blue = Double(ns.blueComponent)
        self.opacity = Double(ns.alphaComponent)
    }
    
    static func == (lhs: NamedColor, rhs: NamedColor) -> Bool {
        return lhs.red == rhs.red && 
               lhs.green == rhs.green && 
               lhs.blue == rhs.blue && 
               lhs.opacity == rhs.opacity
    }
}

struct KeyboardShortcutData: Codable, Equatable {
    var keyChar: String
    var keyCode: UInt16
    var modifiers: Int
    
    var modifierFlags: NSEvent.ModifierFlags { 
        NSEvent.ModifierFlags(rawValue: UInt(modifiers)) 
    }
    
    var displayString: String {
        var str = ""
        let m = modifierFlags
        if m.contains(.control) { str += "⌃" }
        if m.contains(.option) { str += "⌥" }
        if m.contains(.shift) { str += "⇧" }
        if m.contains(.command) { str += "⌘" }
        return str + keyChar.uppercased()
    }
}

struct CustomTheme: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var backgroundColor, boxColor, textColor: NamedColor
    var clockScale, boxCornerRadius: Double
    var clockFont: ClockFont
    var customFontName: String
    var backgroundType: BackgroundType
    var showSeconds, dateDisplay: Bool
    var dateDisplayFormat: DateFormatOption
    var dateFont: ClockFont
    var dateCustomFontName: String
    var dateScale, secondsScale: Double
    var alwaysOnTop, showMenuBarIcon, militaryTimeSound, use24HourFormat: Bool
    var amPmBoxScale, glassOpacity, glassBlur, shadowIntensity: Double
    var liquidGlassEnabled, shadowEnabled, screenSaverEnabled, exitOnActivity, flipSoundEnabled, launchAtLogin: Bool
    var idleTimeMinutes: Int
}
