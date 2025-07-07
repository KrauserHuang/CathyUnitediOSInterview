//
//  ErrorStateView.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Combine
import UIKit

protocol ErrorStateViewDelegate: AnyObject {
    func didTapRetryButton(_ view: ErrorStateView)
}

class ErrorStateView: UIView {
    
    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let errorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "發生錯誤"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "無法載入資料，請檢查網路連線"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var retryButton: GradientButtonView = {
        let button = GradientButtonView()
        button.title = "重試"
        button.icon = UIImage(systemName: "arrow.clockwise")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [errorImageView, errorTitleLabel, errorMessageLabel, retryButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var subscription: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(vStackView)
        
        NSLayoutConstraint.activate([
            vStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            vStackView.topAnchor.constraint(equalTo: topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            errorImageView.heightAnchor.constraint(equalToConstant: 60),
            errorImageView.widthAnchor.constraint(equalToConstant: 60),
            retryButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func setupActions() {
        retryButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                
            }
    }
    
    func configure(with error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
            case .networkUnavailable:
                errorImageView.image = UIImage(systemName: "wifi.slash")
                errorTitleLabel.text = "網路連線異常"
                errorMessageLabel.text = "請檢查您的網路連線狀態"
                
            case .timeout:
                errorImageView.image = UIImage(systemName: "clock.badge.exclamationmark")
                errorTitleLabel.text = "連線逾時"
                errorMessageLabel.text = "請求處理時間過長，請稍後再試"
                
            case .tooManyRetries:
                errorImageView.image = UIImage(systemName: "arrow.clockwise.circle")
                errorTitleLabel.text = "重試次數過多"
                errorMessageLabel.text = "系統正在維護中，請稍後再試"
                
            case .decodingError:
                errorImageView.image = UIImage(systemName: "doc.text.fill")
                errorTitleLabel.text = "資料格式錯誤"
                errorMessageLabel.text = "伺服器回應格式異常"
                
            case .noData:
                errorImageView.image = UIImage(systemName: "tray")
                errorTitleLabel.text = "無資料"
                errorMessageLabel.text = "伺服器未回應任何資料"
                
            default:
                errorImageView.image = UIImage(systemName: "exclamationmark.triangle")
                errorTitleLabel.text = "發生錯誤"
                errorMessageLabel.text = apiError.errorDescription ?? "未知錯誤"
            }
        } else {
            errorImageView.image = UIImage(systemName: "exclamationmark.triangle")
            errorTitleLabel.text = "發生錯誤"
            errorMessageLabel.text = error.localizedDescription
        }
    }
}
