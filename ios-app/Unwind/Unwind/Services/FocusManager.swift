import Foundation
import Combine
import FamilyControls
import DeviceActivity
import ManagedSettings

/// 집중 세션의 타이머와 앱 차단(ScreenTime)을 관리하는 서비스 클래스입니다.
class FocusManager: ObservableObject {
    static let shared = FocusManager()
    
    @Published var currentSchedule: Schedule?
    @Published var remainingTime: Int = 0
    @Published var isFocusing: Bool = false
    
    private var timer: AnyCancellable?
    private let center = DeviceActivityCenter()
    private let store = ManagedSettingsStore()
    
    private init() {}
    
    /// 스크린타임 권한을 요청합니다.
    func requestAuthorization() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            } catch {
                print("Failed to request ScreenTime authorization: \(error)")
            }
        }
    }
    
    /// 집중 세션을 시작합니다.
    func startFocus(for schedule: Schedule) {
        self.currentSchedule = schedule
        self.remainingTime = schedule.durationSeconds
        self.isFocusing = true
        
        startTimer()
        startMonitoring()
    }
    
    /// 집중 세션을 중단합니다.
    func stopFocus() {
        stopTimer()
        stopMonitoring()
        
        self.isFocusing = false
        self.currentSchedule = nil
    }
    
    /// 타이머를 시작합니다.
    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.completeFocus()
                }
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    /// 스크린타임 모니터링을 활성화합니다.
    private func startMonitoring() {
        // 실제 구현 시에는 스케줄 이름을 Activity 이름으로 사용하거나 고유 ID를 사용합니다.
        let activity = DeviceActivityName("com.unwind.focusSession")
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try center.startMonitoring(activity, during: schedule)
            print("Started ScreenTime monitoring")
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }
    
    private func stopMonitoring() {
        center.stopMonitoring([DeviceActivityName("com.unwind.focusSession")])
        print("Stopped ScreenTime monitoring")
    }
    
    /// 세션이 정상적으로 종료되었을 때 호출됩니다.
    private func completeFocus() {
        guard var schedule = currentSchedule else { return }
        schedule.isCompleted = true
        schedule.isRunning = false
        
        // Repository를 통해 상태 업데이트 (여기선 간단히 stop만 호출)
        stopFocus()
        
        // TODO: Repository.updateSchedule(schedule) 호출 필요
    }
}
