//
//  GradientButtonView.swift
//  CathyUnitediOSInterview
//
//  Created by IT-MAC-02 on 2025/6/10.
//

import Combine
import UIKit

class GradientButtonView: UIView {
    
    // MARK: - Properties
    private let gradientLayer = CAGradientLayer()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .icAddFriendWhite).withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let tapSubject = PassthroughSubject<Void, Never>()
    var tapPublisher: AnyPublisher<Void, Never> { tapSubject.eraseToAnyPublisher() }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var icon: UIImage? {
        didSet {
            iconImageView.image = icon
            iconImageView.isHidden = icon == nil
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        setupGradient()
        setupUI()
        setupTapGesture()
    }
    
    private func setupGradient() {
        gradientLayer.colors        = [UIColor.frogGreenStart.cgColor, UIColor.frogGreenEnd.cgColor]
        gradientLayer.startPoint    = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint      = CGPoint(x: 1, y: 0.5)
        
        layer.shadowColor   = UIColor.appleGreen40.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 8
        layer.shadowOpacity = 1
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 48),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 9),
            
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 160),
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc
    private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        animatePress { [weak self] in
            guard let self else { return }
            tapSubject.send()
        }
    }
    
    private func animatePress(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.8
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
                self.alpha = 1.0
            } completion: { _ in
                completion()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // CAGradientLayer並不會自動調整大小，需手動設定
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = bounds.height / 2
        
        layer.cornerRadius = bounds.height / 2
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
