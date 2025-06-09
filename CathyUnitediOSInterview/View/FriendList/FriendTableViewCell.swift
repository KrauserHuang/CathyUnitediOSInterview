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
        config.image = UIImage(systemName: "star.fill")
        config.baseForegroundColor = .systemYellow
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        button.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            var config = button.configuration
            config?.baseForegroundColor = isTop ? .systemYellow : .white
            button.configuration = config
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var transferButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "轉帳"
        config.baseForegroundColor = .systemPink
        config.background.strokeColor = .systemPink
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        config.background.backgroundColor = .white
        config.cornerStyle = .small
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { outgoing in
            var incoming = outgoing
            incoming.font = UIFont.preferredFont(forTextStyle: .caption1)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var invitingButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "邀請中"
        config.baseForegroundColor = .secondaryLabel
        config.background.strokeColor = .secondaryLabel
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        config.background.backgroundColor = .white
        config.cornerStyle = .small
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { outgoing in
            var incoming = outgoing
            incoming.font = UIFont.preferredFont(forTextStyle: .caption1)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var moreActionButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "ellipsis")
        config.baseForegroundColor = .systemGray
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [isTopButton, avatarImageView, nameLabel, UIView(), transferButton, invitingButton, moreActionButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            hStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding * 2),
            hStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding * 2),
            hStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor, multiplier: 1.0)
        ])
    }
    
    func configure(with friend: Friend) {
        nameLabel.text              = friend.name
        isTop                       = friend.starred
        invitingButton.isHidden     = !(friend.friendStatus == .inviting)
        moreActionButton.isHidden   = (friend.friendStatus == .inviting)
    }
}
