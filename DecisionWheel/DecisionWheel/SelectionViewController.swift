import UIKit

/**
 - Screen 3 (Overlay): Displays the winning choice with "Try again" and "Clear" buttons.
 */
class SelectionViewController: UIViewController {
    
    // Closure callback that tells DecisionWheelViewController to return to the Main screen
    var onClear: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Semi-transparent dark backdrop so the wheel remains visible behind the card
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        setupCard()
    }
    
    /// Creates the centered pop-up card containing the winning choice and two action buttons
    private func setupCard() {
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Top box displaying the selected choice text
        let choiceLabel = UILabel()
        choiceLabel.text = AppState.shared.selectedChoice?.text ?? "Choice"
        choiceLabel.font = .boldSystemFont(ofSize: 24)
        choiceLabel.textAlignment = .center
        choiceLabel.backgroundColor = .secondarySystemBackground
        choiceLabel.layer.cornerRadius = 8
        choiceLabel.clipsToBounds = true
        
        // Middle button: dismisses the overlay so the user can spin the same wheel again
        let tryAgainButton = UIButton(type: .system)
        tryAgainButton.setTitle("Try again", for: .normal)
        tryAgainButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        tryAgainButton.backgroundColor = .systemBlue
        tryAgainButton.setTitleColor(.white, for: .normal)
        tryAgainButton.layer.cornerRadius = 8
        tryAgainButton.addTarget(self, action: #selector(tryAgainTapped), for: .touchUpInside)
        
        // Bottom button: resets the question and navigates back to the Create Wheel screen
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        clearButton.backgroundColor = .systemGray5
        clearButton.setTitleColor(.label, for: .normal)
        clearButton.layer.cornerRadius = 8
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [choiceLabel, tryAgainButton, clearButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stack)
        view.addSubview(card)
        
        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            choiceLabel.heightAnchor.constraint(equalToConstant: 60),
            tryAgainButton.heightAnchor.constraint(equalToConstant: 48),
            clearButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    /// Clears the selected winner and closes this overlay to return to the wheel
    @objc private func tryAgainTapped() {
        AppState.shared.selectedChoice = nil
        dismiss(animated: true)
    }
    
    /// Resets the app state, closes this overlay, and triggers onClear to return to the first screen
    @objc private func clearTapped() {
        AppState.shared.selectedChoice = nil
        AppState.shared.question = ""
        dismiss(animated: true) {
            self.onClear?()
        }
    }
}
