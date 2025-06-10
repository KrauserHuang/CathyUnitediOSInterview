//
//  EmptyStateView.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import UIKit

class EmptyStateView: UIView {
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .imgFriendsEmpty)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "就從加好友開始吧 ：）"
        label.font = UIFont.systemFont(ofSize: 21)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateSubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "與好友們一起用 KOKO 聊起來！\n還能互相收付款、發紅包喔：）"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addFriendButton: GradientButtonView = {
        let button = GradientButtonView()
        button.title = "加好友"
        button.icon = UIImage(resource: .icAddFriendWhite)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "幫助好友更快找到你？"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var setupIDButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .hotPink
        config.contentInsets = .zero
        let attributedTitle = NSAttributedString(
            string: "設定 KOKO ID",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.hotPink,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        config.attributedTitle = AttributedString(attributedTitle)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var notificationHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [notificationLabel, setupIDButton])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyStateImageView, emptyStateTitleLabel, emptyStateSubTitleLabel, addFriendButton, notificationHStackView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(vStackView)
        
        vStackView.setCustomSpacing(41, after: emptyStateImageView)
        vStackView.setCustomSpacing(8, after: emptyStateTitleLabel)
        vStackView.setCustomSpacing(25, after: emptyStateSubTitleLabel)
        vStackView.setCustomSpacing(37, after: addFriendButton)
        
        NSLayoutConstraint.activate([
            vStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            vStackView.topAnchor.constraint(equalTo: topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 300),
            addFriendButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}
