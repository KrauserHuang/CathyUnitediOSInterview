//
//  FriendInvitationTableViewCell.swift
//  CathyUnitediOSInterview
//
//  Created by IT-MAC-02 on 2025/6/9.
//

import UIKit

class FriendInvitationTableViewCell: UITableViewCell {
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "邀請你成為好友：）"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, subTitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var acceptButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .btnFriendsAgree).withConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
        config.background.backgroundColor = .clear
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var declineButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .btnFriendsDelet).withConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
        config.background.backgroundColor = .clear
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, labelVStackView, UIView(), acceptButton, declineButton])
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.alignment = .center
        stackView.clipsToBounds = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(hStackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            hStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            hStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            hStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            hStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor, multiplier: 1.0)
        ])
    }
    
    func configure(with friend: Friend) {
        nameLabel.text = friend.name
    }
}
