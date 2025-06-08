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
        stackView.distribution = .fillEqually
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
    weak var delegate: PagingHeaderViewDelegate?
    
    init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStackView)
        
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(index == 0 ? .systemPink : .lightGray, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.tag = index
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            hStackView.addArrangedSubview(button)
        }
        
        indicatorView.backgroundColor = .systemPink
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicatorView)
        addSubview(underlineView)
        
        NSLayoutConstraint.activate([
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStackView.topAnchor.constraint(equalTo: topAnchor),
            hStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9),
            
            underlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1),
            underlineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let indicatorWidth = bounds.width / CGFloat(titles.count)
        indicatorView.frame = CGRect(x: CGFloat(selectedIndex) * indicatorWidth,
                                     y: bounds.height - 3,
                                     width: indicatorWidth,
                                     height: 3)
    }
    
    @objc private func tabTapped(_ sender: UIButton) {
        setSelectedIndex(sender.tag, animated: true)
        delegate?.pagingHeaderView(self, didSelect: sender.tag)
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool) {
        guard index != selectedIndex, index < buttons.count else { return }
        buttons[selectedIndex].setTitleColor(.lightGray, for: .normal)
        buttons[index].setTitleColor(.systemPink, for: .normal)
        selectedIndex = index
        
        let indicatorWidth = bounds.width / CGFloat(titles.count)
        let newFrame = CGRect(x: CGFloat(index) * indicatorWidth, y: bounds.height - 3, width: indicatorWidth, height: 3)
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.indicatorView.frame = newFrame
            }
        } else {
            indicatorView.frame = newFrame
        }
    }
}
