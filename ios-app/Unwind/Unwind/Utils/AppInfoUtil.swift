import Foundation

/// 앱의 버전 및 빌드 정보를 제공하는 유틸리티 클래스입니다.
struct AppInfoUtil {
    /// 앱의 버전 정보를 가져옵니다 (예: 1.0.0).
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// 앱의 빌드 번호를 가져옵니다 (예: 1).
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// 표시용 전체 버전 문자열을 가져옵니다 (예: v1.0.0 (Build 1)).
    static var fullVersionString: String {
        return "v\(appVersion) (Build \(buildNumber))"
    }
}

