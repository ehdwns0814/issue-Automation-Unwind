import Foundation

/// 사용자의 연속 성공(Streak)을 계산하는 유틸리티 클래스입니다.
struct StreakCalculator {
    /// 현재까지의 연속 성공 일수를 계산합니다.
    /// - Parameter dailyRecords: 일별 기록 딕셔너리 (Key: "yyyy-MM-dd")
    /// - Returns: 연속 성공 일수
    static func calculateCurrentStreak(from dailyRecords: [String: DailyRecord]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()
        
        // 오늘 이미 성공했는지 확인
        let todayString = formatDate(checkDate)
        if dailyRecords[todayString]?.status == .success {
            streak += 1
        } else if dailyRecords[todayString]?.status == .failure {
            // 오늘 실패했다면 스트릭은 0
            return 0
        }
        // 오늘이 아직 success도 failure도 아니라면(pending) 어제부터 역순으로 계산 시작
        
        // 어제부터 역순으로 탐색
        while let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) {
            let dateString = formatDate(yesterday)
            
            if let record = dailyRecords[dateString] {
                if record.status == .success {
                    streak += 1
                } else if record.status == .noPlan {
                    // 계획 없는 날은 스트릭 유지 (건너뜀)
                    // 단, 이미 스트릭이 시작된 경우에만 의미가 있음
                    checkDate = yesterday
                    continue
                } else {
                    // 실패(failure)나 경고(warning)가 있으면 스트릭 중단
                    break
                }
            } else {
                // 기록이 없는 날은 계획 없는 날과 동일하게 취급하여 스트릭 유지
                checkDate = yesterday
                continue
            }
            
            checkDate = yesterday
            
            // 무한 루프 방지 및 합리적인 최대치 설정 (예: 10년)
            if streak > 3650 { break }
        }
        
        return streak
    }
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

