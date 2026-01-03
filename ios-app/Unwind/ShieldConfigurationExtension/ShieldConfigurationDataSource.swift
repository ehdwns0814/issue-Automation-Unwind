import ManagedSettings
import ManagedSettingsUI
import UIKit

// 이 클래스는 차단된 앱이 실행될 때 보여지는 화면(Shield)의 디자인과 문구를 결정합니다.
class ShieldConfigurationProvider: ShieldConfigurationDataSource {
    
    // 공유 UserDefaults에서 현재 진행 중인 스케줄 이름을 가져옵니다.
    private let sharedDefaults = UserDefaults(suiteName: "group.com.unwind.data")
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return createCustomConfiguration()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return createCustomConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return createCustomConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return createCustomConfiguration()
    }
    
    private func createCustomConfiguration() -> ShieldConfiguration {
        // 현재 활성화된 스케줄 이름과 남은 시간을 가져옵니다.
        let scheduleName = sharedDefaults?.string(forKey: "activeScheduleName") ?? "집중"
        let remainingSeconds = sharedDefaults?.integer(forKey: "remainingSeconds") ?? 0
        
        // 남은 시간을 HH:MM:SS 형식으로 변환합니다.
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        return ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: .systemBackground,
            icon: UIImage(systemName: "clock.badge.checkmark"),
            title: ShieldConfiguration.Label(
                text: "지금은 '\(scheduleName)' 중!",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "남은 시간: \(timeString)\n목표를 달성할 때까지 조금만 더 힘내세요.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "확인",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemBlue
        )
    }
}

