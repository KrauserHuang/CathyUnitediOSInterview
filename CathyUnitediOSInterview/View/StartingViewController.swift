//
//  StartingViewController.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import UIKit

class StartingViewController: UIViewController {
    
    // 無友好畫面
    private lazy var noFriendsButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "無友好畫面"
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // 只有好友列表
    private lazy var friendsButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "只有好友列表"
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // 好友列表含邀請
    private lazy var friendsWithInvitationsButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "好友列表含邀請"
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [noFriendsButton, friendsButton, friendsWithInvitationsButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupButtonActions()
    }
    
    private func setupUI() {
        view.addSubview(vStackView)
        
        NSLayoutConstraint.activate([
            vStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            vStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func setupButtonActions() {
        noFriendsButton.addTarget(self, action: #selector(noFriendsButtonTapped(_:)), for: .touchUpInside)
        friendsButton.addTarget(self, action: #selector(friendsButtonTapped(_:)), for: .touchUpInside)
        friendsWithInvitationsButton.addTarget(self, action: #selector(friendsWithInvitationsButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc
    private func noFriendsButtonTapped(_ sender: UIButton) {
        let vc = FriendsViewController(entryStatus: .noFriends)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func friendsButtonTapped(_ sender: UIButton) {
        let vc = FriendsViewController(entryStatus: .friends)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func friendsWithInvitationsButtonTapped(_ sender: UIButton) {
        let vc = FriendsViewController(entryStatus: .friendsWithInvitations)
        navigationController?.pushViewController(vc, animated: true)
    }
}
