import SwiftUI
import Cocoa

// MARK: - Shapes & Helpers

struct RoundedRectangleTopHalf: Shape {
    let cornerRadius: Double
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        p.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius), 
                 radius: cornerRadius, 
                 startAngle: .degrees(270), 
                 endAngle: .degrees(180), 
                 clockwise: true)
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius))
        p.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius), 
                 radius: cornerRadius, 
                 startAngle: .degrees(0), 
                 endAngle: .degrees(270), 
                 clockwise: true)
        p.closeSubpath()
        return p
    }
}

struct RoundedRectangleBottomHalf: Shape {
    let cornerRadius: Double
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius))
        p.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius), 
                 radius: cornerRadius, 
                 startAngle: .degrees(180), 
                 endAngle: .degrees(90), 
                 clockwise: true)
        p.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
        p.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius), 
                 radius: cornerRadius, 
                 startAngle: .degrees(90), 
                 endAngle: .degrees(0), 
                 clockwise: true)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

struct AnyShape: Shape {
    private let _p: (CGRect) -> Path
    
    init<S: Shape>(_ s: S) { _p = s.path }
    
    func path(in r: CGRect) -> Path { _p(r) }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Components

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 24, height: 24)
                if isSelected {
                    Circle()
                        .stroke(Color.primary, lineWidth: 2)
                        .frame(width: 30, height: 30)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ThemePreviewButton: View {
    let theme: FlipClockTheme?
    let custom: CustomTheme?
    let isSelected: Bool
    let action: () -> Void
    @ObservedObject private var mgr = FlipClockManager.shared
    
    var body: some View {
        let colors = custom != nil ? 
            (custom!.backgroundColor.color, custom!.boxColor.color, custom!.textColor.color) : 
            (theme?.colors.background ?? .black, theme?.colors.box ?? .gray, theme?.colors.text ?? .white)
        let font = custom?.clockFont ?? mgr.clockFont
        
        Button(action: action) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colors.0)
                        .frame(height: 60)
                    HStack(spacing: 2) {
                        MiniFlipDigit(value: 0, color: colors.2, boxColor: colors.1, font: font)
                        MiniFlipDigit(value: 9, color: colors.2, boxColor: colors.1, font: font)
                        Text(":")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(colors.2)
                        MiniFlipDigit(value: 4, color: colors.2, boxColor: colors.1, font: font)
                        MiniFlipDigit(value: 1, color: colors.2, boxColor: colors.1, font: font)
                    }
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 3)
                    }
                }
                Text(custom?.name ?? theme?.rawValue ?? "")
                    .font(.caption)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MiniFlipDigit: View {
    let value: Int
    let color: Color
    let boxColor: Color
    let font: ClockFont
    @ObservedObject private var mgr = FlipClockManager.shared
    
    var body: some View {
        let currentCustomFont = mgr.customFontName
        let miniFont: Font = {
            switch font {
            case .rounded: return .system(size: 14, weight: .bold, design: .rounded)
            case .monospaced: return .system(size: 14, weight: .bold, design: .monospaced)
            case .serif: return .system(size: 14, weight: .bold, design: .serif)
            case .digital: return .custom("Courier", size: 14).weight(.bold)
            case .system: return .custom(currentCustomFont, size: 14).weight(.bold)
            }
        }()
        
        VStack(spacing: 0.5) {
            ZStack {
                AnyShape(RoundedRectangleTopHalf(cornerRadius: 2))
                    .fill(boxColor)
                Text("\(value)")
                    .font(miniFont)
                    .foregroundColor(color)
                    .offset(y: 5)
                    .clipped()
            }
            .frame(width: 14, height: 10)
            
            ZStack {
                AnyShape(RoundedRectangleBottomHalf(cornerRadius: 2))
                    .fill(boxColor)
                Text("\(value)")
                    .font(miniFont)
                    .foregroundColor(color)
                    .offset(y: -5)
                    .clipped()
            }
            .frame(width: 14, height: 10)
        }
    }
}

struct ColorSection: View {
    let title: String
    @Binding var selectedColor: Color
    let presetColors: [Color]
    let customPresets: [NamedColor]
    let onAddColor: () -> Void
    let onDeletePreset: (NamedColor) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(presetColors, id: \.self) { c in
                        ColorButton(color: c, isSelected: selectedColor == c) {
                            selectedColor = c
                        }
                    }
                    ForEach(customPresets) { p in
                        ColorButton(color: p.color, isSelected: selectedColor == p.color) {
                            selectedColor = p.color
                        }
                        .contextMenu {
                            Button("Delete") { onDeletePreset(p) }
                        }
                    }
                    Button(action: onAddColor) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 5)
            }
        }
    }
}

struct ShortcutRecorder: View {
    @Binding var shortcut: KeyboardShortcutData
    @State private var isRecording = false
    @State private var monitor: Any?
    
    var body: some View {
        Button(action: {
            if isRecording { stopRecording() }
            else { startRecording() }
        }) {
            Text(isRecording ? "..." : shortcut.displayString)
                .frame(minWidth: 100)
                .padding(6)
                .background(isRecording ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isRecording ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onDisappear { stopRecording() }
    }
    
    private func startRecording() {
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if [123, 124, 125, 126, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63].contains(event.keyCode) { return event }
            let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let char = event.charactersIgnoringModifiers?.lowercased() ?? ""
            if !char.isEmpty {
                let map: [UInt16: String] = [0:"a",1:"s",2:"d",3:"f",4:"h",5:"g",6:"z",7:"x",8:"c",9:"v",11:"b",12:"q",13:"w",14:"e",15:"r",16:"y",17:"t",18:"1",19:"2",20:"3",21:"4",22:"6",23:"5",25:"9",26:"7",28:"8",29:"0",31:"o",32:"u",34:"i",35:"p",37:"l",38:"j",40:"k",45:"n",46:"m"]
                let finalChar = map[event.keyCode] ?? (char.range(of: "^[a-z0-9]$") != nil ? char : "")
                if !finalChar.isEmpty {
                    self.shortcut = KeyboardShortcutData(keyChar: finalChar, keyCode: event.keyCode, modifiers: Int(mods.rawValue))
                    self.stopRecording()
                    return nil
                }
            }
            return event
        }
    }
    
    private func stopRecording() {
        isRecording = false
        if let m = monitor {
            NSEvent.removeMonitor(m)
            monitor = nil
        }
    }
}

struct SaveThemeView: View {
    @StateObject private var mgr = FlipClockManager.shared
    @Binding var themeName: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(mgr.localized("save_current_as_theme"))
                .font(.headline)
            TextField(mgr.localized("theme_name"), text: $themeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 220)
            HStack {
                Button(mgr.localized("cancel")) { dismiss() }
                Button(mgr.localized("save")) {
                    if !themeName.isEmpty {
                        onSave()
                        dismiss()
                    }
                }
                .disabled(themeName.isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    let onSave: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var colorName: String = "My Color"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Color")
                .font(.headline)
            TextField("Name", text: $colorName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
            ColorPicker("Select", selection: $selectedColor)
                .frame(width: 200)
            HStack {
                Button("Cancel") { dismiss() }
                Button("Add") {
                    onSave(colorName)
                    dismiss()
                }
            }
        }
        .padding()
        .frame(width: 300)
    }
}

// MARK: - Clock Views

struct FlipHalfCard: View {
    let value: Int
    let type: CardType
    let color: Color
    let boxColor: Color
    let cornerRadius: Double
    let scale: Double
    let liquidGlass: Bool
    let glassOpacity: Double
    let glassBlur: Double
    let clockFont: ClockFont
    @ObservedObject private var mgr = FlipClockManager.shared
    
    enum CardType { case top, bottom }
    
    var body: some View {
        let s = 100 * scale
        let font: Font = {
            switch clockFont {
            case .rounded: return .system(size: s, weight: .bold, design: .rounded)
            case .monospaced: return .system(size: s, weight: .bold, design: .monospaced)
            case .serif: return .system(size: s, weight: .bold, design: .serif)
            case .digital: return .custom("Courier", size: s).weight(.bold)
            case .system: return .custom(mgr.customFontName, size: s).weight(.bold)
            }
        }()
        
        ZStack {
            Rectangle()
                .fill(boxColor)
                .frame(width: s, height: 70 * scale)
            Text("\(value)")
                .font(font)
                .foregroundColor(color)
                .offset(y: type == .top ? 35 * scale : -35 * scale)
                .frame(width: s, height: 70 * scale)
                .clipped()
            
            if liquidGlass {
                Rectangle()
                    .fill(LinearGradient(colors: [.white.opacity(glassOpacity), .white.opacity(glassOpacity * 0.5), .clear], 
                                         startPoint: .topLeading, 
                                         endPoint: .bottomTrailing))
                    .blur(radius: glassBlur * 0.1)
            }
            
            Rectangle()
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        }
        .frame(width: s, height: 70 * scale)
        .clipShape(type == .top ? AnyShape(RoundedRectangleTopHalf(cornerRadius: cornerRadius * scale)) : AnyShape(RoundedRectangleBottomHalf(cornerRadius: cornerRadius * scale)))
    }
}

struct FlipDigitView: View {
    let value: Int
    let color: Color
    let boxColor: Color
    let cornerRadius: Double
    let scale: Double
    let liquidGlass: Bool
    let glassOpacity: Double
    let glassBlur: Double
    let clockFont: ClockFont
    
    @State private var cur: Int
    @State private var nxt: Int
    @State private var rot: Double = 0
    @ObservedObject private var mgr = FlipClockManager.shared
    
    init(value: Int, color: Color, boxColor: Color, cornerRadius: Double, scale: Double, liquidGlass: Bool, glassOpacity: Double, glassBlur: Double, clockFont: ClockFont) {
        self.value = value
        self.color = color
        self.boxColor = boxColor
        self.cornerRadius = cornerRadius
        self.scale = scale
        self.liquidGlass = liquidGlass
        self.glassOpacity = glassOpacity
        self.glassBlur = glassBlur
        self.clockFont = clockFont
        _cur = State(initialValue: value)
        _nxt = State(initialValue: value)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                FlipHalfCard(value: nxt, type: .top, color: color, boxColor: boxColor, cornerRadius: cornerRadius, scale: scale, liquidGlass: liquidGlass, glassOpacity: glassOpacity, glassBlur: glassBlur, clockFont: clockFont)
                FlipHalfCard(value: cur, type: .bottom, color: color, boxColor: boxColor, cornerRadius: cornerRadius, scale: scale, liquidGlass: liquidGlass, glassOpacity: glassOpacity, glassBlur: glassBlur, clockFont: clockFont)
            }
            
            VStack(spacing: 0) {
                ZStack {
                    if rot <= 90 {
                        FlipHalfCard(value: cur, type: .top, color: color, boxColor: boxColor, cornerRadius: cornerRadius, scale: scale, liquidGlass: liquidGlass, glassOpacity: glassOpacity, glassBlur: glassBlur, clockFont: clockFont)
                            .overlay(Color.black.opacity(rot / 180 * 0.3))
                    } else {
                        FlipHalfCard(value: nxt, type: .bottom, color: color, boxColor: boxColor, cornerRadius: cornerRadius, scale: scale, liquidGlass: liquidGlass, glassOpacity: glassOpacity, glassBlur: glassBlur, clockFont: clockFont)
                            .rotation3DEffect(.degrees(180), axis: (1,0,0))
                            .overlay(Color.black.opacity((180-rot)/180*0.3))
                    }
                }
                .rotation3DEffect(.degrees(rot), axis: (1,0,0), anchor: .bottom, perspective: 0.3)
                Spacer().frame(height: 70 * scale)
            }
            .zIndex(10)
            
            Rectangle()
                .fill(Color.black.opacity(0.15))
                .frame(width: 100 * scale, height: 1.5 * scale)
                .zIndex(11)
        }
        .frame(width: 100 * scale, height: 140 * scale)
        .shadow(color: mgr.shadowEnabled ? .black.opacity(mgr.shadowIntensity) : .clear, 
                radius: 10 * scale, x: 0, y: 5 * scale)
        .onChange(of: value) { newValue in
            if newValue != cur {
                nxt = newValue
                rot = 0
                if mgr.flipSoundEnabled { NSSound(named: "Tink")?.play() }
                withAnimation(.easeInOut(duration: 0.6)) { rot = 180 }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {
                    cur = newValue
                    rot = 0
                }
            }
        }
    }
}

struct FlipTextView: View {
    let text: String
    let color: Color
    let boxColor: Color
    let cornerRadius: Double
    let scale: Double
    let liquidGlass: Bool
    let glassOpacity: Double
    let glassBlur: Double
    let clockFont: ClockFont
    
    @State private var cur: String
    @State private var nxt: String
    @State private var rot: Double = 0
    @ObservedObject private var mgr = FlipClockManager.shared
    
    init(text: String, color: Color, boxColor: Color, cornerRadius: Double, scale: Double, liquidGlass: Bool, glassOpacity: Double, glassBlur: Double, clockFont: ClockFont) {
        self.text = text
        self.color = color
        self.boxColor = boxColor
        self.cornerRadius = cornerRadius
        self.scale = scale
        self.liquidGlass = liquidGlass
        self.glassOpacity = glassOpacity
        self.glassBlur = glassBlur
        self.clockFont = clockFont
        _cur = State(initialValue: text)
        _nxt = State(initialValue: text)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                FlipTextHalfCard(text: nxt, type: .top, color: color, boxColor: boxColor, cornerRadius: cornerRadius, scale: scale, liquidGlass: liquidGlass, glassOpacity: glassOpacity, glassBlur: glassBlur, clockFont: clockFont)
                FlipTextHalfCard(text: cur, type: .bottom, color: color, boxColor: boxColor, cornerRadius: cornerRadius, scale: scale, liquidGlass: liquidGlass, glassOpacity: glassOpacity, glassBlur: glassBlur, clockFont: clockFont)
            }
            
            VStack(spacing: 0) {
                ZStack {
                    if rot <= 90 {
                        FlipTextHalfCard(text: cur, type: .top, color: color, boxColor: boxColor, cornerRadius: cornerRadius, scale: scale, liquidGlass: liquidGlass, glassOpacity: glassOpacity, glassBlur: glassBlur, clockFont: clockFont)
                            .overlay(Color.black.opacity(rot / 180 * 0.3))
                    } else {
                        FlipTextHalfCard(text: nxt, type: .bottom, color: color, boxColor: boxColor, cornerRadius: cornerRadius, scale: scale, liquidGlass: liquidGlass, glassOpacity: glassOpacity, glassBlur: glassBlur, clockFont: clockFont)
                            .rotation3DEffect(.degrees(180), axis: (1,0,0))
                            .overlay(Color.black.opacity((180-rot)/180*0.3))
                    }
                }
                .rotation3DEffect(.degrees(rot), axis: (1,0,0), anchor: .bottom, perspective: 0.3)
                Spacer().frame(height: 70 * scale)
            }
            .zIndex(10)
            
            Rectangle()
                .fill(Color.black.opacity(0.15))
                .frame(width: 100 * scale, height: 1.5 * scale)
                .zIndex(11)
        }
        .frame(width: 100 * scale, height: 140 * scale)
        .shadow(color: mgr.shadowEnabled ? .black.opacity(mgr.shadowIntensity) : .clear, 
                radius: 10 * scale, x: 0, y: 5 * scale)
        .onChange(of: text) { newValue in
            if newValue != cur {
                nxt = newValue
                rot = 0
                if mgr.flipSoundEnabled { NSSound(named: "Tink")?.play() }
                withAnimation(.easeInOut(duration: 0.6)) { rot = 180 }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {
                    cur = newValue
                    rot = 0
                }
            }
        }
    }
}

struct FlipTextHalfCard: View {
    let text: String
    let type: FlipHalfCard.CardType
    let color: Color
    let boxColor: Color
    let cornerRadius: Double
    let scale: Double
    let liquidGlass: Bool
    let glassOpacity: Double
    let glassBlur: Double
    let clockFont: ClockFont
    @ObservedObject private var mgr = FlipClockManager.shared
    
    var body: some View {
        let s = 100 * scale
        let font: Font = {
            switch clockFont {
            case .rounded: return .system(size: 50 * scale, weight: .bold, design: .rounded)
            case .monospaced: return .system(size: 50 * scale, weight: .bold, design: .monospaced)
            case .serif: return .system(size: 50 * scale, weight: .bold, design: .serif)
            case .digital: return .custom("Courier", size: 50 * scale).weight(.bold)
            case .system: return .custom(mgr.customFontName, size: 50 * scale).weight(.bold)
            }
        }()
        
        ZStack {
            Rectangle()
                .fill(boxColor)
                .frame(width: s, height: 70 * scale)
            Text(text)
                .font(font)
                .foregroundColor(color)
                .offset(y: type == .top ? 35 * scale : -35 * scale)
                .frame(width: s, height: 70 * scale)
                .clipped()
            
            if liquidGlass {
                Rectangle()
                    .fill(LinearGradient(colors: [.white.opacity(glassOpacity), .white.opacity(glassOpacity * 0.5), .clear], 
                                         startPoint: .topLeading, 
                                         endPoint: .bottomTrailing))
                    .blur(radius: glassBlur * 0.1)
            }
            
            Rectangle()
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        }
        .frame(width: s, height: 70 * scale)
        .clipShape(type == .top ? AnyShape(RoundedRectangleTopHalf(cornerRadius: cornerRadius * scale)) : AnyShape(RoundedRectangleBottomHalf(cornerRadius: cornerRadius * scale)))
    }
}
