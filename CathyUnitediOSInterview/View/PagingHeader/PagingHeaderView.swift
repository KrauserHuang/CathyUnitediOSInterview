//
//  PagingHeaderView.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import UIKit

protocol PagingHeaderViewDelegate: AnyObject {
    func pagingHeaderView(_ headerView: PagingHeaderView, didSelect index: Int)
}

class PagingHeaderView: UIView {
    
    private let titles: [String]
    private var buttons: [UIButton] = []
    private let indicatorView = UIView()
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 36
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var selectedIndex: Int = 0
    private var indicatorCenterXConstraint: NSLayoutConstraint!
    private var indicatorWidthConstraint: NSLayoutConstraint!
    weak var delegate: PagingHeaderViewDelegate?
    
    init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateIndicatorPosition(animated: false)
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStackView)
        
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(index == 0 ? .label : .secondaryLabel, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: index == 0 ? .medium : .regular)
            button.tag = index
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            hStackView.addArrangedSubview(button)
        }
        
        indicatorView.backgroundColor = .hotPink
        indicatorView.layer.cornerRadius = 2
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicatorView)
        addSubview(underlineView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: buttons[0].centerXAnchor)
        indicatorWidthConstraint = indicatorView.widthAnchor.constraint(equalTo: buttons[0].widthAnchor, multiplier: 0.625)
        
        NSLayoutConstraint.activate([
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            hStackView.topAnchor.constraint(equalTo: topAnchor),
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            
            indicatorCenterXConstraint,
            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            indicatorView.heightAnchor.constraint(equalToConstant: 4),
            indicatorWidthConstraint,
            
            underlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    private func updateIndicatorPosition(animated: Bool) {
        let targetButton = buttons[selectedIndex]
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
                self.indicatorCenterXConstraint.isActive = false
                self.indicatorCenterXConstraint = self.indicatorView.centerXAnchor.constraint(equalTo: targetButton.centerXAnchor)
                self.indicatorCenterXConstraint.isActive = true
                self.layoutIfNeeded()
            }
        } else {
            indicatorCenterXConstraint.isActive = false
            indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: targetButton.centerXAnchor)
            indicatorCenterXConstraint.isActive = true
        }
    }
    
    @objc
    private func tabTapped(_ sender: UIButton) {
        setSelectedIndex(sender.tag, animated: true)
        delegate?.pagingHeaderView(self, didSelect: sender.tag)
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool) {
        guard index != selectedIndex, index < buttons.count else { return }
        
        // 取消前一個的選取樣式
        buttons[selectedIndex].setTitleColor(.secondaryLabel, for: .normal)
        buttons[selectedIndex].titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        // Update newly selected button
        buttons[index].setTitleColor(.label, for: .normal)
        buttons[index].titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // 更新indicator位置
        selectedIndex = index
        updateIndicatorPosition(animated: animated)
    }
    
    // Public method to update from external page controller
    func updateSelectedIndex(_ index: Int, animated: Bool = true) {
        setSelectedIndex(index, animated: animated)
    }
}
