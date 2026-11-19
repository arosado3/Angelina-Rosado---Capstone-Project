import UIKit

/// Protocol used to notify DecisionWheelViewController when the user taps "Spin Again" or "Clear"
protocol SelectionViewControllerDelegate: AnyObject {
    func didTapSpinAgain()
    func didTapClearWheel()
}

/**
 - Screen 3: Pop-up overlay card displaying the winning option with Spin Again and Clear actions.
 */
class SelectionViewController: UIViewController {
    
    // MARK: - Storyboard Outlets
    @IBOutlet weak var cardView: UIView?
    @IBOutlet weak var winnerLabel: UILabel?
    
    // MARK: - Data & Delegate Properties
    var winningOption: String = ""
    weak var delegate: SelectionViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardView?.layer.cornerRadius = 16
        winnerLabel?.text = winningOption
    }
    
    // MARK: - Actions
    @IBAction func didTapSpinAgainButton(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.didTapSpinAgain()
        }
    }
    
    @IBAction func didTapClearButton(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.didTapClearWheel()
        }
    }
}
