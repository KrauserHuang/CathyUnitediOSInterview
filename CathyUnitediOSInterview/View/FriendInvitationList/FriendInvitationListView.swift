//
//  FriendInvitationListView.swift
//  CathyUnitediOSInterview
//
//  Created by IT-MAC-02 on 2025/6/9.
//

import Combine
import UIKit

class FriendInvitationListView: UIView {
    
    enum Section {
        case main
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cell: FriendInvitationTableViewCell.self)
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Friend>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Friend>
    private lazy var dataSource = makeDataSource()
    
    @Published var height: CGFloat = 0
    private var subscriptions: Set<AnyCancellable> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setupBindings() {
        tableView.publisher(for: \.contentSize)
            .map(\.height)
            .removeDuplicates()
            .assign(to: \.height, on: self)
            .store(in: &subscriptions)
    }
}

// MARK: - UITableViewDelegate

extension FriendInvitationListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Data Source
extension FriendInvitationListView {
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, friend in
            let cell: FriendInvitationTableViewCell = tableView.dequeueReusableCell(for: indexPath)
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
        updateSnapshot(with: friends)
    }
}
