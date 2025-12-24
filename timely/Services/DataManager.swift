//
//  DataManager.swift
//  Timely
//
//  Handles data persistence to CSV files
//

import Foundation

class DataManager {
    static let shared = DataManager()

    private let fileManager = FileManager.default
    private var dataDirectory: URL

    private init() {
        // Create data directory in Application Support
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        dataDirectory = appSupport.appendingPathComponent("Timely", isDirectory: true)

        createDataDirectoryIfNeeded()
    }

    private func createDataDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: dataDirectory.path) {
            try? fileManager.createDirectory(at: dataDirectory, withIntermediateDirectories: true)
            print("📁 Created data directory at: \(dataDirectory.path)")
        }
    }

    // MARK: - Session Management

    func saveSession(_ session: Session) {
        let csvFile = dataDirectory.appendingPathComponent("sessions.csv")

        // Create file with header if it doesn't exist
        if !fileManager.fileExists(atPath: csvFile.path) {
            let header = Session.csvHeader + "\n"
            try? header.write(to: csvFile, atomically: true, encoding: .utf8)
        }

        // Append session data
        if let fileHandle = try? FileHandle(forWritingTo: csvFile) {
            fileHandle.seekToEndOfFile()
            let sessionData = session.csvRow + "\n"
            if let data = sessionData.data(using: .utf8) {
                fileHandle.write(data)
            }
            try? fileHandle.close()
        }

        print("💾 Session saved to CSV: \(session.id)")
    }

    func loadSessions() -> [Session] {
        let csvFile = dataDirectory.appendingPathComponent("sessions.csv")

        guard fileManager.fileExists(atPath: csvFile.path),
              let content = try? String(contentsOf: csvFile, encoding: .utf8) else {
            print("ℹ️  No sessions file found")
            return []
        }

        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else { return [] } // Skip if only header exists

        // Parse CSV (skip header)
        var sessions: [Session] = []
        for line in lines.dropFirst() {
            if let session = parseCSVLine(line) {
                sessions.append(session)
            }
        }

        print("📖 Loaded \(sessions.count) sessions")
        return sessions
    }

    private func parseCSVLine(_ line: String) -> Session? {
        let components = line.components(separatedBy: ",")
        guard components.count >= 13 else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        guard let sessionId = UUID(uuidString: components[0]),
              let date = dateFormatter.date(from: components[2]),
              let startTime = timeFormatter.date(from: components[3]) else {
            return nil
        }

        let endTime = components[4].isEmpty ? nil : timeFormatter.date(from: components[4])
        let userId = components[1]
        let keyboardEvents = Int(components[8]) ?? 0
        let mouseEvents = Int(components[9]) ?? 0
        let idleMinutes = Int(components[7]) ?? 0
        let notes = components[11].isEmpty ? nil : components[11]
        let tags = components[12].components(separatedBy: "|").filter { !$0.isEmpty }

        var session = Session(id: sessionId, userId: userId, startTime: startTime, endTime: endTime, notes: notes, tags: tags)
        session.keyboardEvents = keyboardEvents
        session.mouseEvents = mouseEvents
        session.idleTimeMinutes = idleMinutes

        return session
    }

    func loadSessionsForDate(_ date: Date) -> [Session] {
        return loadSessions().filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func loadTodaySessions() -> [Session] {
        return loadSessionsForDate(Date())
    }

    // MARK: - Export

    func exportToCSV(sessions: [Session], filename: String) -> URL? {
        let exportFile = dataDirectory.appendingPathComponent(filename)

        var csvContent = Session.csvHeader + "\n"
        csvContent += sessions.map { $0.csvRow }.joined(separator: "\n")

        do {
            try csvContent.write(to: exportFile, atomically: true, encoding: .utf8)
            print("📤 Exported \(sessions.count) sessions to \(filename)")
            return exportFile
        } catch {
            print("❌ Export failed: \(error)")
            return nil
        }
    }

    // MARK: - User Management

    func saveUser(_ user: User) {
        let userFile = dataDirectory.appendingPathComponent("user.json")
        if let data = try? JSONEncoder().encode(user) {
            try? data.write(to: userFile)
            print("👤 User saved")
        }
    }

    func loadUser() -> User? {
        let userFile = dataDirectory.appendingPathComponent("user.json")
        guard let data = try? Data(contentsOf: userFile),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }

    func getOrCreateUser() -> User {
        if let existingUser = loadUser() {
            return existingUser
        }

        // Create default user
        let newUser = User(name: "User", email: nil)
        saveUser(newUser)
        UserDefaults.standard.set(newUser.id, forKey: "currentUserId")
        return newUser
    }
}
