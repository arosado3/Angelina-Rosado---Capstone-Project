import Foundation

// Handles saving and loading wheels and haptic settings locally using UserDefaults
class WheelStorageManager {
    static let shared = WheelStorageManager()

    private let wheelsKey = "saved_decision_wheels"
    private let hapticKey = "selected_haptic_intensity"

    private init() {}

    // MARK: - Saved Wheels
    func loadWheels() -> [SavedWheel] {
        guard let data = UserDefaults.standard.data(forKey: wheelsKey),
              let decoded = try? JSONDecoder().decode([SavedWheel].self, from: data) else {
            return []
        }
        return decoded
    }

    func saveWheels(_ wheels: [SavedWheel]) {
        if let encoded = try? JSONEncoder().encode(wheels) {
            UserDefaults.standard.set(encoded, forKey: wheelsKey)
        }
    }

    func addWheel(_ wheel: SavedWheel) {
        var wheels = loadWheels()
        wheels.insert(wheel, at: 0)
        saveWheels(wheels)
    }

    func updateWheel(_ updatedWheel: SavedWheel) {
        var wheels = loadWheels()
        if let index = wheels.firstIndex(where: { $0.id == updatedWheel.id }) {
            wheels[index] = updatedWheel
            saveWheels(wheels)
        }
    }

    func deleteWheel(at index: Int) {
        var wheels = loadWheels()
        guard index >= 0 && index < wheels.count else { return }
        wheels.remove(at: index)
        saveWheels(wheels)
    }

    // MARK: - Haptic Intensity
    func loadHapticIntensity() -> HapticIntensity {
        guard let rawValue = UserDefaults.standard.string(forKey: hapticKey),
              let intensity = HapticIntensity(rawValue: rawValue) else {
            return .medium
        }
        return intensity
    }

    func saveHapticIntensity(_ intensity: HapticIntensity) {
        UserDefaults.standard.set(intensity.rawValue, forKey: hapticKey)
    }
}
