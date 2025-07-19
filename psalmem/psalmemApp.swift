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
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            DiagnosticLogger.shared.logAppStart()
            
            // Run migration for old data
            let context = container.mainContext
            Progress.migrateOldData(modelContext: context)
            
            return container
        } catch {
            DiagnosticLogger.shared.logError(error, context: "ModelContainer initialization")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainNavigationView()
        }
        .modelContainer(sharedModelContainer)
    }
}
