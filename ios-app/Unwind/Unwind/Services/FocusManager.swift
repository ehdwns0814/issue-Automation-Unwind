import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import Combine

class FocusManager: ObservableObject {
    static let shared = FocusManager()
    
    @Published var currentSchedule: Schedule?
    @Published var timeRemaining: Int = 0
    @Published var isFocusing: Bool = false
    @Published var showSuccessScreen: Bool = false
    @Published var isAllInModeActive: Bool = false {
        didSet {
            UserDefaults.standard.set(isAllInModeActive, forKey: "isAllInModeActive")
        }
    }
    
    private var timer: AnyCancellable?
    private let deviceActivityCenter = DeviceActivityCenter()
    private let store = ManagedSettingsStore()
    private let sharedDefaults = UserDefaults(suiteName: "group.com.unwind.data")
    
    private init() {
        self.isAllInModeActive = UserDefaults.standard.bool(forKey: "isAllInModeActive")
        
        // 만약 앱 실행 시 올인 모드가 활성 상태라면 차단 재설정
        if isAllInModeActive {
            activateShield()
            startAllInMonitoring()
        }
    }
    
    func startFocus(on schedule: Schedule) {
        self.showSuccessScreen = false
        self.currentSchedule = schedule
        self.timeRemaining = schedule.durationSeconds
        self.isFocusing = true
        
        // Save current schedule name and initial time for Shield Extension
        sharedDefaults?.set(schedule.name, forKey: "activeScheduleName")
        sharedDefaults?.set(schedule.durationSeconds, forKey: "remainingSeconds")
        
        // 1. Activate Shield
        activateShield()
        
        // 2. Start Timer
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
        
        // 3. Start Device Activity Monitoring (for system level enforcement)
        startMonitoring(schedule: schedule)
    }
    
    func stopFocus() {
        isFocusing = false
        timer?.cancel()
        timer = nil
        
        // 올인 모드가 아닐 때만 차단을 해제합니다.
        if !isAllInModeActive {
            deactivateShield()
            stopMonitoring()
        }
    }
    
    /// 올인 모드를 시작합니다.
    func startAllInMode() {
        isAllInModeActive = true
        activateShield()
        startAllInMonitoring()
    }
    
    /// 올인 모드를 중단하거나 완료했을 때 호출됩니다.
    func stopAllInMode() {
        isAllInModeActive = false
        deactivateShield()
        stopAllInMonitoring()
    }
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            // Sync remaining time to Shield Extension
            sharedDefaults?.set(timeRemaining, forKey: "remainingSeconds")
        } else {
            completeFocus()
        }
    }
    
    private func completeFocus() {
        guard var schedule = currentSchedule else { return }
        
        // 1. 상태 업데이트 (성공 기록)
        schedule.status = .completed
        schedule.isCompleted = true
        schedule.updatedAt = Date()
        schedule.completedAt = Date()
        ScheduleRepository.shared.updateSchedule(schedule)
        
        // 2. 집중 종료 처리
        stopFocus()
        
        // 3. 성공 화면 표시 신호 발생
        showSuccessScreen = true
    }
    
    /// 사용자가 수동으로 집중을 중단했을 때 호출됩니다.
    func abandonFocus() {
        guard var schedule = currentSchedule else { return }
        
        // 1. 상태 업데이트 (실패로 기록)
        schedule.status = .failed
        schedule.isCompleted = false
        schedule.updatedAt = Date()
        schedule.completedAt = Date()
        ScheduleRepository.shared.updateSchedule(schedule)
        
        // 2. 집중 종료 처리 (타이머 중지, Shield 해제, 모니터링 중지)
        stopFocus()
    }
    
    private func activateShield() {
        let selection = ScreentimeManager.shared.selection
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
    }
    
    private func deactivateShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
    
    private func startMonitoring(schedule: Schedule) {
        let name = DeviceActivityName("com.unwind.focusSession")
        // Use a simple schedule for monitoring
        let activitySchedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try deviceActivityCenter.startMonitoring(name, during: activitySchedule)
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }
    
    private func stopMonitoring() {
        deviceActivityCenter.stopMonitoring([DeviceActivityName("com.unwind.focusSession")])
    }
    
    private func startAllInMonitoring() {
        let name = DeviceActivityName("com.unwind.allInMode")
        let activitySchedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try deviceActivityCenter.startMonitoring(name, during: activitySchedule)
        } catch {
            print("Failed to start All-in monitoring: \(error)")
        }
    }
    
    private func stopAllInMonitoring() {
        deviceActivityCenter.stopMonitoring([DeviceActivityName("com.unwind.allInMode")])
    }
}
