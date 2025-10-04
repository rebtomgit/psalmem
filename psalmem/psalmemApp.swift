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
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            DiagnosticLogger.shared.logAppStart()
            
            // Migrate any existing data
            migrateExistingData(container: container)
            
            return container
        } catch {
            DiagnosticLogger.shared.logError("ModelContainer initialization failed: \(error)")
            
            // If migration fails, try with a fresh store
            do {
                let freshConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                let container = try ModelContainer(for: schema, configurations: [freshConfiguration])
                DiagnosticLogger.shared.logAppStart()
                return container
            } catch {
                DiagnosticLogger.shared.logError("Fresh ModelContainer also failed: \(error)")
                fatalError("Could not create ModelContainer: \(error)")
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
