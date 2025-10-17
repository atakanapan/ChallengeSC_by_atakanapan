import UIKit

protocol UserTableViewCellDelegate: AnyObject {
    func didTapBookmark(for user: User)
}

class UserTableViewCell: UITableViewCell {
    static let identifier = "UserTableViewCell"
    
    weak var delegate: UserTableViewCellDelegate?
    private var user: User?
    
    // MARK: - UI Elements
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        button.tintColor = .systemYellow
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .default
        
        // Add subtle background color change on selection
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .systemGray6
        self.selectedBackgroundView = selectedBackgroundView
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(bookmarkButton)
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(locationLabel)
        
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Avatar ImageView
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Stack View
            stackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -12),
            
            // Bookmark Button
            bookmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Content View Height
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }
    
    // MARK: - Configuration
    func configure(with user: User) {
        self.user = user
        
        nameLabel.text = user.fullName
        emailLabel.text = user.email
        locationLabel.text = "\(user.location.city), \(user.location.country)"
        
        // Update bookmark button state
        bookmarkButton.isSelected = BookmarkManager.shared.isBookmarked(user)
        
        // Load avatar image
        loadAvatar(from: user.picture.thumbnail)
    }
    
    private func loadAvatar(from urlString: String) {
        // Show placeholder with user initials while loading
        if let user = user {
            let firstInitial = user.name.first.first.map(String.init) ?? ""
            let lastInitial = user.name.last.first.map(String.init) ?? ""
            let initials = "\(firstInitial)\(lastInitial)"
            avatarImageView.image = UIImage.placeholder(initials: initials, size: CGSize(width: 60, height: 60))
        }
        
        ImageLoadingService.shared.loadImage(from: urlString) { [weak self] (image: UIImage?) in
            if let image = image {
                self?.avatarImageView.image = image
            }
        }
    }
    
    @objc private func bookmarkTapped() {
        guard let user = user else { return }
        delegate?.didTapBookmark(for: user)
        
        // Update button state immediately for better UX
        bookmarkButton.isSelected = BookmarkManager.shared.isBookmarked(user)
        
        // Add a little animation
        UIView.animate(withDuration: 0.1, animations: {
            self.bookmarkButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.bookmarkButton.transform = .identity
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let user = user {
            let firstInitial = user.name.first.first.map(String.init) ?? ""
            let lastInitial = user.name.last.first.map(String.init) ?? ""
            let initials = "\(firstInitial)\(lastInitial)"
            avatarImageView.image = UIImage.placeholder(initials: initials, size: CGSize(width: 60, height: 60))
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
        nameLabel.text = nil
        emailLabel.text = nil
        locationLabel.text = nil
        bookmarkButton.isSelected = false
        user = nil
    }
}