import UIKit

/**
 - Represents a single option/wedge on the wheel.
 - Each choice gets a unique ID automatically via UUID().
 */
struct Choice {
    let id = UUID()
    var text: String
}

/**
 - Central data store shared across every screen in the app.
 - Uses the Singleton pattern (`AppState.shared`) so all View Controllers read and update the exact same data.
 */
class AppState {
    // The single shared instance of AppState
    static let shared = AppState()
    
    // The user's question (e.g., "Where should we eat?")
    var question: String = ""
    
    // The list of options that will appear as slices on the wheel
    var choices: [Choice] = [
        Choice(text: "Option 1"),
        Choice(text: "Option 2"),
        Choice(text: "Option 3")
    ]
    
    // Stores whichever Choice won after the wheel finishes spinning
    var selectedChoice: Choice? = nil
    
    // Tracks whether vibration feedback is turned on or off in Settings
    var hapticsEnabled: Bool = true
    
    // Private initializer prevents other files from accidentally creating duplicate AppStates
    private init() {}
}
