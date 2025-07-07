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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.refreshControl = UIRefreshControl()
        return scrollView
    }()
    
    private let refreshControl = UIRefreshControl()
    private let userInfoHeaderView = UserInfoHeaderView()
    private let friendInvitationListView = FriendInvitationListView()
    private let pagingHeaderView = PagingHeaderView(titles: ["好友", "聊天"])
    private let emptyStateView = EmptyStateView()
    private let loadingStateView = LoadingStateView()
    private let errorStateView = ErrorStateView()
    private let friendListView = FriendListView()
    private let vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    
    private let scenario: FriendPageScenario
    private let viewModel: FriendsViewControllerVM
    
    private var friendInvitationListHeightConstraint: NSLayoutConstraint?
    private var friendListHeightConstraint: NSLayoutConstraint?
    private var subscriptions: Set<AnyCancellable> = []
    private let networkMonitor = NetworkMonitor.shared
    
    init(scenario: FriendPageScenario) {
        self.scenario = scenario
        self.viewModel = FriendsViewControllerVM(scenario: scenario)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationBar()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        
        refreshControl.addTarget(self, action: #selector(refreshFriendList(_:)), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
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
        setupLoadingStateView()
        setupErrorStateView()
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
    
    private func setupLoadingStateView() {
        loadingStateView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.addArrangedSubview(loadingStateView)
        loadingStateView.isHidden = true
    }
    
    private func setupErrorStateView() {
        errorStateView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.addArrangedSubview(errorStateView)
        errorStateView.isHidden = true
    }
    
    private func setupFriendListView() {
        friendListView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.addArrangedSubview(friendListView)
        friendListView.delegate = self
        
        let heightConstraint = friendListView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        friendListHeightConstraint = heightConstraint
    }
    
    private func scrollToFriendList(animated: Bool = true) {
        // 確保 layout 是最新的
        view.layoutIfNeeded()
        
        // 計算好友列表在 stackView 中的位置
        var targetY: CGFloat = 0
        
        // 累加前面所有 view 的高度
        targetY += userInfoHeaderView.frame.height
        targetY += vStackView.spacing // stackView spacing
        
        if !friendInvitationListView.isHidden {
            targetY += friendInvitationListView.frame.height
            targetY += vStackView.spacing
        }
        
        targetY += pagingHeaderView.frame.height
        targetY += vStackView.spacing
        
        // 設定滾動位置，確保不超過最大滾動範圍
        let maxOffsetY = max(0, scrollView.contentSize.height - scrollView.frame.height)
        let finalTargetY = min(targetY, maxOffsetY)
        
        let targetPoint = CGPoint(x: 0, y: finalTargetY)
        scrollView.setContentOffset(targetPoint, animated: animated)
    }
    
    @objc
    private func refreshFriendList(_ sender: UIRefreshControl) {
        Task {
            await viewModel.reloadFriendList()
        }
    }
    
    private func showErrorAlert() {
        guard let error = viewModel.currentError else { return }
        
        let title: String
        let message: String
        
        if let apiError = error as? APIError {
            title = "連線異常"
            message = apiError.errorDescription ?? "發生未知錯誤"
        } else {
            title = "錯誤"
            message = error.localizedDescription
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "重試", style: .default) { [weak self] _ in
            Task {
                await self?.viewModel.retry()
            }
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in
            self?.viewModel.clearError()
        })
        
        present(alert, animated: true)
    }
    
    private func updateNetworkStatusUI(_ networkStatus: NetworkStatus) {
        switch networkStatus {
        case .disconnected:
            showNetworkDisconnectedBanner()
        case .connected, .wifi, .cellular, .wired:
            hideNetworkDisconnectedBanner()
        }
    }
    
    private func showNetworkDisconnectedBanner() {
        let banner = UIView()
        banner.backgroundColor = .systemRed
        banner.tag = 999
        
        let label = UILabel()
        label.text = "網路連線中斷"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        banner.addSubview(label)
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        if view.viewWithTag(999) == nil {
            view.addSubview(banner)
            
            NSLayoutConstraint.activate([
                banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                banner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                banner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                banner.heightAnchor.constraint(equalToConstant: 30),
                
                label.centerXAnchor.constraint(equalTo: banner.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: banner.centerYAnchor)
            ])
        }
    }
    
    private func hideNetworkDisconnectedBanner() {
        view.viewWithTag(999)?.removeFromSuperview()
    }
    
    private func updateUI() {
        let hasInviteFriends                = !viewModel.inviteFriends.isEmpty
        let hasFriends                      = !viewModel.friends.isEmpty
        let hasError                        = viewModel.hasError
        let isLoading                       = viewModel.isLoading
        
        friendInvitationListView.isHidden   = !hasInviteFriends || hasError || isLoading
        emptyStateView.isHidden             = hasFriends || hasError || isLoading
        friendListView.isHidden             = !hasFriends || hasError || isLoading
        errorStateView.isHidden             = !hasError
        loadingStateView.isHidden           = !isLoading
        
        if isLoading {
            loadingStateView.startLoading()
        } else {
            loadingStateView.stopLoading()
        }
        
        if hasError, let error = viewModel.currentError {
            errorStateView.configure(with: error)
        }
        
        if hasInviteFriends && !hasError && !isLoading {
            friendInvitationListView.configure(with: viewModel.inviteFriends)
            friendInvitationListView.setNeedsLayout()
            friendInvitationListView.layoutIfNeeded()
        }
        
        if hasFriends && !hasError && !isLoading {
            friendListView.configure(with: viewModel.friends)
            friendListView.setNeedsLayout()
            friendListView.layoutIfNeeded()
        }
    }
    
    private func setupBindings() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self else { return }
                if let user = user {
//                    userInfoHeaderView.configure(with: user)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$inviteFriends
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inviteFriends in
                guard let self else { return }
                friendInvitationListView.configure(with: inviteFriends)
                refreshControl.endRefreshing()
            }
            .store(in: &subscriptions)
        
        viewModel.$friends
            .receive(on: DispatchQueue.main)
            .sink { [weak self] friends in
                guard let self else { return }
                friendListView.updateFriends(friends)
                refreshControl.endRefreshing()
            }
            .store(in: &subscriptions)
            
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                if !isLoading {
                    refreshControl.endRefreshing()
                }
                updateUI()
            }
            .store(in: &subscriptions)
        
        viewModel.$hasError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasError in
                guard let self else { return }
                updateUI()
                if hasError {
                    showErrorAlert()
                }
            }
            .store(in: &subscriptions)
        
        networkMonitor.$networkStatus
            .receive(on: DispatchQueue.main)
            .print("🛜 networkStatus")
            .sink { [weak self] networkStatus in
                guard let self else { return }
                updateNetworkStatusUI(networkStatus)
            }
            .store(in: &subscriptions)
        
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
    
    func friendListViewDidBeginSearch(_ view: FriendListView) {
        scrollToFriendList()
    }
}

// MARK: - PagingHeaderViewDelegate
extension FriendsViewController: PagingHeaderViewDelegate {
    func pagingHeaderView(_ pagingHeaderView: PagingHeaderView, didSelect index: Int) {
        print("選擇了索引：\(index)")
    }
}
