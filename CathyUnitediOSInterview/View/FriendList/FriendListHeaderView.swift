//
//  FriendListHeaderView.swift
//  CathyUnitediOSInterview
//
//  Created by IT-MAC-02 on 2025/6/9.
//

import UIKit

protocol FriendListHeaderViewDelegate: AnyObject {
    func friendListHeaderView(_ headerView: FriendListHeaderView, didUpdateSearchText searchText: String)
    func friendListHeaderViewDidCancelSearch(_ headerView: FriendListHeaderView)
}

class FriendListHeaderView: UITableViewHeaderFooterView {
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundColor = .clear
        searchBar.searchBarStyle = .minimal // 設完才可以設定backgroundColor
        searchBar.tintColor = .black
        searchBar.placeholder = "想轉一筆給誰呢？"
        searchBar.delegate = self
        searchBar.searchTextField.textContentType = nil
        searchBar.searchTextField.keyboardType = .default
        searchBar.searchTextField.autocorrectionType = .no
        searchBar.searchTextField.autocapitalizationType = .none
        return searchBar
    }()
    
    private lazy var addFriendButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .icBtnAddFriends).withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
        config.background.backgroundColor = .clear
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [searchBar, addFriendButton])
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    weak var delegate: FriendListHeaderViewDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        addSubview(hStackView)
        
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: padding / 2),
            hStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
            hStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -30),
            hStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding / 2),
        ])
    }
}

extension FriendListHeaderView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.friendListHeaderView(self, didUpdateSearchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text, !searchText.isEmpty {
            delegate?.friendListHeaderView(self, didUpdateSearchText: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        delegate?.friendListHeaderViewDidCancelSearch(self)
    }
}
