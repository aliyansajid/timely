//
//  ActivityData.swift
//  Timely
//
//  Model for tracking user activity metrics
//

import Foundation

struct ActivityData: Codable {
    let timestamp: Date
    var keyboardCount: Int
    var mouseCount: Int
    var isIdle: Bool

    init(timestamp: Date = Date(), keyboardCount: Int = 0, mouseCount: Int = 0, isIdle: Bool = false) {
        self.timestamp = timestamp
        self.keyboardCount = keyboardCount
        self.mouseCount = mouseCount
        self.isIdle = isIdle
    }
}

struct DailySummary: Identifiable {
    let id = UUID()
    let date: Date
    let totalMinutes: Int
    let activeMinutes: Int
    let idleMinutes: Int
    let sessionCount: Int
    let keyboardEvents: Int
    let mouseEvents: Int

    var totalHours: Double {
        return Double(totalMinutes) / 60.0
    }

    var productivityPercentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(activeMinutes) / Double(totalMinutes) * 100
    }
}
