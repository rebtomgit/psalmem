import SwiftUI
import SwiftData

struct MemorizationView: View {
    let psalm: Psalm
    let translation: Translation
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allVerses: [Verse]
    @Query private var users: [User]
    @State private var currentVerseIndex = 0
    @State private var memorizedVerses: Set<Int> = []
    @State private var showingPuzzle = false
    @State private var puzzleType: PuzzleType = .fillInTheBlank
    @State private var showingProgress = false
    
    private var verses: [Verse] {
        allVerses.filter { $0.psalm?.id == psalm.id && $0.translation?.id == translation.id }.sorted { $0.number < $1.number }
    }
    
    private var user: User? {
        users.first
    }
    
    private var progress: Double {
        guard !verses.isEmpty else { return 0 }
        return Double(memorizedVerses.count) / Double(verses.count)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with dismiss button
            HStack {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("Psalm \(psalm.number)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Progress") {
                    showingProgress = true
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            
            // Progress indicator
            VStack(spacing: 10) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal)
                
                Text("\(memorizedVerses.count) of \(verses.count) verses memorized")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            
            if currentVerseIndex < verses.count {
                currentVerseView(verse: verses[currentVerseIndex])
            } else {
                completionView
            }
            
            Spacer()
            
            // Navigation buttons
            HStack {
                Button("Previous Verse") {
                    if currentVerseIndex > 0 {
                        currentVerseIndex -= 1
                    }
                }
                .disabled(currentVerseIndex == 0)
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Next Verse") {
                    if currentVerseIndex < verses.count - 1 {
                        currentVerseIndex += 1
                    }
                }
                .disabled(currentVerseIndex == verses.count - 1)
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingProgress) {
            if let user = user {
                ProgressReportView(psalm: psalm, user: user, translation: translation, memorizedVerses: memorizedVerses)
            }
        }
    }
    
    private func currentVerseView(verse: Verse) -> some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Verse \(verse.number)")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(verse.text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            if memorizedVerses.contains(verse.number) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Memorized!")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            } else {
                VStack(spacing: 15) {
                    Text("Choose a puzzle type to practice:")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        ForEach(PuzzleType.allCases, id: \.self) { type in
                            Button(action: {
                                puzzleType = type
                                showingPuzzle = true
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: type.iconName)
                                        .font(.title2)
                                    Text(type.displayName)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(height: 80)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingPuzzle) {
            PuzzleView(
                verse: verse,
                puzzleType: puzzleType,
                onComplete: { success in
                    if success {
                        memorizedVerses.insert(verse.number)
                        updateProgress()
                    }
                }
            )
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You have completed memorizing Psalm \(psalm.number)")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Progress: \(Int(progress * 100))%")
                .font(.headline)
                .foregroundColor(.blue)
            
            Button("View Progress Report") {
                showingProgress = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func updateProgress() {
        guard let user = user else { return }
        
        // Find or create progress record
        let allProgress = try? modelContext.fetch(FetchDescriptor<Progress>())
        let existingProgress = allProgress?.first(where: { $0.psalm?.id == psalm.id && $0.user?.id == user.id && $0.translation?.id == translation.id })
        if let progressObj = existingProgress {
            progressObj.memorizedVerses = Array(memorizedVerses)
            progressObj.overallProgress = progress
            progressObj.lastPracticed = Date()
        } else {
            let newProgress = Progress(psalm: psalm, user: user, translation: translation)
            newProgress.memorizedVerses = Array(memorizedVerses)
            newProgress.overallProgress = progress
            modelContext.insert(newProgress)
        }
        try? modelContext.save()
    }
}

enum PuzzleType: CaseIterable {
    case fillInTheBlank
    case wordOrder
    case multipleChoice
    case typing
    case dragAndDrop
    
    var displayName: String {
        switch self {
        case .fillInTheBlank: return "Fill in the\nBlank"
        case .wordOrder: return "Word\nOrder"
        case .multipleChoice: return "Multiple\nChoice"
        case .typing: return "Type the\nVerse"
        case .dragAndDrop: return "Drag &\nDrop"
        }
    }
    
    var iconName: String {
        switch self {
        case .fillInTheBlank: return "textformat.abc"
        case .wordOrder: return "list.number"
        case .multipleChoice: return "checkmark.circle"
        case .typing: return "keyboard"
        case .dragAndDrop: return "hand.draw"
        }
    }
}

struct PuzzleView: View {
    let verse: Verse
    let puzzleType: PuzzleType
    let onComplete: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingHint = false
    @State private var attempts = 0
    @State private var isCorrect = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Verse \(verse.number)")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(puzzleType.displayName)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                switch puzzleType {
                case .fillInTheBlank:
                    FillInTheBlankPuzzle(verse: verse, onComplete: handleCompletion)
                case .wordOrder:
                    WordOrderPuzzle(verse: verse, onComplete: handleCompletion)
                case .multipleChoice:
                    MultipleChoicePuzzle(verse: verse, onComplete: handleCompletion)
                case .typing:
                    TypingPuzzle(verse: verse, onComplete: handleCompletion)
                case .dragAndDrop:
                    DragAndDropPuzzle(verse: verse, onComplete: handleCompletion)
                }
                
                Spacer()
                
                if attempts > 0 {
                    Button("Show Hint") {
                        showingHint = true
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("Puzzle")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
#else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
#endif
            }
            .alert("Hint", isPresented: $showingHint) {
                Button("OK") { }
            } message: {
                Text("Try to remember the key words and their order. Focus on the meaning of each phrase.")
            }
        }
    }
    
    private func handleCompletion(success: Bool) {
        attempts += 1
        isCorrect = success
        
        if success {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
                onComplete(true)
            }
        }
    }
}

// MARK: - Puzzle Components

struct FillInTheBlankPuzzle: View {
    let verse: Verse
    let onComplete: (Bool) -> Void
    @State private var userInput = ""
    @State private var blankWord = ""
    @State private var verseWords: [String] = []
    @State private var blankIndex = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Fill in the missing word:")
                .font(.headline)
            
            let displayText = createDisplayText()
            Text(displayText)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            TextField("Enter the missing word", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Submit") {
                let success = userInput.lowercased().trimmingCharacters(in: .whitespaces) == blankWord.lowercased()
                onComplete(success)
                if !success {
                    userInput = ""
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(userInput.isEmpty)
        }
        .onAppear {
            setupPuzzle()
        }
    }
    
    private func setupPuzzle() {
        verseWords = verse.text.components(separatedBy: " ")
        blankIndex = Int.random(in: 0..<verseWords.count)
        blankWord = verseWords[blankIndex]
    }
    
    private func createDisplayText() -> String {
        var words = verseWords
        words[blankIndex] = "_____"
        return words.joined(separator: " ")
    }
}

struct WordOrderPuzzle: View {
    let verse: Verse
    let onComplete: (Bool) -> Void
    @State private var shuffledWords: [String] = []
    @State private var selectedWords: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Arrange the words in the correct order:")
                .font(.headline)
            
            // Selected words
            VStack(spacing: 10) {
                Text("Your answer:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(selectedWords, id: \.self) { word in
                        Text(word)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Available words
            VStack(spacing: 10) {
                Text("Available words:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(shuffledWords, id: \.self) { word in
                        Button(action: {
                            if let index = shuffledWords.firstIndex(of: word) {
                                selectedWords.append(word)
                                shuffledWords.remove(at: index)
                            }
                        }) {
                            Text(word)
                                .padding(8)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(selectedWords.contains(word))
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            HStack {
                Button("Clear") {
                    shuffledWords.append(contentsOf: selectedWords)
                    selectedWords.removeAll()
                }
                .buttonStyle(.bordered)
                
                Button("Check") {
                    let userAnswer = selectedWords.joined(separator: " ")
                    let correctAnswer = verse.text
                    let success = userAnswer.lowercased() == correctAnswer.lowercased()
                    onComplete(success)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedWords.isEmpty)
            }
        }
        .onAppear {
            setupPuzzle()
        }
    }
    
    private func setupPuzzle() {
        let words = verse.text.components(separatedBy: " ")
        shuffledWords = words.shuffled()
    }
}

struct MultipleChoicePuzzle: View {
    let verse: Verse
    let onComplete: (Bool) -> Void
    @State private var options: [String] = []
    @State private var correctAnswer = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Complete the verse:")
                .font(.headline)
            
            let questionText = createQuestionText()
            Text(questionText)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        let success = option == correctAnswer
                        onComplete(success)
                    }) {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            setupPuzzle()
        }
    }
    
    private func setupPuzzle() {
        let words = verse.text.components(separatedBy: " ")
        let randomIndex = Int.random(in: 0..<words.count)
        correctAnswer = words[randomIndex]
        
        // Create options
        options = [correctAnswer]
        let allWords = verse.text.components(separatedBy: " ")
        let otherWords = allWords.filter { $0 != correctAnswer }
        
        for _ in 0..<3 {
            if let randomWord = otherWords.randomElement() {
                options.append(randomWord)
            }
        }
        
        options.shuffle()
    }
    
    private func createQuestionText() -> String {
        let words = verse.text.components(separatedBy: " ")
        var displayWords = words
        let randomIndex = Int.random(in: 0..<words.count)
        displayWords[randomIndex] = "_____"
        return displayWords.joined(separator: " ")
    }
}

struct TypingPuzzle: View {
    let verse: Verse
    let onComplete: (Bool) -> Void
    @State private var userInput = ""
    @State private var showingHint = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Type the complete verse:")
                .font(.headline)
            
            TextEditor(text: $userInput)
                .frame(height: 120)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            Button("Check Answer") {
                let success = userInput.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == verse.text.lowercased()
                onComplete(success)
                if !success {
                    showingHint = true
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(userInput.isEmpty)
        }
        .alert("Hint", isPresented: $showingHint) {
            Button("OK") { }
        } message: {
            Text("Try to type the verse word by word. Remember the key phrases and their order.")
        }
    }
}

struct DragAndDropPuzzle: View {
    let verse: Verse
    let onComplete: (Bool) -> Void
    @State private var phrases: [String] = []
    @State private var selectedPhrases: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Arrange the phrases in order:")
                .font(.headline)
            
            // Selected phrases
            VStack(spacing: 10) {
                Text("Your arrangement:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(selectedPhrases, id: \.self) { phrase in
                    Text(phrase)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Available phrases
            VStack(spacing: 10) {
                Text("Available phrases:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(phrases, id: \.self) { phrase in
                    Button(action: {
                        if let index = phrases.firstIndex(of: phrase) {
                            selectedPhrases.append(phrase)
                            phrases.remove(at: index)
                        }
                    }) {
                        Text(phrase)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(selectedPhrases.contains(phrase))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            HStack {
                Button("Clear") {
                    phrases.append(contentsOf: selectedPhrases)
                    selectedPhrases.removeAll()
                }
                .buttonStyle(.bordered)
                
                Button("Check") {
                    let userAnswer = selectedPhrases.joined(separator: " ")
                    let correctAnswer = verse.text
                    let success = userAnswer.lowercased() == correctAnswer.lowercased()
                    onComplete(success)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedPhrases.isEmpty)
            }
        }
        .onAppear {
            setupPuzzle()
        }
    }
    
    private func setupPuzzle() {
        // Split verse into phrases
        let words = verse.text.components(separatedBy: " ")
        phrases = []
        
        for i in stride(from: 0, to: words.count, by: 3) {
            let endIndex = min(i + 3, words.count)
            let phrase = words[i..<endIndex].joined(separator: " ")
            phrases.append(phrase)
        }
        
        phrases.shuffle()
    }
} 