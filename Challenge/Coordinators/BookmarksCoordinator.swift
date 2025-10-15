//
//  BookmarksCoordinator.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import UIKit

protocol BookmarksCoordinatorDelegate: AnyObject {
    func bookmarksCoordinatorDidFinish(_ coordinator: BookmarksCoordinator)
}

class BookmarksCoordinator: Coordinator {
    weak var delegate: BookmarksCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showBookmarks()
    }
    
    private func showBookmarks() {
        let bookmarksVC = BookmarksViewController()
        bookmarksVC.coordinator = self
        navigationController.pushViewController(bookmarksVC, animated: false)
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
extension BookmarksCoordinator: UserDetailCoordinatorDelegate {
    func userDetailCoordinatorDidFinish(_ coordinator: UserDetailCoordinator) {
        removeChildCoordinator(coordinator)
    }
}