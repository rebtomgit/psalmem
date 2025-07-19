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
    @StateObject private var logger = DiagnosticLogger.shared
    @State private var logContents = ""
    @State private var showingLogViewer = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Diagnostic Tools")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                Button("View Logs") {
                    logContents = FileLogger().getLogContents()
                    showingLogViewer = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("Clear Logs") {
                    FileLogger().clearLog()
                }
                .buttonStyle(.bordered)
                
                Button("Log Memory Usage") {
                    logger.logMemoryUsage()
                }
                .buttonStyle(.bordered)
                
                Button("Log Test Message") {
                    logger.logInfo("Test diagnostic message")
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingLogViewer) {
            LogViewerView(logContents: logContents)
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