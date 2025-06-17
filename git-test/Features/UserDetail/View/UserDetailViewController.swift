import UIKit

final class UserDetailViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let userInfoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let followersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let followersCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let followersTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = String.followersTitle
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let followingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let followingCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let followingTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = String.followingTitle
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let errorView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        return stackView
    }()
    
    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemRed
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(String.retryButtonTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    weak var coordinator: UserDetailCoordinator?
    private var viewModel: UserDetailViewModelProtocol
    private var repositories: [Repository] = []
    
    // MARK: - Initialization
    
    init(viewModel: UserDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the display mode for this specific view controller
        // This doesn't change the global prefersLargeTitles setting
        navigationItem.largeTitleDisplayMode = .never
        
        setupView()
        setupBindings()
        viewModel.viewDidLoad()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(userInfoContainerView)
        view.addSubview(tableView)
        view.addSubview(loadingView)
        
        errorView.addArrangedSubview(errorImageView)
        errorView.addArrangedSubview(errorLabel)
        errorView.addArrangedSubview(retryButton)
        view.addSubview(errorView)
        
        userInfoContainerView.addSubview(userImageView)
        userInfoContainerView.addSubview(usernameLabel)
        userInfoContainerView.addSubview(nameLabel)
        userInfoContainerView.addSubview(statsStackView)
        
        followersStackView.addArrangedSubview(followersCountLabel)
        followersStackView.addArrangedSubview(followersTextLabel)
        
        followingStackView.addArrangedSubview(followingCountLabel)
        followingStackView.addArrangedSubview(followingTextLabel)
        
        statsStackView.addArrangedSubview(followersStackView)
        statsStackView.addArrangedSubview(followingStackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // User info container
            userInfoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            userInfoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userInfoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // User Image
            userImageView.topAnchor.constraint(equalTo: userInfoContainerView.topAnchor, constant: 10),
            userImageView.centerXAnchor.constraint(equalTo: userInfoContainerView.centerXAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 80),
            userImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Username Label
            usernameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 16),
            usernameLabel.leadingAnchor.constraint(equalTo: userInfoContainerView.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: userInfoContainerView.trailingAnchor, constant: -20),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: userInfoContainerView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: userInfoContainerView.trailingAnchor, constant: -20),
            
            // Stats Stack
            statsStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            statsStackView.centerXAnchor.constraint(equalTo: userInfoContainerView.centerXAnchor),
            statsStackView.bottomAnchor.constraint(equalTo: userInfoContainerView.bottomAnchor, constant: -24),
            
            // TableView for repositories
            tableView.topAnchor.constraint(equalTo: userInfoContainerView.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Loading View
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Error View
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            errorImageView.widthAnchor.constraint(equalToConstant: 60),
            errorImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Setup actions
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onStateChanged = { [weak self] state in
            self?.handleStateChange(state)
        }
    }
    
    // MARK: - Actions
    
    @objc private func retryButtonTapped() {
        viewModel.refreshData()
    }
    
    // MARK: - State Handling
    
    private func handleStateChange(_ state: UserDetailState) {
        switch state {
        case .loading:
            showLoadingState()
        case .loaded(let userDetail, let repositories):
            showLoadedState(userDetail: userDetail, repositories: repositories)
        case .error(let message):
            showErrorState(message: message)
        }
    }
    
    private func showLoadingState() {
        userInfoContainerView.isHidden = true
        tableView.isHidden = true
        errorView.isHidden = true
        loadingView.startAnimating()
    }
    
    private func showLoadedState(userDetail: UserDetail, repositories: [Repository]) {
        loadingView.stopAnimating()
        errorView.isHidden = true
        userInfoContainerView.isHidden = false
        tableView.isHidden = false
        
        // Set user details
        usernameLabel.text = userDetail.login
        nameLabel.text = userDetail.name
        nameLabel.isHidden = userDetail.name == nil
        
        followersCountLabel.text = "\(userDetail.followers)"
        followingCountLabel.text = "\(userDetail.following)"
        
        // Update repositories and reload table view
        self.repositories = repositories
        tableView.reloadData()
        
        // Load avatar image
        if let avatarUrl = URL(string: userDetail.avatarUrl) {
            URLSession.shared.dataTask(with: avatarUrl) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.userImageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    private func showErrorState(message: String) {
        loadingView.stopAnimating()
        userInfoContainerView.isHidden = true
        tableView.isHidden = true
        errorLabel.text = message
        errorView.isHidden = false
    }
}

// MARK: - UITableViewDataSource

extension UserDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.reuseIdentifier, for: indexPath) as? RepositoryTableViewCell else {
            return UITableViewCell()
        }
        
        let repository = repositories[indexPath.row]
        cell.configure(with: repository)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension UserDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let url = URL(string: repositories[indexPath.row].htmlUrl) {
            coordinator?.showRepositoryWebView(with: url)
        }
    }
}
