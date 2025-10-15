# Random Users Browser App

A modern iOS application built with UIKit that allows users to browse random user profiles from the randomuser.me API and bookmark their favorites.

## Features

### 🧑‍🤝‍🧑 User Browsing
- **Infinite Scroll**: Seamlessly browse through users with automatic pagination
- **Pull to Refresh**: Refresh the list with a simple pull gesture
- **Search Functionality**: Search users by name, email, city, or country
- **User Profiles**: Detailed profile pages with comprehensive user information

### 📖 Bookmarking System
- **Local Storage**: Bookmarks persist between app launches using UserDefaults
- **Cross-App Bookmarking**: Add/remove bookmarks from any screen
- **Real-time Updates**: UI updates immediately when bookmarks change
- **Bookmark Management**: Dedicated bookmarks tab with clear all functionality

### 🎨 User Experience
- **Modern UI**: Clean, iOS-native interface using UIKit
- **Loading States**: Smooth loading indicators and placeholder images
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Responsive Design**: Optimized for all iPhone screen sizes
- **Accessibility**: VoiceOver and accessibility features support

### 🔧 Technical Features
- **Production Ready**: Configured for App Store deployment
- **Networking**: Robust API service with error handling and image caching
- **Architecture**: Clean MVVM-inspired architecture with separation of concerns
- **Performance**: Efficient image loading and caching system
- **Notifications**: Real-time bookmark updates across the app

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

### Models
- `User.swift` - Complete user data model with computed properties
- Handles complex JSON structure with proper error handling

### Services
- `APIService.swift` - Network layer for randomuser.me API
- `BookmarkManager.swift` - Local bookmark persistence and management
- `ImageLoadingService.swift` - Image downloading and caching

### Views
- `UserTableViewCell.swift` - Custom table view cell with bookmark functionality
- Clean, reusable components with delegate pattern

### Controllers
- `MainTabBarController.swift` - Root tab bar with badge management
- `UsersListViewController.swift` - Users list with search and infinite scroll
- `UserDetailViewController.swift` - Detailed user profile view
- `BookmarksViewController.swift` - Bookmarks management

### Extensions
- `UIView+Extensions.swift` - Utility extensions for enhanced UX

## API Integration

The app integrates with the [randomuser.me API](https://randomuser.me/documentation):

- **Endpoint**: `https://randomuser.me/api/`
- **Pagination**: 25 users per page with consistent seed for reliable pagination
- **Image Loading**: Progressive image loading with placeholder initials
- **Error Handling**: Comprehensive network error handling

## Local Storage

Bookmarks are stored locally using UserDefaults with JSON encoding:

- **Persistence**: Bookmarks survive app restarts
- **Efficiency**: Fast bookmark operations with in-memory caching
- **Data Integrity**: Proper encoding/decoding with error handling
- **Notifications**: Real-time updates across all app screens

## Installation & Setup

1. Clone the repository
2. Open `Challenge.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

**Requirements:**
- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## Configuration

The app is configured for production deployment:

- **Info.plist**: Proper app transport security settings
- **Bundle**: Display name and version configuration
- **Networking**: Timeout configurations and error handling

## Testing

The app includes comprehensive error handling and edge cases:

- Network connectivity issues
- Empty states and loading states
- Large data sets with performance optimization
- Memory management for image caching

## Screenshots & Demo

The app features:

1. **Users Tab**: Browse random users with search and infinite scroll
2. **User Details**: Comprehensive profile information
3. **Bookmarks Tab**: Manage saved users with badge notifications
4. **Cross-Platform**: Bookmark/unbookmark from any screen

## Future Enhancements

Potential improvements for future versions:

- Core Data integration for advanced bookmark management
- User favorites with custom categories
- Offline mode with cached data
- Advanced search filters
- Social sharing features
- Dark mode optimization
- iPad-specific layouts

## Code Quality

The codebase follows iOS best practices:

- **Clean Code**: Well-structured, readable, and maintainable
- **Documentation**: Comprehensive inline documentation
- **Error Handling**: Robust error management throughout
- **Performance**: Efficient memory usage and smooth scrolling
- **Accessibility**: VoiceOver and accessibility support

## Contact

Built with ❤️ using UIKit and Swift for the iOS technical challenge.

---

*This app demonstrates modern iOS development practices, clean architecture, and production-ready code quality.*