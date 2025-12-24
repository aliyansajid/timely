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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        // Authentication/Onboarding window (shows first)
        Window("Welcome to Timely", id: "welcome") {
            if !hasCompletedOnboarding {
                AuthenticationView(isAuthenticated: $isAuthenticated)
            }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        // Menu bar extra for the timer controls
        MenuBarExtra("Timely", systemImage: "clock.fill") {
            if hasCompletedOnboarding {
                MenuBarView()
                    .environmentObject(timerManager)
            } else {
                VStack {
                    Text("Please complete setup first")
                        .padding()
                    Button("Open Setup") {
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
                .frame(width: 200)
            }
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
