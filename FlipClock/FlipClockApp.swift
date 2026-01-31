import SwiftUI
import Cocoa
import Combine
import Carbon
import WebKit
import UniformTypeIdentifiers

// MARK: - Main Views

class BlockMoveView: NSView { 
    override var mouseDownCanMoveWindow: Bool { false } 
}

struct BlockWindowDrag: NSViewRepresentable {
    func makeNSView(context: Context) -> BlockMoveView { 
        BlockMoveView() 
    }
    func updateNSView(_ nsView: BlockMoveView, context: Context) {}
}

struct WebView: NSViewRepresentable {
    let urlString: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        if let view = webView.enclosingScrollView {
            view.hasVerticalScroller = false
            view.hasHorizontalScroller = false
            view.horizontalScrollElasticity = .none
            view.verticalScrollElasticity = .none
        }
        loadURL(in: webView)
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if nsView.url?.absoluteString != formattedURLString {
            loadURL(in: nsView)
        }
    }
    
    private var formattedURLString: String {
        var str = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !str.isEmpty && !str.lowercased().hasPrefix("http") { 
            str = "https://" + str 
        }
        return str
    }
    
    private func loadURL(in webView: WKWebView) {
        if let url = URL(string: formattedURLString) {
            webView.load(URLRequest(url: url))
        }
    }
}

struct SettingsView: View {
    @ObservedObject private var mgr = FlipClockManager.shared
    @Binding var isPresented: Bool
    @State private var showCP = false
    @State private var newC = Color.blue
    @State private var cpT: ColorPickerType = .background
    @State private var showCust = false
    @State private var showSave = false
    @State private var nName = ""
    @State private var selectedTab = 0
    
    enum ColorPickerType { case background, box, text }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(mgr.localized("settings"))
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { withAnimation { isPresented = false } }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            // Liquid Glass Style Tab Bar
            HStack(spacing: 0) {
                tabButton(idx: 0, title: mgr.localized("tab_general"), icon: "gearshape")
                tabButton(idx: 1, title: mgr.localized("tab_appearance"), icon: "paintbrush")
                tabButton(idx: 2, title: mgr.localized("tab_time"), icon: "clock")
                tabButton(idx: 3, title: mgr.localized("tab_saver"), icon: "display")
                tabButton(idx: 4, title: mgr.localized("tab_info"), icon: "info.circle")
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
            
            Divider()
            
            // Tab Content
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    if selectedTab == 0 {
                        // General Tab
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text(mgr.localized("language"))
                                    .font(.headline)
                                Spacer()
                                Picker("", selection: $mgr.language) {
                                    ForEach(AppLanguage.allCases) { 
                                        Text($0.displayName).tag($0) 
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 120)
                            }
                            
                            Divider()
                            
                            Toggle(mgr.localized("launch_at_login"), isOn: $mgr.launchAtLogin)
                            Toggle(mgr.localized("show_menubar"), isOn: $mgr.showMenuBarIcon)
                            Toggle(mgr.localized("hide_dock_icon"), isOn: $mgr.hideDockIcon)
                            Toggle(mgr.localized("always_on_top"), isOn: $mgr.alwaysOnTop)
                            
                            Divider()
                            
                            Picker(mgr.localized("multi_monitor"), selection: $mgr.multiMonitorMode) {
                                Text(mgr.localized("primary_only")).tag(MultiMonitorMode.primary)
                                Text(mgr.localized("all_screens")).tag(MultiMonitorMode.all)
                            }
                            .pickerStyle(.menu)
                            
                            Divider()
                            
                            Text("Feedback")
                                .font(.headline)
                            Toggle(mgr.localized("hourly_chime"), isOn: $mgr.militaryTimeSound)
                            Toggle(mgr.localized("flip_sound"), isOn: $mgr.flipSoundEnabled)
                        }
                    } else if selectedTab == 1 {
                        // Appearance Tab
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 15) {
                                Text(mgr.localized("themes"))
                                    .font(.headline)
                                Toggle(mgr.localized("follow_system"), isOn: $mgr.followSystemAppearance)
                                
                                Text(mgr.localized("standard"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                    ForEach(FlipClockTheme.allCases.filter { $0 != .custom }) { t in
                                        ThemePreviewButton(theme: t, custom: nil, isSelected: mgr.selectedTheme == t) { 
                                            mgr.applyTheme(t) 
                                        }
                                    }
                                }
                                
                                HStack { 
                                    Text(mgr.localized("my_presets"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer() 
                                }
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                    ForEach(mgr.savedThemes) { t in
                                        ThemePreviewButton(theme: nil, custom: t, isSelected: mgr.selectedTheme == .custom && mgr.activeCustomThemeId == t.id) {
                                            mgr.applyCustomTheme(t)
                                        }
                                        .contextMenu { 
                                            Button(mgr.localized("delete")) { mgr.removeTheme(t) } 
                                        }
                                    }
                                    
                                    Button(action: { showSave = true }) {
                                        VStack {
                                            ZStack { 
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                                    .frame(height: 60)
                                                Image(systemName: "plus") 
                                            }
                                            Text(mgr.localized("save"))
                                                .font(.caption)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .popover(isPresented: $showSave) {
                                        SaveThemeView(themeName: $nName, onSave: { 
                                            mgr.saveCurrentAsTheme(name: nName) 
                                        })
                                    }
                                }
                            }
                            
                            Divider()
                            
                            DisclosureGroup(mgr.localized("customize"), isExpanded: $showCust) {
                                VStack(spacing: 20) {
                                    ColorSection(title: mgr.localized("background_color"), 
                                                 selectedColor: $mgr.backgroundColor, 
                                                 presetColors: mgr.presetColors, 
                                                 customPresets: mgr.customPresets, 
                                                 onAddColor: { cpT = .background; showCP = true }, 
                                                 onDeletePreset: { mgr.removePreset($0) })
                                    
                                    ColorSection(title: mgr.localized("box_color"), 
                                                 selectedColor: $mgr.boxColor, 
                                                 presetColors: mgr.presetColors, 
                                                 customPresets: mgr.customPresets, 
                                                 onAddColor: { cpT = .box; showCP = true }, 
                                                 onDeletePreset: { mgr.removePreset($0) })
                                    
                                    ColorSection(title: mgr.localized("text_color"), 
                                                 selectedColor: $mgr.textColor, 
                                                 presetColors: mgr.presetColors, 
                                                 customPresets: mgr.customPresets, 
                                                 onAddColor: { cpT = .text; showCP = true }, 
                                                 onDeletePreset: { mgr.removePreset($0) })
                                }
                                .padding(.top)
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text(mgr.localized("size_appearance"))
                                    .font(.headline)
                                HStack {
                                    Text(mgr.localized("font"))
                                        .font(.subheadline)
                                    Spacer()
                                    Picker("", selection: $mgr.clockFont) { 
                                        ForEach(ClockFont.allCases) { 
                                            Text($0.rawValue).tag($0) 
                                        } 
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 120)
                                }
                                
                                if mgr.clockFont == .system {
                                    HStack {
                                        Text("System Font")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Picker("", selection: $mgr.customFontName) {
                                            ForEach(NSFontManager.shared.availableFontFamilies.sorted(), id: \.self) { family in
                                                Text(family).tag(family)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .frame(width: 180)
                                    }
                                    .padding(.leading, 10)
                                }
                                
                                VStack {
                                    HStack { 
                                        Text(mgr.localized("clock_size"))
                                        Spacer()
                                        Text(String(format: "%.1fx", mgr.clockScale)) 
                                    }
                                    Slider(value: $mgr.clockScale, in: 0.5...2.0)
                                }
                                
                                VStack {
                                    HStack { 
                                        Text(mgr.localized("corner_radius"))
                                        Spacer()
                                        Text("\(Int(mgr.boxCornerRadius))") 
                                    }
                                    Slider(value: $mgr.boxCornerRadius, in: 0...30)
                                }
                                
                                HStack {
                                    Text(mgr.localized("background_style"))
                                    Spacer()
                                    Picker("", selection: $mgr.backgroundType) {
                                        Text(mgr.localized("solid")).tag(BackgroundType.solid)
                                        Text(mgr.localized("linear_gradient")).tag(BackgroundType.linearGradient)
                                        Text(mgr.localized("animated_gradient")).tag(BackgroundType.animatedGradient)
                                        Text(mgr.localized("image")).tag(BackgroundType.image)
                                        Text(mgr.localized("web")).tag(BackgroundType.web)
                                        Text(mgr.localized("onlineImage")).tag(BackgroundType.onlineImage)
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 140)
                                }
                                
                                if mgr.backgroundType == .image {
                                    Button(action: selectBackgroundImage) {
                                        HStack {
                                            Image(systemName: "photo")
                                            Text(mgr.localized("select_image"))
                                            Spacer()
                                            if let path = mgr.backgroundImagePath {
                                                Text(URL(fileURLWithPath: path).lastPathComponent)
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                if mgr.backgroundType == .web {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(mgr.localized("web_url"))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        TextField("https://...", text: $mgr.backgroundWebURL)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                    .padding(.leading, 10)
                                }
                                
                                if mgr.backgroundType == .onlineImage {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(mgr.localized("image_url"))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        TextField("https://...", text: $mgr.onlineImageURL)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                    .padding(.leading, 10)
                                }
                                
                                Toggle(mgr.localized("liquid_glass"), isOn: $mgr.liquidGlassEnabled)
                                if mgr.liquidGlassEnabled {
                                    VStack {
                                        Slider(value: $mgr.glassOpacity, in: 0.1...0.8)
                                        Slider(value: $mgr.glassBlur, in: 5...50)
                                    }
                                    .padding(.leading)
                                }
                                
                                Toggle(mgr.localized("shadow_effect"), isOn: $mgr.shadowEnabled)
                                if mgr.shadowEnabled { 
                                    Slider(value: $mgr.shadowIntensity, in: 0.1...0.8)
                                        .padding(.leading) 
                                }
                            }
                        }
                    } else if selectedTab == 2 {
                        // Time & Date Tab
                        VStack(alignment: .leading, spacing: 25) {
                            VStack(alignment: .leading, spacing: 15) {
                                Text(mgr.localized("display_options"))
                                    .font(.headline)
                                Toggle(mgr.localized("use_24h_format"), isOn: $mgr.use24HourFormat)
                                
                                if !mgr.use24HourFormat {
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack { 
                                            Text(mgr.localized("ampm_size"))
                                            Spacer()
                                            Text(String(format: "%.1fx", mgr.amPmBoxScale)) 
                                        }
                                        Slider(value: $mgr.amPmBoxScale, in: 0.3...1.0)
                                    }
                                    .padding(.leading, 20)
                                }
                                
                                Toggle(mgr.localized("show_seconds"), isOn: $mgr.showSeconds)
                                if mgr.showSeconds {
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack { 
                                            Text(mgr.localized("seconds_size"))
                                            Spacer()
                                            Text(String(format: "%.1fx", mgr.secondsScale)) 
                                        }
                                        Slider(value: $mgr.secondsScale, in: 0.3...1.2)
                                    }
                                    .padding(.leading, 20)
                                }
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Toggle(mgr.localized("show_date"), isOn: $mgr.dateDisplay)
                                
                                if mgr.dateDisplay {
                                    VStack(alignment: .leading, spacing: 15) {
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack { 
                                                Text(mgr.localized("date_size"))
                                                Spacer()
                                                Text(String(format: "%.1fx", mgr.dateScale)) 
                                            }
                                            Slider(value: $mgr.dateScale, in: 0.3...3.0)
                                        }
                                        .padding(.horizontal, 5)
                                        
                                        Text(mgr.localized("date_format"))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding(.bottom, 5)
                                        
                                        VStack(alignment: .leading, spacing: 12) {
                                            ForEach(DateFormatOption.allCases) { opt in
                                                Button(action: { mgr.dateDisplayFormat = opt }) {
                                                    HStack(spacing: 12) {
                                                        Image(systemName: mgr.dateDisplayFormat == opt ? "largecircle.fill.circle" : "circle")
                                                            .foregroundColor(mgr.dateDisplayFormat == opt ? .blue : .secondary)
                                                            .font(.system(size: 14))
                                                        Text(getDatePreview(for: opt))
                                                            .font(.body)
                                                    }
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.leading, 15)
                                    }
                                    .padding(.top, 10)
                                    .padding(.leading, 5)
                                }
                            }
                            Spacer()
                        }
                    } else if selectedTab == 3 {
                        // ScreenSaver Tab
                        VStack(alignment: .leading, spacing: 20) {
                            Toggle(mgr.localized("enable_screensaver"), isOn: $mgr.screenSaverEnabled)
                                .font(.headline)
                            if mgr.screenSaverEnabled {
                                VStack(alignment: .leading, spacing: 15) {
                                    HStack { 
                                        Text("Idle Timeout")
                                        Spacer()
                                        Stepper("\(mgr.idleTimeMinutes) \(mgr.localized("minutes"))", value: $mgr.idleTimeMinutes, in: 1...60) 
                                    }
                                    
                                    HStack { 
                                        Text(mgr.localized("shortcut"))
                                        Spacer()
                                        ShortcutRecorder(shortcut: $mgr.screensaverShortcut) 
                                    }
                                    
                                    Toggle(mgr.localized("exit_on_activity"), isOn: $mgr.exitOnActivity)
                                }
                                .padding(.leading)
                            }
                        }
                    } else {
                        // Info Tab
                        VStack(spacing: 25) {
                            VStack(spacing: 10) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue)
                                Text("macOS Flip Clock")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Version 1.0.0")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 20)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Developer Info")
                                    .font(.headline)
                                
                                Button(action: { NSWorkspace.shared.open(URL(string: "https://github.com/orion-gz")!) }) {
                                    HStack { 
                                        Image(systemName: "person.fill")
                                        Text("GitHub: orion-gz")
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square") 
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: { NSWorkspace.shared.open(URL(string: "https://github.com/orion-gz/FlipClock")!) }) {
                                    HStack { 
                                        Image(systemName: "link")
                                        Text("Project Repository")
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square") 
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Spacer()
                            
                            Text("© 2026 orion-gz. All rights reserved.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 10)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
        }
        .frame(width: 450)
        .frame(maxHeight: .infinity)
        .background(BlockWindowDrag())
        .background(Color(NSColor.windowBackgroundColor))
        .shadow(radius: 20)
        .sheet(isPresented: $showCP) {
            ColorPickerView(selectedColor: $newC, onSave: { n in
                mgr.addPreset(name: n, color: newC)
                switch cpT {
                case .background: mgr.backgroundColor = newC
                case .box: mgr.boxColor = newC
                case .text: mgr.textColor = newC
                }
            })
        }
    }
    
    @ViewBuilder
    func tabButton(idx: Int, title: String, icon: String) -> some View {
        Button(action: { withAnimation(.spring()) { selectedTab = idx } }) {
            VStack(spacing: 4) { 
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 10, weight: .medium)) 
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                ZStack { 
                    if selectedTab == idx { 
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.15))
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1) 
                    } 
                }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(selectedTab == idx ? .blue : .secondary)
    }
    
    func getDatePreview(for opt: DateFormatOption) -> String {
        let f = DateFormatter()
        f.dateFormat = opt.format(for: mgr.language)
        f.locale = Locale(identifier: mgr.language.rawValue)
        return f.string(from: Date())
    }
    
    func selectBackgroundImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.png, .jpeg, .webP, UTType("public.heic")!]
        if panel.runModal() == .OK { 
            mgr.backgroundImagePath = panel.url?.path
            mgr.backgroundType = .image 
        }
    }
}

struct ContentView: View {
    @ObservedObject private var mgr = FlipClockManager.shared
    @State private var time = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var anim = false
    
    var body: some View {
        ZStack {
            bgView.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                if mgr.dateDisplay { 
                    Text(dateStr)
                        .font(.system(size: 20 * mgr.clockScale * mgr.dateScale, weight: .medium, design: .rounded))
                        .foregroundColor(mgr.textColor.opacity(0.8))
                        .padding(.bottom, 10) 
                }
                
                HStack(spacing: mgr.showSeconds ? 20 * mgr.clockScale : 8 * mgr.clockScale) {
                    if !mgr.use24HourFormat { 
                        FlipTextView(text: amPm, 
                                     color: mgr.textColor, 
                                     boxColor: mgr.boxColor, 
                                     cornerRadius: mgr.boxCornerRadius, 
                                     scale: mgr.clockScale * mgr.amPmBoxScale, 
                                     liquidGlass: mgr.liquidGlassEnabled, 
                                     glassOpacity: mgr.glassOpacity, 
                                     glassBlur: mgr.glassBlur, 
                                     clockFont: mgr.clockFont) 
                    }
                    
                    FlipDigitView(value: dispH / 10, 
                                  color: mgr.textColor, 
                                  boxColor: mgr.boxColor, 
                                  cornerRadius: mgr.boxCornerRadius, 
                                  scale: mgr.clockScale, 
                                  liquidGlass: mgr.liquidGlassEnabled, 
                                  glassOpacity: mgr.glassOpacity, 
                                  glassBlur: mgr.glassBlur, 
                                  clockFont: mgr.clockFont)
                    
                    FlipDigitView(value: dispH % 10, 
                                  color: mgr.textColor, 
                                  boxColor: mgr.boxColor, 
                                  cornerRadius: mgr.boxCornerRadius, 
                                  scale: mgr.clockScale, 
                                  liquidGlass: mgr.liquidGlassEnabled, 
                                  glassOpacity: mgr.glassOpacity, 
                                  glassBlur: mgr.glassBlur, 
                                  clockFont: mgr.clockFont)
                    
                    Text(":")
                        .font(.system(size: 120 * mgr.clockScale, weight: .bold, design: .rounded))
                        .foregroundColor(mgr.textColor)
                        .padding(.bottom, 30)
                    
                    FlipDigitView(value: mins / 10, 
                                  color: mgr.textColor, 
                                  boxColor: mgr.boxColor, 
                                  cornerRadius: mgr.boxCornerRadius, 
                                  scale: mgr.clockScale, 
                                  liquidGlass: mgr.liquidGlassEnabled, 
                                  glassOpacity: mgr.glassOpacity, 
                                  glassBlur: mgr.glassBlur, 
                                  clockFont: mgr.clockFont)
                    
                    FlipDigitView(value: mins % 10, 
                                  color: mgr.textColor, 
                                  boxColor: mgr.boxColor, 
                                  cornerRadius: mgr.boxCornerRadius, 
                                  scale: mgr.clockScale, 
                                  liquidGlass: mgr.liquidGlassEnabled, 
                                  glassOpacity: mgr.glassOpacity, 
                                  glassBlur: mgr.glassBlur, 
                                  clockFont: mgr.clockFont)
                    
                    if mgr.showSeconds {
                        FlipDigitView(value: secs / 10, 
                                      color: mgr.textColor, 
                                      boxColor: mgr.boxColor, 
                                      cornerRadius: mgr.boxCornerRadius, 
                                      scale: mgr.clockScale * mgr.secondsScale, 
                                      liquidGlass: mgr.liquidGlassEnabled, 
                                      glassOpacity: mgr.glassOpacity, 
                                      glassBlur: mgr.glassBlur, 
                                      clockFont: mgr.clockFont)
                            .padding(.leading, 10 * mgr.clockScale)
                        
                        FlipDigitView(value: secs % 10, 
                                      color: mgr.textColor, 
                                      boxColor: mgr.boxColor, 
                                      cornerRadius: mgr.boxCornerRadius, 
                                      scale: mgr.clockScale * mgr.secondsScale, 
                                      liquidGlass: mgr.liquidGlassEnabled, 
                                      glassOpacity: mgr.glassOpacity, 
                                      glassBlur: mgr.glassBlur, 
                                      clockFont: mgr.clockFont)
                    }
                }
                .background(WindowAccessor { _ in })
                .background(GeometryReader { geo in Color.clear.preference(key: SizePreferenceKey.self, value: geo.size) })
                
                Spacer()
                
                HStack { 
                    Spacer()
                    Button(action: { withAnimation { mgr.showSettingsPanel.toggle() } }) { 
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(mgr.textColor.opacity(0.7))
                            .padding() 
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding() 
                }
            }
            
            if mgr.showSettingsPanel { 
                HStack { 
                    Spacer()
                    SettingsView(isPresented: $mgr.showSettingsPanel) 
                }
                .frame(maxHeight: .infinity)
                .zIndex(2)
                .transition(.move(edge: .trailing)) 
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(timer) { _ in 
            let old = Calendar.current.component(.minute, from: time)
            time = Date()
            let new = Calendar.current.component(.minute, from: time)
            if mgr.militaryTimeSound && old != new && new == 0 { NSSound.beep() } 
        }
    }
    
    @ViewBuilder
    var bgView: some View {
        switch mgr.backgroundType {
        case .solid: 
            mgr.backgroundColor
        case .linearGradient: 
            LinearGradient(colors: [mgr.backgroundColor, mgr.backgroundColor.opacity(0.6)], 
                           startPoint: .topLeading, 
                           endPoint: .bottomTrailing)
        case .animatedGradient: 
            LinearGradient(colors: [mgr.backgroundColor, mgr.boxColor], 
                           startPoint: anim ? .topLeading : .bottomLeading, 
                           endPoint: anim ? .bottomTrailing : .topTrailing)
            .onAppear { 
                withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) { anim.toggle() } 
            }
        case .image:
            if let path = mgr.backgroundImagePath, let img = NSImage(contentsOfFile: path) { 
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped() 
            } else { 
                mgr.backgroundColor 
            }
        case .web: 
            WebView(urlString: mgr.backgroundWebURL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        case .onlineImage: 
            AsyncImage(url: URL(string: mgr.onlineImageURL)) { phase in 
                switch phase { 
                case .success(let image): 
                    image.resizable()
                        .aspectRatio(contentMode: .fill) 
                default: 
                    mgr.backgroundColor 
                } 
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
    }
    
    var dispH: Int { 
        let h = Calendar.current.component(.hour, from: time)
        if mgr.use24HourFormat { return h } 
        else { 
            let h12 = h % 12
            return h12 == 0 ? 12 : h12 
        } 
    }
    
    var amPm: String { Calendar.current.component(.hour, from: time) < 12 ? "AM" : "PM" }
    var mins: Int { Calendar.current.component(.minute, from: time) }
    var secs: Int { Calendar.current.component(.second, from: time) }
    var dateStr: String { 
        let f = DateFormatter()
        f.dateFormat = mgr.dateDisplayFormat.format(for: mgr.language)
        f.locale = Locale(identifier: mgr.language.rawValue)
        return f.string(from: time) 
    }
}

struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> Void
    func makeNSView(context: Context) -> NSView { 
        let view = NSView()
        DispatchQueue.main.async { callback(view.window) }
        return view 
    }
    func updateNSView(_ nsView: NSView, context: Context) { 
        DispatchQueue.main.async { callback(nsView.window) } 
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []
    var statusItem: NSStatusItem?
    var cancellables = Set<AnyCancellable>()
    var lastActivityTime = Date()
    var idleTimer: Timer?
    var hotKeyRef: EventHotKeyRef?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        startIdleMonitoring()
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .keyDown, .leftMouseDown]) { _ in self.handleActivity() }
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .keyDown, .leftMouseDown]) { event in self.handleActivity(); return event }
        setupHotKeyHandler()
        DispatchQueue.main.async { 
            self.setupWindows()
            self.setupMenuBar()
            self.observeSettings()
            self.registerGlobalShortcut() 
        }
    }
    
    func registerGlobalShortcut() {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref); hotKeyRef = nil }
        let sc = FlipClockManager.shared.screensaverShortcut
        var carbonMods: UInt32 = 0
        let mods = sc.modifierFlags
        if mods.contains(.command) { carbonMods |= UInt32(cmdKey) }
        if mods.contains(.option) { carbonMods |= UInt32(optionKey) }
        if mods.contains(.control) { carbonMods |= UInt32(controlKey) }
        if mods.contains(.shift) { carbonMods |= UInt32(shiftKey) }
        let hotKeyID = EventHotKeyID(signature: OSType(0x464c4950), id: 1)
        RegisterEventHotKey(UInt32(sc.keyCode), carbonMods, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }
    
    func setupHotKeyHandler() {
        var eventHandler: EventHandlerRef?
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { (handler, event, userData) -> OSStatus in 
            let ad = unsafeBitCast(userData, to: AppDelegate.self)
            ad.activateScreenSaver()
            return noErr 
        }, 1, &spec, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), &eventHandler)
    }
    
    func setupWindows() {
        let oldWindows = windows
        windows.removeAll()
        let mgr = FlipClockManager.shared
        if mgr.multiMonitorMode == .all { 
            for s in NSScreen.screens { createWindow(for: s) } 
        } else if let p = NSScreen.main { 
            createWindow(for: p) 
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
            for w in oldWindows { w.close() } 
        }
    }
    
    func createWindow(for screen: NSScreen) {
        let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700), 
                         styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], 
                         backing: .buffered, defer: false, screen: screen)
        w.center()
        w.title = "Flip Clock"
        w.isMovableByWindowBackground = true
        w.backgroundColor = .clear
        w.hasShadow = false
        w.isReleasedWhenClosed = false
        w.titlebarAppearsTransparent = true
        w.titleVisibility = .hidden
        w.standardWindowButton(.closeButton)?.isHidden = false
        w.standardWindowButton(.miniaturizeButton)?.isHidden = false
        w.standardWindowButton(.zoomButton)?.isHidden = false
        w.contentView = NSHostingView(rootView: ContentView())
        w.makeKeyAndOrderFront(nil)
        w.level = FlipClockManager.shared.alwaysOnTop ? .floating : .normal
        windows.append(w)
    }
    
    func setupMenuBar() { 
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Flip Clock")
        updateMenu() 
    }
    
    func updateMenu() {
        let mgr = FlipClockManager.shared
        let menu = NSMenu()
        menu.addItem(withTitle: mgr.localized("open_clock"), action: #selector(showApp), keyEquivalent: "o")
        menu.addItem(withTitle: mgr.localized("trigger_screensaver"), action: #selector(triggerScreenSaver), keyEquivalent: "s")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: mgr.localized("quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem?.menu = menu
    }
    
    private func handleActivity() { 
        lastActivityTime = Date()
        if FlipClockManager.shared.exitOnActivity { 
            for w in windows { 
                if w.styleMask.contains(.fullScreen) { w.toggleFullScreen(nil) } 
            } 
        } 
    }
    
    func observeSettings() {
        FlipClockManager.shared.$showMenuBarIcon.receive(on: RunLoop.main).sink { [weak self] show in 
            self?.statusItem?.isVisible = show 
        }.store(in: &cancellables)
        FlipClockManager.shared.$language.receive(on: RunLoop.main).sink { [weak self] _ in 
            self?.updateMenu() 
        }.store(in: &cancellables)
        FlipClockManager.shared.$multiMonitorMode.receive(on: RunLoop.main).sink { [weak self] _ in 
            self?.setupWindows() 
        }.store(in: &cancellables)
        FlipClockManager.shared.$alwaysOnTop.receive(on: RunLoop.main).sink { [weak self] val in 
            self?.windows.forEach { $0.level = val ? .floating : .normal } 
        }.store(in: &cancellables)
        FlipClockManager.shared.$screensaverShortcut.receive(on: RunLoop.main).sink { [weak self] _ in 
            self?.registerGlobalShortcut() 
        }.store(in: &cancellables)
    }
    
    @objc func showApp() { 
        NSApp.activate(ignoringOtherApps: true)
        for w in windows { 
            w.makeKeyAndOrderFront(nil)
            w.setIsVisible(true) 
        } 
    }
    
    @objc func triggerScreenSaver() { activateScreenSaver() }
    
    func activateScreenSaver() { 
        DispatchQueue.main.async { 
            FlipClockManager.shared.showSettingsPanel = false
            NSApp.activate(ignoringOtherApps: true)
            for w in self.windows { 
                if !w.styleMask.contains(.fullScreen) { w.toggleFullScreen(nil) } 
            } 
        } 
    }
    
    func startIdleMonitoring() { 
        idleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in 
            guard let self = self else { return }
            let mgr = FlipClockManager.shared
            if mgr.screenSaverEnabled && Date().timeIntervalSince(self.lastActivityTime) >= TimeInterval(mgr.idleTimeMinutes * 60) { 
                self.activateScreenSaver() 
            } 
        } 
    }
}

@main
struct FlipClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var ad
    var body: some Scene {
        Settings { EmptyView() }
    }
}
