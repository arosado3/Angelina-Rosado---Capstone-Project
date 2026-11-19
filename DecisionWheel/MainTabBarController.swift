import UIKit

/**
 - The root container of the app that displays the bottom Tab Bar.
 - Switches between the "Create Wheel" flow and the "Settings" screen configured in Main.storyboard.
 */
class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize the tab bar tint; tab view controllers and navigation flows are wired in Main.storyboard
        tabBar.tintColor = .systemBlue
    }
}
