//
//  TabBarCoordinator.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import UIKit

class TabBarCoordinator: NSObject, Coordinator {
    var navigationController: UINavigationController
    
    private(set) var tabBarController: UITabBarController
    private var usersListCoordinator: UsersListCoordinator?
    private var bookmarksCoordinator: BookmarksCoordinator?
    
    override init() {
        self.navigationController = UINavigationController()
        self.tabBarController = UITabBarController()
        super.init()
    }
    
    func start() {
        setupTabBar()
        setupCoordinators()
    }
    
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
        
        // Set up tab bar view controllers
        tabBarController.viewControllers = [usersListNavController, bookmarksNavController]
        
        // Start child coordinators
        usersListCoordinator?.start()
        bookmarksCoordinator?.start()
        
        // Setup bookmark badge observer
        setupBookmarkBadgeObserver()
        updateBookmarkBadge()
    }
    
    private func setupBookmarkBadgeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bookmarkDidChange),
            name: BookmarkManager.bookmarkDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func bookmarkDidChange(_ notification: Notification) {
        updateBookmarkBadge()
    }
    
    private func updateBookmarkBadge() {
        let bookmarkCount = BookmarkManager.shared.bookmarkedCount
        let bookmarkTab = tabBarController.viewControllers?[1]
        
        DispatchQueue.main.async {
            if bookmarkCount > 0 {
                bookmarkTab?.tabBarItem.badgeValue = "\(bookmarkCount)"
            } else {
                bookmarkTab?.tabBarItem.badgeValue = nil
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
