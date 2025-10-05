import Foundation
import SwiftData
import SwiftUI
import os.log

class DiagnosticLogger: ObservableObject {
    static let shared = DiagnosticLogger()
    
    private let logger = Logger(subsystem: "com.creacom.psalmem", category: "diagnostics")
    private let fileLogger = FileLogger()
    
    private init() {}
    
    // MARK: - Logging Methods
    
    func logAppStart() {
        let message = "App started - Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logMemoryAssessmentStarted() {
        let message = "Memory assessment started"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logMemoryAssessmentCompleted(score: Double, type: String) {
        let message = "Memory assessment completed - Type: \(type), Score: \(score)"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logTranslationSelected(translation: String) {
        let message = "Translation selected: \(translation)"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logPsalmSelected(psalmNumber: Int, title: String) {
        let message = "Psalm selected: \(psalmNumber) - \(title)"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logQuizStarted(psalmNumber: Int, quizType: String) {
        let message = "Quiz started - Psalm: \(psalmNumber), Type: \(quizType)"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logQuizCompleted(psalmNumber: Int, quizType: String, score: Int, totalQuestions: Int) {
        let percentage = totalQuestions > 0 ? Double(score) / Double(totalQuestions) * 100 : 0
        let message = "Quiz completed - Psalm: \(psalmNumber), Type: \(quizType), Score: \(score)/\(totalQuestions) (\(String(format: "%.1f", percentage))%)"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logQuestionAnswered(questionType: String, correct: Bool, verseNumber: Int) {
        let result = correct ? "correct" : "incorrect"
        let message = "Question answered - Type: \(questionType), Verse: \(verseNumber), Result: \(result)"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logDataLoadStarted() {
        let message = "Data loading started"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logDataLoadCompleted(psalmCount: Int, verseCount: Int, translationCount: Int) {
        let message = "Data loading completed - Psalms: \(psalmCount), Verses: \(verseCount), Translations: \(translationCount)"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logError(_ error: Error, context: String) {
        let message = "Error in \(context): \(error.localizedDescription)"
        logError(message)
        fileLogger.log(message, level: .error)
    }
    
    func logWarning(_ warning: String, context: String) {
        let message = "Warning in \(context): \(warning)"
        logWarning(message)
        fileLogger.log(message, level: .warning)
    }
    
    func logUserAction(_ action: String, details: String? = nil) {
        let message = details != nil ? "User action: \(action) - \(details!)" : "User action: \(action)"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logPerformance(_ operation: String, duration: TimeInterval) {
        let message = "Performance - \(operation): \(String(format: "%.3f", duration))s"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logMemoryUsage() {
        let memoryUsage = getMemoryUsage()
        let message = "Memory usage: \(memoryUsage) MB"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    func logDatabaseOperation(_ operation: String, entity: String, success: Bool) {
        let status = success ? "success" : "failed"
        let message = "Database operation: \(operation) on \(entity) - \(status)"
        logInfo(message)
        fileLogger.log(message, level: .info)
    }
    
    // MARK: - Private Methods
    
    func logInfo(_ message: String) {
        logger.info("\(message)")
    }
    
    func logError(_ message: String) {
        logger.error("\(message)")
    }
    
    func logWarning(_ message: String) {
        logger.warning("\(message)")
    }
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0
        } else {
            return 0.0
        }
    }
}

// MARK: - File Logger

class FileLogger {
    private let logFileURL: URL
    private let dateFormatter: DateFormatter
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        logFileURL = documentsPath.appendingPathComponent("psalmem_diagnostics.log")
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    func log(_ message: String, level: LogLevel) {
        let timestamp = dateFormatter.string(from: Date())
        let logEntry = "[\(timestamp)] [\(level.rawValue)] \(message)\n"
        
        do {
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                let handle = try FileHandle(forWritingTo: logFileURL)
                handle.seekToEndOfFile()
                handle.write(logEntry.data(using: .utf8)!)
                handle.closeFile()
            } else {
                try logEntry.write(to: logFileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Failed to write to log file: \(error)")
        }
    }
    
    func getLogContents() -> String {
        do {
            return try String(contentsOf: logFileURL, encoding: .utf8)
        } catch {
            return "Unable to read log file: \(error.localizedDescription)"
        }
    }
    
    func clearLog() {
        do {
            try "".write(to: logFileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to clear log file: \(error)")
        }
    }
}

enum LogLevel: String {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case debug = "DEBUG"
}

// MARK: - Diagnostic View

struct DiagnosticView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [Progress]
    @Query private var allUsers: [User]
    @Query private var allPsalms: [Psalm]
    @Query private var allQuizScores: [QuizScore]
    
    @StateObject private var logger = DiagnosticLogger.shared
    @State private var logContents = ""
    @State private var showingLogViewer = false
    @State private var selectedProgress: Progress?
    
    private var currentUser: User? {
        allUsers.first
    }
    
    private var totalQuizAttempts: Int {
        allProgress.reduce(0) { $0 + $1.totalQuizAttempts }
    }
    
    private var totalTimeSpent: Int {
        allProgress.reduce(0) { $0 + $1.timeSpentMinutes }
    }
    
    private var averageAccuracy: Double {
        let totalCorrect = allProgress.reduce(0) { $0 + $1.correctAnswers }
        let totalAnswers = allProgress.reduce(0) { $0 + $1.totalAnswers }
        guard totalAnswers > 0 else { return 0.0 }
        return Double(totalCorrect) / Double(totalAnswers) * 100.0
    }
    
    private var memorizedVersesCount: Int {
        allProgress.reduce(0) { $0 + $1.memorizedVerses.count }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Progress Overview
                    progressOverviewSection
                    
                    // User Progress Details
                    userProgressSection
                    
                    // Quiz Performance
                    quizPerformanceSection
                    
                    // Diagnostic Tools
                    diagnosticToolsSection
                    
                    // Extra padding at bottom to ensure all content is accessible
                    Spacer(minLength: 30)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.visible)
            .navigationTitle("Diagnostics & Progress")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingLogViewer) {
            LogViewerView(logContents: logContents)
        }
        .sheet(item: $selectedProgress) { progress in
            ProgressDetailView(progress: progress)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Diagnostic Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let user = currentUser {
                Text("User: \(user.name)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var progressOverviewSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Compact user info header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let user = currentUser {
                        Text("User: \(user.name)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.bottom, 8)
            
            Text("Progress Overview")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                DiagnosticStatCard(
                    title: "Total Psalms",
                    value: "\(allPsalms.count)",
                    icon: "book.fill",
                    color: .blue
                )
                
                DiagnosticStatCard(
                    title: "Quiz Attempts",
                    value: "\(totalQuizAttempts)",
                    icon: "questionmark.circle.fill",
                    color: .green
                )
                
                DiagnosticStatCard(
                    title: "Time Spent",
                    value: "\(totalTimeSpent) min",
                    icon: "clock.fill",
                    color: .orange
                )
                
                DiagnosticStatCard(
                    title: "Memorized Verses",
                    value: "\(memorizedVersesCount)",
                    icon: "brain.head.profile",
                    color: .purple
                )
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var userProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("User Progress Details")
                .font(.title2)
                .fontWeight(.bold)
            
            if allProgress.isEmpty {
                Text("No progress recorded yet")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                ForEach(allProgress.sorted(by: { $0.lastPracticed > $1.lastPracticed }), id: \.id) { progress in
                    ProgressCard(progress: progress) {
                        selectedProgress = progress
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var quizPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quiz Performance")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                HStack {
                    Text("Average Accuracy:")
                        .font(.headline)
                    Spacer()
                    Text("\(String(format: "%.1f", averageAccuracy))%")
                        .font(.headline)
                        .foregroundColor(averageAccuracy >= 80 ? .green : averageAccuracy >= 60 ? .orange : .red)
                }
                
                HStack {
                    Text("Recent Quiz Scores:")
                        .font(.headline)
                    Spacer()
                    Text("\(allQuizScores.count) recorded")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !allQuizScores.isEmpty {
                    let recentScores = allQuizScores.sorted { $0.date > $1.date }.prefix(5)
                    ForEach(Array(recentScores), id: \.id) { score in
                        HStack {
                            Text(score.date, format: .dateTime.day().month().hour().minute())
                                .font(.caption)
                            Spacer()
                            Text("\(Int(score.score))%")
                                .font(.caption)
                                .foregroundColor(score.score >= 80 ? .green : score.score >= 60 ? .orange : .red)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var diagnosticToolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Diagnostic Tools")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                Button("View System Logs") {
                    logContents = FileLogger().getLogContents()
                    showingLogViewer = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 12) {
                    Button("Clear Logs") {
                        FileLogger().clearLog()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Log Memory Usage") {
                        logger.logMemoryUsage()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                
                Button("Log Test Message") {
                    logger.logInfo("Test diagnostic message")
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct DiagnosticStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ProgressCard: View {
    let progress: Progress
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Psalm \(progress.psalm?.number ?? 0) - \(progress.translation?.abbreviation ?? "N/A")")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Progress: \(Int(progress.overallProgress * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Level: \(progress.memorizationLevel.rawValue)")
                        .font(.caption)
                        .foregroundColor(Color(progress.memorizationLevel.color))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(progress.streakDays) day streak")
                        .font(.caption)
                        .foregroundColor(progress.isStreakActive ? .orange : .gray)
                    
                    Text("Last: \(progress.lastPracticed, format: .dateTime.day().month())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProgressDetailView: View {
    let progress: Progress
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Psalm \(progress.psalm?.number ?? 0) - \(progress.translation?.abbreviation ?? "N/A")")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Memorization Level: \(progress.memorizationLevel.rawValue)")
                            .font(.headline)
                            .foregroundColor(Color(progress.memorizationLevel.color))
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Progress Stats
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Progress Statistics")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("Overall Progress:")
                                Spacer()
                                Text("\(Int(progress.overallProgress * 100))%")
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Quiz Attempts:")
                                Spacer()
                                Text("\(progress.totalQuizAttempts)")
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Accuracy:")
                                Spacer()
                                Text("\(Int(progress.accuracyPercentage))%")
                                    .fontWeight(.bold)
                                    .foregroundColor(progress.accuracyPercentage >= 80 ? .green : progress.accuracyPercentage >= 60 ? .orange : .red)
                            }
                            
                            HStack {
                                Text("Streak Days:")
                                Spacer()
                                Text("\(progress.streakDays)")
                                    .fontWeight(.bold)
                                    .foregroundColor(progress.isStreakActive ? .orange : .gray)
                            }
                            
                            HStack {
                                Text("Time Spent:")
                                Spacer()
                                Text("\(progress.timeSpentMinutes) minutes")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Memorized Verses
                    if !progress.memorizedVerses.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Memorized Verses")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(progress.memorizedVerses.map(String.init).joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Progress Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
}

struct LogViewerView: View {
    let logContents: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(logContents)
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle("Diagnostic Logs")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
#else
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
#endif
            }
        }
    }
} 