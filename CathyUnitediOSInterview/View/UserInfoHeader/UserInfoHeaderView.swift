//
//  UserInfoHeaderView.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import UIKit

class UserInfoHeaderView: UIView {
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "紫晽"
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var kokoIdButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "設定 KOKO ID"
        config.image = UIImage(resource: .icInfoBackDeepGray).withConfiguration(UIImage.SymbolConfiguration(pointSize: 18))
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.baseForegroundColor = .secondaryLabel
        config.contentInsets = .zero
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 13)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            var config = button.configuration
            config?.title = (kokoid.isEmpty) ? "設定 KOKO ID" : "KOKO ID：\(kokoid)"
            button.configuration = config
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var userInfoVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [usernameLabel, kokoIdButton])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .imgFriendsFemaleDefault).withConfiguration(UIImage.SymbolConfiguration(pointSize: 54))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userInfoVStackView, UIView(), userImageView])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var kokoid: String = "" {
        didSet {
            kokoIdButton.setNeedsUpdateConfiguration()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStackView)
        
        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
    }
    
    func configure(with user: User) {
        usernameLabel.text = user.name
        kokoid = user.kokoid
    }
}
