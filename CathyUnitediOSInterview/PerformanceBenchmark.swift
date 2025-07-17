//
//  PerformanceBenchmark.swift
//  CathyUnitediOSInterview
//
//  Created for performance benchmarking
//

import Foundation
import UIKit
import Network

class PerformanceBenchmark {
    static let shared = PerformanceBenchmark()
    private init() {}
    
    // MARK: - Benchmark Results
    struct BenchmarkResult {
        let testName: String
        let executionTime: TimeInterval
        let memoryUsage: UInt64
        let isSlowPerformance: Bool
        
        var formattedTime: String {
            if executionTime < 0.001 {
                return String(format: "%.3f μs", executionTime * 1_000_000)
            } else if executionTime < 1.0 {
                return String(format: "%.3f ms", executionTime * 1_000)
            } else {
                return String(format: "%.3f s", executionTime)
            }
        }
        
        var formattedMemory: String {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .memory
            return formatter.string(fromByteCount: Int64(memoryUsage))
        }
    }
    
    // MARK: - Core Benchmarking Functions
    func measurePerformance<T>(
        testName: String,
        threshold: TimeInterval = 0.1,
        block: () throws -> T
    ) rethrows -> (result: T, benchmark: BenchmarkResult) {
        let startMemory = getCurrentMemoryUsage()
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let result = try block()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let endMemory = getCurrentMemoryUsage()
        
        let executionTime = endTime - startTime
        let memoryUsage = endMemory - startMemory
        let isSlowPerformance = executionTime > threshold
        
        let benchmark = BenchmarkResult(
            testName: testName,
            executionTime: executionTime,
            memoryUsage: memoryUsage,
            isSlowPerformance: isSlowPerformance
        )
        
        return (result, benchmark)
    }
    
    private func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        }
        return 0
    }
    
    // MARK: - Specific Benchmark Tests
    func benchmarkFriendListMerging() -> BenchmarkResult {
        let testFriends = generateTestFriends(count: 1000)
        
        let (_, benchmark) = measurePerformance(
            testName: "Friend List Merging",
            threshold: 0.05
        ) {
            // Simulate the merging logic from APIClient.fetchAndMergeFriendLists()
            let allFriends = testFriends + testFriends
            let merged = Dictionary(grouping: allFriends, by: { $0.fid })
                .compactMap { $0.value.max(by: { $0.formattedUpdateDate < $1.formattedUpdateDate }) }
            let sorted = merged.sorted { $0.fid < $1.fid }
            return sorted
        }
        
        return benchmark
    }
    
    func benchmarkDateParsing() -> BenchmarkResult {
        let testDates = generateTestDates(count: 1000)
        
        let (_, benchmark) = measurePerformance(
            testName: "Date Parsing",
            threshold: 0.02
        ) {
            return testDates.map { dateString in
                let formatter = DateFormatter()
                
                formatter.dateFormat = "yyyyMMdd"
                if let date = formatter.date(from: dateString) {
                    return date
                }
                
                formatter.dateFormat = "yyyy/MM/dd"
                if let date = formatter.date(from: dateString) {
                    return date
                }
                
                return Date()
            }
        }
        
        return benchmark
    }
    
    func benchmarkSearchFiltering() -> BenchmarkResult {
        let testFriends = generateTestFriends(count: 1000)
        let searchText = "test"
        
        let (_, benchmark) = measurePerformance(
            testName: "Search Filtering",
            threshold: 0.01
        ) {
            return testFriends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return benchmark
    }
    
    func benchmarkDiffableDataSourceUpdate() -> BenchmarkResult {
        let testFriends = generateTestFriends(count: 500)
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        typealias DataSource = UITableViewDiffableDataSource<Int, Friend>
        typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Friend>
        
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, friend in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = friend.name
            return cell
        }
        
        let (_, benchmark) = measurePerformance(
            testName: "Diffable Data Source Update",
            threshold: 0.05
        ) {
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(testFriends, toSection: 0)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
        
        return benchmark
    }
    
    func benchmarkNetworkRetryLogic() -> BenchmarkResult {
        let config = RetryConfiguration.default
        
        let (_, benchmark) = measurePerformance(
            testName: "Network Retry Logic",
            threshold: 0.001
        ) {
            // Simulate retry delay calculation
            var totalDelay: TimeInterval = 0
            for attempt in 0..<config.maxRetries {
                var delay = config.initialDelay * pow(config.backoffMultiplier, Double(attempt))
                delay = min(delay, config.maxDelay)
                
                if config.jitter {
                    let jitterRange = delay * 0.1
                    let jitter = Double.random(in: -jitterRange...jitterRange)
                    delay += jitter
                }
                
                totalDelay += max(0, delay)
            }
            return totalDelay
        }
        
        return benchmark
    }
    
    func benchmarkNetworkStatusUpdate() -> BenchmarkResult {
        let testInterfaceTypes: [NWInterface.InterfaceType] = [.wifi, .cellular, .wiredEthernet, .loopback, .other]
        
        let (_, benchmark) = measurePerformance(
            testName: "Network Status Update",
            threshold: 0.001
        ) {
            return testInterfaceTypes.map { type in
                NetworkInterfaceWrapper.getDisplayName(for: type)
            }
        }
        
        return benchmark
    }
    
    // MARK: - Test Data Generation
    func generateTestFriends(count: Int) -> [Friend] {
        return (0..<count).map { index in
            Friend.createTestFriend(
                name: "Test Friend \(index)",
                status: Int.random(in: 0...2),
                isTop: Bool.random() ? "1" : "0",
                fid: String(format: "%06d", index),
                updateDate: Bool.random() ? "20190801" : "2019/08/01"
            )
        }
    }
    
    func generateTestDates(count: Int) -> [String] {
        return (0..<count).map { index in
            if index % 2 == 0 {
                return "20190801"
            } else {
                return "2019/08/01"
            }
        }
    }
    
    // MARK: - Run All Benchmarks
    func runAllBenchmarks() -> [BenchmarkResult] {
        print("🚀 Starting Performance Benchmarks...")
        print("=" * 50)
        
        let benchmarks: [BenchmarkResult] = [
            benchmarkFriendListMerging(),
            benchmarkDateParsing(),
            benchmarkSearchFiltering(),
            benchmarkDiffableDataSourceUpdate(),
            benchmarkNetworkRetryLogic(),
            benchmarkNetworkStatusUpdate()
        ]
        
        // Print results
        for benchmark in benchmarks {
            let status = benchmark.isSlowPerformance ? "⚠️  SLOW" : "✅ FAST"
            print("\(status) \(benchmark.testName)")
            print("   Time: \(benchmark.formattedTime)")
            print("   Memory: \(benchmark.formattedMemory)")
            print()
        }
        
        let slowBenchmarks = benchmarks.filter { $0.isSlowPerformance }
        
        if slowBenchmarks.isEmpty {
            print("🎉 All benchmarks passed! No performance issues detected.")
        } else {
            print("⚠️  Performance Issues Detected:")
            for benchmark in slowBenchmarks {
                print("   - \(benchmark.testName): \(benchmark.formattedTime)")
            }
        }
        
        print("=" * 50)
        return benchmarks
    }
}

// MARK: - String Extension for Formatting
extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}

// MARK: - Friend Extension for Testing
extension Friend {
    static func createTestFriend(name: String, status: Int, isTop: String, fid: String, updateDate: String) -> Friend {
        return Friend(name: name, status: status, isTop: isTop, fid: fid, updateDate: updateDate)
    }
}