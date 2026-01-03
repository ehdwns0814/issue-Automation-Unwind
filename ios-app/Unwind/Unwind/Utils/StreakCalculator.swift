import Foundation

/// 사용자의 연속 성공(Streak)을 계산하는 유틸리티 클래스입니다.
struct StreakCalculator {
    /// 현재까지의 연속 성공 일수를 계산합니다.
    /// - Parameter dailyRecords: 일별 기록 딕셔너리 (Key: "yyyy-MM-dd")
    /// - Returns: 연속 성공 일수
    static func calculateCurrentStreak(from dailyRecords: [String: DailyRecord]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        let checkDate = calendar.startOfDay(for: Date())
        
        // 오늘 이미 성공했는지 확인
        let todayString = formatDate(checkDate)
        if dailyRecords[todayString]?.status == .success {
            streak += 1
        } else if dailyRecords[todayString]?.status == .failure {
            return 0
        }
        
        // 최근 100일까지만 스트릭을 계산하여 메인 스레드 프리징 방지
        for i in 1...100 {
            guard let previousDate = calendar.date(byAdding: .day, value: -i, to: calendar.startOfDay(for: Date())) else { break }
            let dateString = formatDate(previousDate)
            
            if let record = dailyRecords[dateString] {
                if record.status == .success {
                    streak += 1
                } else if record.status == .noPlan {
                    continue // 계획 없는 날은 건너뜀 (스트릭 유지)
                } else {
                    break // 실패 시 중단
                }
            } else {
                // 기록이 없는 날은 스트릭 중단 (데이터 무결성 위해)
                break
            }
        }
        
        return streak
    }
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

