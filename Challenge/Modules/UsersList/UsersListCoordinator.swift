import UIKit

@MainActor
class UsersListCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var userDetailCoordinator: UserDetailCoordinator?
    
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
    
    func showUserDetail(for user: UserEntity) {
        userDetailCoordinator = UserDetailCoordinator(
            navigationController: navigationController,
            user: user
        )
        userDetailCoordinator?.delegate = self
        userDetailCoordinator?.start()
    }
}

// MARK: - UserDetailCoordinatorDelegate
extension UsersListCoordinator: UserDetailCoordinatorDelegate {
    func userDetailCoordinatorDidFinish(_ coordinator: UserDetailCoordinator) {
        userDetailCoordinator = nil
    }
}
