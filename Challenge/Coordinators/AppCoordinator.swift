//
//  AppCoordinator.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import UIKit

protocol AppCoordinatorDelegate: AnyObject {
    func didFinishApp()
}

class AppCoordinator: Coordinator {
    weak var delegate: AppCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let tabBarCoordinator = TabBarCoordinator()
        tabBarCoordinator.delegate = self
        addChildCoordinator(tabBarCoordinator)
        
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
        
        tabBarCoordinator.start()
    }
}

// MARK: - TabBarCoordinatorDelegate
extension AppCoordinator: TabBarCoordinatorDelegate {
    func tabBarCoordinatorDidFinish(_ coordinator: TabBarCoordinator) {
        removeChildCoordinator(coordinator)
        delegate?.didFinishApp()
    }
}