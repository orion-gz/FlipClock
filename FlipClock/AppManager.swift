import SwiftUI
import Cocoa
import Combine
import ServiceManagement

class FlipClockManager: ObservableObject {
    static let shared = FlipClockManager()
    @Published var showSettingsPanel: Bool = false
    private var isLoading = true
    private var isApplyingTheme = false
    private var isSaving = false
    
    @Published var language: AppLanguage = .english {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var activeCustomThemeId: UUID? {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var clockFont: ClockFont = .rounded {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var customFontName: String = "Helvetica" {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var backgroundType: BackgroundType = .solid {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var multiMonitorMode: MultiMonitorMode = .primary {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var launchAtLogin: Bool = false {
        didSet { if !isLoading { updateLaunchAtLogin(); saveSettings() } }
    }
    @Published var screensaverShortcut = KeyboardShortcutData(keyChar: "s", keyCode: 1, modifiers: Int(NSEvent.ModifierFlags([.command, .control]).rawValue)) {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var backgroundColor: Color = .black {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var boxColor: Color = Color(white: 0.2) {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var textColor: Color = .white {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var selectedTheme: FlipClockTheme = .dark {
        didSet { if !isLoading && !isApplyingTheme { if selectedTheme != .custom { applyTheme(selectedTheme) }; saveSettings() } }
    }
    @Published var showSeconds: Bool = false {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var screenSaverEnabled: Bool = false {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var idleTimeMinutes: Int = 5 {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var exitOnActivity: Bool = false {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var customPresets: [NamedColor] = [] {
        didSet { if !isLoading { saveCustomPresets() } }
    }
    @Published var savedThemes: [CustomTheme] = [] {
        didSet { if !isLoading { saveCustomThemes() } }
    }
    @Published var clockScale: Double = 1.0 {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var boxCornerRadius: Double = 10.0 {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var use24HourFormat: Bool = true {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var amPmBoxScale: Double = 0.6 {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var liquidGlassEnabled: Bool = false {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var glassOpacity: Double = 0.3 {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var glassBlur: Double = 20.0 {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var shadowEnabled: Bool = true {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var shadowIntensity: Double = 0.3 {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var alwaysOnTop: Bool = false {
        didSet { if !isLoading { saveSettings(); updateWindowLevel() } }
    }
    @Published var showMenuBarIcon: Bool = true {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var hideDockIcon: Bool = false {
        didSet { if !isLoading { saveSettings(); updateActivationPolicy() } }
    }
    @Published var dateDisplay: Bool = false {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var dateDisplayFormat: DateFormatOption = .full {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var dateScale: Double = 1.0 {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var dateFont: ClockFont = .rounded {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var dateCustomFontName: String = "Helvetica" {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var secondsScale: Double = 1.0 {
        didSet { if !isLoading { checkAuto(); saveSettings() } }
    }
    @Published var flipSoundEnabled: Bool = true {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var militaryTimeSound: Bool = false {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var followSystemAppearance: Bool = false {
        didSet { if !isLoading { saveSettings(); if followSystemAppearance { updateThemeForSystem() } } }
    }
    @Published var backgroundImagePath: String? {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var backgroundWebURL: String = "https://www.google.com" {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var onlineImageURL: String = "" {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var isUpdateAvailable: Bool = false
    @Published var latestVersion: String = ""
    @Published var updateURL: String = ""
    @Published var releaseNotes: String = ""
    @Published var isCheckingUpdates: Bool = false
    @Published var showUpdateAlert: Bool = false
    @Published var updateAlertTitle: String = ""
    @Published var updateAlertMessage: String = ""
    
    @Published var updateCheckFrequency: UpdateCheckFrequency = .weekly {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var lastUpdateCheckDate: Date? {
        didSet { if !isLoading { saveSettings() } }
    }
    @Published var enableUpdateNotification: Bool = true {
        didSet { if !isLoading { saveSettings() } }
    }
    
    let presetColors: [Color] = [
        .black, .white, .gray, 
        Color(red: 0.2, green: 0.2, blue: 0.2), 
        Color(red: 0.1, green: 0.3, blue: 0.5), 
        Color(red: 0.5, green: 0.1, blue: 0.2), 
        Color(red: 0.2, green: 0.4, blue: 0.3), 
        Color(red: 0.4, green: 0.3, blue: 0.5)
    ]
    
    private let localizations: [AppLanguage: [String: String]] = [
        .english: [
            "settings": "Settings", "language": "Language", "themes": "Themes", "standard": "Standard", "my_presets": "My Presets",
            "delete": "Delete", "save": "Save", "customize": "Customize", "background_color": "Background Color", "box_color": "Box Color",
            "text_color": "Text Color", "size_appearance": "Size & Appearance", "font": "Font", "clock_size": "Clock Size", "corner_radius": "Corner Radius",
            "background_style": "Background Style", "solid": "Solid", "linear_gradient": "Linear Gradient", "animated_gradient": "Animated Gradient", "image": "Image", "web": "Website", "onlineImage": "Online Image",
            "liquid_glass": "Liquid Glass", "shadow_effect": "Shadow Effect", "display_options": "Display Options", "show_seconds": "Show Seconds", "use_24h_format": "24-Hour Format",
            "show_date": "Show Date", "always_on_top": "Always on Top", "show_menubar": "Show Menu Bar Icon", "hide_dock_icon": "Hide App Icon in Dock", "multi_monitor": "Multi-Monitor",
            "primary_only": "Primary Only", "all_screens": "All Screens", "launch_at_login": "Launch at Login", "hourly_chime": "Hourly Chime",
            "flip_sound": "Flip Sound", "enable_screensaver": "Enable ScreenSaver", "minutes": "minutes", "shortcut": "Shortcut",
            "exit_on_activity": "Exit on Activity", "open_clock": "Open Clock", "trigger_screensaver": "Trigger ScreenSaver", "quit": "Quit",
            "save_current_as_theme": "Save current as theme", "theme_name": "Theme Name", "cancel": "Cancel", "date_format": "Date Format", "ampm_size": "AM/PM Size",
            "date_size": "Date Size", "seconds_size": "Seconds Size",
            "tab_general": "General", "tab_appearance": "Appearance", "tab_time": "Time & Date", "tab_saver": "ScreenSaver", "tab_info": "Info",
            "follow_system": "Follow System Appearance", "select_image": "Select Background Image", "web_url": "Website URL", "image_url": "Image URL",
            "check_updates": "Check for Updates", "update_available": "New version available", "is_latest": "Already on latest version",
            "update_freq": "Update Check Frequency",
            "enable_update_notif": "Show Update Notification Bar", "release_notes": "Release Notes"
        ],
        .korean: [
            "settings": "설정", "language": "언어", "themes": "테마", "standard": "기본 테마", "my_presets": "나의 프리셋",
            "delete": "삭제", "save": "저장", "customize": "사용자 설정", "background_color": "배경 색상", "box_color": "박스 색상",
            "text_color": "텍스트 색상", "size_appearance": "크기 및 외형", "font": "글꼴", "clock_size": "시계 크기", "corner_radius": "모서리 곡률",
            "background_style": "배경 스타일", "solid": "단색", "linear_gradient": "선형 그라데이션", "animated_gradient": "애니메이션 그라데이션", "image": "이미지", "web": "웹사이트", "onlineImage": "온라인 이미지",
            "liquid_glass": "리퀴드 글래스", "shadow_effect": "그림자 효과", "display_options": "디스플레이 옵션", "show_seconds": "초 표시", "use_24h_format": "24시간 형식",
            "show_date": "날짜 표시", "always_on_top": "항상 위에", "show_menubar": "메뉴바 아이콘 표시", "hide_dock_icon": "Dock에서 아이콘 숨기기", "multi_monitor": "멀티 모니터",
            "primary_only": "주 모니터만", "all_screens": "모든 화면", "launch_at_login": "로그인 시 실행", "hourly_chime": "정각 알림",
            "flip_sound": "플립 사운드", "enable_screensaver": "스크린세이버 활성화", "minutes": "분", "shortcut": "단축키",
            "exit_on_activity": "활동 시 종료", "open_clock": "시계 열기", "trigger_screensaver": "스크린세이버 실행", "quit": "종료",
            "save_current_as_theme": "현재 설정을 테마로 저장", "theme_name": "테마 이름", "cancel": "취소", "date_format": "날짜 형식", "ampm_size": "AM/PM 크기",
            "date_size": "날짜 크기", "seconds_size": "초 크기",
            "tab_general": "일반", "tab_appearance": "외형", "tab_time": "시간 및 날짜", "tab_saver": "화면보호기", "tab_info": "정보",
            "follow_system": "시스템 설정에 따라 테마 변경", "select_image": "배경 이미지 선택", "web_url": "웹사이트 URL", "image_url": "이미지 URL",
            "check_updates": "업데이트 확인", "update_available": "새로운 버전이 있습니다", "is_latest": "최신 버전을 사용 중입니다",
            "update_freq": "업데이트 확인 주기",
            "enable_update_notif": "업데이트 알림 바 표시", "release_notes": "업데이트 내용"
        ]
    ]
    
    func localized(_ key: String) -> String { localizations[language]?[key] ?? key }
    
    private init() {
        loadCustomPresets(); loadCustomThemes(); loadSettings(); self.isLoading = false; updateActivationPolicy()
        checkIfUpdateNeeded()
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil, queue: .main) { [weak self] _ in
            if self?.followSystemAppearance == true { self?.updateThemeForSystem() }
        }
    }
    
    func updateThemeForSystem() {
        let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        applyTheme(isDark ? .dark : .light)
    }
    
    private func checkAuto() { 
        if !isApplyingTheme && selectedTheme != .custom { 
            isApplyingTheme = true
            selectedTheme = .custom
            activeCustomThemeId = nil
            isApplyingTheme = false 
        } 
    }
    
    func applyTheme(_ t: FlipClockTheme) { 
        isApplyingTheme = true
        loadStandardSettingsFromDefaults(UserDefaults.standard)
        let c = t.colors
        backgroundColor = c.background
        boxColor = c.box
        textColor = c.text
        selectedTheme = t
        activeCustomThemeId = nil
        isApplyingTheme = false
        if !isLoading { saveSettings() } 
    }
    
    func applyCustomTheme(_ t: CustomTheme) { 
        isApplyingTheme = true
        backgroundColor = t.backgroundColor.color
        boxColor = t.boxColor.color
        textColor = t.textColor.color
        clockScale = t.clockScale
        boxCornerRadius = t.boxCornerRadius
        clockFont = t.clockFont
        customFontName = t.customFontName
        backgroundType = t.backgroundType
        showSeconds = t.showSeconds
        dateDisplay = t.dateDisplay
        dateDisplayFormat = t.dateDisplayFormat
        dateFont = t.dateFont
        dateCustomFontName = t.dateCustomFontName
        dateScale = t.dateScale
        secondsScale = t.secondsScale
        alwaysOnTop = t.alwaysOnTop
        showMenuBarIcon = t.showMenuBarIcon
        militaryTimeSound = t.militaryTimeSound
        use24HourFormat = t.use24HourFormat
        amPmBoxScale = t.amPmBoxScale
        liquidGlassEnabled = t.liquidGlassEnabled
        glassOpacity = t.glassOpacity
        glassBlur = t.glassBlur
        shadowEnabled = t.shadowEnabled
        shadowIntensity = t.shadowIntensity
        screenSaverEnabled = t.screenSaverEnabled
        idleTimeMinutes = t.idleTimeMinutes
        exitOnActivity = t.exitOnActivity
        flipSoundEnabled = t.flipSoundEnabled
        launchAtLogin = t.launchAtLogin
        selectedTheme = .custom
        activeCustomThemeId = t.id
        isApplyingTheme = false
        if !isLoading { saveSettings() } 
    }
    
    func saveCurrentAsTheme(name: String) { 
        let nt = createCustomTheme(name: name)
        savedThemes.append(nt)
        selectedTheme = .custom
        activeCustomThemeId = nt.id
        saveSettings() 
    }
    
    private func createCustomTheme(name: String) -> CustomTheme { 
        CustomTheme(id: UUID(), name: name, backgroundColor: NamedColor(name: "BG", color: backgroundColor), boxColor: NamedColor(name: "Box", color: boxColor), textColor: NamedColor(name: "Text", color: textColor), clockScale: clockScale, boxCornerRadius: boxCornerRadius, clockFont: clockFont, customFontName: customFontName, backgroundType: backgroundType, showSeconds: showSeconds, dateDisplay: dateDisplay, dateDisplayFormat: dateDisplayFormat, dateFont: dateFont, dateCustomFontName: dateCustomFontName, dateScale: dateScale, secondsScale: secondsScale, alwaysOnTop: alwaysOnTop, showMenuBarIcon: showMenuBarIcon, militaryTimeSound: militaryTimeSound, use24HourFormat: use24HourFormat, amPmBoxScale: amPmBoxScale, glassOpacity: glassOpacity, glassBlur: glassBlur, shadowIntensity: shadowIntensity, liquidGlassEnabled: liquidGlassEnabled, shadowEnabled: shadowEnabled, screenSaverEnabled: screenSaverEnabled, exitOnActivity: exitOnActivity, flipSoundEnabled: flipSoundEnabled, launchAtLogin: launchAtLogin, idleTimeMinutes: idleTimeMinutes) 
    }
    
    func removeTheme(_ t: CustomTheme) { 
        savedThemes.removeAll { $0.id == t.id }
        if activeCustomThemeId == t.id { activeCustomThemeId = nil } 
    }
    
    func addPreset(name: String, color: Color) { 
        customPresets.append(NamedColor(name: name, color: color)) 
    }
    
    func removePreset(_ p: NamedColor) { 
        customPresets.removeAll { $0.id == p.id } 
    }
    
    func updateWindowLevel() { 
        DispatchQueue.main.async { 
            NSApplication.shared.windows.forEach { $0.level = self.alwaysOnTop ? .floating : .normal } 
        } 
    }
    
    func updateLaunchAtLogin() { 
        do { 
            if launchAtLogin { try SMAppService.mainApp.register() } 
            else { try SMAppService.mainApp.unregister() } 
        } catch { } 
    }
    
    func updateActivationPolicy() {
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(self.hideDockIcon ? .accessory : .regular)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.activate(ignoringOtherApps: true)
                for window in NSApp.windows {
                    if window.styleMask.contains(.titled) && window.isVisible {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
            }
        }
    }
    
    func checkIfUpdateNeeded() {
        guard updateCheckFrequency != .manual else { return }
        if let lastCheck = lastUpdateCheckDate {
            let daysSinceLastCheck = Calendar.current.dateComponents([.day], from: lastCheck, to: Date()).day ?? 0
            if daysSinceLastCheck >= updateCheckFrequency.days {
                checkForUpdates(isManual: false)
            }
        } else {
            checkForUpdates(isManual: false)
        }
    }
    
    func checkForUpdates(isManual: Bool = true) {
        guard !isCheckingUpdates else { return }
        isCheckingUpdates = true
        guard let url = URL(string: "https://api.github.com/repos/orion-gz/FlipClock/releases/latest") else {
            isCheckingUpdates = false
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isCheckingUpdates = false
                self?.lastUpdateCheckDate = Date()
                if let error = error {
                    if isManual {
                        self?.updateAlertTitle = "Error"
                        self?.updateAlertMessage = error.localizedDescription
                        self?.showUpdateAlert = true
                    }
                    return
                }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tagName = json["tag_name"] as? String,
                      let htmlURL = json["html_url"] as? String,
                      let body = json["body"] as? String else {
                    if isManual {
                        self?.updateAlertTitle = "Error"
                        self?.updateAlertMessage = "Could not parse update info."
                        self?.showUpdateAlert = true
                    }
                    return
                }
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.2"
                self?.latestVersion = tagName
                self?.updateURL = htmlURL
                self?.releaseNotes = body
                let cleanTag = tagName.lowercased().replacingOccurrences(of: "v", with: "")
                let cleanCurrent = currentVersion.lowercased().replacingOccurrences(of: "v", with: "")
                if cleanTag.compare(cleanCurrent, options: .numeric) == .orderedDescending {
                    self?.isUpdateAvailable = true
                    if isManual {
                        self?.updateAlertTitle = self?.localized("update_available") ?? "Update Available"
                        self?.updateAlertMessage = "New version \(tagName) is available."
                        self?.showUpdateAlert = true
                    }
                } else {
                    self?.isUpdateAvailable = false
                    if isManual {
                        self?.updateAlertTitle = self?.localized("settings") ?? "Settings"
                        self?.updateAlertMessage = self?.localized("is_latest") ?? "Already on latest version"
                        self?.showUpdateAlert = true
                    }
                }
            }
        }.resume()
    }
    
    private func saveSettings() {
        if isApplyingTheme || isLoading || isSaving { return }
        isSaving = true
        defer { isSaving = false }
        let d = UserDefaults.standard
        d.set(selectedTheme.rawValue, forKey: "selectedTheme")
        d.set(language.rawValue, forKey: "appLanguage")
        d.set(clockFont.rawValue, forKey: "clockFont")
        d.set(backgroundType.rawValue, forKey: "backgroundType")
        d.set(multiMonitorMode.rawValue, forKey: "multiMonitorMode")
        d.set(hideDockIcon, forKey: "hideDockIcon")
        d.set(followSystemAppearance, forKey: "followSystemAppearance")
        d.set(updateCheckFrequency.rawValue, forKey: "updateCheckFrequency")
        d.set(enableUpdateNotification, forKey: "enableUpdateNotification")
        if let lastCheck = lastUpdateCheckDate { d.set(lastCheck, forKey: "lastUpdateCheckDate") }
        if let bgi = backgroundImagePath { d.set(bgi, forKey: "backgroundImagePath") }
        d.set(backgroundWebURL, forKey: "backgroundWebURL")
        d.set(onlineImageURL, forKey: "onlineImageURL")
        if let sc = try? JSONEncoder().encode(screensaverShortcut) { d.set(sc, forKey: "screensaverShortcut") }
        if let id = activeCustomThemeId, let idx = savedThemes.firstIndex(where: { $0.id == id }) { 
            var up = createCustomTheme(name: savedThemes[idx].name)
            up.id = id
            if savedThemes[idx] != up { savedThemes[idx] = up } 
        } else { 
            saveStandardSettingsToDefaults(d) 
        }
        d.synchronize()
    }
    
    private func saveStandardSettingsToDefaults(_ d: UserDefaults) {
        let bg = NSColor(backgroundColor).usingColorSpace(.sRGB) ?? .black
        d.set([Double(bg.redComponent), Double(bg.greenComponent), Double(bg.blueComponent)], forKey: "backgroundColor")
        let bx = NSColor(boxColor).usingColorSpace(.sRGB) ?? .black
        d.set([Double(bx.redComponent), Double(bx.greenComponent), Double(bx.blueComponent)], forKey: "boxColor")
        let tx = NSColor(textColor).usingColorSpace(.sRGB) ?? .white
        d.set([Double(tx.redComponent), Double(tx.greenComponent), Double(tx.blueComponent)], forKey: "textColor")
        d.set(customFontName, forKey: "customFontName")
        d.set(showSeconds, forKey: "showSeconds")
        d.set(screenSaverEnabled, forKey: "screenSaverEnabled")
        d.set(idleTimeMinutes, forKey: "idleTimeMinutes")
        d.set(exitOnActivity, forKey: "exitOnActivity")
        d.set(clockScale, forKey: "clockScale")
        d.set(boxCornerRadius, forKey: "boxCornerRadius")
        d.set(use24HourFormat, forKey: "use24HourFormat")
        d.set(amPmBoxScale, forKey: "amPmBoxScale")
        d.set(liquidGlassEnabled, forKey: "liquidGlassEnabled")
        d.set(glassOpacity, forKey: "glassOpacity")
        d.set(glassBlur, forKey: "glassBlur")
        d.set(shadowEnabled, forKey: "shadowEnabled")
        d.set(shadowIntensity, forKey: "shadowIntensity")
        d.set(alwaysOnTop, forKey: "alwaysOnTop")
        d.set(showMenuBarIcon, forKey: "showMenuBarIcon")
        d.set(dateDisplay, forKey: "dateDisplay")
        d.set(dateDisplayFormat.rawValue, forKey: "dateDisplayFormat")
        d.set(dateScale, forKey: "dateScale")
        d.set(dateFont.rawValue, forKey: "dateFont")
        d.set(dateCustomFontName, forKey: "dateCustomFontName")
        d.set(secondsScale, forKey: "secondsScale")
        d.set(flipSoundEnabled, forKey: "flipSoundEnabled")
        d.set(launchAtLogin, forKey: "launchAtLogin")
        d.set(militaryTimeSound, forKey: "militaryTimeSound")
    }
    
    private func loadSettings() {
        let d = UserDefaults.standard
        if let lString = d.string(forKey: "appLanguage"), let l = AppLanguage(rawValue: lString) { language = l }
        if let scData = d.data(forKey: "screensaverShortcut"), let sc = try? JSONDecoder().decode(KeyboardShortcutData.self, from: scData) { screensaverShortcut = sc }
        if let fString = d.string(forKey: "clockFont"), let f = ClockFont(rawValue: fString) { clockFont = f }
        if let bString = d.string(forKey: "backgroundType"), let b = BackgroundType(rawValue: bString) { backgroundType = b }
        if let mString = d.string(forKey: "multiMonitorMode"), let m = MultiMonitorMode(rawValue: mString) { multiMonitorMode = m }
        if let ucfRaw = d.string(forKey: "updateCheckFrequency"), let ucf = UpdateCheckFrequency(rawValue: ucfRaw) { updateCheckFrequency = ucf }
        if d.object(forKey: "enableUpdateNotification") != nil { enableUpdateNotification = d.bool(forKey: "enableUpdateNotification") }
        lastUpdateCheckDate = d.object(forKey: "lastUpdateCheckDate") as? Date
        if d.object(forKey: "flipSoundEnabled") != nil { flipSoundEnabled = d.bool(forKey: "flipSoundEnabled") }
        if d.object(forKey: "launchAtLogin") != nil { launchAtLogin = d.bool(forKey: "launchAtLogin") }
        if d.object(forKey: "hideDockIcon") != nil { hideDockIcon = d.bool(forKey: "hideDockIcon") }
        if d.object(forKey: "dateScale") != nil { dateScale = d.double(forKey: "dateScale") }
        if let dfRaw = d.string(forKey: "dateFont"), let df = ClockFont(rawValue: dfRaw) { dateFont = df }
        if let dcfn = d.string(forKey: "dateCustomFontName") { dateCustomFontName = dcfn }
        if d.object(forKey: "secondsScale") != nil { secondsScale = d.double(forKey: "secondsScale") }
        if d.object(forKey: "followSystemAppearance") != nil { followSystemAppearance = d.bool(forKey: "followSystemAppearance") }
        if let bgi = d.string(forKey: "backgroundImagePath") { backgroundImagePath = bgi }
        if let bwu = d.string(forKey: "backgroundWebURL") { backgroundWebURL = bwu }
        if let oiu = d.string(forKey: "onlineImageURL") { onlineImageURL = oiu }
        let tr = d.string(forKey: "selectedTheme") ?? FlipClockTheme.dark.rawValue
        let theme = FlipClockTheme(rawValue: tr) ?? .dark
        let id = d.string(forKey: "activeCustomThemeId").flatMap(UUID.init)
        if let sid = id, let ct = savedThemes.first(where: { $0.id == sid }) { applyCustomTheme(ct) } 
        else { 
            loadStandardSettingsFromDefaults(d)
            if theme != .custom { applyTheme(theme) } 
            else { selectedTheme = .custom; activeCustomThemeId = nil } 
        }
    }
    
    private func loadStandardSettingsFromDefaults(_ d: UserDefaults) {
        if let rgb = d.array(forKey: "backgroundColor") as? [Double], rgb.count >= 3 { backgroundColor = Color(red: rgb[0], green: rgb[1], blue: rgb[2]) }
        if let rgb = d.array(forKey: "boxColor") as? [Double], rgb.count >= 3 { boxColor = Color(red: rgb[0], green: rgb[1], blue: rgb[2]) }
        if let rgb = d.array(forKey: "textColor") as? [Double], rgb.count >= 3 { textColor = Color(red: rgb[0], green: rgb[1], blue: rgb[2]) }
        if let cfn = d.string(forKey: "customFontName") { customFontName = cfn }
        if d.object(forKey: "showSeconds") != nil { showSeconds = d.bool(forKey: "showSeconds") }
        if d.object(forKey: "screenSaverEnabled") != nil { screenSaverEnabled = d.bool(forKey: "screenSaverEnabled") }
        if d.object(forKey: "idleTimeMinutes") != nil { idleTimeMinutes = d.integer(forKey: "idleTimeMinutes") }
        if d.object(forKey: "exitOnActivity") != nil { exitOnActivity = d.bool(forKey: "exitOnActivity") }
        if d.object(forKey: "clockScale") != nil { clockScale = d.double(forKey: "clockScale") }
        if d.object(forKey: "boxCornerRadius") != nil { boxCornerRadius = d.double(forKey: "boxCornerRadius") }
        if d.object(forKey: "use24HourFormat") != nil { use24HourFormat = d.bool(forKey: "use24HourFormat") }
        if d.object(forKey: "amPmBoxScale") != nil { amPmBoxScale = d.double(forKey: "amPmBoxScale") }
        if d.object(forKey: "liquidGlassEnabled") != nil { liquidGlassEnabled = d.bool(forKey: "liquidGlassEnabled") }
        if d.object(forKey: "glassOpacity") != nil { glassOpacity = d.double(forKey: "glassOpacity") }
        if d.object(forKey: "glassBlur") != nil { glassBlur = d.double(forKey: "glassBlur") }
        if d.object(forKey: "shadowEnabled") != nil { shadowEnabled = d.bool(forKey: "shadowEnabled") }
        if d.object(forKey: "shadowIntensity") != nil { shadowIntensity = d.double(forKey: "shadowIntensity") }
        if d.object(forKey: "alwaysOnTop") != nil { alwaysOnTop = d.bool(forKey: "alwaysOnTop"); updateWindowLevel() }
        if d.object(forKey: "showMenuBarIcon") != nil { showMenuBarIcon = d.bool(forKey: "showMenuBarIcon") }
        if d.object(forKey: "dateDisplay") != nil { dateDisplay = d.bool(forKey: "dateDisplay") }
        if let fmtRaw = d.string(forKey: "dateDisplayFormat"), let fmt = DateFormatOption(rawValue: fmtRaw) { dateDisplayFormat = fmt }
        if d.object(forKey: "militaryTimeSound") != nil { militaryTimeSound = d.bool(forKey: "militaryTimeSound") }
    }
    
    private func saveCustomPresets() { 
        if let e = try? JSONEncoder().encode(customPresets) { 
            UserDefaults.standard.set(e, forKey: "savedCustomPresets") 
        } 
    }
    
    private func loadCustomPresets() { 
        if let d = UserDefaults.standard.data(forKey: "savedCustomPresets"), 
           let de = try? JSONDecoder().decode([NamedColor].self, from: d) { 
            customPresets = de 
        } 
    }
    
    private func saveCustomThemes() { 
        if let e = try? JSONEncoder().encode(savedThemes) { 
            UserDefaults.standard.set(e, forKey: "savedCustomThemes") 
        } 
    }
    
    private func loadCustomThemes() { 
        if let d = UserDefaults.standard.data(forKey: "savedCustomThemes"), 
           let de = try? JSONDecoder().decode([CustomTheme].self, from: d) { 
            savedThemes = de 
        } 
    }
}
