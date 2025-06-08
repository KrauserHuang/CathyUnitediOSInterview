//
//  FriendsViewController.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import UIKit

enum FriendsVCEntryStatus {
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
    private let vStackView = UIStackView()
    private let entryStatus: FriendsVCEntryStatus
    
    init(entryStatus: FriendsVCEntryStatus) {
        self.entryStatus = entryStatus
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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
    }
    
    private func setupUserInfoView() {
        userInfoHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        vStackView.addArrangedSubview(userInfoHeaderView)
    }
}
