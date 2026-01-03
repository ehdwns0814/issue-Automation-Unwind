
import Foundation

class FocusManager {
    var remainingTime: Int = 0
    var isFocusing: Bool = false
    
    func startFocus(duration: Int) {
        self.remainingTime = duration
        self.isFocusing = true
    }
    
    func tick() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            isFocusing = false
        }
    }
}

let fm = FocusManager()
fm.startFocus(duration: 5)
print("Initial: \(fm.remainingTime)s, focusing: \(fm.isFocusing)")

for i in 1...2 {
    fm.tick()
}
print("After 2 ticks: \(fm.remainingTime)s")

for i in 1...3 {
    fm.tick()
}
print("After 3 more ticks: \(fm.remainingTime)s, focusing: \(fm.isFocusing)")

print("End of test.")
