//
//  User.swift
//  Timely
//
//  User model for authentication and preferences
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var email: String?
    var createdAt: Date

    // User preferences
    var preferences: UserPreferences

    init(id: String = UUID().uuidString, name: String, email: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = Date()
        self.preferences = UserPreferences()
    }
}

struct UserPreferences: Codable {
    // Activity monitoring
    var enableActivityTracking: Bool = true
    var idleTimeoutMinutes: Int = 5
    var autoPauseOnIdle: Bool = true

    // Notifications
    var enableBreakReminders: Bool = true
    var breakReminderIntervalMinutes: Int = 60
    var enableIdleWarnings: Bool = true

    // Working hours
    var dailyHourGoal: Double = 8.0
    var weeklyHourGoal: Double = 40.0

    // Data
    var dataStorageLocation: String = "~/Library/Application Support/Timely/"
    var autoExportEnabled: Bool = false

    // UI
    var showMenuBarTimer: Bool = true
    var use24HourFormat: Bool = true
}
