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
        imageView.image = UIImage(resource: .emptyState)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "就從加好友開始吧 ：）"
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateSubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "與好友們一起用 KOKO 聊起來！\n還能互相收付款、發紅包喔：）"
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addFriendButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "加好友"
        config.image = UIImage(systemName: "face.smiling.inverse")
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
            return outgoing
        }
        config.imagePlacement = .trailing
        config.imagePadding = 10
        config.baseForegroundColor = .white
        config.background.backgroundColor = .systemGreen
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 60, bottom: 12, trailing: 60)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "幫助好友更快找到你？"
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var setupIDButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "設定 KOKO ID"
        config.baseForegroundColor = .systemPink
        config.contentInsets = .zero
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .subheadline)
            return outgoing
        }
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
        
        vStackView.setCustomSpacing(10, after: emptyStateTitleLabel)
        
        NSLayoutConstraint.activate([
            vStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            vStackView.topAnchor.constraint(equalTo: topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 300),
        ])
    }
}
