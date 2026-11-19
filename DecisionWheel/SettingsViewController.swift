import UIKit

/**
 - Settings Tab: Allows the user to select haptic vibration intensity (Off, Light, Medium, Heavy)
   and persists the preference using WheelStorageManager (UserDefaults).
 */
class SettingsViewController: UIViewController {
    
    private let intensities: [HapticIntensity] = HapticIntensity.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = "Haptic Feedback Intensity"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let segmentedControl = UISegmentedControl(items: intensities.map { $0.rawValue })
        let savedIntensity = WheelStorageManager.shared.loadHapticIntensity()
        segmentedControl.selectedSegmentIndex = intensities.firstIndex(of: savedIntensity) ?? 2
        segmentedControl.addTarget(self, action: #selector(intensityChanged(_:)), for: .valueChanged)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, segmentedControl])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    /// Persists the chosen HapticIntensity in UserDefaults and plays a preview vibration
    @objc private func intensityChanged(_ sender: UISegmentedControl) {
        let selected = intensities[sender.selectedSegmentIndex]
        WheelStorageManager.shared.saveHapticIntensity(selected)
        
        switch selected {
        case .off:
            break
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}
