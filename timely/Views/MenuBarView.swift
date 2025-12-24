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
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Timer display
            VStack(spacing: 8) {
                Text(timerManager.formattedTime())
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(timerManager.isPaused ? .orange : (timerManager.isRunning ? .green : .secondary))

                Text(timerManager.isPaused ? "Paused" : (timerManager.isRunning ? "Working" : "Idle"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            // Control buttons
            HStack(spacing: 12) {
                // Start/Stop button
                Button(action: {
                    if timerManager.isRunning || timerManager.isPaused {
                        timerManager.stopTimer()
                    } else {
                        timerManager.startTimer()
                    }
                }) {
                    HStack {
                        Image(systemName: (timerManager.isRunning || timerManager.isPaused) ? "stop.circle.fill" : "play.circle.fill")
                        Text((timerManager.isRunning || timerManager.isPaused) ? "Stop" : "Start")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint((timerManager.isRunning || timerManager.isPaused) ? .red : .green)

                // Pause/Resume button
                if timerManager.isRunning || timerManager.isPaused {
                    Button(action: {
                        if timerManager.isPaused {
                            timerManager.resumeTimer()
                        } else {
                            timerManager.pauseTimer()
                        }
                    }) {
                        Image(systemName: timerManager.isPaused ? "play.fill" : "pause.fill")
                            .font(.title3)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
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

                SettingsLink {
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
        openWindow(id: "dashboard")
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
