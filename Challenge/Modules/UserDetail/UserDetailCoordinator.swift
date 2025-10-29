import UIKit

@MainActor
protocol UserDetailCoordinatorDelegate: AnyObject {
    func userDetailCoordinatorDidFinish(_ coordinator: UserDetailCoordinator)
}

@MainActor
class UserDetailCoordinator: Coordinator {
    weak var delegate: UserDetailCoordinatorDelegate?
    var navigationController: UINavigationController
    
    private let user: UserEntity
    
    init(navigationController: UINavigationController, user: UserEntity) {
        self.navigationController = navigationController
        self.user = user
    }
    
    func start() {
        showUserDetail()
    }
    
    private func showUserDetail() {
        let userDetailVC = UserDetailViewController(user: user)
        userDetailVC.coordinator = self
        navigationController.pushViewController(userDetailVC, animated: true)
    }
    
    func didFinishUserDetail() {
        delegate?.userDetailCoordinatorDidFinish(self)
    }
    
    func presentShareActivity(with items: [Any], from sourceView: UIView?) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // iPad support
        if let popover = activityVC.popoverPresentationController {
            if let sourceView = sourceView {
                popover.sourceView = sourceView
                popover.sourceRect = sourceView.bounds
            } else {
                popover.sourceView = navigationController.view
                popover.sourceRect = CGRect(
                    x: navigationController.view.bounds.midX,
                    y: navigationController.view.bounds.midY,
                    width: 0,
                    height: 0
                )
            }
        }
        
        navigationController.present(activityVC, animated: true)
    }
}
