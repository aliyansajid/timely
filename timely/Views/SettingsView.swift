//
//  SettingsView.swift
//  Timely
//
//  Settings and preferences window
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("idleTimeoutMinutes") private var idleTimeout = 5
    @AppStorage("enableActivityTracking") private var activityTracking = true
    @AppStorage("autoPauseOnIdle") private var autoPause = true
    @AppStorage("enableBreakReminders") private var breakReminders = true
    @AppStorage("breakInterval") private var breakInterval = 60

    var body: some View {
        TabView {
            GeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            ActivitySettings(
                idleTimeout: $idleTimeout,
                activityTracking: $activityTracking,
                autoPause: $autoPause
            )
            .tabItem {
                Label("Activity", systemImage: "bolt")
            }

            NotificationSettings(
                breakReminders: $breakReminders,
                breakInterval: $breakInterval
            )
            .tabItem {
                Label("Notifications", systemImage: "bell")
            }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - General Settings

struct GeneralSettings: View {
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Timely")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }

                Divider()

                LabeledContent("Developer") {
                    Text("Aliyan Sajid")
                }

                LabeledContent("GitHub") {
                    Link("github.com/aliyansajid/timely", destination: URL(string: "https://github.com/aliyansajid/timely")!)
                }

                LabeledContent("License") {
                    Text("MIT License")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Activity Settings

struct ActivitySettings: View {
    @Binding var idleTimeout: Int
    @Binding var activityTracking: Bool
    @Binding var autoPause: Bool

    var body: some View {
        Form {
            Section("Activity Monitoring") {
                Toggle("Enable activity tracking", isOn: $activityTracking)
                    .help("Track keyboard and mouse activity")
                    .onChange(of: activityTracking) { oldValue, newValue in
                        if newValue {
                            ActivityMonitor.shared.startMonitoring()
                        } else {
                            ActivityMonitor.shared.stopMonitoring()
                        }
                    }

                Toggle("Auto-pause on idle", isOn: $autoPause)
                    .help("Automatically pause timer when idle")
                    .disabled(!activityTracking)

                Picker("Idle timeout", selection: $idleTimeout) {
                    Text("5 minutes").tag(5)
                    Text("10 minutes").tag(10)
                    Text("15 minutes").tag(15)
                    Text("30 minutes").tag(30)
                }
                .help("Time of inactivity before marking as idle")
                .disabled(!activityTracking)
                .onChange(of: idleTimeout) { oldValue, newValue in
                    ActivityMonitor.shared.setIdleThreshold(minutes: newValue)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("⚠️ Accessibility Permissions Required")
                        .font(.headline)

                    Text("Activity monitoring requires accessibility permissions to track keyboard and mouse events.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Open System Settings") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Notification Settings

struct NotificationSettings: View {
    @Binding var breakReminders: Bool
    @Binding var breakInterval: Int

    var body: some View {
        Form {
            Section("Break Reminders") {
                Toggle("Enable break reminders", isOn: $breakReminders)
                    .help("Get reminded to take breaks during long work sessions")

                Picker("Reminder interval", selection: $breakInterval) {
                    Text("30 minutes").tag(30)
                    Text("45 minutes").tag(45)
                    Text("60 minutes").tag(60)
                    Text("90 minutes").tag(90)
                    Text("120 minutes").tag(120)
                }
                .disabled(!breakReminders)
                .help("How often to show break reminders")
            }

            Section {
                Text("Break reminders help prevent burnout and maintain productivity throughout the day.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

#Preview {
    SettingsView()
}
