//
//  Session.swift
//  Timely
//
//  Data model for work sessions
//

import Foundation

struct Session: Identifiable, Codable {
    let id: UUID
    let userId: String
    let date: Date
    let startTime: Date
    var endTime: Date?
    var isActive: Bool

    // Activity tracking
    var keyboardEvents: Int
    var mouseEvents: Int
    var idleTimeMinutes: Int

    // Optional metadata
    var notes: String?
    var tags: [String]

    // Computed properties
    var duration: TimeInterval {
        guard let end = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return end.timeIntervalSince(startTime)
    }

    var durationMinutes: Int {
        return Int(duration / 60)
    }

    var activeMinutes: Int {
        return max(0, durationMinutes - idleTimeMinutes)
    }

    var productivityPercentage: Double {
        guard durationMinutes > 0 else { return 0 }
        return Double(activeMinutes) / Double(durationMinutes) * 100
    }

    init(
        id: UUID = UUID(),
        userId: String,
        startTime: Date = Date(),
        endTime: Date? = nil,
        notes: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.userId = userId
        self.date = Calendar.current.startOfDay(for: startTime)
        self.startTime = startTime
        self.endTime = endTime
        self.isActive = endTime == nil
        self.keyboardEvents = 0
        self.mouseEvents = 0
        self.idleTimeMinutes = 0
        self.notes = notes
        self.tags = tags
    }
}

// MARK: - CSV Conversion
extension Session {
    var csvRow: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        let dateStr = dateFormatter.string(from: date)
        let startStr = timeFormatter.string(from: startTime)
        let endStr = endTime.map { timeFormatter.string(from: $0) } ?? ""
        let notesStr = notes?.replacingOccurrences(of: ",", with: ";") ?? ""
        let tagsStr = tags.joined(separator: "|")

        return "\(id.uuidString),\(userId),\(dateStr),\(startStr),\(endStr),\(durationMinutes),\(activeMinutes),\(idleTimeMinutes),\(keyboardEvents),\(mouseEvents),\(String(format: "%.2f", productivityPercentage)),\(notesStr),\(tagsStr)"
    }

    static var csvHeader: String {
        return "session_id,user_id,date,start_time,end_time,duration_minutes,active_minutes,idle_minutes,keyboard_events,mouse_events,productivity_percentage,notes,tags"
    }
}
