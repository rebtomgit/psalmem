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
            return container
        } catch {
            DiagnosticLogger.shared.logError("ModelContainer initialization failed: \(error)")
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
