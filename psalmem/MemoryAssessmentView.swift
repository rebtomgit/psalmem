import SwiftUI
import SwiftData
import AVFoundation

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
    @State private var testPhase: TestPhase = .instructions
    @State private var userPattern: [Int] = []
    @State private var correctPattern = [1, 3, 2, 4]
    @State private var currentStep = 0
    @State private var showingPattern = false
    
    enum TestPhase {
        case instructions, showing, replicating
    }
    
    var body: some View {
        VStack(spacing: 20) {
            switch testPhase {
            case .instructions:
                VStack(spacing: 15) {
                    Text("Visual Memory Test")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You will see a pattern of highlighted squares appear one by one. Remember the order, then tap the squares in the same sequence.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Start Test") {
                        testPhase = .showing
                        startPattern()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            case .showing:
                VStack(spacing: 15) {
                    Text("Watch the pattern carefully...")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                        ForEach(1...4, id: \.self) { number in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(showingPattern && correctPattern[currentStep] == number ? Color.blue : Color.gray)
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
                }
                
            case .replicating:
                VStack(spacing: 15) {
                    Text("Now tap the squares in the same order:")
                        .font(.headline)
                    
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
                    
                    Text("Your pattern: \(userPattern.map(String.init).joined(separator: "-"))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
    
    private func startPattern() {
        currentStep = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if currentStep < correctPattern.count {
                showingPattern = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingPattern = false
                    currentStep += 1
                }
            } else {
                timer.invalidate()
                testPhase = .replicating
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
    @State private var testPhase: TestPhase = .instructions
    @State private var userInput = ""
    @State private var correctSequence = "3-7-1-9"
    @State private var audioPlayer: AVAudioPlayer?
    
    enum TestPhase {
        case instructions, playing, input
    }
    
    var body: some View {
        VStack(spacing: 20) {
            switch testPhase {
            case .instructions:
                VStack(spacing: 15) {
                    Text("Auditory Memory Test")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You will hear a sequence of numbers. Listen carefully and remember the order, then enter the numbers you heard.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Play Sequence") {
                        testPhase = .playing
                        playSequence()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            case .playing:
                VStack(spacing: 15) {
                    Text("Listening to sequence...")
                        .font(.headline)
                    
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Make sure your device volume is turned on")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
            case .input:
                VStack(spacing: 15) {
                    Text("Enter the sequence you heard:")
                        .font(.headline)
                    
                    TextField("e.g., 3-7-1-9", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
#if os(iOS)
                        .keyboardType(.numberPad)
#endif
                    
                    Text("Format: numbers separated by hyphens")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Submit") {
                        let score = userInput == correctSequence ? 1.0 : 0.0
                        onComplete(score)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(userInput.isEmpty)
                }
            }
        }
        .padding()
    }
    
    private func playSequence() {
        // Create audio sequence using system sounds
        let numbers = correctSequence.components(separatedBy: "-")
        var delay: TimeInterval = 0
        
        for (_, number) in numbers.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Use system sound for number
                AudioServicesPlaySystemSound(1103) // System sound
                
                // Also speak the number
                let utterance = AVSpeechUtterance(string: number)
                utterance.rate = 0.5
                utterance.volume = 1.0
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            }
            delay += 1.5 // 1.5 seconds between numbers
        }
        
        // Switch to input phase after sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            testPhase = .input
        }
    }
}

struct PatternMemoryTest: View {
    let onComplete: (Double) -> Void
    @State private var testPhase: TestPhase = .instructions
    @State private var showingPattern = false
    @State private var correctPattern = [1, 2, 4, 8, 16]
    
    enum TestPhase {
        case instructions, showing, answering
    }
    
    var body: some View {
        VStack(spacing: 20) {
            switch testPhase {
            case .instructions:
                VStack(spacing: 15) {
                    Text("Pattern Recognition Test")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Look at the sequence of numbers and identify the pattern. Then choose what number comes next in the sequence.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Show Sequence") {
                        testPhase = .showing
                        showingPattern = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            case .showing:
                VStack(spacing: 15) {
                    Text("Study this sequence:")
                        .font(.headline)
                    
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
                }
                
            case .answering:
                // This case is handled in the showing case
                EmptyView()
            }
        }
        .padding()
    }
}

struct SequenceMemoryTest: View {
    let onComplete: (Double) -> Void
    @State private var testPhase: TestPhase = .instructions
    @State private var userSequence: [String] = []
    @State private var correctSequence = ["Red", "Blue", "Green", "Yellow"]
    @State private var showingSequence = false
    
    enum TestPhase {
        case instructions, showing, replicating
    }
    
    var body: some View {
        VStack(spacing: 20) {
            switch testPhase {
            case .instructions:
                VStack(spacing: 15) {
                    Text("Color Sequence Memory Test")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You will see a sequence of colored squares appear one by one. Remember the order, then tap the colors in the same sequence.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Start Test") {
                        testPhase = .showing
                        startSequence()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            case .showing:
                VStack(spacing: 15) {
                    Text("Watch the color sequence...")
                        .font(.headline)
                    
                    VStack {
                        ForEach(correctSequence, id: \.self) { color in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(showingSequence ? colorFromString(color) : Color.gray)
                                .frame(height: 40)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                
            case .replicating:
                VStack(spacing: 15) {
                    Text("Now tap the colors in the same order:")
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
                    
                    Text("Your sequence: \(userSequence.joined(separator: "-"))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
    
    private func startSequence() {
        var currentIndex = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if currentIndex < correctSequence.count {
                showingSequence = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingSequence = false
                    currentIndex += 1
                }
            } else {
                timer.invalidate()
                testPhase = .replicating
            }
        }
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
    @State private var testPhase: TestPhase = .instructions
    @State private var userClicks: Set<Int> = []
    @State private var correctPositions: Set<Int> = [1, 5, 9, 13]
    @State private var showingGrid = false
    
    enum TestPhase {
        case instructions, showing, replicating
    }
    
    var body: some View {
        VStack(spacing: 20) {
            switch testPhase {
            case .instructions:
                VStack(spacing: 15) {
                    Text("Spatial Memory Test")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You will see a grid with some squares highlighted. Remember their positions, then tap the same squares when the grid is blank.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Show Grid") {
                        testPhase = .showing
                        showingGrid = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            case .showing:
                VStack(spacing: 15) {
                    Text("Remember the highlighted positions...")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                        ForEach(1...16, id: \.self) { position in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(correctPositions.contains(position) ? Color.blue : Color.gray)
                                .frame(height: 50)
                        }
                    }
                    .padding()
                    
                    Button("Continue") {
                        testPhase = .replicating
                        showingGrid = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            case .replicating:
                VStack(spacing: 15) {
                    Text("Now tap the squares you remember:")
                        .font(.headline)
                    
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
                                    .fill(userClicks.contains(position) ? Color.blue : Color.gray)
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
                }
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