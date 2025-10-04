//
//  psalmemApp.swift
//  psalmem
//
//  Created by Rebecca Tomlinson on 7/12/25.
//

import SwiftUI
import SwiftData

@main
struct psalmemApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Psalm.self,
            Verse.self,
            Translation.self,
            MemoryTest.self,
            Progress.self,
            QuizScore.self,
            Item.self
        ])
        
        do {
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            DiagnosticLogger.shared.logAppStart()
            
            // Migrate any existing data
            migrateExistingData(container: container)
            
            return container
        } catch {
            DiagnosticLogger.shared.logError("ModelContainer initialization failed: \(error)")
            
            // Try to delete the existing store and create a fresh one
            do {
                // Delete existing store files
                let storeURL = URL.applicationSupportDirectory.appendingPathComponent("default.store")
                if FileManager.default.fileExists(atPath: storeURL.path) {
                    try FileManager.default.removeItem(at: storeURL)
                    DiagnosticLogger.shared.logInfo("Removed existing store file")
                }
                
                let freshConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                let container = try ModelContainer(for: schema, configurations: [freshConfiguration])
                DiagnosticLogger.shared.logAppStart()
                DiagnosticLogger.shared.logInfo("Created fresh ModelContainer after store deletion")
                return container
            } catch {
                DiagnosticLogger.shared.logError("Fresh ModelContainer after store deletion failed: \(error)")
                
                // As a last resort, try with in-memory storage
                do {
                    let inMemoryConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                    let container = try ModelContainer(for: schema, configurations: [inMemoryConfiguration])
                    DiagnosticLogger.shared.logAppStart()
                    DiagnosticLogger.shared.logError("Using in-memory storage as fallback")
                    return container
                } catch {
                    DiagnosticLogger.shared.logError("In-memory storage also failed: \(error)")
                    fatalError("Could not create ModelContainer: \(error)")
                }
            }
        }
    }()
    
    private static func migrateExistingData(container: ModelContainer) {
        let context = container.mainContext
        
        do {
            let allProgress = try context.fetch(FetchDescriptor<Progress>())
            for progress in allProgress {
                // Ensure memorizedVersesString has a default value if it's nil
                if progress.memorizedVersesString == nil {
                    progress.memorizedVersesString = ""
                }
                
                // Initialize new properties if they don't exist (for existing data)
                if progress.totalQuizAttempts == 0 && progress.correctAnswers == 0 && progress.totalAnswers == 0 {
                    // This is likely existing data, initialize new properties
                    progress.totalQuizAttempts = 0
                    progress.correctAnswers = 0
                    progress.totalAnswers = 0
                    progress.streakDays = 0
                    progress.lastStreakDate = nil
                    progress.bestScore = 0.0
                    progress.averageScore = 0.0
                    progress.timeSpentMinutes = 0
                    progress.quizScores = []
                    progress.memorizationLevel = .notStarted
                }
            }
            try context.save()
            DiagnosticLogger.shared.logDatabaseOperation("Data migration completed", entity: "Progress", success: true)
        } catch {
            DiagnosticLogger.shared.logError("Data migration failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainNavigationView()
        }
        .modelContainer(sharedModelContainer)
    }
}
