import SwiftUI
import SwiftData

struct MemoryAssessmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var currentTestIndex = 0
    @State private var testResults: [TestType: Double] = [:]
    @State private var showingResults = false
    @State private var userName = ""
    @State private var showingNameInput = true
    
    private let tests: [TestType] = TestType.allCases
    
    var body: some View {
        VStack {
            if showingNameInput {
                nameInputView
            } else if showingResults {
                assessmentResultsView
            } else {
                testView
            }
        }
#if os(iOS)
        .navigationTitle("Memory Assessment")
        .navigationBarTitleDisplayMode(.large)
#else
        .navigationTitle("Memory Assessment")
#endif
    }
    
    private var nameInputView: some View {
        VStack(spacing: 30) {
            Text("Welcome to PsalmMem")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Let's start by understanding your memory strengths and weaknesses through a series of quick tests.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("What's your name?")
                    .font(.headline)
                
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            
            Button("Start Assessment") {
                showingNameInput = false
            }
            .buttonStyle(.borderedProminent)
            .disabled(userName.isEmpty)
        }
        .padding()
    }
    
    private var testView: some View {
        VStack(spacing: 20) {
            ProgressView(value: Double(currentTestIndex), total: Double(tests.count))
                .padding(.horizontal)
            
            Text("Test \(currentTestIndex + 1) of \(tests.count)")
                .font(.headline)
            
            Text(tests[currentTestIndex].rawValue)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            switch tests[currentTestIndex] {
            case .visual:
                VisualMemoryTest { score in
                    testResults[.visual] = score
                    nextTest()
                }
            case .auditory:
                AuditoryMemoryTest { score in
                    testResults[.auditory] = score
                    nextTest()
                }
            case .pattern:
                PatternMemoryTest { score in
                    testResults[.pattern] = score
                    nextTest()
                }
            case .sequence:
                SequenceMemoryTest { score in
                    testResults[.sequence] = score
                    nextTest()
                }
            case .spatial:
                SpatialMemoryTest { score in
                    testResults[.spatial] = score
                    nextTest()
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var assessmentResultsView: some View {
        VStack(spacing: 20) {
            Text("Assessment Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Based on your performance, here are your memory strengths and recommendations:")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(Array(testResults.keys.sorted(by: { testResults[$0]! > testResults[$1]! })), id: \.self) { testType in
                        HStack {
                            Text(testType.rawValue)
                                .font(.headline)
                            Spacer()
                            Text("\(Int(testResults[testType]! * 100))%")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            
            Button("Continue to Psalms") {
                saveUserAndResults()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
    
    private func nextTest() {
        if currentTestIndex < tests.count - 1 {
            currentTestIndex += 1
        } else {
            showingResults = true
        }
    }
    
    private func saveUserAndResults() {
        let user = User(name: userName)
        
        // Determine strengths and weaknesses based on test results
        let sortedResults = testResults.sorted { $0.value > $1.value }
        let strengths = Array(sortedResults.prefix(2)).map { MemoryStrength(rawValue: $0.key.rawValue.replacingOccurrences(of: " Memory", with: "")) ?? .visual }
        let weaknesses = Array(sortedResults.suffix(2)).map { MemoryWeakness(rawValue: $0.key.rawValue.replacingOccurrences(of: " Memory", with: "")) ?? .visual }
        
        user.memoryStrengths = strengths
        user.memoryWeaknesses = weaknesses
        
        // Save test results
        for (testType, score) in testResults {
            let test = MemoryTest(type: testType, score: score, user: user)
            modelContext.insert(test)
        }
        
        modelContext.insert(user)
        try? modelContext.save()
        
        // Post notification that assessment is completed
        NotificationCenter.default.post(name: .assessmentCompleted, object: nil)
    }
}

// MARK: - Memory Test Components

struct VisualMemoryTest: View {
    let onComplete: (Double) -> Void
    @State private var showingPattern = false
    @State private var userPattern: [Int] = []
    @State private var correctPattern = [1, 3, 2, 4]
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Remember the pattern shown below")
                .font(.headline)
            
            if showingPattern {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                    ForEach(1...4, id: \.self) { number in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(correctPattern[currentStep] == number ? Color.blue : Color.gray)
                            .frame(height: 60)
                            .overlay(
                                Text("\(number)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                    ForEach(1...4, id: \.self) { number in
                        Button(action: {
                            userPattern.append(number)
                            if userPattern.count == correctPattern.count {
                                let score = calculateScore()
                                onComplete(score)
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                                .frame(height: 60)
                                .overlay(
                                    Text("\(number)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            startPattern()
        }
    }
    
    private func startPattern() {
        showingPattern = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if currentStep < correctPattern.count - 1 {
                currentStep += 1
            } else {
                timer.invalidate()
                showingPattern = false
            }
        }
    }
    
    private func calculateScore() -> Double {
        var correct = 0
        for i in 0..<min(userPattern.count, correctPattern.count) {
            if userPattern[i] == correctPattern[i] {
                correct += 1
            }
        }
        return Double(correct) / Double(correctPattern.count)
    }
}

struct AuditoryMemoryTest: View {
    let onComplete: (Double) -> Void
    @State private var showingInstructions = true
    @State private var userInput = ""
    @State private var correctSequence = "3-7-1-9"
    
    var body: some View {
        VStack(spacing: 20) {
            if showingInstructions {
                Text("Listen to the number sequence and repeat it")
                    .font(.headline)
                
                Button("Play Sequence") {
                    // In a real app, this would play audio
                    showingInstructions = false
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("Enter the sequence you heard:")
                    .font(.headline)
                
                TextField("e.g., 3-7-1-9", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Submit") {
                    let score = userInput == correctSequence ? 1.0 : 0.0
                    onComplete(score)
                }
                .buttonStyle(.borderedProminent)
                .disabled(userInput.isEmpty)
            }
        }
        .padding()
    }
}

struct PatternMemoryTest: View {
    let onComplete: (Double) -> Void
    @State private var showingPattern = false
    @State private var userPattern: [Int] = []
    @State private var correctPattern = [1, 2, 4, 8, 16]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Find the pattern in this sequence")
                .font(.headline)
            
            if showingPattern {
                HStack {
                    ForEach(correctPattern, id: \.self) { number in
                        Text("\(number)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                Text("What comes next?")
                    .font(.headline)
                
                HStack {
                    ForEach([16, 32, 64, 128], id: \.self) { option in
                        Button(action: {
                            let score = option == 32 ? 1.0 : 0.0
                            onComplete(score)
                        }) {
                            Text("\(option)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            } else {
                Button("Show Pattern") {
                    showingPattern = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

struct SequenceMemoryTest: View {
    let onComplete: (Double) -> Void
    @State private var showingSequence = false
    @State private var userSequence: [String] = []
    @State private var correctSequence = ["Red", "Blue", "Green", "Yellow"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Remember the color sequence")
                .font(.headline)
            
            if showingSequence {
                VStack {
                    ForEach(correctSequence, id: \.self) { color in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorFromString(color))
                            .frame(height: 40)
                            .padding(.horizontal)
                    }
                }
                .padding()
                
                Text("Repeat the sequence:")
                    .font(.headline)
                
                HStack {
                    ForEach(["Red", "Blue", "Green", "Yellow"], id: \.self) { color in
                        Button(action: {
                            userSequence.append(color)
                            if userSequence.count == correctSequence.count {
                                let score = calculateScore()
                                onComplete(score)
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorFromString(color))
                                .frame(width: 60, height: 40)
                        }
                    }
                }
            } else {
                Button("Show Sequence") {
                    showingSequence = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private func colorFromString(_ color: String) -> Color {
        switch color {
        case "Red": return .red
        case "Blue": return .blue
        case "Green": return .green
        case "Yellow": return .yellow
        default: return .gray
        }
    }
    
    private func calculateScore() -> Double {
        var correct = 0
        for i in 0..<min(userSequence.count, correctSequence.count) {
            if userSequence[i] == correctSequence[i] {
                correct += 1
            }
        }
        return Double(correct) / Double(correctSequence.count)
    }
}

struct SpatialMemoryTest: View {
    let onComplete: (Double) -> Void
    @State private var showingGrid = false
    @State private var userClicks: Set<Int> = []
    @State private var correctPositions: Set<Int> = [1, 5, 9, 13]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Remember the highlighted positions")
                .font(.headline)
            
            if showingGrid {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(1...16, id: \.self) { position in
                        Button(action: {
                            if userClicks.contains(position) {
                                userClicks.remove(position)
                            } else {
                                userClicks.insert(position)
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(correctPositions.contains(position) ? Color.blue : Color.gray)
                                .frame(height: 50)
                        }
                    }
                }
                .padding()
                
                Button("Submit") {
                    let score = calculateScore()
                    onComplete(score)
                }
                .buttonStyle(.borderedProminent)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(1...16, id: \.self) { position in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(correctPositions.contains(position) ? Color.blue : Color.gray)
                            .frame(height: 50)
                    }
                }
                .padding()
                
                Button("Show Grid") {
                    showingGrid = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private func calculateScore() -> Double {
        let correct = userClicks.intersection(correctPositions).count
        let incorrect = userClicks.subtracting(correctPositions).count
        let missed = correctPositions.subtracting(userClicks).count
        
        let totalCorrect = correct
        let totalIncorrect = incorrect + missed
        
        return totalIncorrect == 0 ? 1.0 : Double(totalCorrect) / Double(totalCorrect + totalIncorrect)
    }
} 