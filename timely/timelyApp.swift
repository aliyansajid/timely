//
//  timelyApp.swift
//  Timely
//
//  Created by Aliyan Sajid on 24/12/2025.
//

import SwiftUI

@main
struct TimelyApp: App {
    @StateObject private var timerManager = TimerManager.shared
    @NSApplicationDelegateAdaptor(AppDelegate.class) var appDelegate

    var body: some Scene {
        // Menu bar extra for the timer controls
        MenuBarExtra("Timely", systemImage: "clock.fill") {
            MenuBarView()
                .environmentObject(timerManager)
        }
        .menuBarExtraStyle(.window)

        // Main window for dashboard
        Window("Timely Dashboard", id: "dashboard") {
            DashboardView()
                .environmentObject(timerManager)
                .frame(minWidth: 900, minHeight: 650)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        // Settings window
        Settings {
            SettingsView()
        }
    }
}

// App Delegate for initialization
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize user on first launch
        let _ = DataManager.shared.getOrCreateUser()
        print("✅ Timely initialized")
    }
}
