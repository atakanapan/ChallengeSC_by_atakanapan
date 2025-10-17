import UIKit

class AppCoordinator: Coordinator {
    var tabBarCoordinator: TabBarCoordinator!

    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        tabBarCoordinator = TabBarCoordinator()
        
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
        
        tabBarCoordinator.start()
    }
}
