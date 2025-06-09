//
//  FriendListView.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import UIKit

class FriendListView: UIView {
    
    enum Section {
        case main
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cell: FriendTableViewCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Friend>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Friend>
    private lazy var dataSource = makeDataSource()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

extension FriendListView {
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, friend in
            let cell: FriendTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: friend)
            return cell
        }
        return dataSource
    }
    
    private func updateSnapshot(with friends: [Friend], animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(friends, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func configure(with friends: [Friend]) {
        print("有到這？？？？？")
        updateSnapshot(with: friends)
    }
}
