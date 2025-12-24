//
//  DashboardView.swift
//  Timely
//
//  Main dashboard window
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var timerManager: TimerManager
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Today's sessions
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(0)

            // Analytics with Charts
            ChartsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(1)

            // History
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(2)
        }
    }
}

// MARK: - Today View

struct TodayView: View {
    @EnvironmentObject var timerManager: TimerManager
    @StateObject private var activityMonitor = ActivityMonitor.shared
    @State private var todaySessions: [Session] = []
    @State private var refreshTrigger = false

    var body: some View {
        VStack(spacing: 20) {
            // Header with current timer
            VStack(spacing: 8) {
                Text("Today's Work")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(timerManager.formattedTime())
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(timerManager.isRunning ? .green : .secondary)

                HStack(spacing: 16) {
                    Button(timerManager.isRunning ? "Stop" : "Start") {
                        if timerManager.isRunning {
                            timerManager.stopTimer()
                            loadTodaySessions()
                        } else {
                            timerManager.startTimer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(timerManager.isRunning ? .red : .green)
                }
            }
            .padding()

            // Stats cards
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Time",
                    value: formatMinutes(totalMinutes),
                    icon: "clock"
                )
                StatCard(
                    title: "Sessions",
                    value: "\(todaySessions.count)",
                    icon: "list.bullet"
                )
                StatCard(
                    title: "Active Time",
                    value: String(format: "%.0f%%", productivityPercentage),
                    icon: "bolt.fill"
                )
            }
            .padding(.horizontal)

            // Sessions list
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Today's Sessions")
                        .font(.headline)

                    Spacer()

                    Button(action: loadTodaySessions) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal)

                ScrollView {
                    if todaySessions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "clock.badge.checkmark")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No sessions yet")
                                .font(.title3)
                                .fontWeight(.medium)
                            Text("Start the timer to begin tracking!")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(todaySessions) { session in
                                SessionRow(session: session)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            loadTodaySessions()
        }
    }

    private var totalMinutes: Int {
        todaySessions.reduce(0) { $0 + $1.durationMinutes }
    }

    private var totalActiveMinutes: Int {
        todaySessions.reduce(0) { $0 + $1.activeMinutes }
    }

    private var productivityPercentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(totalActiveMinutes) / Double(totalMinutes) * 100
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }

    private func loadTodaySessions() {
        todaySessions = DataManager.shared.loadTodaySessions()
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: Session

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: session.isActive ? "play.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(session.isActive ? .green : .blue)

                    Text(timeRange)
                        .font(.headline)
                }

                HStack(spacing: 16) {
                    Label("\(session.durationMinutes) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("\(session.keyboardEvents)", systemImage: "keyboard")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("\(session.mouseEvents)", systemImage: "cursorarrow.click")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(String(format: "%.0f%%", session.productivityPercentage))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(productivityColor)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private var timeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let start = formatter.string(from: session.startTime)
        if let end = session.endTime {
            let endStr = formatter.string(from: end)
            return "\(start) - \(endStr)"
        }
        return "\(start) - Now"
    }

    private var productivityColor: Color {
        let percentage = session.productivityPercentage
        if percentage >= 80 { return .green }
        if percentage >= 60 { return .orange }
        return .red
    }
}

// MARK: - Reports View

struct ReportsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("Reports & Analytics")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Charts and productivity insights coming soon...")
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - History View

struct HistoryView: View {
    @State private var allSessions: [Session] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("Work History")
                .font(.largeTitle)
                .fontWeight(.bold)

            if allSessions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)

                    Text("No history yet")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(allSessions) { session in
                            SessionRow(session: session)
                        }
                    }
                    .padding()
                }
            }

            Button("Export to CSV") {
                exportSessions()
            }
            .buttonStyle(.borderedProminent)
            .disabled(allSessions.isEmpty)

            Spacer()
        }
        .padding()
        .onAppear {
            loadAllSessions()
        }
    }

    private func loadAllSessions() {
        allSessions = DataManager.shared.loadSessions()
    }

    private func exportSessions() {
        if let url = DataManager.shared.exportToCSV(sessions: allSessions, filename: "timely_export_\(Date().timeIntervalSince1970).csv") {
            NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .environmentObject(TimerManager.shared)
}
