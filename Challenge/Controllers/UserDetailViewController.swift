//
//  UserDetailViewController.swift
//  Challenge
//
//  Created by Taras Nikulin on 15/10/2025.
//

import UIKit

class UserDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: UserDetailViewModel
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.systemBackground.cgColor
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ageLocationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    init(user: User) {
        self.viewModel = UserDetailViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
        configureWithUser()
    }
    
    deinit {
        // ViewModel handles its own cleanup
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel.delegate = self
    }
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        // Add navigation bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareUser)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(ageLocationLabel)
        contentView.addSubview(bookmarkButton)
        contentView.addSubview(infoStackView)
        
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        
        setupConstraints()
        createInfoSections()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 150),
            profileImageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Age Location Label
            ageLocationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            ageLocationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ageLocationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Bookmark Button
            bookmarkButton.topAnchor.constraint(equalTo: ageLocationLabel.bottomAnchor, constant: 20),
            bookmarkButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 200),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Info Stack View
            infoStackView.topAnchor.constraint(equalTo: bookmarkButton.bottomAnchor, constant: 30),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createInfoSections() {
        // Contact Information
        let contactSection = createInfoSection(
            title: "Contact Information",
            items: viewModel.getContactInformation()
        )
        
        // Location Information
        let locationSection = createInfoSection(
            title: "Location",
            items: viewModel.getLocationInformation()
        )
        
        // Personal Information
        let personalSection = createInfoSection(
            title: "Personal Information",
            items: viewModel.getPersonalInformation()
        )
        
        // Login Information
        let loginSection = createInfoSection(
            title: "Account Information",
            items: viewModel.getAccountInformation()
        )
        
        infoStackView.addArrangedSubview(contactSection)
        infoStackView.addArrangedSubview(locationSection)
        infoStackView.addArrangedSubview(personalSection)
        infoStackView.addArrangedSubview(loginSection)
    }
    
    private func createInfoSection(title: String, items: [(String, String, String)]) -> UIView {
        let sectionView = UIView()
        sectionView.backgroundColor = .secondarySystemBackground
        sectionView.layer.cornerRadius = 12
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        sectionView.addSubview(titleLabel)
        sectionView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -16)
        ])
        
        for (label, value, iconName) in items {
            let itemView = createInfoItem(label: label, value: value, iconName: iconName)
            stackView.addArrangedSubview(itemView)
        }
        
        return sectionView
    }
    
    private func createInfoItem(label: String, value: String, iconName: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let labelLabel = UILabel()
        labelLabel.text = label
        labelLabel.font = .systemFont(ofSize: 14, weight: .medium)
        labelLabel.textColor = .secondaryLabel
        labelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(labelLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            labelLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            labelLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            labelLabel.widthAnchor.constraint(equalToConstant: 80),
            
            valueLabel.leadingAnchor.constraint(equalTo: labelLabel.trailingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func configureWithUser() {
        nameLabel.text = viewModel.displayName
        ageLocationLabel.text = viewModel.ageLocationText
        
        updateBookmarkButton()
        loadProfileImage()
    }
    
    private func updateBookmarkButton() {
        let config = viewModel.bookmarkButtonConfiguration
        bookmarkButton.setTitle(config.title, for: .normal)
        bookmarkButton.setTitleColor(.white, for: .normal)
        bookmarkButton.backgroundColor = config.backgroundColor
    }
    
    private func loadProfileImage() {
        // Show placeholder image first
        profileImageView.image = viewModel.placeholderImage
        
        // Load actual image
        viewModel.loadProfileImage()
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            return displayFormatter.string(from: date)
        }
        return dateString
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bookmarkDidChange),
            name: BookmarkManager.bookmarkDidChangeNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    @objc private func bookmarkTapped() {
        viewModel.toggleBookmark()
        
        // Add animation
        UIView.animate(withDuration: 0.1, animations: {
            self.bookmarkButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.bookmarkButton.transform = .identity
            }
        }
    }
    
    @objc private func shareUser() {
        let shareText = viewModel.getShareText()
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityVC, animated: true)
    }
    
    @objc private func bookmarkDidChange(_ notification: Notification) {
        updateBookmarkButton()
    }
}

// MARK: - UserDetailViewModelDelegate
extension UserDetailViewController: UserDetailViewModelDelegate {
    func didUpdateBookmarkStatus() {
        DispatchQueue.main.async {
            self.updateBookmarkButton()
        }
    }
    
    func didLoadProfileImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.profileImageView.image = image
        }
    }
}