import UIKit

class MainNavigationViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Storyboard Outlets
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var choicesStackView: UIStackView!
    @IBOutlet weak var savedWheelsTableView: UITableView!
    @IBOutlet weak var inspireButton: UIButton!
    
    // MARK: - Properties
    private var savedWheels: [SavedWheel] = []
    private var selectedWheelForSegue: SavedWheel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadInitialChoiceRows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSavedWheels()
    }
    
    // MARK: - Setup
    private func setupUI() {
        questionTextField?.delegate = self
        questionTextField?.returnKeyType = .done
        questionTextField?.adjustsFontSizeToFitWidth = true
        questionTextField?.minimumFontSize = 12
        
        // Dismiss keyboard when tapping outside text fields
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTableView() {
        savedWheelsTableView?.dataSource = self
        savedWheelsTableView?.delegate = self
    }
    
    private func loadInitialChoiceRows() {
        guard let choicesStackView = choicesStackView else { return }
        
        // Clear any placeholder subviews in Storyboard and add 2 initial rows with delete buttons
        choicesStackView.arrangedSubviews.forEach {
            choicesStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        addChoiceRow()
        addChoiceRow()
    }
    
    private func reloadSavedWheels() {
        savedWheels = WheelStorageManager.shared.loadWheels()
        savedWheelsTableView?.reloadData()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Dynamic Choice Rows with Delete Button
    
    /// Adds a horizontal row containing a choice UITextField and a red delete UIButton
    private func addChoiceRow(with text: String = "") {
        guard let choicesStackView = choicesStackView else { return }
        
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.alignment = .fill
        rowStackView.distribution = .fill
        rowStackView.spacing = 8
        rowStackView.translatesAutoresizingMaskIntoConstraints = false
        rowStackView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Choice \(choicesStackView.arrangedSubviews.count + 1)"
        textField.text = text
        textField.returnKeyType = .done
        textField.delegate = self
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        deleteButton.addTarget(self, action: #selector(didTapDeleteChoice(_:)), for: .touchUpInside)
        
        rowStackView.addArrangedSubview(textField)
        rowStackView.addArrangedSubview(deleteButton)
        
        choicesStackView.addArrangedSubview(rowStackView)
    }
    
    @objc private func didTapDeleteChoice(_ sender: UIButton) {
        guard let choicesStackView = choicesStackView else { return }
        
        // Keep at least 2 choices so the wheel always has options to spin
        guard choicesStackView.arrangedSubviews.count > 2 else {
            showAlert(title: "Minimum Choices", message: "Your decision wheel needs at least 2 choices.")
            return
        }
        
        guard let rowStackView = sender.superview else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            rowStackView.isHidden = true
            rowStackView.alpha = 0
        }, completion: { [weak self] _ in
            self?.choicesStackView?.removeArrangedSubview(rowStackView)
            rowStackView.removeFromSuperview()
            self?.updateChoicePlaceholders()
        })
    }
    
    private func updateChoicePlaceholders() {
        guard let choicesStackView = choicesStackView else { return }
        
        for (index, subview) in choicesStackView.arrangedSubviews.enumerated() {
            if let rowStack = subview as? UIStackView,
               let textField = rowStack.arrangedSubviews.first as? UITextField {
                textField.placeholder = "Choice \(index + 1)"
            }
        }
    }
    
    private func currentChoiceTexts() -> [String] {
        guard let choicesStackView = choicesStackView else { return [] }
        
        return choicesStackView.arrangedSubviews.compactMap { subview in
            let textField = (subview as? UIStackView)?.arrangedSubviews.first as? UITextField
                ?? subview as? UITextField
            let trimmed = textField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return trimmed.isEmpty ? nil : trimmed
        }
    }
    
    // MARK: - Actions
    
    @IBAction func didTapAddChoice(_ sender: UIButton) {
        addChoiceRow()
    }
    
    @IBAction func didTapInspireMe(_ sender: UIButton) {
        inspireButton?.isEnabled = false
        sender.isEnabled = false
        
        MealAPIService.shared.fetchRandomQuestion { [weak self] result in
            guard let self = self else { return }
            self.inspireButton?.isEnabled = true
            sender.isEnabled = true
            
            switch result {
            case .success(let randomQuestion):
                self.questionTextField?.text = randomQuestion
            case .failure(let error):
                print("Failed to fetch question: \(error.localizedDescription)")
                self.showAlert(
                    title: "Couldn't Load Question",
                    message: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    @IBAction func didTapBuildWheel(_ sender: UIButton) {
        let question = questionTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let choices = currentChoiceTexts()
        
        guard !question.isEmpty else {
            showAlert(title: "Missing Question", message: "Please enter a question or tap Inspire Me.")
            return
        }
        
        guard choices.count >= 2 else {
            showAlert(title: "Not Enough Choices", message: "Please enter at least 2 choices to build your wheel.")
            return
        }
        
        let newWheel = SavedWheel(
            id: UUID(),
            question: question,
            choices: choices,
            lastWinner: nil,
            createdAt: Date()
        )
        
        var updatedWheels = WheelStorageManager.shared.loadWheels()
        updatedWheels.insert(newWheel, at: 0)
        WheelStorageManager.shared.saveWheels(updatedWheels)
        
        reloadSavedWheels()
        navigateToWheel(newWheel)
    }
    
    // MARK: - Navigation
    private func navigateToWheel(_ wheel: SavedWheel) {
        if let wheelVC = storyboard?.instantiateViewController(withIdentifier: "DecisionWheelViewController") as? DecisionWheelViewController {
            wheelVC.savedWheel = wheel
            navigationController?.pushViewController(wheelVC, animated: true)
        } else {
            selectedWheelForSegue = wheel
            performSegue(withIdentifier: "ShowDecisionWheel", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let wheelVC = segue.destination as? DecisionWheelViewController {
            wheelVC.savedWheel = selectedWheelForSegue
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedWheels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedWheelCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "SavedWheelCell")
        
        let wheel = savedWheels[indexPath.row]
        cell.textLabel?.text = wheel.question
        if let winner = wheel.lastWinner {
            cell.detailTextLabel?.text = "Last Winner: \(winner) (\(wheel.choices.count) choices)"
        } else {
            cell.detailTextLabel?.text = "\(wheel.choices.count) choices"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigateToWheel(savedWheels[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            WheelStorageManager.shared.deleteWheel(at: indexPath.row)
            reloadSavedWheels()
        }
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
