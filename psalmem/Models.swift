import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var name: String
    var memoryStrengths: [MemoryStrength]
    var memoryWeaknesses: [MemoryWeakness]
    var visualMemoryScore: Int
    var auditoryMemoryScore: Int
    var kinestheticMemoryScore: Int
    var createdAt: Date
    var progress: [Progress]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.memoryStrengths = []
        self.memoryWeaknesses = []
        self.visualMemoryScore = 0
        self.auditoryMemoryScore = 0
        self.kinestheticMemoryScore = 0
        self.createdAt = Date()
        self.progress = []
    }
}

@Model
final class Psalm {
    var id: UUID
    var number: Int
    var title: String
    
    init(number: Int, title: String) {
        self.id = UUID()
        self.number = number
        self.title = title
    }
}

@Model
final class Verse {
    var id: UUID
    var number: Int
    var text: String
    var psalm: Psalm?
    var translation: Translation?
    
    init(number: Int, text: String, psalm: Psalm? = nil, translation: Translation? = nil) {
        self.id = UUID()
        self.number = number
        self.text = text
        self.psalm = psalm
        self.translation = translation
    }
}

@Model
final class Translation {
    var id: UUID
    var name: String
    var abbreviation: String
    
    init(name: String, abbreviation: String) {
        self.id = UUID()
        self.name = name
        self.abbreviation = abbreviation
    }
}

@Model
final class MemoryTest {
    var id: UUID
    var type: TestType
    var score: Double
    var completedAt: Date
    var user: User?
    
    init(type: TestType, score: Double, user: User?) {
        self.id = UUID()
        self.type = type
        self.score = score
        self.completedAt = Date()
        self.user = user
    }
}

@Model
final class Progress {
    var id: UUID
    var psalm: Psalm?
    var user: User?
    var translation: Translation?
    var memorizedVersesString: String?
    var overallProgress: Double
    var lastPracticed: Date
    var createdAt: Date
    
    // Enhanced progress tracking
    var totalQuizAttempts: Int
    var correctAnswers: Int
    var totalAnswers: Int
    var streakDays: Int
    var lastStreakDate: Date?
    var bestScore: Double
    var averageScore: Double
    var timeSpentMinutes: Int
    var quizScores: [QuizScore]
    var memorizationLevel: MemorizationLevel
    
    init(psalm: Psalm?, user: User?, translation: Translation?) {
        self.id = UUID()
        self.psalm = psalm
        self.user = user
        self.translation = translation
        self.memorizedVersesString = ""
        self.overallProgress = 0.0
        self.lastPracticed = Date()
        self.createdAt = Date()
        self.totalQuizAttempts = 0
        self.correctAnswers = 0
        self.totalAnswers = 0
        self.streakDays = 0
        self.lastStreakDate = nil
        self.bestScore = 0.0
        self.averageScore = 0.0
        self.timeSpentMinutes = 0
        self.quizScores = []
        self.memorizationLevel = .notStarted
    }
    
    var memorizedVerses: [Int] {
        get {
            guard let memorizedVersesString = memorizedVersesString, !memorizedVersesString.isEmpty else {
                return []
            }
            let result = memorizedVersesString.components(separatedBy: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            return result
        }
        set {
            memorizedVersesString = newValue.map(String.init).joined(separator: ",")
        }
    }
    
    var accuracyPercentage: Double {
        guard totalAnswers > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalAnswers) * 100.0
    }
    
    var isStreakActive: Bool {
        guard let lastStreakDate = lastStreakDate else { return false }
        let daysSinceLastStreak = Calendar.current.dateComponents([.day], from: lastStreakDate, to: Date()).day ?? 0
        return daysSinceLastStreak <= 1
    }
    
    func updateStreak() {
        let today = Date()
        if let lastStreakDate = lastStreakDate {
            let daysSinceLastStreak = Calendar.current.dateComponents([.day], from: lastStreakDate, to: today).day ?? 0
            if daysSinceLastStreak == 1 {
                streakDays += 1
            } else if daysSinceLastStreak > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastStreakDate = today
    }
    
    func addQuizScore(score: Double, timeSpent: Int) {
        let quizScore = QuizScore(score: score, date: Date(), timeSpent: timeSpent)
        quizScores.append(quizScore)
        
        totalQuizAttempts += 1
        timeSpentMinutes += timeSpent
        
        if score > bestScore {
            bestScore = score
        }
        
        // Update average score
        let totalScore = quizScores.reduce(0.0) { $0 + $1.score }
        averageScore = totalScore / Double(quizScores.count)
        
        // Update memorization level based on progress
        updateMemorizationLevel()
    }
    
    private func updateMemorizationLevel() {
        if overallProgress >= 0.9 && averageScore >= 80.0 {
            memorizationLevel = .mastered
        } else if overallProgress >= 0.7 && averageScore >= 60.0 {
            memorizationLevel = .advanced
        } else if overallProgress >= 0.4 && averageScore >= 40.0 {
            memorizationLevel = .intermediate
        } else if overallProgress > 0.0 {
            memorizationLevel = .beginner
        } else {
            memorizationLevel = .notStarted
        }
    }
}

@Model
final class QuizScore {
    var id: UUID
    var score: Double
    var date: Date
    var timeSpent: Int
    var quizType: String
    
    init(score: Double, date: Date, timeSpent: Int, quizType: String = "Mixed") {
        self.id = UUID()
        self.score = score
        self.date = date
        self.timeSpent = timeSpent
        self.quizType = quizType
    }
}

enum MemorizationLevel: String, CaseIterable, Codable {
    case notStarted = "Not Started"
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case mastered = "Mastered"
    
    var color: String {
        switch self {
        case .notStarted: return "gray"
        case .beginner: return "red"
        case .intermediate: return "orange"
        case .advanced: return "blue"
        case .mastered: return "green"
        }
    }
    
    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .beginner: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced: return "3.circle.fill"
        case .mastered: return "star.fill"
        }
    }
}

enum MemoryStrength: String, CaseIterable, Codable {
    case visual = "Visual"
    case auditory = "Auditory"
    case kinesthetic = "Kinesthetic"
    case logical = "Logical"
    case social = "Social"
}

enum MemoryWeakness: String, CaseIterable, Codable {
    case visual = "Visual"
    case auditory = "Auditory"
    case kinesthetic = "Kinesthetic"
    case logical = "Logical"
    case social = "Social"
}

enum TestType: String, CaseIterable, Codable {
    case visual = "Visual Memory"
    case pattern = "Pattern Recognition"
    case sequence = "Sequence Memory"
    case spatial = "Spatial Memory"
} 