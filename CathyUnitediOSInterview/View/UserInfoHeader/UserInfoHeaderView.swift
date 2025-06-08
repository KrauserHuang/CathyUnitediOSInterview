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
        label.text = "紫瞵"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var kokoIdButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "設定 KOKO ID"
        config.image = UIImage(systemName: "chevron.forward")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.baseForegroundColor = .secondaryLabel
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
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
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
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            
            userImageView.widthAnchor.constraint(equalToConstant: 60),
            userImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
