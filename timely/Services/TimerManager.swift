//
//  TimerManager.swift
//  Timely
//
//  Manages timer state and session lifecycle
//

import Foundation
import Combine

class TimerManager: ObservableObject {
    static let shared = TimerManager()

    @Published var currentSession: Session?
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var elapsedTime: TimeInterval = 0

    private var timer: Timer?
    private var startTime: Date?
    private var pauseStartTime: Date?
    private var totalPausedTime: TimeInterval = 0

    private init() {}

    func startTimer() {
        guard !isRunning else { return }

        let userId = UserDefaults.standard.string(forKey: "currentUserId") ?? "default_user"
        currentSession = Session(userId: userId)
        isRunning = true
        isPaused = false
        startTime = Date()
        totalPausedTime = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }

        // Start activity monitoring
        ActivityMonitor.shared.startMonitoring()

        print("⏱️  Timer started at \(Date())")
    }

    func stopTimer() {
        guard isRunning, var session = currentSession else { return }

        session.endTime = Date()
        session.isActive = false

        // Capture final activity counts
        session.keyboardEvents = ActivityMonitor.shared.keyboardCount
        session.mouseEvents = ActivityMonitor.shared.mouseCount

        // Save session
        DataManager.shared.saveSession(session)

        isRunning = false
        currentSession = nil
        elapsedTime = 0
        timer?.invalidate()
        timer = nil

        // Stop activity monitoring
        ActivityMonitor.shared.stopMonitoring()
        ActivityMonitor.shared.resetCounters()

        print("⏹️  Timer stopped. Duration: \(session.durationMinutes) minutes")
    }

    func pauseTimer() {
        guard isRunning, !isPaused else { return }

        timer?.invalidate()
        timer = nil
        isPaused = true
        pauseStartTime = Date()

        // Pause activity monitoring
        ActivityMonitor.shared.stopMonitoring()

        print("⏸️  Timer paused at \(formattedTime())")
    }

    func resumeTimer() {
        guard isPaused, currentSession != nil else { return }

        // Calculate paused duration
        if let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
        }

        isPaused = false
        pauseStartTime = nil

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }

        // Resume activity monitoring
        ActivityMonitor.shared.startMonitoring()

        print("▶️  Timer resumed at \(formattedTime())")
    }

    private func updateElapsedTime() {
        guard let start = startTime else { return }
        elapsedTime = Date().timeIntervalSince(start) - totalPausedTime

        // Update current session with activity data
        if var session = currentSession {
            session.keyboardEvents = ActivityMonitor.shared.keyboardCount
            session.mouseEvents = ActivityMonitor.shared.mouseCount
            currentSession = session
        }
    }

    func formattedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
