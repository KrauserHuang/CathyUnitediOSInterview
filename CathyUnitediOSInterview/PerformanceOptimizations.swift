//
//  PerformanceOptimizations.swift
//  CathyUnitediOSInterview
//
//  Created for performance optimizations
//

import Foundation
import UIKit

class PerformanceOptimizations {
    
    // MARK: - Optimized Date Parsing
    
    // Static formatters to avoid recreation overhead
    private static let dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    private static let dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    // Cache for parsed dates
    private static var dateCache: [String: Date] = [:]
    
    static func optimizedDateParsing(from dateString: String) -> Date {
        // Check cache first
        if let cachedDate = dateCache[dateString] {
            return cachedDate
        }
        
        var result: Date
        
        // Try first format
        if let date = dateFormatter1.date(from: dateString) {
            result = date
        } else if let date = dateFormatter2.date(from: dateString) {
            result = date
        } else {
            result = Date()
        }
        
        // Cache the result
        dateCache[dateString] = result
        return result
    }
    
    // MARK: - Optimized Friend List Merging
    
    static func optimizedFriendListMerging(friends1: [Friend], friends2: [Friend]) -> [Friend] {
        // Pre-sort both arrays to make merging more efficient
        let sortedFriends1 = friends1.sorted { $0.fid < $1.fid }
        let sortedFriends2 = friends2.sorted { $0.fid < $1.fid }
        
        // Use more efficient merging algorithm
        var result: [Friend] = []
        var i = 0, j = 0
        
        while i < sortedFriends1.count && j < sortedFriends2.count {
            let friend1 = sortedFriends1[i]
            let friend2 = sortedFriends2[j]
            
            if friend1.fid < friend2.fid {
                result.append(friend1)
                i += 1
            } else if friend1.fid > friend2.fid {
                result.append(friend2)
                j += 1
            } else {
                // Same fid, take the one with more recent date
                let date1 = optimizedDateParsing(from: friend1.updateDate)
                let date2 = optimizedDateParsing(from: friend2.updateDate)
                
                if date1 > date2 {
                    result.append(friend1)
                } else {
                    result.append(friend2)
                }
                i += 1
                j += 1
            }
        }
        
        // Add remaining friends
        while i < sortedFriends1.count {
            result.append(sortedFriends1[i])
            i += 1
        }
        
        while j < sortedFriends2.count {
            result.append(sortedFriends2[j])
            j += 1
        }
        
        return result
    }
    
    // MARK: - Optimized Search with Debouncing
    
    class SearchDebouncer {
        private var timer: Timer?
        private let delay: TimeInterval
        
        init(delay: TimeInterval = 0.3) {
            self.delay = delay
        }
        
        func debounce(action: @escaping () -> Void) {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                action()
            }
        }
    }
    
    // MARK: - Optimized Diffable Data Source Updates
    
    static func batchUpdateDataSource<T: Hashable>(
        dataSource: UITableViewDiffableDataSource<Int, T>,
        newItems: [T],
        animated: Bool = false
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, T>()
        snapshot.appendSections([0])
        snapshot.appendItems(newItems, toSection: 0)
        
        // Apply without animation for better performance
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: - Network Optimization
    
    static func optimizedRetryConfiguration() -> RetryConfiguration {
        return RetryConfiguration(
            maxRetries: 2,          // Reduced from 3
            initialDelay: 0.5,      // Reduced from 1.0
            maxDelay: 15.0,         // Reduced from 30.0
            backoffMultiplier: 1.5, // Reduced from 2.0
            jitter: false           // Disabled for consistency
        )
    }
    
    // MARK: - Memory Management
    
    static func clearCaches() {
        dateCache.removeAll()
    }
}

// MARK: - Friend Extension for Optimized Date Parsing
extension Friend {
    var optimizedFormattedUpdateDate: Date {
        return PerformanceOptimizations.optimizedDateParsing(from: updateDate)
    }
}