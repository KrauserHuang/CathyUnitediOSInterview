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
    case connected
    case disconnected
    case cellular
    case wifi
    case wired
}

final class NetworkMonitor: ObservableObject {
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    @Published var networkStatus: NetworkStatus = .disconnected
    @Published var isConnected: Bool = false
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                self.updateNetworkStatus(path: path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    private func updateNetworkStatus(path: NWPath) {
        if path.status == .satisfied {
            guard let interface = NetworkInterfaceWrapper.getAllInterfaceTypes()
                .filter({ path.usesInterfaceType($0) })
                .sorted(by: { NetworkInterfaceWrapper.getPriority(for: $0) > NetworkInterfaceWrapper.getPriority(for: $1) })
                .first
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
    let maxRetries: Int
    let initialDelay: TimeInterval
    let maxDelay: TimeInterval
    let backoffMultiplier: Double
    let jitter: Bool
    
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
        
        for attempt in 0...configuration.maxRetries {
            do {
                let (data, response) = try await data(from: url)
                return (data, response)
            } catch {
                lastError = error
                
                if attempt < configuration.maxRetries {
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
