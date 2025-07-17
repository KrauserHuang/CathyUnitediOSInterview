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
    // MARK: - UI 元件
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.refreshControl = UIRefreshControl()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let refreshControl = UIRefreshControl()
    private let userInfoHeaderView = UserInfoHeaderView()
    private let friendInvitationListView = FriendInvitationListView()
    private let pagingHeaderView = PagingHeaderView(titles: ["好友", "聊天"])
    private let emptyStateView = EmptyStateView()
    private let loadingStateView = LoadingStateView()
    private let friendListView = FriendListView()
    private let vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let scenario: FriendPageScenario
    private let viewModel: FriendsViewControllerVM
    private let networkMonitor = NetworkMonitor.shared
    private var subscriptions: Set<AnyCancellable> = []
    private var friendInvitationListHeightConstraint: NSLayoutConstraint?
    private var friendListHeightConstraint: NSLayoutConstraint?
    private let searchDebouncer = PerformanceOptimizations.SearchDebouncer()
    
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
        
        refreshControl.addTarget(self, action: #selector(refreshFriendList(_:)), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        view.addSubview(scrollView)
        scrollView.addSubview(vStackView)
        view.addSubview(loadingStateView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            vStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            vStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            loadingStateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loadingStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
        
        // 加入各區塊
        [userInfoHeaderView,
         friendInvitationListView,
         pagingHeaderView,
         emptyStateView,
         friendListView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            vStackView.addArrangedSubview($0)
        }
        
        // 初始隱藏
        emptyStateView.isHidden = true
        loadingStateView.isHidden = true
        
        // 高度約束
        friendInvitationListHeightConstraint = friendInvitationListView.heightAnchor.constraint(equalToConstant: 0)
        friendInvitationListHeightConstraint?.isActive = true
        friendListHeightConstraint = friendListView.heightAnchor.constraint(equalToConstant: 0)
        friendListHeightConstraint?.isActive = true
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
    private func navTransferButtonTapped(_ sender: UIBarButtonItem) {}
    
    @objc
    private func navScanButtonTapped(_ sender: UIBarButtonItem) {}
    
    private func setupBindings() {
        viewModel.$user
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self else { return }
                userInfoHeaderView.configure(with: user)
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
            .combineLatest(viewModel.$currentError)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasError, currentError in
                guard let self else { return }
                updateUI()
            }
            .store(in: &subscriptions)
        
        networkMonitor.$networkStatus
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                if #available(iOS 17.0, *) {
                    updateNetworkContentUnavailable(status)
                } else {
                    updateNetworkStatusUI(status)
                }
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
        
        friendListView.actionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self else { return }
                
                switch action {
                case .updateSearchText(let searchText):
                    // Use debounced search for better performance
                    searchDebouncer.debounce { [weak self] in
                        guard let self else { return }
                        viewModel.updateSearchText(searchText)
                        friendListView.updateFriends(viewModel.filteredFriends)
                    }
                    
                case .beginSearch:
                    scrollToFriendList()
                    
                case .cancelSearch:
                    viewModel.updateSearchText("")
                    friendListView.updateFriends(viewModel.friends)
                }
            }
            .store(in: &subscriptions)
        
        pagingHeaderView.actionPublisher
            .receive(on: DispatchQueue.main)
            .sink { action in
                switch action {
                case .selectPage(let index):
                    print("選擇了索引：\(index)")
                }
            }
            .store(in: &subscriptions)
    }
    
    private func updateUI() {
        let hasInviteFriends                = !viewModel.inviteFriends.isEmpty
        let hasFriends                      = !viewModel.friends.isEmpty
        let hasError                        = viewModel.hasError
        let isLoading                       = viewModel.isLoading
        
        friendInvitationListView.isHidden   = !hasInviteFriends || hasError || isLoading
        emptyStateView.isHidden             = hasFriends || hasError || isLoading
        friendListView.isHidden             = !hasFriends || hasError || isLoading
        loadingStateView.isHidden           = !isLoading
        
        if isLoading {
            loadingStateView.startLoading()
        } else {
            loadingStateView.stopLoading()
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
    
    // MARK: - 網路狀態顯示 (iOS 17+)
    @available(iOS 17.0, *)
    private func updateNetworkContentUnavailable(_ status: NetworkStatus) {
        if status == .disconnected {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "wifi.slash")
            config.text = "網路連線中斷"
            config.secondaryText = "請檢查您的網路設定"
            
            var buttonConfig = UIButton.Configuration.filled()
            buttonConfig.title = "重試"
            config.button = buttonConfig
            config.buttonProperties.primaryAction = UIAction { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.viewModel.retry()
                    self.setNeedsUpdateContentUnavailableConfiguration()
                }
            }
            
            contentUnavailableConfiguration = config
        } else {
            contentUnavailableConfiguration = nil
        }
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    // iOS 16 以下的實作
    private func showErrorOverlay(_ error: Error) {
        let errorView = ErrorStateView()
        errorView.configure(with: error)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.alpha = 0
        
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
        
        var errorViewSubscriptions = Set<AnyCancellable>()
        
        errorView.onRetry
            .sink { [weak self] _ in
                self?.hideErrorOverlay(errorView)
                Task {
                    await self?.viewModel.retry()
                }
            }
            .store(in: &errorViewSubscriptions)
        
        errorView.onDismiss
            .sink { [weak self] _ in
                self?.hideErrorOverlay(errorView)
                self?.viewModel.clearError()
            }
            .store(in: &errorViewSubscriptions)
        
        // 保存 subscriptions 避免被釋放
        objc_setAssociatedObject(errorView, "subscriptions", errorViewSubscriptions, .OBJC_ASSOCIATION_RETAIN)
        
        // 動畫顯示
        UIView.animate(withDuration: 0.3) {
            errorView.alpha = 1
        }
    }
    
    private func hideErrorOverlay(_ errorView: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            errorView.alpha = 0
        }) { _ in
            errorView.removeFromSuperview()
        }
    }
}
