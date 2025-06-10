//
//  FriendTableViewCell.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    private lazy var isTopButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .icFriendsStar).withConfiguration(UIImage.SymbolConfiguration(pointSize: 14))
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        button.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            var config = button.configuration
            button.configuration = config
            button.alpha = isTop ? 1 : 0
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .imgFriendsList).withConfiguration(UIImage.SymbolConfiguration(pointSize: 40))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var transferButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "轉帳"
        config.baseForegroundColor = .hotPink
        config.background.strokeColor = .hotPink
        config.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 9, bottom: 2, trailing: 9)
        config.background.backgroundColor = .white
        config.background.cornerRadius = 2
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var invitingButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "邀請中"
        config.baseForegroundColor = .lightGray
        config.background.strokeColor = .pinkishGrey
        config.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 9, bottom: 2, trailing: 9)
        config.background.backgroundColor = .white
        config.background.cornerRadius = 2
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var moreActionButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .icFriendsMore)
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [isTopButton, avatarImageView, nameLabel, UIView(), transferButton, invitingButton, moreActionButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .opaqueSeparator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var isTop: Bool = false {
        didSet {
            isTopButton.setNeedsUpdateConfiguration()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        isTop = false
        avatarImageView.image = nil
        nameLabel.text = nil
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(hStackView)
        contentView.addSubview(underlineView)
        
        hStackView.setCustomSpacing(6, after: isTopButton)
        hStackView.setCustomSpacing(15, after: avatarImageView)
        
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            hStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding * 3),
            hStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding * 3),
            hStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor, multiplier: 1.0),
            
            underlineView.heightAnchor.constraint(equalToConstant: 1),
            underlineView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding * 3),
            underlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func configure(with friend: Friend) {
        nameLabel.text              = friend.name
        isTop                       = friend.starred
        invitingButton.isHidden     = !(friend.friendStatus == .inviting)
        moreActionButton.isHidden   = (friend.friendStatus == .inviting)
    }
}
