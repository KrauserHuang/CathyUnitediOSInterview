//
//  BenchmarkRunner.swift
//  CathyUnitediOSInterview
//
//  Created for running performance benchmarks
//

import Foundation
import UIKit

class BenchmarkRunner {
    static func runBenchmarks() {
        let benchmark = PerformanceBenchmark.shared
        let results = benchmark.runAllBenchmarks()
        
        analyzeResults(results)
    }
    
    static func analyzeResults(_ results: [PerformanceBenchmark.BenchmarkResult]) {
        let slowResults = results.filter { $0.isSlowPerformance }
        
        if !slowResults.isEmpty {
            print("\n🔧 Performance Optimization Recommendations:")
            print("=" * 50)
            
            for result in slowResults {
                switch result.testName {
                case "Friend List Merging":
                    print("📊 Friend List Merging is slow (\(result.formattedTime))")
                    print("   💡 Optimization suggestions:")
                    print("   - Pre-sort friends by fid to avoid final sorting")
                    print("   - Use cached date parsing for updateDate")
                    print("   - Consider using Set for deduplication instead of Dictionary grouping")
                    print()
                    
                case "Date Parsing":
                    print("📅 Date Parsing is slow (\(result.formattedTime))")
                    print("   💡 Optimization suggestions:")
                    print("   - Create static DateFormatter instances to avoid recreation")
                    print("   - Cache parsed dates")
                    print("   - Use a single formatter with locale detection")
                    print()
                    
                case "Search Filtering":
                    print("🔍 Search Filtering is slow (\(result.formattedTime))")
                    print("   💡 Optimization suggestions:")
                    print("   - Implement debouncing for search input")
                    print("   - Use background queue for filtering large datasets")
                    print("   - Create search index for faster lookups")
                    print()
                    
                case "Diffable Data Source Update":
                    print("📱 Diffable Data Source Update is slow (\(result.formattedTime))")
                    print("   💡 Optimization suggestions:")
                    print("   - Batch updates when possible")
                    print("   - Use performBatchUpdates for multiple changes")
                    print("   - Implement cell reuse optimization")
                    print()
                    
                case "Network Retry Logic":
                    print("🌐 Network Retry Logic is slow (\(result.formattedTime))")
                    print("   💡 Optimization suggestions:")
                    print("   - Reduce max retry attempts")
                    print("   - Implement circuit breaker pattern")
                    print("   - Cache successful responses")
                    print()
                    
                case "Network Status Update":
                    print("📡 Network Status Update is slow (\(result.formattedTime))")
                    print("   💡 Optimization suggestions:")
                    print("   - Cache network interface information")
                    print("   - Reduce frequency of status updates")
                    print("   - Use lazy evaluation for interface properties")
                    print()
                    
                default:
                    print("⚠️  Unknown performance issue: \(result.testName)")
                    print()
                }
            }
            
            print("=" * 50)
        }
    }
}

// MARK: - Performance Optimizations
extension PerformanceBenchmark {
    
    // Optimized friend list merging
    func optimizedFriendListMerging() -> BenchmarkResult {
        let testFriends = self.generateTestFriends(count: 1000)
        
        let (_, benchmark) = measurePerformance(
            testName: "Optimized Friend List Merging",
            threshold: 0.05
        ) {
            // Pre-sort by fid to avoid final sorting
            let allFriends = (testFriends + testFriends).sorted(by: { $0.fid < $1.fid })
            
            // Use more efficient deduplication
            var seenFids = Set<String>()
            var uniqueFriends: [Friend] = []
            var friendsByFid: [String: Friend] = [:]
            
            for friend in allFriends {
                if let existingFriend = friendsByFid[friend.fid] {
                    if friend.formattedUpdateDate > existingFriend.formattedUpdateDate {
                        friendsByFid[friend.fid] = friend
                    }
                } else {
                    friendsByFid[friend.fid] = friend
                }
            }
            
            return friendsByFid.values.sorted(by: { $0.fid < $1.fid })
        }
        
        return benchmark
    }
    
    // Optimized date parsing with static formatters
    func optimizedDateParsing() -> BenchmarkResult {
        let testDates = self.generateTestDates(count: 1000)
        
        // Static formatters to avoid recreation
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyyMMdd"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy/MM/dd"
        
        let (_, benchmark) = measurePerformance(
            testName: "Optimized Date Parsing",
            threshold: 0.02
        ) {
            return testDates.map { dateString in
                if let date = formatter1.date(from: dateString) {
                    return date
                }
                if let date = formatter2.date(from: dateString) {
                    return date
                }
                return Date()
            }
        }
        
        return benchmark
    }
    
    // Run optimized benchmarks
    func runOptimizedBenchmarks() -> [BenchmarkResult] {
        print("🚀 Running Optimized Benchmarks...")
        print("=" * 50)
        
        let optimizedBenchmarks: [BenchmarkResult] = [
            optimizedFriendListMerging(),
            optimizedDateParsing()
        ]
        
        // Print results
        for benchmark in optimizedBenchmarks {
            let status = benchmark.isSlowPerformance ? "⚠️  SLOW" : "✅ FAST"
            print("\(status) \(benchmark.testName)")
            print("   Time: \(benchmark.formattedTime)")
            print("   Memory: \(benchmark.formattedMemory)")
            print()
        }
        
        return optimizedBenchmarks
    }
}