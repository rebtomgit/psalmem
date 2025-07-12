import SwiftUI
import SwiftData

struct MainNavigationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Query private var psalms: [Psalm]
    @Query private var verses: [Verse]
    @Query private var translations: [Translation]
    @Query private var progress: [Progress]
    
    @State private var selectedPsalm: Psalm?
    @State private var selectedTranslation: Translation?
    @State private var showingAssessment = false
    @State private var showingMemorization = false
    @State private var currentUser: User?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Always show assessment button
                Button(currentUser == nil ? "Take Memory Assessment" : "Retake Memory Assessment") {
                    showingAssessment = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
                
                headerSection
                
                // Psalm selection
                if psalms.isEmpty {
                    Text("No psalms available.")
                        .foregroundColor(.red)
                    Button("Load Sample Psalms") {
                        loadSamplePsalms()
                    }
                    .buttonStyle(.bordered)
                } else {
                    psalmSelectionSection
                    translationSelectionSection
                }
                
                // Show verses if both selected
                if let psalm = selectedPsalm, let translation = selectedTranslation {
                    versesSection(psalm: psalm, translation: translation)
                }
                
                if !progress.isEmpty {
                    progressSection
                }
                
                if let user = currentUser {
                    memoryProfileSection(user: user)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAssessment) {
            MemoryAssessmentView()
        }
        .onAppear {
            checkUserStatus()
        }
    }
    
    private func checkUserStatus() {
        if !users.isEmpty {
            currentUser = users.first
        }
    }
    
    private func loadSamplePsalms() {
        // Add 2 sample psalms and 2 translations, and a few verses for each
        let kjv = Translation(name: "King James", abbreviation: "KJV")
        let esv = Translation(name: "English Standard", abbreviation: "ESV")
        modelContext.insert(kjv)
        modelContext.insert(esv)
        let psalm1 = Psalm(number: 1, title: "The Way of the Righteous and the Wicked")
        let psalm2 = Psalm(number: 2, title: "The Reign of the Lord's Anointed")
        modelContext.insert(psalm1)
        modelContext.insert(psalm2)
        let verses1kjv = [
            Verse(number: 1, text: "Blessed is the man that walketh not in the counsel of the ungodly...", psalm: psalm1, translation: kjv),
            Verse(number: 2, text: "But his delight is in the law of the LORD...", psalm: psalm1, translation: kjv)
        ]
        let verses1esv = [
            Verse(number: 1, text: "Blessed is the man who walks not in the counsel of the wicked...", psalm: psalm1, translation: esv),
            Verse(number: 2, text: "But his delight is in the law of the LORD...", psalm: psalm1, translation: esv)
        ]
        let verses2kjv = [
            Verse(number: 1, text: "Why do the heathen rage, and the people imagine a vain thing?", psalm: psalm2, translation: kjv)
        ]
        let verses2esv = [
            Verse(number: 1, text: "Why do the nations rage and the peoples plot in vain?", psalm: psalm2, translation: esv)
        ]
        for v in verses1kjv + verses1esv + verses2kjv + verses2esv { modelContext.insert(v) }
        try? modelContext.save()
    }
    
    private var headerSection: some View {
        VStack {
            Text("PsalmMem")
                .font(.largeTitle)
                .fontWeight(.bold)
            if let user = currentUser {
                Text("Welcome back, \(user.name)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private var psalmSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Available Psalms")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Choose a psalm to memorize.")
                .font(.body)
                .foregroundColor(.secondary)
            ForEach(psalms.prefix(20), id: \.id) { psalm in
                Button(action: {
                    selectedPsalm = psalm
                }) {
                    HStack {
                        Text("Psalm \(psalm.number): \(psalm.title)")
                            .fontWeight(selectedPsalm?.id == psalm.id ? .bold : .regular)
                        if selectedPsalm?.id == psalm.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .padding(6)
                .background(selectedPsalm?.id == psalm.id ? Color.blue.opacity(0.1) : Color.clear)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var translationSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose Translation")
                .font(.title2)
                .fontWeight(.semibold)
            HStack(spacing: 10) {
                ForEach(translations, id: \.id) { t in
                    Button(t.name) {
                        selectedTranslation = t
                    }
                    .padding()
                    .background(selectedTranslation?.id == t.id ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func versesSection(psalm: Psalm, translation: Translation) -> some View {
        let psalmVerses = verses.filter { $0.psalm?.id == psalm.id && $0.translation?.id == translation.id }
        return VStack(alignment: .leading, spacing: 10) {
            Text("Psalm \(psalm.number) (\(translation.name))")
                .font(.title2)
                .fontWeight(.bold)
            if psalmVerses.isEmpty {
                Text("No verses available for this psalm and translation.")
                    .foregroundColor(.red)
            } else {
                ForEach(psalmVerses.sorted { $0.number < $1.number }, id: \.id) { verse in
                    Text("\(verse.number). \(verse.text)")
                        .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var progressSection: some View {
        ProgressListView(progress: Array(progress.prefix(5)))
    }
    
    private func memoryProfileSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Memory Profile")
                .font(.title2)
                .fontWeight(.semibold)
            MemoryScoreView(user: user)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct MainNavigationBodyView: View {
    let users: [User]
    let psalms: [Psalm]
    let verses: [Verse]
    let translations: [Translation]
    let progress: [Progress]
    @Binding var selectedPsalm: Psalm?
    @Binding var selectedTranslation: Translation?
    @Binding var showingAssessment: Bool
    @Binding var showingMemorization: Bool
    @Binding var currentUser: User?
    let checkUserStatus: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                
                if currentUser == nil {
                    assessmentSection
                }
                
                psalmSelectionSection
                
                if selectedPsalm != nil {
                    translationSelectionSection
                }
                
                if let psalm = selectedPsalm, let translation = selectedTranslation {
                    selectedPsalmSection(psalm: psalm, translation: translation)
                }
                
                if !progress.isEmpty {
                    progressSection
                }
                
                if let user = currentUser {
                    memoryProfileSection(user: user)
                }
            }
            .padding()
        }
    }
    
    private var headerSection: some View {
        VStack {
            Text("PsalmMem")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let user = currentUser {
                Text("Welcome back, \(user.name)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private var assessmentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Memory Assessment")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Take a quick assessment to analyze your memory strengths and get personalized psalm recommendations.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button("Start Assessment") {
                showingAssessment = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var psalmSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Available Psalms")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Choose a psalm to memorize. Based on your assessment, we'll recommend the best starting point.")
                .font(.body)
                .foregroundColor(.secondary)
            
            PsalmGridView(
                psalms: Array(psalms.prefix(20)),
                selectedPsalm: selectedPsalm,
                translations: translations,
                onSelect: { psalm in
                    selectedPsalm = psalm
                    selectedTranslation = translations.first { $0.name == "King James" }
                }
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var translationSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose Translation")
                .font(.title2)
                .fontWeight(.semibold)
            
            TranslationButtonsView(
                selectedTranslation: selectedTranslation,
                onSelection: { name in
                    if let t = translations.first(where: { $0.name == name }) {
                        selectedTranslation = t
                    }
                }
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func selectedPsalmSection(psalm: Psalm, translation: Translation) -> some View {
        let psalmVerses = verses.filter { $0.psalm?.id == psalm.id && $0.translation?.id == translation.id }
        return SelectedPsalmDetailsView(
            psalm: psalm,
            translation: translation,
            psalmVersesCount: psalmVerses.count,
            isDisabled: psalmVerses.isEmpty,
            onStart: { showingMemorization = true }
        )
    }
    
    private var progressSection: some View {
        ProgressListView(progress: Array(progress.prefix(5)))
    }
    
    private func memoryProfileSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Memory Profile")
                .font(.title2)
                .fontWeight(.semibold)
            
            MemoryScoreView(user: user)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct PsalmCard: View {
    let psalm: Psalm
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            PsalmCardContent(psalm: psalm, isSelected: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PsalmCardContent: View {
    let psalm: Psalm
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Text("Psalm \(psalm.number)")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(psalm.title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct ProgressRow: View {
    let progress: Progress
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Psalm \(progress.psalm?.number ?? 0)")
                    .font(.headline)
                Text(progress.translation?.name ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(Int(progress.overallProgress * 100))%")
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SelectedPsalmDetailsView: View {
    let psalm: Psalm
    let translation: Translation
    let psalmVersesCount: Int
    let isDisabled: Bool
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected: Psalm \(psalm.number)")
                .font(.title2)
                .fontWeight(.semibold)
            Text("\(psalmVersesCount) verses")
                .font(.body)
                .foregroundColor(.secondary)
            Button("Start Memorization") {
                onStart()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isDisabled)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ProgressListView: View {
    let progress: [Progress]
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Progress")
                .font(.title2)
                .fontWeight(.semibold)
            ProgressRows(progress: progress)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ProgressRows: View {
    let progress: [Progress]
    var body: some View {
        ForEach(progress, id: \.id) { prog in
            ProgressRow(progress: prog)
        }
    }
}

struct TranslationButtonsView: View {
    let selectedTranslation: Translation?
    let onSelection: (String) -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button("King James") {
                onSelection("King James")
            }
            .padding()
            .background(selectedTranslation?.name == "King James" ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(selectedTranslation?.name == "King James" ? .white : .primary)
            .cornerRadius(8)

            Button("English Standard") {
                onSelection("English Standard")
            }
            .padding()
            .background(selectedTranslation?.name == "English Standard" ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(selectedTranslation?.name == "English Standard" ? .white : .primary)
            .cornerRadius(8)
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let assessmentCompleted = Notification.Name("assessmentCompleted")
    static let psalmSelected = Notification.Name("psalmSelected")
} 

struct PsalmGridView: View {
    let psalms: [Psalm]
    let selectedPsalm: Psalm?
    let translations: [Translation]
    let onSelect: (Psalm) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
            ForEach(psalms, id: \.id) { psalm in
                PsalmCard(
                    psalm: psalm,
                    isSelected: selectedPsalm?.id == psalm.id,
                    onSelect: { onSelect(psalm) }
                )
            }
        }
    }
} 

struct MemoryScoreView: View {
    let user: User
    
    var body: some View {
        HStack {
            VStack {
                Text("\(user.visualMemoryScore)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Visual")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            
            VStack {
                Text("\(user.auditoryMemoryScore)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Auditory")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            
            VStack {
                Text("\(user.kinestheticMemoryScore)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Kinesthetic")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
} 
