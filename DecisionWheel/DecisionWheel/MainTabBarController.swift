import UIKit

/**
 - The root container of the app that displays the bottom Tab Bar.
 - Switches between the "Create Wheel" flow and the "Settings" screen.
 */
class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Set up the left tab: MainNavigationViewController wrapped in a Navigation Controller
        // Wrapping it in UINavigationController allows pushing to the DecisionWheel screen later
        let mainVC = MainNavigationViewController()
        let navController = UINavigationController(rootViewController: mainVC)
        navController.tabBarItem = UITabBarItem(
            title: "Create Wheel",
            image: UIImage(systemName: "circle.grid.cross"),
            tag: 0
        )
        
        // 2. Set up the right tab: SettingsViewController wrapped in its own Navigation Controller
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            tag: 1
        )
        
        // Attach both tabs to the Tab Bar Controller
        viewControllers = [navController, settingsNav]
    }
}
