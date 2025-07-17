//
//  RunBenchmarks.swift
//  CathyUnitediOSInterview
//
//  Created for running benchmarks manually
//

import Foundation

func runBenchmarksManually() {
    let benchmark = PerformanceBenchmark.shared
    
    print("🚀 Starting Performance Benchmarks...")
    print("=" * 50)
    
    // Run all benchmarks
    let results = benchmark.runAllBenchmarks()
    
    // Run optimized benchmarks for comparison
    let optimizedResults = benchmark.runOptimizedBenchmarks()
    
    print("📊 Performance Comparison:")
    print("=" * 50)
    
    // Compare original vs optimized
    if let originalMerging = results.first(where: { $0.testName == "Friend List Merging" }),
       let optimizedMerging = optimizedResults.first(where: { $0.testName == "Optimized Friend List Merging" }) {
        
        let improvement = ((originalMerging.executionTime - optimizedMerging.executionTime) / originalMerging.executionTime) * 100
        print("📈 Friend List Merging:")
        print("   Original: \(originalMerging.formattedTime)")
        print("   Optimized: \(optimizedMerging.formattedTime)")
        print("   Improvement: \(String(format: "%.1f", improvement))%")
        print()
    }
    
    if let originalParsing = results.first(where: { $0.testName == "Date Parsing" }),
       let optimizedParsing = optimizedResults.first(where: { $0.testName == "Optimized Date Parsing" }) {
        
        let improvement = ((originalParsing.executionTime - optimizedParsing.executionTime) / originalParsing.executionTime) * 100
        print("📅 Date Parsing:")
        print("   Original: \(originalParsing.formattedTime)")
        print("   Optimized: \(optimizedParsing.formattedTime)")
        print("   Improvement: \(String(format: "%.1f", improvement))%")
        print()
    }
    
    BenchmarkRunner.analyzeResults(results)
}

