//
//  ActivityMonitor.swift
//  Timely
//
//  Monitors keyboard and mouse activity
//

import Foundation
import Cocoa
import ApplicationServices
import Combine

class ActivityMonitor: ObservableObject {
    static let shared = ActivityMonitor()

    @Published var keyboardCount: Int = 0
    @Published var mouseCount: Int = 0
    @Published var isIdle: Bool = false

    private var eventMonitor: Any?
    private var idleCheckTimer: Timer?

    private var lastActivityTime: Date = Date()
    private var idleThresholdSeconds: TimeInterval = 300 // 5 minutes

    private init() {}

    // MARK: - Activity Monitoring

    func startMonitoring() {
        guard checkAccessibilityPermissions() else {
            print("⚠️  Accessibility permissions not granted")
            requestAccessibilityPermissions()
            return
        }

        startEventMonitoring()
        startIdleDetection()

        print("👀 Activity monitoring started")
    }

    func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }

        idleCheckTimer?.invalidate()
        idleCheckTimer = nil

        print("🛑 Activity monitoring stopped")
    }

    // MARK: - Event Monitoring

    private func startEventMonitoring() {
        // Monitor keyboard and mouse events globally
        eventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.keyDown, .leftMouseDown, .rightMouseDown, .mouseMoved]
        ) { [weak self] event in
            self?.handleEvent(event)
        }
    }

    private func handleEvent(_ event: NSEvent) {
        switch event.type {
        case .keyDown:
            keyboardCount += 1
        case .leftMouseDown, .rightMouseDown:
            mouseCount += 1
        case .mouseMoved:
            // Count significant mouse movements
            if abs(event.deltaX) > 10 || abs(event.deltaY) > 10 {
                mouseCount += 1
            }
        default:
            break
        }

        lastActivityTime = Date()
        if isIdle {
            isIdle = false
            print("✅ User is active again")
        }
    }

    // MARK: - Idle Detection

    private func startIdleDetection() {
        idleCheckTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.checkIdleStatus()
        }
    }

    private func checkIdleStatus() {
        let timeSinceLastActivity = Date().timeIntervalSince(lastActivityTime)

        if timeSinceLastActivity >= idleThresholdSeconds {
            if !isIdle {
                isIdle = true
                print("💤 User is idle")
                // TODO: Notify TimerManager about idle state
            }
        }
    }

    func setIdleThreshold(minutes: Int) {
        idleThresholdSeconds = TimeInterval(minutes * 60)
        print("⏱️  Idle threshold set to \(minutes) minutes")
    }

    // MARK: - Permissions

    private func checkAccessibilityPermissions() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options)
    }

    private func requestAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options)
        print("🔐 Requesting accessibility permissions...")
    }

    // MARK: - Reset

    func resetCounters() {
        keyboardCount = 0
        mouseCount = 0
        lastActivityTime = Date()
        isIdle = false
    }

    // MARK: - Stats

    func getActivitySummary() -> (keyboard: Int, mouse: Int, isIdle: Bool) {
        return (keyboard: keyboardCount, mouse: mouseCount, isIdle: isIdle)
    }
}
