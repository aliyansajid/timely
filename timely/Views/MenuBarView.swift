//
//  MenuBarView.swift
//  Timely
//
//  Menu bar dropdown interface
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var timerManager: TimerManager
    @StateObject private var activityMonitor = ActivityMonitor.shared

    var body: some View {
        VStack(spacing: 0) {
            // Timer display
            VStack(spacing: 8) {
                Text(timerManager.formattedTime())
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(timerManager.isRunning ? .green : .secondary)

                Text(timerManager.isRunning ? "Working" : "Idle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            // Start/Stop button
            Button(action: {
                if timerManager.isRunning {
                    timerManager.stopTimer()
                } else {
                    timerManager.startTimer()
                }
            }) {
                HStack {
                    Image(systemName: timerManager.isRunning ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                    Text(timerManager.isRunning ? "Stop Timer" : "Start Timer")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(timerManager.isRunning ? .red : .green)
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Quick stats
            if timerManager.isRunning {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "keyboard")
                            .frame(width: 20)
                        Text("Keyboard: \(activityMonitor.keyboardCount)")
                            .font(.caption)
                    }
                    HStack {
                        Image(systemName: "cursorarrow.click")
                            .frame(width: 20)
                        Text("Mouse: \(activityMonitor.mouseCount)")
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
            }

            // Menu options
            VStack(spacing: 0) {
                Button(action: openDashboard) {
                    Label("Open Dashboard", systemImage: "chart.bar")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 6)
                .padding(.horizontal)

                Divider()

                Button(action: openSettings) {
                    Label("Settings", systemImage: "gearshape")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 6)
                .padding(.horizontal)

                Divider()

                Button(action: quitApp) {
                    Label("Quit Timely", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 6)
                .padding(.horizontal)
            }
        }
        .frame(width: 280)
    }

    private func openDashboard() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows {
            if window.title == "Timely Dashboard" {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
    }

    private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

#Preview {
    MenuBarView()
        .environmentObject(TimerManager.shared)
}
