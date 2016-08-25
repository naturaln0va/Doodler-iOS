
import Foundation

extension Date {
    
    func hoursSince(date: Date) -> Int {
        var dateComponents = Set<Calendar.Component>()
        dateComponents.insert(.hour)
        return Calendar.current.dateComponents(dateComponents, from: date, to: self).hour ?? 0
    }
    
    func daysSince(date: Date) -> Int {
        var dateComponents = Set<Calendar.Component>()
        dateComponents.insert(.day)
        return Calendar.current.dateComponents(dateComponents, from: date, to: self).day ?? 0
    }
    
    var relativeString: String {
        let now = Date()
        let intervalDifference = now.timeIntervalSince(self)
        
        if intervalDifference < TimeInterval(60) {
            return "Now"
        }
        
        if intervalDifference <= TimeInterval(60 * 60) {
            return "\(Int(intervalDifference / 60))m"
        }
        
        let daysAgo = now.daysSince(date: self)
        
        if daysAgo <= 1 {
            let hoursAgo = Int(intervalDifference / TimeInterval(60 * 60))
            return "\(hoursAgo)h"
        }
        else if daysAgo <= 6 {
            return "\(daysAgo)d"
        }
        
        let weeksAgo = daysAgo / 7
        if weeksAgo < 52 {
            return "\(weeksAgo)w"
        }
        
        return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .none)
    }
    
}
