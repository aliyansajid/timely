//
//  ChartsView.swift
//  Timely
//
//  Interactive charts and data visualization
//

import SwiftUI
import Charts

struct ChartsView: View {
    @State private var sessions: [Session] = []
    @State private var selectedPeriod: TimePeriod = .week

    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Analytics")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 250)
                }
                .padding(.horizontal)

                // Daily work hours chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Work Hours")
                        .font(.headline)
                        .padding(.horizontal)

                    Chart(dailyData) { item in
                        BarMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Hours", item.hours)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Productivity trend chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Productivity Trend")
                        .font(.headline)
                        .padding(.horizontal)

                    Chart(productivityData) { item in
                        LineMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Productivity", item.percentage)
                        )
                        .foregroundStyle(Color.green.gradient)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Productivity", item.percentage)
                        )
                        .foregroundStyle(Color.green.opacity(0.1).gradient)
                        .interpolationMethod(.catmullRom)
                    }
                    .chartYScale(domain: 0...100)
                    .frame(height: 200)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Activity distribution
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity Distribution")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack(spacing: 16) {
                        // Keyboard vs Mouse pie chart
                        VStack {
                            Text("Input Methods")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Chart(activityDistribution) { item in
                                SectorMark(
                                    angle: .value("Count", item.count),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 2
                                )
                                .foregroundStyle(by: .value("Type", item.type))
                                .cornerRadius(4)
                            }
                            .frame(height: 150)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)

                        // Active vs Idle time
                        VStack {
                            Text("Time Distribution")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Chart(timeDistribution) { item in
                                SectorMark(
                                    angle: .value("Time", item.minutes),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 2
                                )
                                .foregroundStyle(by: .value("Type", item.type))
                                .cornerRadius(4)
                            }
                            .frame(height: 150)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                // Stats summary
                HStack(spacing: 16) {
                    StatsCard(
                        title: "Total Hours",
                        value: String(format: "%.1f", totalHours),
                        trend: "+12%",
                        trendUp: true
                    )

                    StatsCard(
                        title: "Avg. Productivity",
                        value: String(format: "%.0f%%", avgProductivity),
                        trend: "+5%",
                        trendUp: true
                    )

                    StatsCard(
                        title: "Sessions",
                        value: "\(totalSessions)",
                        trend: "+8",
                        trendUp: true
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onAppear {
            loadData()
        }
    }

    // MARK: - Data Processing

    private var dailyData: [DailyWorkData] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!

        var data: [DailyWorkData] = []
        var currentDate = startDate

        while currentDate <= endDate {
            let daySessions = sessions.filter {
                calendar.isDate($0.date, inSameDayAs: currentDate)
            }
            let totalMinutes = daySessions.reduce(0) { $0 + $1.durationMinutes }
            let hours = Double(totalMinutes) / 60.0

            data.append(DailyWorkData(date: currentDate, hours: hours))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return data
    }

    private var productivityData: [ProductivityData] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!

        var data: [ProductivityData] = []
        var currentDate = startDate

        while currentDate <= endDate {
            let daySessions = sessions.filter {
                calendar.isDate($0.date, inSameDayAs: currentDate)
            }

            let totalMinutes = daySessions.reduce(0) { $0 + $1.durationMinutes }
            let activeMinutes = daySessions.reduce(0) { $0 + $1.activeMinutes }
            let percentage = totalMinutes > 0 ? Double(activeMinutes) / Double(totalMinutes) * 100 : 0

            data.append(ProductivityData(date: currentDate, percentage: percentage))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return data
    }

    private var activityDistribution: [ActivityDistData] {
        let totalKeyboard = sessions.reduce(0) { $0 + $1.keyboardEvents }
        let totalMouse = sessions.reduce(0) { $0 + $1.mouseEvents }

        return [
            ActivityDistData(type: "Keyboard", count: totalKeyboard),
            ActivityDistData(type: "Mouse", count: totalMouse)
        ]
    }

    private var timeDistribution: [TimeDistData] {
        let totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }
        let activeMinutes = sessions.reduce(0) { $0 + $1.activeMinutes }
        let idleMinutes = totalMinutes - activeMinutes

        return [
            TimeDistData(type: "Active", minutes: activeMinutes),
            TimeDistData(type: "Idle", minutes: idleMinutes)
        ]
    }

    private var totalHours: Double {
        let totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }
        return Double(totalMinutes) / 60.0
    }

    private var avgProductivity: Double {
        guard !sessions.isEmpty else { return 0 }
        let totalProductivity = sessions.reduce(0.0) { $0 + $1.productivityPercentage }
        return totalProductivity / Double(sessions.count)
    }

    private var totalSessions: Int {
        return sessions.count
    }

    private func loadData() {
        sessions = DataManager.shared.loadSessions()
    }
}

// MARK: - Data Models

struct DailyWorkData: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
}

struct ProductivityData: Identifiable {
    let id = UUID()
    let date: Date
    let percentage: Double
}

struct ActivityDistData: Identifiable {
    let id = UUID()
    let type: String
    let count: Int
}

struct TimeDistData: Identifiable {
    let id = UUID()
    let type: String
    let minutes: Int
}

// MARK: - Stats Card

struct StatsCard: View {
    let title: String
    let value: String
    let trend: String
    let trendUp: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            HStack(spacing: 4) {
                Image(systemName: trendUp ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)
                Text(trend)
                    .font(.caption)
            }
            .foregroundColor(trendUp ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ChartsView()
}
