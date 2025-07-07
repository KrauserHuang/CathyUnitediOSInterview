//
//  FriendListView.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Combine
import UIKit

class FriendListView: UIView, ViewActionPublisher {
    
    enum Section {
        case main
    }
    
    enum Action {
        case updateSearchText(String)
        case beginSearch
        case cancelSearch
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cell: FriendTableViewCell.self)
        tableView.register(view: FriendListHeaderView.self)
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Friend>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Friend>
    private lazy var dataSource = makeDataSource()
    
    private let actionSubject = PassthroughSubject<Action, Never>()
    var actionPublisher: AnyPublisher<Action, Never> { actionSubject.eraseToAnyPublisher() }
    var headerActionCancellable: AnyCancellable?
    private var subscriptions: Set<AnyCancellable> = []
    @Published var height: CGFloat = 0
    
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

extension FriendListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: FriendListHeaderView.reuseIdentifier) as? FriendListHeaderView else { return nil }
        setupHeaderAction(headerView)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func setupHeaderAction(_ headerView: FriendListHeaderView) {
        headerActionCancellable?.cancel()
        
        headerActionCancellable = headerView.actionPublisher
            .sink { [weak self] headerAction in
                guard let self else { return }
                
                switch headerAction {
                case .updateSearchText(let text):
                    actionSubject.send(.updateSearchText(text))
                case .beginSearch:
                    actionSubject.send(.beginSearch)
                case .cancelSearch:
                    actionSubject.send(.cancelSearch)
                }
            }
    }
}

// MARK: - Data Source
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
        updateSnapshot(with: friends)
    }
    
    func updateFriends(_ friends: [Friend]) {
        updateSnapshot(with: friends)
    }
}
