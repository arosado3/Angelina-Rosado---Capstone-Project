import UIKit

/**
 - Settings Tab: Allows the user to toggle haptic vibration feedback on or off.
 */
class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "Haptics"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        
        // Toggle switch bound to AppState.shared.hapticsEnabled
        let hapticsSwitch = UISwitch()
        hapticsSwitch.isOn = AppState.shared.hapticsEnabled
        hapticsSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        // Horizontal row placing the "Haptics" label on the left and the switch on the right
        let row = UIStackView(arrangedSubviews: [label, hapticsSwitch])
        row.axis = .horizontal
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(row)
        
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            row.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            row.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    /// Updates AppState whenever the user flips the switch and gives a sample tap if turned on
    @objc private func switchChanged(_ sender: UISwitch) {
        AppState.shared.hapticsEnabled = sender.isOn
        if sender.isOn {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}
