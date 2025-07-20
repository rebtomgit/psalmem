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
                        if randomWord != correctWord && !wrongOptions.contains(randomWord) {
                            wrongOptions.append(randomWord)
                        }
                    }
                }
                
                // Add contextually similar words as additional wrong options
                let similarWords = ["the", "his", "her", "their", "our", "my", "your", "its", "this", "that", "these", "those", "a", "an", "some", "any", "all", "each", "every", "many", "few", "several", "both", "either", "neither"]
                for word in similarWords.shuffled() {
                    if word != correctWord && !wrongOptions.contains(word) && wrongOptions.count < 3 {
                        wrongOptions.append(word)
                    }
                }
                
                // Ensure we have exactly 3 unique wrong options
                while wrongOptions.count < 3 {
                    let fallbackWords = ["and", "of", "in", "to", "for", "with", "by", "from", "is", "are", "was", "were", "be", "been", "have", "has", "had"]
                    for word in fallbackWords.shuffled() {
                        if word != correctWord && !wrongOptions.contains(word) && wrongOptions.count < 3 {
                            wrongOptions.append(word)
                            break
                        }
                    }
                    // Prevent infinite loop
                    if wrongOptions.count < 3 {
                        wrongOptions.append("the")
                        break
                    }
                }
                
                let options = [correctWord] + wrongOptions
                
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
        
        // Question type 1: Word meaning/context questions
        for verse in verses {
            let words = verse.text.components(separatedBy: " ")
            if words.count > 3 {
                // Find meaningful words (not articles, prepositions, etc.)
                let meaningfulWords = words.filter { word in
                    let cleanWord = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
                    return cleanWord.count > 2 && !["the", "and", "of", "in", "to", "for", "with", "by", "from", "a", "an", "is", "are", "was", "were", "be", "been", "have", "has", "had"].contains(cleanWord)
                }
                
                if let targetWord = meaningfulWords.randomElement() {
                    let options = generateContextualOptions(correctWord: targetWord, allVerses: verses)
                    // Ensure no duplicates
                    let uniqueOptions = Array(Set(options))
                    if uniqueOptions.count >= 4 {
                        let question = QuizQuestion(
                            type: .multipleChoice,
                            question: "What is the main action or subject in verse \(verse.number)?",
                            correctAnswer: targetWord,
                            options: uniqueOptions.shuffled(),
                            verseNumber: verse.number
                        )
                        questions.append(question)
                    }
                }
            }
        }
        
        // Question type 2: Verse identification questions
        for verse in verses {
            let otherVerses = verses.filter { $0.number != verse.number }
            if let otherVerse = otherVerses.randomElement() {
                // Generate unique wrong options
                var wrongOptions: [String] = []
                wrongOptions.append("Verse \(otherVerse.number)")
                
                // Add more unique wrong options
                let allVerseNumbers = Set(verses.map { $0.number })
                let availableNumbers = Set(1...20).subtracting(allVerseNumbers)
                
                // Add 2 more unique wrong options
                for _ in 0..<2 {
                    if let randomNumber = availableNumbers.randomElement() {
                        wrongOptions.append("Verse \(randomNumber)")
                    } else {
                        // Fallback if we run out of numbers
                        let fallbackNumber = Int.random(in: 21...30)
                        wrongOptions.append("Verse \(fallbackNumber)")
                    }
                }
                
                let options = ["Verse \(verse.number)"] + wrongOptions
                
                let question = QuizQuestion(
                    type: .multipleChoice,
                    question: "Which verse contains this phrase: \"\(verse.text.prefix(50))...\"?",
                    correctAnswer: "Verse \(verse.number)",
                    options: options.shuffled(),
                    verseNumber: verse.number
                )
                questions.append(question)
            }
        }
        
        // Question type 3: Dynamic theme questions based on psalm content
        questions.append(contentsOf: generateDynamicThemeQuestions())
        
        return questions
    }
    
    private func generateContextualOptions(correctWord: String, allVerses: [Verse]) -> [String] {
        var options = [correctWord]
        
        // Get other meaningful words from different verses
        for verse in allVerses {
            let words = verse.text.components(separatedBy: " ")
            let meaningfulWords = words.filter { word in
                let cleanWord = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
                return cleanWord.count > 2 && cleanWord != correctWord.lowercased() && !["the", "and", "of", "in", "to", "for", "with", "by", "from", "a", "an", "is", "are", "was", "were", "be", "been", "have", "has", "had"].contains(cleanWord)
            }
            
            if let word = meaningfulWords.randomElement() {
                options.append(word)
            }
        }
        
        // Add some thematic words if we don't have enough options
        let thematicWords = ["praise", "worship", "pray", "sing", "bless", "thank", "love", "trust", "hope", "faith", "grace", "mercy", "peace", "joy", "light", "life", "truth", "wisdom", "strength", "power"]
        
        while options.count < 4 {
            if let word = thematicWords.randomElement() {
                if !options.contains(word) {
                    options.append(word)
                }
            }
        }
        
        return options.shuffled()
    }
    
    private func generateDynamicThemeQuestions() -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        // Analyze the psalm content to determine appropriate themes
        let allText = verses.map { $0.text }.joined(separator: " ").lowercased()
        
        // Determine the main focus based on content analysis
        let focus = determinePsalmFocus(allText: allText)
        let theme = determinePsalmTheme(allText: allText)
        let emotion = determinePsalmEmotion(allText: allText)
        
        // Create questions based on actual content
        if let focus = focus {
            let uniqueOptions = Array(Set(focus.options))
            if uniqueOptions.count >= 4 {
                let question = QuizQuestion(
                    type: .multipleChoice,
                    question: "Who is the main focus of this psalm?",
                    correctAnswer: focus.correct,
                    options: uniqueOptions.shuffled(),
                    verseNumber: 1,
                    explanation: focus.explanation
                )
                questions.append(question)
            }
        }
        
        if let theme = theme {
            let uniqueOptions = Array(Set(theme.options))
            if uniqueOptions.count >= 4 {
                let question = QuizQuestion(
                    type: .multipleChoice,
                    question: "What is the main theme of this psalm?",
                    correctAnswer: theme.correct,
                    options: uniqueOptions.shuffled(),
                    verseNumber: 1,
                    explanation: theme.explanation
                )
                questions.append(question)
            }
        }
        
        if let emotion = emotion {
            let uniqueOptions = Array(Set(emotion.options))
            if uniqueOptions.count >= 4 {
                let question = QuizQuestion(
                    type: .multipleChoice,
                    question: "What emotion or attitude does this psalm express?",
                    correctAnswer: emotion.correct,
                    options: uniqueOptions.shuffled(),
                    verseNumber: 1,
                    explanation: emotion.explanation
                )
                questions.append(question)
            }
        }
        
        return questions
    }
    
    private func determinePsalmFocus(allText: String) -> (correct: String, options: [String], explanation: String)? {
        // Analyze text to determine the main focus
        if allText.contains("blessed") && allText.contains("righteous") && allText.contains("wicked") {
            return ("The righteous person", ["The righteous person", "God", "The wicked person", "Nature"], 
                   "Psalm 1 focuses on contrasting the righteous person (who delights in God's law) with the wicked person (who follows the counsel of the ungodly). While God is mentioned, the main focus is on human choices and their consequences.")
        } else if allText.contains("praise") || allText.contains("worship") {
            return ("God", ["God", "The psalmist", "Others", "Creation"], 
                   "This psalm is primarily focused on praising and worshiping God, with God as the central subject of the psalmist's adoration.")
        } else if allText.contains("help") || allText.contains("deliver") {
            return ("God", ["God", "The psalmist", "Enemies", "Others"], 
                   "This psalm is a prayer for help and deliverance, with God as the one being appealed to for assistance.")
        } else if allText.contains("king") || allText.contains("anointed") {
            return ("The king/Messiah", ["The king/Messiah", "God", "The people", "Enemies"], 
                   "This psalm focuses on the king or Messiah, with God's anointed one as the central figure.")
        }
        
        return nil
    }
    
    private func determinePsalmTheme(allText: String) -> (correct: String, options: [String], explanation: String)? {
        // Analyze text to determine the main theme
        if allText.contains("blessed") && allText.contains("righteous") {
            return ("Righteous living", ["Righteous living", "Praise", "Prayer", "Wisdom"], 
                   "Psalm 1's main theme is righteous living - it contrasts the blessed life of the righteous person who meditates on God's law with the way of the wicked.")
        } else if allText.contains("praise") || allText.contains("worship") {
            return ("Praise and worship", ["Praise and worship", "Prayer", "Thanksgiving", "Joy"], 
                   "This psalm's main theme is praise and worship, focusing on exalting and glorifying God.")
        } else if allText.contains("help") || allText.contains("deliver") || allText.contains("save") {
            return ("Prayer for help", ["Prayer for help", "Praise", "Thanksgiving", "Trust"], 
                   "This psalm's main theme is prayer for help, as the psalmist cries out to God for deliverance and assistance.")
        } else if allText.contains("king") || allText.contains("anointed") {
            return ("Royal/Messianic", ["Royal/Messianic", "Praise", "Prayer", "Prophecy"], 
                   "This psalm's main theme is royal or messianic, focusing on God's anointed king and his reign.")
        }
        
        return nil
    }
    
    private func determinePsalmEmotion(allText: String) -> (correct: String, options: [String], explanation: String)? {
        // Analyze text to determine the main emotion
        if allText.contains("blessed") && allText.contains("delight") {
            return ("Joy and contentment", ["Joy and contentment", "Sadness", "Anger", "Fear"], 
                   "Psalm 1 expresses joy and contentment, as the righteous person is described as 'blessed' and finds delight in God's law.")
        } else if allText.contains("praise") || allText.contains("rejoice") {
            return ("Joy and praise", ["Joy and praise", "Sadness", "Anger", "Fear"], 
                   "This psalm expresses joy and praise, with the psalmist rejoicing and exalting God.")
        } else if allText.contains("help") || allText.contains("deliver") {
            return ("Trust and hope", ["Trust and hope", "Fear", "Anger", "Despair"], 
                   "This psalm expresses trust and hope, as the psalmist confidently looks to God for help and deliverance.")
        } else if allText.contains("enemies") || allText.contains("wicked") {
            return ("Trust in God's justice", ["Trust in God's justice", "Fear", "Anger", "Despair"], 
                   "This psalm expresses trust in God's justice, believing that God will judge the wicked and vindicate the righteous.")
        }
        
        return nil
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
    let explanation: String?
    
    init(type: QuizType, question: String, correctAnswer: String, options: [String], verseNumber: Int, explanation: String? = nil) {
        self.type = type
        self.question = question
        self.correctAnswer = correctAnswer
        self.options = options
        self.verseNumber = verseNumber
        self.explanation = explanation
    }
    
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
            if isCorrect {
                Text("Great job!")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The correct answer was: \(question.correctAnswer)")
                    if let explanation = question.explanation {
                        Text(explanation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
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