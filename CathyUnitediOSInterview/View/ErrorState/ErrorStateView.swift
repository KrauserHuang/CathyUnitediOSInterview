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
    
    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemRed
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let errorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "重試"
        config.image = UIImage(systemName: "arrow.clockwise")
        config.imagePadding = 8
        config.cornerStyle = .medium
        config.baseBackgroundColor = .systemBlue
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dismissButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "關閉"
        config.baseForegroundColor = .secondaryLabel
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [errorImageView, errorTitleLabel, errorMessageLabel, retryButton, dismissButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let retrySubject = PassthroughSubject<Void, Never>()
    var onRetry: AnyPublisher<Void, Never> { retrySubject.eraseToAnyPublisher() }
    private let dismissSubject = PassthroughSubject<Void, Never>()
    var onDismiss: AnyPublisher<Void, Never> { dismissSubject.eraseToAnyPublisher() }
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
        retryButton.addTarget(self, action: #selector(retryTapped(_:)), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissTapped(_:)), for: .touchUpInside)
        
        // 點擊背景關閉
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        blurView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func retryTapped(_ sender: UIButton) {
        retrySubject.send()
    }
    
    @objc private func dismissTapped(_ sender: UIButton) {
        dismissSubject.send()
    }
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        dismissSubject.send()
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
                setDefaultError(message: error.localizedDescription)
            }
        } else {
            setDefaultError(message: error.localizedDescription)
        }
    }
    
    private func setDefaultError(message: String?) {
        errorImageView.image = UIImage(systemName: "exclamationmark.triangle")
        errorTitleLabel.text = "發生錯誤"
        errorMessageLabel.text = message ?? "未知錯誤"
    }
}
