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
        // 올인 모드 여부를 확인합니다.
        let isAllInMode = sharedDefaults?.bool(forKey: "isAllInModeActive") ?? false
        
        let titleText: String
        let subtitleText: String
        
        if isAllInMode {
            // 올인 모드일 경우의 문구
            let progress = sharedDefaults?.string(forKey: "allInModeProgress") ?? ""
            titleText = "올인 모드 진행 중!"
            subtitleText = "오늘의 모든 스케줄을 완료할 때까지 앱이 차단됩니다.\n현재 진행 상황: \(progress)"
        } else {
            // 일반 스케줄 모드일 경우의 문구
            let scheduleName = sharedDefaults?.string(forKey: "activeScheduleName") ?? "집중"
            let remainingSeconds = sharedDefaults?.integer(forKey: "remainingSeconds") ?? 0
            
            let hours = remainingSeconds / 3600
            let minutes = (remainingSeconds % 3600) / 60
            let seconds = remainingSeconds % 60
            let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            titleText = "지금은 '\(scheduleName)' 중!"
            subtitleText = "남은 시간: \(timeString)\n목표를 달성할 때까지 조금만 더 힘내세요."
        }
        
        return ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: .systemBackground,
            icon: UIImage(systemName: isAllInMode ? "bolt.fill" : "clock.badge.checkmark"),
            title: ShieldConfiguration.Label(
                text: titleText,
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: subtitleText,
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "확인",
                color: .white
            ),
            primaryButtonBackgroundColor: isAllInMode ? .systemOrange : .systemBlue
        )
    }
}

