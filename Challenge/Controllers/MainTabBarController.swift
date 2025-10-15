//
//  MainTabBarController.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private var bookmarkBadgeObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
        setupBookmarkBadgeObserver()
        updateBookmarkBadge()
    }
    
    deinit {
        if let observer = bookmarkBadgeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupTabs() {
        // Users List Tab
        let usersListVC = UsersListViewController()
        let usersNav = UINavigationController(rootViewController: usersListVC)
        usersNav.tabBarItem = UITabBarItem(
            title: "Users",
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
        
        // Bookmarks Tab
        let bookmarksVC = BookmarksViewController()
        let bookmarksNav = UINavigationController(rootViewController: bookmarksVC)
        bookmarksNav.tabBarItem = UITabBarItem(
            title: "Bookmarks",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )
        
        viewControllers = [usersNav, bookmarksNav]
    }
    
    private func setupAppearance() {
        // Configure tab bar appearance
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupBookmarkBadgeObserver() {
        bookmarkBadgeObserver = NotificationCenter.default.addObserver(
            forName: BookmarkManager.bookmarkDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBookmarkBadge()
        }
    }
    
    private func updateBookmarkBadge() {
        let bookmarkCount = BookmarkManager.shared.bookmarkedCount
        let bookmarkTab = viewControllers?[1]
        
        if bookmarkCount > 0 {
            bookmarkTab?.tabBarItem.badgeValue = "\(bookmarkCount)"
        } else {
            bookmarkTab?.tabBarItem.badgeValue = nil
        }
    }
}