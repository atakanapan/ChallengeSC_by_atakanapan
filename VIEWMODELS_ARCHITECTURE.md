# ViewModels Architecture

This document explains the MVVM (Model-View-ViewModel) architecture implementation for the Random Users Browser app.

## Overview

The ViewModels have been added to create a clean separation between business logic and view controllers, following the MVVM architectural pattern.

## Benefits of Adding ViewModels

### 🏗️ **Improved Architecture**
- **Separation of Concerns**: Business logic moved from View Controllers to ViewModels
- **Testability**: ViewModels can be easily unit tested without UI dependencies
- **Reusability**: ViewModels can be reused across different views
- **Maintainability**: Cleaner, more focused code in both ViewModels and View Controllers

### 📱 **Better Code Organization**
- **Delegate Pattern**: Clean communication between ViewModels and View Controllers
- **Single Responsibility**: Each ViewModel handles specific business logic
- **Data Management**: Centralized data handling and state management

## ViewModel Classes

### 1. **UsersListViewModel**
**Location**: `ViewModels/UsersListViewModel.swift`

**Responsibilities**:
- Manages user list data and search functionality
- Handles API calls for fetching users
- Implements infinite scroll logic
- Manages search and filtering
- Handles bookmark operations for list items

**Key Features**:
```swift
// Data Management
var currentUsers: [User] { get }
var isEmpty: Bool { get }
var userCount: Int { get }

// Core Functions
func loadUsers()
func refreshUsers()
func loadMoreUsersIfNeeded(for index: Int)
func performSearch(with searchText: String)
func toggleBookmark(at index: Int)
```

**Delegate Protocol**:
```swift
protocol UsersListViewModelDelegate: AnyObject {
    func didUpdateUsers()
    func didUpdateSearchResults()
    func didReceiveError(_ error: NetworkError)
    func didStartLoading()
    func didFinishLoading()
}
```

### 2. **UserDetailViewModel**
**Location**: `ViewModels/UserDetailViewModel.swift`

**Responsibilities**:
- Manages user detail display data
- Handles profile image loading
- Manages bookmark state for individual user
- Provides formatted user information sections
- Handles sharing functionality

**Key Features**:
```swift
// Display Properties
var displayName: String { get }
var ageLocationText: String { get }
var bookmarkButtonConfiguration: (title: String, backgroundColor: UIColor) { get }
var placeholderImage: UIImage? { get }

// Information Sections
func getContactInformation() -> [(String, String, String)]
func getLocationInformation() -> [(String, String, String)]
func getPersonalInformation() -> [(String, String, String)]
func getAccountInformation() -> [(String, String, String)]

// Actions
func loadProfileImage()
func toggleBookmark()
func getShareText() -> String
```

**Delegate Protocol**:
```swift
protocol UserDetailViewModelDelegate: AnyObject {
    func didUpdateBookmarkStatus()
    func didLoadProfileImage(_ image: UIImage)
}
```

### 3. **BookmarksViewModel**
**Location**: `ViewModels/BookmarksViewModel.swift`

**Responsibilities**:
- Manages bookmarked users list
- Handles bookmark removal operations
- Provides empty state configuration
- Manages bookmark notifications and updates

**Key Features**:
```swift
// Data Properties
var isEmpty: Bool { get }
var bookmarkCount: Int { get }
var canClearAll: Bool { get }

// Core Functions
func loadBookmarks()
func removeBookmark(at index: Int)
func toggleBookmark(at index: Int)
func clearAllBookmarks()
func getRemoveConfirmationMessage(at index: Int) -> String
func getEmptyStateConfiguration() -> (imageName: String, title: String, subtitle: String)
```

**Delegate Protocol**:
```swift
protocol BookmarksViewModelDelegate: AnyObject {
    func didUpdateBookmarks()
    func didReceiveError(_ message: String)
}
```

## View Controller Changes

### **Before ViewModels** (Traditional MVC):
```swift
class UsersListViewController: UIViewController {
    private var users: [User] = []
    private var isLoading = false
    // ... many properties for state management
    
    private func loadUsers() {
        // Complex API logic mixed with UI logic
        APIService.shared.fetchUsers { result in
            // Data processing + UI updates mixed
        }
    }
}
```

### **After ViewModels** (MVVM):
```swift
class UsersListViewController: UIViewController {
    private var viewModel = UsersListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.loadUsers() // Clean, simple call
    }
    
    private func setupViewModel() {
        viewModel.delegate = self // Clear communication channel
    }
}

extension UsersListViewController: UsersListViewModelDelegate {
    func didUpdateUsers() {
        updateUI() // Simple UI updates only
    }
}
```

## Key Improvements

### 🧪 **Testability**
- ViewModels can be unit tested independently
- Business logic separated from UI dependencies
- Mock delegates can be used for testing

### 🔄 **Data Flow**
1. **View Controller** → **ViewModel**: User actions (loadUsers, search, etc.)
2. **ViewModel** → **Service Layer**: Data requests (API, BookmarkManager)
3. **Service Layer** → **ViewModel**: Data responses
4. **ViewModel** → **View Controller**: UI updates via delegate

### 📊 **State Management**
- ViewModels maintain single source of truth for data
- View Controllers only handle UI state
- Clean separation between business and presentation logic

### 🔧 **Memory Management**
- Proper weak delegate references prevent retain cycles
- ViewModels handle their own notification cleanup
- Automatic memory management for complex data operations

## Usage Examples

### **Loading Users**:
```swift
// In View Controller
viewModel.loadUsers()

// ViewModel handles the complexity
// Delegate receives clean updates
func didUpdateUsers() {
    updateUI() // Simple UI refresh
}
```

### **Search Implementation**:
```swift
// In Search Controller
func updateSearchResults(for searchController: UISearchController) {
    let searchText = searchController.searchBar.text ?? ""
    viewModel.performSearch(with: searchText) // Single call
}

// ViewModel handles filtering logic
// Delegate receives update notification
```

### **Bookmark Management**:
```swift
// In Cell Delegate
func didTapBookmark(for user: User) {
    if let index = viewModel.currentUsers.firstIndex(of: user) {
        viewModel.toggleBookmark(at: index) // Clean action
    }
}
```

## Architecture Benefits

### ✅ **Clean Code**
- View Controllers are now focused only on UI
- Business logic is centralized in ViewModels
- Clear separation of responsibilities

### ✅ **Scalability**
- Easy to add new features to ViewModels
- ViewModels can be shared between different views
- Consistent patterns across the app

### ✅ **Maintainability**
- Easier to locate and fix business logic issues
- UI and business logic can be updated independently
- Clear contracts via delegate protocols

This MVVM implementation significantly improves the app's architecture while maintaining all existing functionality and enhancing code quality for future development.