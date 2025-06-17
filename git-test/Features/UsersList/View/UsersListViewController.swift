//
//  UsersListViewController.swift
//  git-test
//
//  Created by Carlos Andres Mendieta Triana on 16/06/25.
//

import UIKit

final class UsersListViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 70
        tableView.isHidden = true
        return tableView
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
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(String.retryButtonTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    weak var coordinator: UsersListCoordinator?
    private var viewModel: UsersListViewModelProtocol
    private var users: [User] = []
    private var originalUsers: [User] = []
    private var isSearchActive = false
    
    // MARK: - Initialization
    
    init(viewModel: UsersListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchController()
        setupBindings()
        viewModel.viewDidLoad()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        title = "screen_title".localized
        view.backgroundColor = .systemBackground
        
        // Configure navigation bar appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(loadingView)
        
        errorView.addArrangedSubview(errorImageView)
        errorView.addArrangedSubview(errorLabel)
        errorView.addArrangedSubview(refreshButton)
        view.addSubview(errorView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            errorImageView.widthAnchor.constraint(equalToConstant: 60),
            errorImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Setup actions
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onStateChanged = { [weak self] state in
            self?.handleStateChange(state)
        }
    }
    
    private func setupSearchController() {
        // Configure search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "search.placeholder".localized
        searchController.searchBar.delegate = self
        
        // Configure search bar appearance
        searchController.searchBar.tintColor = .label
        searchController.searchBar.searchTextField.backgroundColor = .systemGray6
        
        // Add search controller to navigation bar
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Define the scope bar behavior
        definesPresentationContext = true
    }
    
    private func setupTableViewFooter() {
        tableView.tableFooterView = nil
    }
    
    private func showTableViewLoadingFooter() {
        let footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        tableView.tableFooterView = footerView
    }
    
    // MARK: - Actions
    
    @objc private func refreshButtonTapped() {
        viewModel.refreshUsers()
    }
    
    // MARK: - State Handling
    
    private func handleStateChange(_ state: UsersListState) {
        switch state {
        case .loading:
            showLoadingState()
        case .loaded(let users):
            showLoadedState(users: users)
        case .loadingMore:
            showLoadingMoreState()
        case .loadedMore(let users):
            showLoadedMoreState(users: users)
        case .error(let message):
            showErrorState(message: message)
        }
    }
    
    private func showLoadingState() {
        tableView.isHidden = true
        errorView.isHidden = true
        setupTableViewFooter()
        loadingView.startAnimating()
    }
    
    private func showLoadedState(users: [User]) {
        self.users = users
        self.originalUsers = users
        loadingView.stopAnimating()
        errorView.isHidden = true
        tableView.isHidden = false
        setupTableViewFooter()
        tableView.reloadData()
    }
    
    private func showLoadingMoreState() {
        showTableViewLoadingFooter()
    }
    
    private func showLoadedMoreState(users: [User]) {
        self.users = users
        setupTableViewFooter()
        tableView.reloadData()
    }
    
    private func showErrorState(message: String) {
        loadingView.stopAnimating()
        setupTableViewFooter()
        tableView.isHidden = true
        errorLabel.text = message
        errorView.isHidden = false
    }
}

// MARK: - UITableViewDataSource

extension UsersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseIdentifier, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        let user = users[indexPath.row]
        cell.configure(with: user)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension UsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = users[indexPath.row]
        coordinator?.didSelectUser(with: selectedUser.login)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate position
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        // Check if reached bottom - with threshold of 100 points from bottom
        if offsetY > contentHeight - height - 100 && contentHeight > 0 {
            loadMoreUsersIfNeeded()
        }
    }
    
    private func loadMoreUsersIfNeeded() {
        // Check if already loading more
        guard !viewModel.isLoadingMore else { return }
        
        // Load more users
        viewModel.loadMoreUsers()
    }
}

// MARK: - UISearchResultsUpdating

extension UsersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // This will be implemented later to perform the actual search
        // For now, we're just setting up the UI components
    }
}

// MARK: - UISearchBarDelegate

extension UsersListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        viewModel.searchUsers(query: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearchActive = false
        // Let the ViewModel handle restoring original users
        viewModel.cancelSearch()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !isSearchActive {
            isSearchActive = true
            // Just clean the UI, data will be managed by ViewModel
            users = []
            tableView.reloadData()
        }
    }
}
