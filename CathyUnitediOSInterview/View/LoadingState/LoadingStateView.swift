//
//  LoadingStateView.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import UIKit

class LoadingStateView: UIView {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "資料讀取中..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, loadingLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
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
        
        NSLayoutConstraint.activate([
            vStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            vStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            vStackView.topAnchor.constraint(equalTo: topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            activityIndicator.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
        isHidden = false
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        isHidden = true
    }
}