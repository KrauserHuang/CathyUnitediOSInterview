//
//  UITableView+.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import UIKit

extension UITableViewHeaderFooterView: ReuseIdentifiable {}
extension UITableViewCell: ReuseIdentifiable {}

extension UITableView {
    func dequeueReusableCell<T>(for indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }
        
        return cell
    }
    
    func register<T: UITableViewCell>(cell: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func register<T: UITableViewHeaderFooterView>(view: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    func safeNumberOfRows(inSection section: Int) -> Int {
        guard self.dataSource != nil,
              section < self.numberOfSections else {
            return 0
        }
        return self.numberOfRows(inSection: section)
    }
}
