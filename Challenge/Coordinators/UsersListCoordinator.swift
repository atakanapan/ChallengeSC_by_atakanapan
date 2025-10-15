//
//  UsersListCoordinator.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import UIKit

protocol UsersListCoordinatorDelegate: AnyObject {
    func usersListCoordinatorDidFinish(_ coordinator: UsersListCoordinator)
}

class UsersListCoordinator: Coordinator {
    weak var delegate: UsersListCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showUsersList()
    }
    
    private func showUsersList() {
        let usersListVC = UsersListViewController()
        usersListVC.coordinator = self
        navigationController.pushViewController(usersListVC, animated: false)
    }
    
    func showUserDetail(for user: User) {
        let userDetailCoordinator = UserDetailCoordinator(
            navigationController: navigationController,
            user: user
        )
        userDetailCoordinator.delegate = self
        addChildCoordinator(userDetailCoordinator)
        userDetailCoordinator.start()
    }
}

// MARK: - UserDetailCoordinatorDelegate
extension UsersListCoordinator: UserDetailCoordinatorDelegate {
    func userDetailCoordinatorDidFinish(_ coordinator: UserDetailCoordinator) {
        removeChildCoordinator(coordinator)
    }
}