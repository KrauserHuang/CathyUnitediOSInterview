//
//  NetworkMonitor.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Foundation
import Network
import Combine

enum NetworkStatus {
    case connected      // 有連接
    case disconnected   // 無連接
    case cellular       // 行動網路
    case wifi           // 無線網路
    case wired          // 乙太網路
}

final class NetworkMonitor: ObservableObject {
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()                           // 監聽網路路徑(path)狀態
    private let queue = DispatchQueue(label: "NetworkMonitorQueue") // 把監聽的工作丟到自訂的佇列執行
    
    @Published var networkStatus: NetworkStatus = .disconnected
    @Published var isConnected: Bool = false
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in       // 每當網路路徑有變化就會被觸發
            guard let self else { return }
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied    // 只有當 .satisfied 才算有連上
                self.updateNetworkStatus(path: path)            // 依據路徑內容來指派 networkStatus
            }
        }
        monitor.start(queue: queue)                             // 開始監聽
    }
    
    private func stopMonitoring() {
        monitor.cancel()                                        // 停止監聽
    }
    
    private func updateNetworkStatus(path: NWPath) {
        if path.status == .satisfied {
            guard let interface = NetworkInterfaceWrapper.getAllInterfaceTypes()
                .filter({ path.usesInterfaceType($0) })                                                                         // 過濾目前路徑有在用的介面
                .sorted(by: { NetworkInterfaceWrapper.getPriority(for: $0) > NetworkInterfaceWrapper.getPriority(for: $1) })    // 排序介面的優先級
                .first                                                                                                          // 選第一個(最高排序介面)
            else {
                networkStatus = .connected
                return
            }
            
            switch interface {
            case .wifi: networkStatus = .wifi
            case .cellular: networkStatus = .cellular
            case .wiredEthernet: networkStatus = .wired
            default: networkStatus = .connected
            }
        } else {
            networkStatus = .disconnected
        }
    }
}

struct RetryConfiguration {
    let maxRetries: Int             // 重試上限
    let initialDelay: TimeInterval  // 初始等待秒數
    let maxDelay: TimeInterval      // 等待秒數上限
    let backoffMultiplier: Double   // 每次延長為前次的幾倍
    let jitter: Bool                // 使否加上隨機抖動（？
    
    static let `default` = RetryConfiguration(
        maxRetries: 3,
        initialDelay: 1.0,
        maxDelay: 30.0,
        backoffMultiplier: 2.0,
        jitter: true
    )
}

extension URLSession {
    func dataWithRetry(
        from url: URL,
        configuration: RetryConfiguration = .default
    ) async throws -> (Data, URLResponse) {
        var lastError: Error?
        
        for attempt in 0...configuration.maxRetries {               // 嘗試網路抓取，執行次數 maxRetries + 1
            do {
                let (data, response) = try await data(from: url)
                return (data, response)
            } catch {
                lastError = error
                
                if attempt < configuration.maxRetries {             // 嘗試次數小於重試上限
                    let delay = calculateDelay(
                        attempt: attempt,
                        configuration: configuration
                    )
                    
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? URLError(.unknown)
    }
    
    private func calculateDelay(
        attempt: Int,
        configuration: RetryConfiguration
    ) -> TimeInterval {
        var delay = configuration.initialDelay * pow(configuration.backoffMultiplier, Double(attempt))
        delay = min(delay, configuration.maxDelay)
        
        if configuration.jitter {
            let jitterRange = delay * 0.1
            let jitter = Double.random(in: -jitterRange...jitterRange)
            delay += jitter
        }
        
        return max(0, delay)
    }
}
