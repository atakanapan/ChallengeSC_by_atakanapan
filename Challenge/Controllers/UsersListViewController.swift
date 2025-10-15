//
//  UsersListViewController.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import UIKit

class UsersListViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: UsersListCoordinator?
    private var viewModel = UsersListViewModel()
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let refreshControl = UIRefreshControl()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No users found"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateSubLabel: UILabel = {
        let label = UILabel()
        label.text = "Try adjusting your search criteria"
        label.textAlignment = .center
        label.textColor = .tertiaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
        setupTableView()
        setupSearchController()
        setupRefreshControl()
        viewModel.loadUsers()
    }
    
    deinit {
        // ViewModel handles its own cleanup
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel.delegate = self
    }
    private func setupUI() {
        title = "Random Users"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateSubLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Table View
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Empty State Labels
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
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
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search users..."
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Loading
    @objc private func handleRefresh() {
        viewModel.refreshUsers()
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.emptyStateView.isHidden = !self.viewModel.isEmpty
            
            let emptyState = self.viewModel.getEmptyStateMessage()
            self.emptyStateLabel.text = emptyState.title
            self.emptyStateSubLabel.text = emptyState.subtitle
        }
    }
    
    // MARK: - Navigation
    private func showUserDetail(for user: User) {
        coordinator?.showUserDetail(for: user)
    }
}

// MARK: - UITableViewDataSource
extension UsersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userCount
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
}

// MARK: - UITableViewDelegate
extension UsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let user = viewModel.user(at: indexPath.row) {
            showUserDetail(for: user)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Infinite scroll - load more data when reaching the end
        viewModel.loadMoreUsersIfNeeded(for: indexPath.row)
    }
}

// MARK: - UISearchResultsUpdating
extension UsersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.performSearch(with: searchText)
    }
}

// MARK: - UserTableViewCellDelegate
extension UsersListViewController: UserTableViewCellDelegate {
    func didTapBookmark(for user: User) {
        if let index = viewModel.currentUsers.firstIndex(of: user) {
            viewModel.toggleBookmark(at: index)
        }
    }
}

// MARK: - UsersListViewModelDelegate
extension UsersListViewController: UsersListViewModelDelegate {
    func didUpdateUsers() {
        updateUI()
    }
    
    func didUpdateSearchResults() {
        updateUI()
    }
    
    func didReceiveError(_ error: NetworkError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                self.viewModel.loadUsers()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
    
    func didStartLoading() {
        DispatchQueue.main.async {
            if self.viewModel.shouldShowInitialLoading() {
                self.loadingIndicator.startAnimating()
            }
        }
    }
    
    func didFinishLoading() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
        }
    }
}
