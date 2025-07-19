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
    @State private var showingQuiz = false
    @State private var currentUser: User?
    @State private var appState: AppState = .loading
    @State private var recommendedPsalms: [Psalm] = []
    @State private var selectedVerses: Set<Int> = []
    
    enum AppState {
        case loading
        case needsAssessment
        case needsTranslation
        case needsPsalmSelection
        case ready
    }
    
    var body: some View {
        Group {
            switch appState {
            case .loading:
                loadingView
            case .needsAssessment:
                assessmentPromptView
            case .needsTranslation:
                translationSelectionView
            case .needsPsalmSelection:
                psalmRecommendationView
            case .ready:
                mainContentView
            }
        }
        .onAppear {
            checkUserStatus()
        }
        .sheet(isPresented: $showingAssessment) {
            MemoryAssessmentView()
        }
        .sheet(isPresented: $showingQuiz) {
            if let psalm = selectedPsalm, let translation = selectedTranslation {
                PsalmQuizView(psalm: psalm, translation: translation)
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView("Loading...")
                .scaleEffect(1.5)
        }
    }
    
    private var assessmentPromptView: some View {
        VStack(spacing: 30) {
            Text("Welcome to PsalmMem")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Let's start with a quick memory assessment to personalize your experience.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Take Memory Assessment") {
                showingAssessment = true
            }
            .buttonStyle(.borderedProminent)
            .font(.title3)
        }
        .padding()
    }
    
    private var translationSelectionView: some View {
        VStack(spacing: 30) {
            Text("Choose Your Translation")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Select the Bible translation you'd like to use for memorization:")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            HStack(spacing: 16) {
                ForEach(translations, id: \.id) { translation in
                    Button(action: {
                        selectedTranslation = translation
                        appState = .needsPsalmSelection
                    }) {
                        Text(translation.name)
                            .fontWeight(selectedTranslation?.id == translation.id ? .bold : .regular)
                            .foregroundColor(selectedTranslation?.id == translation.id ? .white : .blue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selectedTranslation?.id == translation.id ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
    }
    
    private var psalmRecommendationView: some View {
        VStack(spacing: 20) {
            Text("Recommended Psalms")
                .font(.largeTitle)
                .fontWeight(.bold)
            if let user = currentUser, let translation = selectedTranslation {
                Text("Based on your memory profile, here are the best psalms to start with:")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                let recs = getRecommendedPsalms(for: user, translation: translation)
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(recs, id: \.id) { psalm in
                            Button(action: {
                                selectedPsalm = psalm
                                appState = .ready
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Psalm \(psalm.number)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text(psalm.title)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Recommended for your memory type")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
    }
    
    private var mainContentView: some View {
        VStack(spacing: 20) {
            if let psalm = selectedPsalm, let translation = selectedTranslation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Psalm \(psalm.number): \(psalm.title)")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        // Translation switcher
                        Menu {
                            ForEach(translations, id: \.id) { t in
                                Button(t.name) {
                                    selectedTranslation = t
                                }
                            }
                        } label: {
                            Text(translation.abbreviation)
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top)
                    let psalmVerses = verses.filter { $0.psalm?.id == psalm.id && $0.translation?.id == translation.id }.sorted { $0.number < $1.number }
                    Text("Scroll to view the entire psalm. Tap a verse to select for memorization.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(psalmVerses, id: \.id) { verse in
                                HStack(alignment: .top) {
                                    Button(action: {
                                        if selectedVerses.contains(verse.number) {
                                            selectedVerses.remove(verse.number)
                                        } else {
                                            selectedVerses.insert(verse.number)
                                        }
                                    }) {
                                        Image(systemName: selectedVerses.contains(verse.number) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(selectedVerses.contains(verse.number) ? .blue : .gray)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Text("\(verse.number).")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .frame(width: 30, alignment: .trailing)
                                    Text(verse.text)
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding()
            }
            
            // Action buttons
            HStack(spacing: 20) {
                Button("Start Quiz") {
                    showingQuiz = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedPsalm == nil || selectedTranslation == nil)
                
                Button("Reset Sample Data") {
                    resetSampleData()
                }
                .buttonStyle(.bordered)
            }
            .padding(.top)
        }
        .padding()
    }
    
    private func checkUserStatus() {
        // Ensure psalms are loaded
        if psalms.isEmpty {
            loadSamplePsalms()
        }
        // Set up a default user if none exists
        if users.isEmpty {
            appState = .needsAssessment
        } else {
            currentUser = users.first
            if selectedTranslation == nil {
                appState = .needsTranslation
            } else if selectedPsalm == nil {
                appState = .needsPsalmSelection
            } else {
                appState = .ready
            }
        }
    }
    
    private func getRecommendedPsalms(for user: User, translation: Translation) -> [Psalm] {
        // Simple recommendation logic based on memory strengths
        let allPsalms = Array(psalms.prefix(20))
        if user.memoryStrengths.contains(.visual) {
            return Array(allPsalms.prefix(5))
        } else if user.memoryStrengths.contains(.auditory) {
            return Array(allPsalms.suffix(5))
        } else {
            return Array(allPsalms.prefix(10))
        }
    }
    
    private func loadSamplePsalms() {
        PsalmDataService.shared.populatePsalms(modelContext: modelContext)
    }

    private func resetSampleData() {
        // Remove all psalms, verses, and translations, then reload
        for psalm in psalms { modelContext.delete(psalm) }
        for verse in verses { modelContext.delete(verse) }
        for translation in translations { modelContext.delete(translation) }
        loadSamplePsalms()
        selectedPsalm = nil
        selectedTranslation = nil
        appState = .needsTranslation
    }
}

struct PsalmDetailView: View {
    let psalm: Psalm
    let translation: Translation
    @Environment(\.dismiss) private var dismiss
    @Query private var verses: [Verse]
    @State private var showWholePsalm = false
    @State private var currentLineIndex = 0
    @State private var linesPerView = 5
    
    private var psalmVerses: [Verse] {
        verses.filter { $0.psalm?.id == psalm.id && $0.translation?.id == translation.id }
            .sorted { $0.number < $1.number }
    }
    
    private var allLines: [String] {
        if showWholePsalm {
            return psalmVerses.map { $0.text }
        } else {
            return psalmVerses.enumerated().map { index, verse in
                "\(verse.number). \(verse.text)"
            }
        }
    }
    
    private var currentLines: [String] {
        let startIndex = currentLineIndex
        let endIndex = min(startIndex + linesPerView, allLines.count)
        return Array(allLines[startIndex..<endIndex])
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Psalm \(psalm.number)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(psalm.title)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text(translation.name)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
                
                // Display mode toggle
                HStack {
                    Button(showWholePsalm ? "Show Verse by Verse" : "Show Whole Psalm") {
                        showWholePsalm.toggle()
                        currentLineIndex = 0
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    if !showWholePsalm {
                        Button("5 Lines") {
                            linesPerView = 5
                        }
                        .buttonStyle(.bordered)
                        .background(linesPerView == 5 ? Color.blue.opacity(0.2) : Color.clear)
                        
                        Button("10 Lines") {
                            linesPerView = 10
                        }
                        .buttonStyle(.bordered)
                        .background(linesPerView == 10 ? Color.blue.opacity(0.2) : Color.clear)
                    }
                }
                .padding(.horizontal)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(currentLines.indices, id: \.self) { index in
                            Text(currentLines[index])
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 2)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity)
                
                // Navigation buttons
                if !showWholePsalm && allLines.count > linesPerView {
                    HStack {
                        Button("Previous") {
                            currentLineIndex = max(0, currentLineIndex - linesPerView)
                        }
                        .disabled(currentLineIndex == 0)
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Text("\(currentLineIndex + 1)-\(min(currentLineIndex + linesPerView, allLines.count)) of \(allLines.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Next") {
                            currentLineIndex = min(allLines.count - linesPerView, currentLineIndex + linesPerView)
                        }
                        .disabled(currentLineIndex >= allLines.count - linesPerView)
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Psalm \(psalm.number)")
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
