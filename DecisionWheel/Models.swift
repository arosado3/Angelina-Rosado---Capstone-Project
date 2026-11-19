import Foundation

// Represents a saved decision wheel that can be stored in UserDefaults
struct SavedWheel: Codable, Equatable {
    let id: UUID
    var question: String
    var choices: [String]
    var lastWinner: String?
    let createdAt: Date

    init(id: UUID = UUID(), question: String, choices: [String], lastWinner: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.question = question
        self.choices = choices
        self.lastWinner = lastWinner
        self.createdAt = createdAt
    }
}

// Tracks the current animation state of the decision wheel
enum WheelSpinState {
    case ready
    case spinning
    case completed
}

// User preference for haptic vibration strength
enum HapticIntensity: String, Codable, CaseIterable {
    case off = "Off"
    case light = "Light"
    case medium = "Medium"
    case heavy = "Heavy"
}
