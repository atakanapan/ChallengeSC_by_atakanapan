import Foundation

protocol UsersListViewModelDelegate: AnyObject {
    func didUpdateUsers()
    func didUpdateSearchResults()
    func didReceiveError(_ error: NetworkError)
    func didStartLoading()
    func didFinishLoading()
}

class UsersListViewModel {
    
    // MARK: - Properties
    weak var delegate: UsersListViewModelDelegate?
    
    private(set) var users: [UserEntity] = []
    private(set) var filteredUsers: [UserEntity] = []
    private(set) var isSearching = false
    private(set) var isLoading = false
    private(set) var hasMoreData = true
    
    private var currentPage = 1
    private var apiSeed: String?
    private var currentSearchText = ""
    
    private let apiService = APIService.shared
    
    // MARK: - Computed Properties
    var currentUsers: [UserEntity] {
        return isSearching ? filteredUsers : users
    }
    
    var isEmpty: Bool {
        return currentUsers.isEmpty
    }
    
    var userCount: Int {
        return currentUsers.count
    }
    
    // MARK: - Public Methods
    
    /// Load initial users data
    func loadUsers() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        delegate?.didStartLoading()
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let response = try await self.apiService.fetchUsers(
                    page: self.currentPage,
                    results: 25,
                    seed: self.apiSeed
                )
                
                print("📥 ViewModel received \(response.results.count) users (page: \(self.currentPage))")
                
                if self.apiSeed == nil {
                    self.apiSeed = response.info.seed
                }
                
                if self.currentPage == 1 {
                    self.users = response.results
                } else {
                    self.users.append(contentsOf: response.results)
                }
                
                self.currentPage += 1
                self.hasMoreData = response.results.count >= 25
                
                if self.isSearching {
                    self.performSearch(with: self.currentSearchText)
                } else {
                    self.delegate?.didUpdateUsers()
                }
                
            } catch let error as NetworkError {
                self.delegate?.didReceiveError(error)
            }
            
            self.isLoading = false
            self.delegate?.didFinishLoading()
        }
    }
    
    /// Refresh users data
    func refreshUsers() {
        currentPage = 1
        hasMoreData = true
        apiSeed = nil
        users.removeAll()
        
        // Clear search if active
        if isSearching {
            clearSearch()
        }
        
        loadUsers()
    }
    
    /// Load more users for infinite scroll
    func loadMoreUsersIfNeeded(for index: Int) {
        let threshold = 5
        if !isSearching && index >= users.count - threshold && !isLoading && hasMoreData {
            loadUsers()
        }
    }
    
    /// Perform search with given text
    func performSearch(with searchText: String) {
        currentSearchText = searchText
        isSearching = !searchText.isEmpty
        
        if isSearching {
            filteredUsers = users.filter { user in
                let query = searchText.lowercased()
                return user.fullName.lowercased().contains(query) ||
                       user.email.lowercased().contains(query) ||
                       user.location.city.lowercased().contains(query) ||
                       user.location.country.lowercased().contains(query)
            }
            delegate?.didUpdateSearchResults()
        } else {
            filteredUsers.removeAll()
            delegate?.didUpdateUsers()
        }
    }
    
    /// Clear search and return to full list
    func clearSearch() {
        isSearching = false
        currentSearchText = ""
        filteredUsers.removeAll()
        delegate?.didUpdateUsers()
    }
    
    /// Get user at specific index
    func user(at index: Int) -> UserEntity? {
        let dataSource = currentUsers
        guard index >= 0 && index < dataSource.count else { return nil }
        return dataSource[index]
    }
    
    /// Toggle bookmark for user at index
    func toggleBookmark(at index: Int) {
        guard let user = user(at: index) else { return }
        BookmarkManager.shared.toggleBookmark(user)
    }
    
    /// Check if user at index is bookmarked
    func isBookmarked(at index: Int) -> Bool {
        guard let user = user(at: index) else { return false }
        return BookmarkManager.shared.isBookmarked(user)
    }
}

// MARK: - Helper Extensions
extension UsersListViewModel {
    
    /// Get empty state message based on current state
    func getEmptyStateMessage() -> (title: String, subtitle: String) {
        if isSearching {
            return ("No users found", "Try adjusting your search criteria")
        } else {
            return ("No users available", "Pull to refresh or check your connection")
        }
    }
    
    /// Check if should show loading indicator
    func shouldShowInitialLoading() -> Bool {
        return isLoading && users.isEmpty
    }
}
