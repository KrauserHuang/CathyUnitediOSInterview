//
//  FriendTableViewCell.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    private lazy var isTopImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var transferButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "轉帳"
        config.baseBackgroundColor = .systemPink
        config.background.strokeColor = .systemPink
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var invitingButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "邀請中"
        config.baseBackgroundColor = .systemBlue
        config.background.strokeColor = .systemBlue
        let button = UIButton(configuration: config)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var moreActionButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "ellipsis")
        config.baseForegroundColor = .systemGray
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [isTopImageView, avatarImageView, nameLabel, UIView(), transferButton, invitingButton, moreActionButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(hStackView)
        
        NSLayoutConstraint.activate([
            hStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            isTopImageView.widthAnchor.constraint(equalToConstant: 24),
            isTopImageView.heightAnchor.constraint(equalToConstant: 24),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with friend: Friend) {
        nameLabel.text = friend.name
    }
}
