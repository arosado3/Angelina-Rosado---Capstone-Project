import UIKit
import AudioToolbox

class DecisionWheelViewController: UIViewController, SelectionViewControllerDelegate {

    // MARK: - Storyboard Outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var wheelContainerView: UIView!
    @IBOutlet weak var spinButton: UIButton!
    
    // MARK: - Properties
    var savedWheel: SavedWheel?
    
    private var spinState: WheelSpinState = .ready
    private var currentRotationAngle: CGFloat = 0
    private var displayLink: CADisplayLink?
    private var angularVelocity: CGFloat = 0
    private var lastSliceIndex: Int = -1
    private var impactGenerator: UIImpactFeedbackGenerator?
    private var selectedWinner: String?
    
    private let wheelColors: [UIColor] = [
        .systemRed,
        .systemBlue,
        .systemGreen,
        .systemOrange,
        .systemPurple,
        .systemTeal,
        .systemPink,
        .systemIndigo
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        prepareHaptics()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawWheel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // MARK: - Setup
    private func setupUI() {
        questionLabel?.text = savedWheel?.question ?? "Decision Wheel"
        spinButton?.layer.cornerRadius = 12
    }
    
    private func prepareHaptics() {
        let intensity = WheelStorageManager.shared.loadHapticIntensity()
        let style: UIImpactFeedbackGenerator.FeedbackStyle?
        
        switch intensity {
        case .off:
            style = nil
        case .light:
            style = .light
        case .medium:
            style = .medium
        case .heavy:
            style = .heavy
        }
        
        if let style = style {
            impactGenerator = UIImpactFeedbackGenerator(style: style)
            impactGenerator?.prepare()
        } else {
            impactGenerator = nil
        }
    }
    
    // MARK: - Wheel Drawing
    private func drawWheel() {
        guard let wheelContainerView = wheelContainerView,
              let choices = savedWheel?.choices,
              !choices.isEmpty else { return }
        
        wheelContainerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let bounds = wheelContainerView.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2.0 - 8.0
        guard radius > 0 else { return }
        
        let sliceAngle = (2.0 * CGFloat.pi) / CGFloat(choices.count)
        let wheelLayer = CALayer()
        wheelLayer.frame = bounds
        
        for (index, choice) in choices.enumerated() {
            // Start at top (-pi/2)
            let startAngle = -CGFloat.pi / 2.0 + CGFloat(index) * sliceAngle
            let endAngle = startAngle + sliceAngle
            
            let slicePath = UIBezierPath()
            slicePath.move(to: center)
            slicePath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            slicePath.close()
            
            let sliceLayer = CAShapeLayer()
            sliceLayer.path = slicePath.cgPath
            sliceLayer.fillColor = wheelColors[index % wheelColors.count].cgColor
            sliceLayer.strokeColor = UIColor.white.cgColor
            sliceLayer.lineWidth = 2.0
            wheelLayer.addSublayer(sliceLayer)
            
            // Draw slice label (kept upright on both left and right sides)
            let midAngle = startAngle + sliceAngle / 2.0
            let textRadius = radius * 0.62
            let textCenter = CGPoint(
                x: center.x + textRadius * cos(midAngle),
                y: center.y + textRadius * sin(midAngle)
            )
            
            let textLayer = CATextLayer()
            textLayer.string = choice
            textLayer.fontSize = 14
            textLayer.foregroundColor = UIColor.white.cgColor
            textLayer.alignmentMode = .center
            textLayer.truncationMode = .end
            textLayer.contentsScale = traitCollection.displayScale
            textLayer.bounds = CGRect(x: 0, y: 0, width: radius * 0.65, height: 20)
            textLayer.position = textCenter
            
            var textAngle = midAngle
            if cos(midAngle) < 0 {
                textAngle += .pi
            }
            textLayer.setAffineTransform(CGAffineTransform(rotationAngle: textAngle))
            wheelLayer.addSublayer(textLayer)
        }
        
        wheelLayer.setAffineTransform(CGAffineTransform(rotationAngle: currentRotationAngle))
        wheelContainerView.layer.addSublayer(wheelLayer)
    }
    
    // MARK: - Spin Physics & Tick Audio/Haptics
    @IBAction func didTapSpin(_ sender: UIButton) {
        guard spinState != .spinning,
              let choices = savedWheel?.choices,
              choices.count >= 2 else { return }
        
        spinState = .spinning
        spinButton?.isEnabled = false
        prepareHaptics()
        
        // Randomize initial spin speed (radians per second)
        angularVelocity = CGFloat.random(in: 18.0...28.0)
        lastSliceIndex = currentSliceIndexUnderPointer()
        
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateSpinFrame(_:)))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateSpinFrame(_ link: CADisplayLink) {
        let dt = CGFloat(link.targetTimestamp - link.timestamp)
        guard dt > 0, dt < 0.2 else { return }
        
        currentRotationAngle += angularVelocity * dt
        currentRotationAngle = currentRotationAngle.truncatingRemainder(dividingBy: 2.0 * .pi)
        
        // Apply smooth friction deceleration
        angularVelocity *= pow(0.32, dt)
        
        // Rotate wheel layer
        if let wheelLayer = wheelContainerView?.layer.sublayers?.first {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            wheelLayer.setAffineTransform(CGAffineTransform(rotationAngle: currentRotationAngle))
            CATransaction.commit()
        }
        
        // Check if a new slice crossed the top pointer -> play tick sound + haptic
        let currentIndex = currentSliceIndexUnderPointer()
        if currentIndex != lastSliceIndex {
            lastSliceIndex = currentIndex
            triggerSliceTickFeedback()
        }
        
        // Stop when wheel slows down enough
        if angularVelocity < 0.15 {
            displayLink?.invalidate()
            displayLink = nil
            finishSpin(winningIndex: currentIndex)
        }
    }
    
    private func triggerSliceTickFeedback() {
        let intensity = WheelStorageManager.shared.loadHapticIntensity()
        guard intensity != .off else { return }
        
        // Audible click sound (works in iOS Simulator & on physical devices)
        AudioServicesPlaySystemSound(1104)
        
        // Physical Taptic Engine feedback (works on physical iPhones)
        impactGenerator?.impactOccurred()
        impactGenerator?.prepare()
    }
    
    private func currentSliceIndexUnderPointer() -> Int {
        guard let count = savedWheel?.choices.count, count > 0 else { return 0 }
        let sliceAngle = (2.0 * CGFloat.pi) / CGFloat(count)
        
        // Normalize rotation angle into [0, 2*pi)
        var normalized = (-currentRotationAngle).truncatingRemainder(dividingBy: 2.0 * .pi)
        if normalized < 0 { normalized += 2.0 * .pi }
        
        return Int(normalized / sliceAngle) % count
    }
    
    private func finishSpin(winningIndex: Int) {
        spinState = .completed
        spinButton?.isEnabled = true
        
        guard var wheel = savedWheel,
              winningIndex >= 0,
              winningIndex < wheel.choices.count else { return }
        
        let winner = wheel.choices[winningIndex]
        selectedWinner = winner
        wheel.lastWinner = winner
        savedWheel = wheel
        
        // Persist updated lastWinner in UserDefaults
        var allWheels = WheelStorageManager.shared.loadWheels()
        if let existingIndex = allWheels.firstIndex(where: { $0.id == wheel.id }) {
            allWheels[existingIndex] = wheel
            WheelStorageManager.shared.saveWheels(allWheels)
        }
        
        // Present SelectionViewController via Storyboard ID or segue
        if let selectionVC = storyboard?.instantiateViewController(withIdentifier: "SelectionViewController") as? SelectionViewController {
            selectionVC.winningOption = winner
            selectionVC.delegate = self
            present(selectionVC, animated: true)
        } else if shouldPerformSegue(withIdentifier: "ShowSelectionModal", sender: self) {
            performSegue(withIdentifier: "ShowSelectionModal", sender: self)
        }
    }
    
    // MARK: - Navigation & SelectionViewControllerDelegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectionVC = segue.destination as? SelectionViewController {
            selectionVC.winningOption = selectedWinner ?? ""
            selectionVC.delegate = self
        }
    }
    
    func didTapSpinAgain() {
        spinState = .ready
        if let button = spinButton {
            didTapSpin(button)
        }
    }
    
    func didTapClearWheel() {
        navigationController?.popViewController(animated: true)
    }
}
