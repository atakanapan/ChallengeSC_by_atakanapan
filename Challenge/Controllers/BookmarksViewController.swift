//
//  BookmarksViewController.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import UIKit

class BookmarksViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel = BookmarksViewModel()
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bookmark.slash")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No Bookmarks Yet"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateSubLabel: UILabel = {
        let label = UILabel()
        label.text = "Start bookmarking users to see them here"
        label.textAlignment = .center
        label.textColor = .tertiaryLabel
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadBookmarks()
    }
    
    deinit {
        // ViewModel handles its own cleanup
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel.delegate = self
    }
    private func setupUI() {
        title = "Bookmarks"
        view.backgroundColor = .systemBackground
        
        // Add clear all button
        setupNavigationItems()
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateSubLabel)
        
        setupConstraints()
    }
    
    private func setupNavigationItems() {
        // Clear all button (only show when there are bookmarks)
        let clearAllButton = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(clearAllBookmarks)
        )
        clearAllButton.tintColor = .systemRed
        
        navigationItem.rightBarButtonItem = clearAllButton
        updateNavigationItems()
    }
    
    private func updateNavigationItems() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.canClearAll
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Table View
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            
            // Empty State Image
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Empty State Labels
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateSubLabel.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateSubLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateSubLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.emptyStateView.isHidden = !self.viewModel.isEmpty
            self.updateNavigationItems()
            
            let emptyState = self.viewModel.getEmptyStateConfiguration()
            self.emptyStateImageView.image = UIImage(systemName: emptyState.imageName)
            self.emptyStateLabel.text = emptyState.title
            self.emptyStateSubLabel.text = emptyState.subtitle
        }
    }
    
    // MARK: - Actions
    @objc private func clearAllBookmarks() {
        let alert = UIAlertController(
            title: "Clear All Bookmarks",
            message: "Are you sure you want to remove all bookmarked users? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { _ in
            self.viewModel.clearAllBookmarks()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    private func showUserDetail(for user: User) {
        let detailVC = UserDetailViewController(user: user)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func removeBookmark(at indexPath: IndexPath) {
        let message = viewModel.getRemoveConfirmationMessage(at: indexPath.row)
        
        let alert = UIAlertController(
            title: "Remove Bookmark",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
            self.viewModel.removeBookmark(at: indexPath.row)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension BookmarksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookmarkCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        if let user = viewModel.user(at: indexPath.row) {
            cell.configure(with: user)
            cell.delegate = self
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeBookmark(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
}

// MARK: - UITableViewDelegate
extension BookmarksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let user = viewModel.user(at: indexPath.row) {
            showUserDetail(for: user)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            self?.removeBookmark(at: indexPath)
            completion(true)
        }
        
        removeAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [removeAction])
    }
}

// MARK: - UserTableViewCellDelegate
extension BookmarksViewController: UserTableViewCellDelegate {
    func didTapBookmark(for user: User) {
        if let index = viewModel.bookmarkedUsers.firstIndex(of: user) {
            viewModel.toggleBookmark(at: index)
        }
    }
}

// MARK: - BookmarksViewModelDelegate
extension BookmarksViewController: BookmarksViewModelDelegate {
    func didUpdateBookmarks() {
        updateUI()
    }
    
    func didReceiveError(_ message: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: message)
        }
    }
}
