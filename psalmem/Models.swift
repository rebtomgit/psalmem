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
    var memorizedVerses: [Int]
    var overallProgress: Double
    var lastPracticed: Date
    var createdAt: Date
    
    init(psalm: Psalm?, user: User?, translation: Translation?) {
        self.id = UUID()
        self.psalm = psalm
        self.user = user
        self.translation = translation
        self.memorizedVerses = []
        self.overallProgress = 0.0
        self.lastPracticed = Date()
        self.createdAt = Date()
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
    case auditory = "Auditory Memory"
    case pattern = "Pattern Recognition"
    case sequence = "Sequence Memory"
    case spatial = "Spatial Memory"
} 