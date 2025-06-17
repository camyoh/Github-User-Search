import UIKit

final class RepositoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "RepositoryTableViewCell"
    
    // MARK: - UI Components
    
    private let repositoryNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    private let languageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        repositoryNameLabel.text = nil
        languageLabel.text = nil
        starsLabel.text = nil
        descriptionLabel.text = nil
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        // Add subviews
        contentView.addSubview(containerStackView)
        
        infoStackView.addArrangedSubview(languageLabel)
        infoStackView.addArrangedSubview(spacerView)
        infoStackView.addArrangedSubview(starsLabel)
        
        containerStackView.addArrangedSubview(repositoryNameLabel)
        containerStackView.addArrangedSubview(infoStackView)
        containerStackView.addArrangedSubview(descriptionLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        // Set content hugging priority to ensure the description label expands as needed
        repositoryNameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        infoStackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    // MARK: - Configuration
    
    func configure(with repository: Repository) {
        // Set repository name
        repositoryNameLabel.text = repository.name
        
        // Set language if available
        if let language = repository.language {
            languageLabel.text = language
            languageLabel.isHidden = false
        } else {
            languageLabel.isHidden = true
        }
        
        // Always show spacer to maintain layout
        spacerView.isHidden = false
        
        // Set stars count with ⭐️ emoji if stars > 0
        if repository.starsCount > 0 {
            starsLabel.text = "\(repository.starsCount) ⭐️"
            starsLabel.isHidden = false
        } else {
            starsLabel.isHidden = true
        }
        
        // Set description if available
        if let description = repository.description, !description.isEmpty {
            descriptionLabel.text = description
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
    }
}
