import UIKit

/**
 - Screen 1: Lets the user type their question and add/edit their list of choices.
 */
class MainNavigationViewController: UIViewController {
    
    // UI elements for entering the question and stacking choice text fields
    private let questionTextField = UITextField()
    private let choicesStackView = UIStackView()
    private var choiceTextFields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Wheel"
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    // Runs every time this screen appears (including when returning after pressing "Clear")
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadFieldsFromState()
    }
    
    /// Builds and positions all labels, text fields, and buttons on the screen using Auto Layout
    private func setupUI() {
        let questionLabel = UILabel()
        questionLabel.text = "Question"
        questionLabel.font = .boldSystemFont(ofSize: 17)
        
        questionTextField.placeholder = "Enter your question..."
        questionTextField.borderStyle = .roundedRect
        
        // Horizontal row holding the "Choices" title on the left and "+ Add Choice" button on the right
        let choicesHeaderStack = UIStackView()
        choicesHeaderStack.axis = .horizontal
        
        let choicesLabel = UILabel()
        choicesLabel.text = "Choices"
        choicesLabel.font = .boldSystemFont(ofSize: 17)
        
        let addButton = UIButton(type: .system)
        addButton.setTitle("+ Add Choice", for: .normal)
        addButton.addTarget(self, action: #selector(addChoiceTapped), for: .touchUpInside)
        
        choicesHeaderStack.addArrangedSubview(choicesLabel)
        choicesHeaderStack.addArrangedSubview(addButton)
        
        // Vertical stack that holds all the individual choice text boxes
        choicesStackView.axis = .vertical
        choicesStackView.spacing = 12
        
        // Bottom button that navigates to the Decision Wheel screen
        let buildButton = UIButton(type: .system)
        buildButton.setTitle("Build Wheel", for: .normal)
        buildButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        buildButton.backgroundColor = .systemBlue
        buildButton.setTitleColor(.white, for: .normal)
        buildButton.layer.cornerRadius = 10
        buildButton.addTarget(self, action: #selector(buildWheelTapped), for: .touchUpInside)
        
        // Main vertical container for the question and choices
        let container = UIStackView(arrangedSubviews: [
            questionLabel,
            questionTextField,
            choicesHeaderStack,
            choicesStackView
        ])
        container.axis = .vertical
        container.spacing = 14
        container.translatesAutoresizingMaskIntoConstraints = false
        
        buildButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(container)
        view.addSubview(buildButton)
        
        // Pin the container to the top and the Build Wheel button to the bottom
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            buildButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buildButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buildButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buildButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    /// Clears old text boxes and creates fresh ones matching whatever is currently saved in AppState
    private func reloadFieldsFromState() {
        questionTextField.text = AppState.shared.question
        choicesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        choiceTextFields.removeAll()
        
        for choice in AppState.shared.choices {
            let tf = UITextField()
            tf.text = choice.text
            tf.placeholder = "Choice..."
            tf.borderStyle = .roundedRect
            choicesStackView.addArrangedSubview(tf)
            choiceTextFields.append(tf)
        }
    }
    
    /// Adds a blank choice box when "+ Add Choice" is tapped
    @objc private func addChoiceTapped() {
        saveInputsToState()
        AppState.shared.choices.append(Choice(text: ""))
        reloadFieldsFromState()
    }
    
    /// Saves all typed text into AppState and pushes to DecisionWheelViewController
    @objc private func buildWheelTapped() {
        saveInputsToState()
        let wheelVC = DecisionWheelViewController()
        navigationController?.pushViewController(wheelVC, animated: true)
    }
    
    /// Reads text from every text field on screen and saves it into AppState.shared
    private func saveInputsToState() {
        AppState.shared.question = questionTextField.text ?? ""
        AppState.shared.choices = choiceTextFields.compactMap { tf in
            let text = tf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return text.isEmpty ? nil : Choice(text: text)
        }
    }
}
