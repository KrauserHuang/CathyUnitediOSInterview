//
//  FriendsViewController.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Combine
import UIKit

enum FriendPageScenario: CaseIterable {
    case noFriends
    case friends
    case friendsWithInvitations
    
    var descriptions: String {
        switch self {
        case .noFriends: return "無好友畫⾯"
        case .friends: return "只有好友列表"
        case .friendsWithInvitations: return "好友列表含邀請"
        }
    }
}

class FriendsViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let userInfoHeaderView = UserInfoHeaderView()
    private let friendInvitationListView = FriendInvitationListView()
    private let pagingHeaderView = PagingHeaderView(titles: ["好友", "聊天"])
    private let emptyStateView = EmptyStateView()
    private let friendListView = FriendListView()
    private let vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    
    private let entryStatus: FriendPageScenario
    private let viewModel: FriendsViewControllerVM
    
    private var friendInvitationListHeightConstraint: NSLayoutConstraint?
    private var friendListHeightConstraint: NSLayoutConstraint?
    private var subscriptions: Set<AnyCancellable> = []
    
    init(entryStatus: FriendPageScenario) {
        self.entryStatus = entryStatus
        self.viewModel = FriendsViewControllerVM(scenario: entryStatus)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationBar()
        loadScenario()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(vStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            vStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            vStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        setupUserInfoView()
        setupFriendInvitationListView()
        setupPagingHeaderView()
        setupEmptyStateView()
        setupFriendListView()
    }
    
    private func setupNavigationBar() {
        let navWithdrawButton = UIBarButtonItem(
            image: UIImage(resource: .icNavPinkWithdraw),
            style: .plain,
            target: self,
            action: #selector(navWithdrawButtonTapped)
        )
        let navTransferButton = UIBarButtonItem(
            image: UIImage(resource: .icNavPinkTransfer),
            style: .plain,
            target: self,
            action: #selector(navTransferButtonTapped)
        )
        let navScanButton = UIBarButtonItem(
            image: UIImage(resource: .icNavPinkScan),
            style: .plain,
            target: self,
            action: #selector(navScanButtonTapped)
        )
        navigationItem.leftBarButtonItems = [navWithdrawButton, navTransferButton]
        navigationItem.rightBarButtonItem = navScanButton
        navigationController?.navigationBar.tintColor = .hotPink
    }
    
    @objc
    private func navWithdrawButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func navTransferButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @objc
    private func navScanButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    private func setupUserInfoView() {
        userInfoHeaderView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.addArrangedSubview(userInfoHeaderView)
    }
    
    private func setupFriendInvitationListView() {
        friendInvitationListView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.addArrangedSubview(friendInvitationListView)
        
        let heightConstraint = friendInvitationListView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        friendInvitationListHeightConstraint = heightConstraint
    }
    
    private func setupPagingHeaderView() {
        pagingHeaderView.translatesAutoresizingMaskIntoConstraints = false
        pagingHeaderView.delegate = self
        vStackView.addArrangedSubview(pagingHeaderView)
    }
    
    private func setupEmptyStateView() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.addArrangedSubview(emptyStateView)
        emptyStateView.isHidden = true
    }
    
    private func setupFriendListView() {
        friendListView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.addArrangedSubview(friendListView)
        friendListView.delegate = self
        
        let heightConstraint = friendListView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        friendListHeightConstraint = heightConstraint
    }
    
    private func loadScenario() {
        Task {
            await viewModel.loadScenario()
            updateUI()
        }
    }
    
    private func updateUI() {
        let hasInviteFriends                = !viewModel.inviteFriends.isEmpty
        let hasFriends                      = !viewModel.friends.isEmpty
        friendInvitationListView.isHidden   = !hasInviteFriends
        emptyStateView.isHidden             = hasFriends
        friendListView.isHidden             = !hasFriends
        
        if hasInviteFriends {
            friendInvitationListView.configure(with: viewModel.inviteFriends)
            friendInvitationListView.setNeedsLayout()
            friendInvitationListView.layoutIfNeeded()
        }
        
        if hasFriends {
            friendListView.configure(with: viewModel.friends)
            friendListView.setNeedsLayout()
            friendListView.layoutIfNeeded()
        }
    }
    
    private func setupBindings() {
        friendInvitationListView.$height
            .receive(on: DispatchQueue.main)
            .sink { [weak self] height in
                guard let self else { return }
                friendInvitationListHeightConstraint?.constant = height
                view.layoutIfNeeded()
            }
            .store(in: &subscriptions)
        
        friendListView.$height
            .receive(on: DispatchQueue.main)
            .sink { [weak self] height in
                guard let self else { return }
                friendListHeightConstraint?.constant = height
                view.layoutIfNeeded()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - UISearchBarDelegate & UISearchResultsUpdating
extension FriendsViewController: FriendListViewDelegate {
    func friendListView(_ view: FriendListView, didUpdateSearchText searchText: String) {
        print("搜尋字：", searchText)
        viewModel.updateSearchText(searchText)
        friendListView.updateFriends(viewModel.filteredFriends)
    }
    
    func friendListViewDidCancelSearch(_ view: FriendListView) {
        viewModel.updateSearchText("")
        friendListView.updateFriends(viewModel.friends)
    }
}

// MARK: - PagingHeaderViewDelegate
extension FriendsViewController: PagingHeaderViewDelegate {
    func pagingHeaderView(_ pagingHeaderView: PagingHeaderView, didSelect index: Int) {
        print("選擇了索引：\(index)")
    }
}
