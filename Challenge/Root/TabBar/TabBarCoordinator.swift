import UIKit

// MARK: - TabBarCoordinator
/// Coordinates the main tab bar and its child flows.
@MainActor
final class TabBarCoordinator: NSObject, Coordinator {

    // MARK: - Properties

    /// Root navigation controller for the app (not used as a tab, but kept for parity with your architecture).
    var navigationController: UINavigationController

    /// The tab bar controller hosting Users and Bookmarks tabs.
    private(set) var tabBarController: UITabBarController

    /// Child coordinators for each tab.
    private var usersListCoordinator: UsersListCoordinator?
    private var bookmarksCoordinator: BookmarksCoordinator?

    /// Notification token to unregister on deinit (block-based observer).
    private var bookmarkObserver: NSObjectProtocol?

    // MARK: - Initialization

    override init() {
        self.navigationController = UINavigationController()
        self.tabBarController = UITabBarController()
        super.init()
    }

    // MARK: - Coordinator

    /// Entry point — sets up the tab bar UI and starts child coordinators.
    func start() {
        setupTabBar()
        setupCoordinators()
    }

    // MARK: - Setup (Appearance)
    /// Configures the visual appearance of the tab bar
    private func setupTabBar() {
        // Configure tab bar appearance
        tabBarController.tabBar.tintColor = .systemBlue
        tabBarController.tabBar.unselectedItemTintColor = .systemGray
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
    }

    // MARK: - Setup (Child Coordinators)

    /// Creates, configures, and starts the "Users" and "Bookmarks" flows.
    private func setupCoordinators() {
        // Users List Coordinator
        let usersListNavController = UINavigationController()
        usersListCoordinator = UsersListCoordinator(navigationController: usersListNavController)
        usersListNavController.tabBarItem = UITabBarItem(
            title: "Users",
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
        
        // Bookmarks Coordinator
        let bookmarksNavController = UINavigationController()
        bookmarksCoordinator = BookmarksCoordinator(navigationController: bookmarksNavController)
        bookmarksNavController.tabBarItem = UITabBarItem(
            title: "Bookmarks",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )

        // Assign both tabs to the tab bar controller (order matters for badge updates).
        tabBarController.viewControllers = [usersListNavController, bookmarksNavController]

        // Start child flows.
        usersListCoordinator?.start()
        bookmarksCoordinator?.start()

        // Observe bookmark changes to update the badge on the Bookmarks tab.
        setupBookmarkBadgeObserver()
        updateBookmarkBadge()
    }

    // MARK: - Notifications

    /// Subscribes to bookmark change notifications and updates the badge safely on the main actor.
    private func setupBookmarkBadgeObserver() {
        // Block-based observer can be called on any thread; we hop to @MainActor before touching UI.
        bookmarkObserver = NotificationCenter.default.addObserver(
            forName: BookmarkManager.bookmarkDidChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateBookmarkBadge()
            }
        }
    }

    // MARK: - Badge Updates

    /// Reads current bookmark count and sets/clears the badge on the "Bookmarks" tab.
    private func updateBookmarkBadge() {
        let bookmarkCount = BookmarkManager.shared.bookmarkedCount
        guard let bookmarksVC = tabBarController.viewControllers?[1] else { return }

        // Set or clear the badge value based on count.
        bookmarksVC.tabBarItem.badgeValue = (bookmarkCount > 0) ? "\(bookmarkCount)" : nil
    }

    // MARK: - Deinitialization

    /// Clean up observers to avoid leaks.
    deinit {
        if let token = bookmarkObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

