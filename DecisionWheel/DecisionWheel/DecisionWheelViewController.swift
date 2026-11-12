import UIKit

/**
 - Screen 2: Draws the roulette-style wheel with each choice, spins it, and picks a winner.
 */
class DecisionWheelViewController: UIViewController {
    
    // Container view that holds all colored wedges and rotates during a spin
    private let wheelContainer = UIView()
    
    // Keeps track of the wheel's cumulative rotation angle (in radians)
    private var currentRotation: CGFloat = 0
    
    // Palette of colors cycled through for each slice of the wheel
    private let sliceColors: [UIColor] = [.systemBlue, .systemTeal, .systemIndigo, .systemPurple, .systemOrange, .systemPink]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Decision Wheel"
        view.backgroundColor = .systemBackground
        setupUI()
        drawWheel()
    }
    
    /// Sets up the question header, wheel container, top pointer diamond, and Spin button
    private func setupUI() {
        let questionLabel = UILabel()
        questionLabel.text = AppState.shared.question.isEmpty ? "Spin the Wheel!" : AppState.shared.question
        questionLabel.font = .boldSystemFont(ofSize: 22)
        questionLabel.textAlignment = .center
        questionLabel.numberOfLines = 0
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        wheelContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Static pointer at 12 o'clock showing where the winning slice lands
        let pointer = UIImageView(image: UIImage(systemName: "rhombus.fill"))
        pointer.tintColor = .label
        pointer.translatesAutoresizingMaskIntoConstraints = false
        
        let spinButton = UIButton(type: .system)
        spinButton.setTitle("Spin", for: .normal)
        spinButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        spinButton.backgroundColor = .systemBlue
        spinButton.setTitleColor(.white, for: .normal)
        spinButton.layer.cornerRadius = 10
        spinButton.translatesAutoresizingMaskIntoConstraints = false
        spinButton.addTarget(self, action: #selector(spinTapped), for: .touchUpInside)
        
        view.addSubview(questionLabel)
        view.addSubview(wheelContainer)
        view.addSubview(pointer)
        view.addSubview(spinButton)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            wheelContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wheelContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            wheelContainer.widthAnchor.constraint(equalToConstant: 280),
            wheelContainer.heightAnchor.constraint(equalToConstant: 280),
            
            pointer.bottomAnchor.constraint(equalTo: wheelContainer.topAnchor, constant: 10),
            pointer.centerXAnchor.constraint(equalTo: wheelContainer.centerXAnchor),
            pointer.widthAnchor.constraint(equalToConstant: 28),
            pointer.heightAnchor.constraint(equalToConstant: 28),
            
            spinButton.topAnchor.constraint(equalTo: wheelContainer.bottomAnchor, constant: 40),
            spinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinButton.widthAnchor.constraint(equalToConstant: 180),
            spinButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    /// Divides a 360-degree circle into equal pie wedges based on how many choices exist
    private func drawWheel() {
        let choices = AppState.shared.choices
        guard !choices.isEmpty else { return }
        
        let radius: CGFloat = 140
        let center = CGPoint(x: radius, y: radius)
        let sliceAngle = (2 * CGFloat.pi) / CGFloat(choices.count) // Angle of each wedge in radians
        
        for (index, choice) in choices.enumerated() {
            let startAngle = CGFloat(index) * sliceAngle
            let endAngle = startAngle + sliceAngle
            
            // Draw the pie-slice path from the center out to the arc edge
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.close()
            
            // Fill the wedge with color and add a white border
            let sliceLayer = CAShapeLayer()
            sliceLayer.path = path.cgPath
            sliceLayer.fillColor = sliceColors[index % sliceColors.count].cgColor
            sliceLayer.strokeColor = UIColor.white.cgColor
            sliceLayer.lineWidth = 2
            wheelContainer.layer.addSublayer(sliceLayer)
            
            // Create and rotate the text label so it sits centered inside its wedge
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 20))
            label.text = choice.text
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 13)
            label.textAlignment = .right
            
            let midAngle = startAngle + (sliceAngle / 2)
            label.center = CGPoint(
                x: center.x + cos(midAngle) * (radius * 0.55),
                y: center.y + sin(midAngle) * (radius * 0.55)
            )
            label.transform = CGAffineTransform(rotationAngle: midAngle)
            wheelContainer.addSubview(label)
        }
    }
    
    /// Animates the wheel spinning 4 to 7 full rotations with a realistic slow-down at the end
    @objc private func spinTapped() {
        let choices = AppState.shared.choices
        guard !choices.isEmpty else { return }
        
        // Trigger start-of-spin vibration if haptics are enabled
        if AppState.shared.hapticsEnabled {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        
        let randomSpin = CGFloat.random(in: (8 * .pi)...(14 * .pi))
        currentRotation += randomSpin
        
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseOut, animations: {
            self.wheelContainer.transform = CGAffineTransform(rotationAngle: self.currentRotation)
        }) { _ in
            // Trigger end-of-spin vibration when the wheel stops
            if AppState.shared.hapticsEnabled {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            self.selectWinner()
        }
    }
    
    /// Calculates which slice ended up under the top pointer (12 o'clock) and opens SelectionViewController
    private func selectWinner() {
        let choices = AppState.shared.choices
        let twoPi = 2 * CGFloat.pi
        let normalized = currentRotation.truncatingRemainder(dividingBy: twoPi)
        
        // 1.5 * pi represents 12 o'clock (270 degrees) in UIKit's coordinate system
        let pointerAngle = ((1.5 * .pi) - normalized + twoPi).truncatingRemainder(dividingBy: twoPi)
        let sliceAngle = twoPi / CGFloat(choices.count)
        let index = Int(pointerAngle / sliceAngle) % choices.count
        
        // Save the winning choice into AppState
        AppState.shared.selectedChoice = choices[index]
        
        // Present the Selection pop-up card over the wheel
        let selectionVC = SelectionViewController()
        selectionVC.modalPresentationStyle = .overFullScreen
        selectionVC.modalTransitionStyle = .crossDissolve
        selectionVC.onClear = { [weak self] in
            // Pop back to MainNavigationViewController when "Clear" is tapped
            self?.navigationController?.popToRootViewController(animated: true)
        }
        present(selectionVC, animated: true)
    }
}
