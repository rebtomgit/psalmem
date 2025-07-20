import SwiftUI
import SwiftData

struct PsalmQuizView: View {
    let psalm: Psalm
    let translation: Translation
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allVerses: [Verse]
    @Query private var users: [User]
    
    @State private var currentQuizIndex = 0
    @State private var quizQuestions: [QuizQuestion] = []
    @State private var currentScore = 0
    @State private var totalQuestions = 0
    @State private var showingResults = false
    @State private var quizCompleted = false
    @State private var selectedQuizType: QuizType = .mixed
    @State private var showingQuizTypeSelection = true
    
    private var verses: [Verse] {
        allVerses.filter { $0.psalm?.id == psalm.id && $0.translation?.id == translation.id }.sorted { $0.number < $1.number }
    }
    
    private var user: User? {
        users.first
    }
    
    private var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentScore) / Double(totalQuestions)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                if showingQuizTypeSelection {
                    quizTypeSelectionView
                } else if quizCompleted {
                    resultsView
                } else {
                    quizView
                }
            }
            .padding(.horizontal, 8)
            .navigationTitle("Psalm \(psalm.number) Quiz")
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationDetents([.large, .height(1200)])
        .presentationDragIndicator(.visible)
        .frame(minWidth: 600, minHeight: 800)
    }
    
    private var quizTypeSelectionView: some View {
        VStack(spacing: 30) {
            Text("Choose Quiz Type")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Select how you want to practice memorizing Psalm \(psalm.number)")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                ForEach(QuizType.allCases, id: \.self) { quizType in
                    Button(action: {
                        selectedQuizType = quizType
                        startQuiz()
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: quizType.iconName)
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text(quizType.displayName)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Text(quizType.description)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var quizView: some View {
        VStack(spacing: 10) {
            // Progress header
            VStack(spacing: 6) {
                HStack {
                    Text("Question \(currentQuizIndex + 1) of \(totalQuestions)")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(currentScore) correct")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            if currentQuizIndex < quizQuestions.count {
                QuizQuestionView(
                    question: quizQuestions[currentQuizIndex],
                    onAnswer: handleAnswer
                )
            }
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            // Result icon
            Image(systemName: progress >= 0.8 ? "star.fill" : progress >= 0.6 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(progress >= 0.8 ? .yellow : progress >= 0.6 ? .green : .orange)
            
            // Score display
            VStack(spacing: 10) {
                Text("Quiz Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("You scored \(currentScore) out of \(totalQuestions)")
                    .font(.title2)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(progress >= 0.8 ? .yellow : progress >= 0.6 ? .green : .orange)
            }
            
            // Performance message
            VStack(spacing: 8) {
                Text(performanceMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(performanceAdvice)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Action buttons
            VStack(spacing: 15) {
                Button("Try Again") {
                    startQuiz()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Try Different Quiz Type") {
                    showingQuizTypeSelection = true
                    quizCompleted = false
                }
                .buttonStyle(.bordered)
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    private var performanceMessage: String {
        if progress >= 0.9 {
            return "Excellent! You have a strong grasp of this psalm."
        } else if progress >= 0.8 {
            return "Great job! You're well on your way to memorizing this psalm."
        } else if progress >= 0.6 {
            return "Good effort! Keep practicing to improve your memorization."
        } else {
            return "Keep practicing! Review the psalm and try again."
        }
    }
    
    private var performanceAdvice: String {
        if progress >= 0.9 {
            return "Try a more challenging quiz type or move on to the next psalm."
        } else if progress >= 0.8 {
            return "Focus on the verses you missed and practice them specifically."
        } else if progress >= 0.6 {
            return "Spend more time reading and reflecting on the psalm text."
        } else {
            return "Start with reading the full psalm several times before attempting the quiz again."
        }
    }
    
    private func startQuiz() {
        let startTime = Date()
        quizQuestions = generateQuizQuestions()
        currentQuizIndex = 0
        currentScore = 0
        totalQuestions = quizQuestions.count
        showingQuizTypeSelection = false
        quizCompleted = false
        
        let duration = Date().timeIntervalSince(startTime)
        DiagnosticLogger.shared.logPerformance("Quiz generation", duration: duration)
        DiagnosticLogger.shared.logQuizStarted(psalmNumber: psalm.number, quizType: selectedQuizType.displayName)
    }
    
    private func handleAnswer(correct: Bool) {
        if correct {
            currentScore += 1
        }
        
        // Log the question answer
        if currentQuizIndex < quizQuestions.count {
            let question = quizQuestions[currentQuizIndex]
            DiagnosticLogger.shared.logQuestionAnswered(
                questionType: question.type.displayName,
                correct: correct,
                verseNumber: question.verseNumber
            )
        }
        
        if currentQuizIndex < quizQuestions.count - 1 {
            currentQuizIndex += 1
        } else {
            quizCompleted = true
            DiagnosticLogger.shared.logQuizCompleted(
                psalmNumber: psalm.number,
                quizType: selectedQuizType.displayName,
                score: currentScore,
                totalQuestions: totalQuestions
            )
            saveProgress()
        }
    }
    
    private func generateQuizQuestions() -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        switch selectedQuizType {
        case .fillInTheBlank:
            questions = generateFillInTheBlankQuestions()
        case .multipleChoice:
            questions = generateMultipleChoiceQuestions()
        case .wordOrder:
            questions = generateWordOrderQuestions()
        case .verseCompletion:
            questions = generateVerseCompletionQuestions()
        case .mixed:
            questions = generateMixedQuestions()
        }
        
        return questions.shuffled()
    }
    
    private func generateFillInTheBlankQuestions() -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        for verse in verses {
            let words = verse.text.components(separatedBy: " ")
            if words.count > 3 {
                let randomIndex = Int.random(in: 0..<words.count)
                let correctWord = words[randomIndex]
                var displayWords = words
                displayWords[randomIndex] = "_____"
                
                // Generate wrong options from other verses
                var wrongOptions: [String] = []
                for otherVerse in verses where otherVerse.number != verse.number {
                    let otherWords = otherVerse.text.components(separatedBy: " ")
                    if let randomWord = otherWords.randomElement() {
                        wrongOptions.append(randomWord)
                    }
                }
                
                // Add some common words as additional wrong options
                let commonWords = ["the", "and", "of", "in", "to", "for", "with", "by", "from", "that", "this", "is", "are", "was", "were", "be", "been", "have", "has", "had", "will", "shall", "can", "may", "must", "should", "would", "could", "might"]
                for word in commonWords.shuffled().prefix(2) {
                    if !wrongOptions.contains(word) && word != correctWord {
                        wrongOptions.append(word)
                    }
                }
                
                let options = [correctWord] + Array(wrongOptions.prefix(3))
                
                let question = QuizQuestion(
                    type: .fillInTheBlank,
                    question: "Complete the verse: \(displayWords.joined(separator: " "))",
                    correctAnswer: correctWord,
                    options: options.shuffled(),
                    verseNumber: verse.number
                )
                questions.append(question)
            }
        }
        
        return questions
    }
    
    private func generateMultipleChoiceQuestions() -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        for verse in verses {
            let words = verse.text.components(separatedBy: " ")
            if words.count > 2 {
                let randomIndex = Int.random(in: 0..<words.count)
                let correctWord = words[randomIndex]
                
                // Generate wrong options from other verses
                var wrongOptions: [String] = []
                for otherVerse in verses where otherVerse.number != verse.number {
                    let otherWords = otherVerse.text.components(separatedBy: " ")
                    if let randomWord = otherWords.randomElement() {
                        wrongOptions.append(randomWord)
                    }
                }
                
                let options = [correctWord] + Array(wrongOptions.prefix(3))
                
                let question = QuizQuestion(
                    type: .multipleChoice,
                    question: "Which word completes this verse: \(words.enumerated().map { $0.offset == randomIndex ? "_____" : $0.element }.joined(separator: " "))",
                    correctAnswer: correctWord,
                    options: options.shuffled(),
                    verseNumber: verse.number
                )
                questions.append(question)
            }
        }
        
        return questions
    }
    
    private func generateWordOrderQuestions() -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        for verse in verses {
            let words = verse.text.components(separatedBy: " ")
            if words.count > 4 {
                // Use original words without numbering for more flexible validation
                let shuffledWords = words.shuffled()
                
                let question = QuizQuestion(
                    type: .wordOrder,
                    question: "Arrange these words in the correct order for verse \(verse.number):",
                    correctAnswer: words.joined(separator: " "),
                    options: shuffledWords,
                    verseNumber: verse.number
                )
                questions.append(question)
            }
        }
        
        return questions
    }
    
    private func generateVerseCompletionQuestions() -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        for verse in verses {
            let words = verse.text.components(separatedBy: " ")
            if words.count > 5 {
                let halfLength = words.count / 2
                let firstHalf = words[0..<halfLength].joined(separator: " ")
                let secondHalf = words[halfLength...].joined(separator: " ")
                
                let question = QuizQuestion(
                    type: .verseCompletion,
                    question: "Complete verse \(verse.number): \(firstHalf) _____",
                    correctAnswer: secondHalf,
                    options: [secondHalf],
                    verseNumber: verse.number
                )
                questions.append(question)
            }
        }
        
        return questions
    }
    
    private func generateMixedQuestions() -> [QuizQuestion] {
        let fillInQuestions = generateFillInTheBlankQuestions()
        let multipleChoiceQuestions = generateMultipleChoiceQuestions()
        let wordOrderQuestions = generateWordOrderQuestions()
        let verseCompletionQuestions = generateVerseCompletionQuestions()
        
        var allQuestions: [QuizQuestion] = []
        allQuestions.append(contentsOf: fillInQuestions.prefix(3))
        allQuestions.append(contentsOf: multipleChoiceQuestions.prefix(3))
        allQuestions.append(contentsOf: wordOrderQuestions.prefix(2))
        allQuestions.append(contentsOf: verseCompletionQuestions.prefix(2))
        
        return allQuestions
    }
    
    private func saveProgress() {
        guard let user = user else { return }
        
        // Find or create progress record
        let allProgress = try? modelContext.fetch(FetchDescriptor<Progress>())
        let existingProgress = allProgress?.first(where: { $0.psalm?.id == psalm.id && $0.user?.id == user.id && $0.translation?.id == translation.id })
        
        if let progressObj = existingProgress {
            progressObj.overallProgress = max(progressObj.overallProgress, progress)
            progressObj.lastPracticed = Date()
        } else {
            let newProgress = Progress(psalm: psalm, user: user, translation: translation)
            newProgress.overallProgress = progress
            modelContext.insert(newProgress)
        }
        
        try? modelContext.save()
    }
}

enum QuizType: CaseIterable {
    case fillInTheBlank
    case multipleChoice
    case wordOrder
    case verseCompletion
    case mixed
    
    var displayName: String {
        switch self {
        case .fillInTheBlank: return "Fill in the\nBlank"
        case .multipleChoice: return "Multiple\nChoice"
        case .wordOrder: return "Word\nOrder"
        case .verseCompletion: return "Verse\nCompletion"
        case .mixed: return "Mixed\nQuiz"
        }
    }
    
    var description: String {
        switch self {
        case .fillInTheBlank: return "Complete missing words"
        case .multipleChoice: return "Choose correct answers"
        case .wordOrder: return "Arrange words correctly"
        case .verseCompletion: return "Complete verse endings"
        case .mixed: return "Variety of question types"
        }
    }
    
    var iconName: String {
        switch self {
        case .fillInTheBlank: return "textformat.abc"
        case .multipleChoice: return "checkmark.circle"
        case .wordOrder: return "list.number"
        case .verseCompletion: return "text.quote"
        case .mixed: return "square.grid.3x3"
        }
    }
}

struct QuizQuestion: Equatable {
    let type: QuizType
    let question: String
    let correctAnswer: String
    let options: [String]
    let verseNumber: Int
    
    static func == (lhs: QuizQuestion, rhs: QuizQuestion) -> Bool {
        return lhs.type == rhs.type &&
               lhs.question == rhs.question &&
               lhs.correctAnswer == rhs.correctAnswer &&
               lhs.options == rhs.options &&
               lhs.verseNumber == rhs.verseNumber
    }
}

struct QuizQuestionView: View {
    let question: QuizQuestion
    let onAnswer: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text(question.question)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            if question.type == .wordOrder {
                WordOrderQuizView(question: question, onAnswer: onAnswer)
            } else {
                MultipleChoiceQuizView(question: question, onAnswer: onAnswer)
            }
        }
    }
}

struct MultipleChoiceQuizView: View {
    let question: QuizQuestion
    let onAnswer: (Bool) -> Void
    
    @State private var selectedAnswer = ""
    @State private var showingResult = false
    @State private var isCorrect = false
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(question.options, id: \.self) { option in
                Button(action: {
                    selectedAnswer = option
                    isCorrect = option == question.correctAnswer
                    showingResult = true
                }) {
                    Text(option)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedAnswer == option ? Color.blue : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(selectedAnswer != "")
            }
        }
        .alert(isCorrect ? "Correct!" : "Incorrect", isPresented: $showingResult) {
            Button("Continue") {
                selectedAnswer = ""
                showingResult = false
                onAnswer(isCorrect)
            }
        } message: {
            Text(isCorrect ? "Great job!" : "The correct answer was: \(question.correctAnswer)")
        }
    }
}

struct WordOrderQuizView: View {
    let question: QuizQuestion
    let onAnswer: (Bool) -> Void
    
    @State private var selectedWords: [(id: Int, word: String)] = []
    @State private var availableWords: [(id: Int, word: String)] = []
    @State private var showingResult = false
    @State private var isCorrect = false
    
    private var selectedWordsSection: some View {
        VStack(spacing: 8) {
            Text("Your answer:")
                .font(.headline)
                .foregroundColor(.primary)
            
            if selectedWords.isEmpty {
                Text("Tap words below to build your answer")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    ForEach(selectedWords, id: \.id) { item in
                        Button(action: {
                            // Remove word from selected and put back in available
                            if let index = selectedWords.firstIndex(where: { $0.id == item.id }) {
                                availableWords.append(item)
                                selectedWords.remove(at: index)
                            }
                        }) {
                            HStack {
                                Text(item.word)
                                    .font(.body)
                                    .fontWeight(.medium)
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var availableWordsSection: some View {
        VStack(spacing: 8) {
            Text("Available words:")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(availableWords, id: \.id) { item in
                    Button(action: {
                        if let index = availableWords.firstIndex(where: { $0.id == item.id }) {
                            selectedWords.append(item)
                            availableWords.remove(at: index)
                        }
                    }) {
                        Text(item.word)
                            .font(.body)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 6) {
            Button("Clear All") {
                availableWords.append(contentsOf: selectedWords)
                selectedWords.removeAll()
            }
            .buttonStyle(.bordered)
            .font(.body)
            .frame(maxWidth: .infinity)
            
            if !selectedWords.isEmpty {
                Text("Tap any word above to remove it")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 4)
    }
    
    private var correctAnswerSection: some View {
        VStack(spacing: 6) {
            Text("Correct answer:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(question.correctAnswer)
                .font(.body)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area - always visible
            ScrollView {
                VStack(spacing: 6) {
                    selectedWordsSection
                    availableWordsSection
                    actionButtonsSection
                    
                    // Extra padding to ensure submit button is visible
                    Spacer(minLength: 20)
                }
                .padding(.vertical, 4)
                .padding(.bottom, 8)
            }
            .frame(maxHeight: showingResult ? .infinity : .infinity)
            
            // Always visible submit button section
            VStack(spacing: 8) {
                Divider()
                
                Button("Check Answer") {
                    let userAnswer = selectedWords.map { $0.word }.joined(separator: " ")
                    let isCorrect = validateWordOrderAnswer(userAnswer: userAnswer, correctAnswer: question.correctAnswer)
                    showingResult = true
                    self.isCorrect = isCorrect
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .disabled(selectedWords.isEmpty)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .background(Color(.systemBackground))
            
            // Feedback section - only appears when needed
            if showingResult {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? .green : .red)
                            .font(.title2)
                        
                        Text(isCorrect ? "Correct!" : "Incorrect")
                            .font(.headline)
                            .foregroundColor(isCorrect ? .green : .red)
                        
                        Spacer()
                    }
                    
                    if !isCorrect {
                        Text("The correct order was:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ScrollView {
                            Text(question.correctAnswer)
                                .font(.body)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .frame(maxHeight: 100)
                    }
                    
                    Button("Continue") {
                        showingResult = false
                        onAnswer(isCorrect)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 10)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: showingResult)
            }
        }
        .onAppear {
            resetWords()
        }
        .onChange(of: question) { _, _ in
            resetWords()
        }
    }
    
    private func resetWords() {
        selectedWords.removeAll()
        availableWords = question.options.enumerated().map { (id: $0.offset, word: $0.element) }
    }
    
    private func validateWordOrderAnswer(userAnswer: String, correctAnswer: String) -> Bool {
        let userWords = userAnswer.lowercased().components(separatedBy: " ")
        let correctWords = correctAnswer.lowercased().components(separatedBy: " ")
        
        // If exact match, return true
        if userAnswer.lowercased() == correctAnswer.lowercased() {
            return true
        }
        
        // For repeated words, we need to check if they appear in the correct syntactical context
        // Create a mapping of words to their counts
        var correctWordCounts: [String: Int] = [:]
        var userWordCounts: [String: Int] = [:]
        
        // Count words in correct answer
        for word in correctWords {
            correctWordCounts[word, default: 0] += 1
        }
        
        // Count words in user answer
        for word in userWords {
            userWordCounts[word, default: 0] += 1
        }
        
        // Check if word counts match (this ensures repeated words are used correctly)
        for (word, correctCount) in correctWordCounts {
            let userCount = userWordCounts[word, default: 0]
            if userCount != correctCount {
                return false
            }
        }
        
        // Now check if the words are in a reasonable order
        // We'll use a simplified approach: check if the sequence makes sense
        var userIndex = 0
        var correctIndex = 0
        
        while userIndex < userWords.count && correctIndex < correctWords.count {
            let userWord = userWords[userIndex]
            let correctWord = correctWords[correctIndex]
            
            // If words match exactly, move both indices
            if userWord == correctWord {
                userIndex += 1
                correctIndex += 1
                continue
            }
            
            // If user word doesn't match current correct word, check if it matches a later correct word
            // This allows for some flexibility in repeated word positioning
            var foundMatch = false
            var searchIndex = correctIndex + 1
            
            while searchIndex < correctWords.count {
                let searchCorrectWord = correctWords[searchIndex]
                
                if userWord == searchCorrectWord {
                    // Found a match later in the correct sequence
                    // This is acceptable for repeated words
                    foundMatch = true
                    break
                }
                searchIndex += 1
            }
            
            if foundMatch {
                // Skip this position in correct answer and continue with user's next word
                correctIndex += 1
                continue
            }
            
            // If no match found, the answer is incorrect
            return false
        }
        
        // Check if we've processed all words
        return userIndex == userWords.count && correctIndex == correctWords.count
    }
}