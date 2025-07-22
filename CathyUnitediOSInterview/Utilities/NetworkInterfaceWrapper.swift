//
//  NetworkInterfaceWrapper.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Network
import UIKit

struct NetworkInterfaceWrapper {
    
    // MARK: - 基本功能
    static func getAllInterfaceTypes() -> [NWInterface.InterfaceType] {
        return [.wifi, .cellular, .wiredEthernet, .loopback, .other]
    }
    
    static func getCommonInterfaceTypes() -> [NWInterface.InterfaceType] {
        return [.wifi, .cellular, .wiredEthernet]
    }
    
    // MARK: - 顯示相關
    static func getDisplayName(for type: NWInterface.InterfaceType) -> String {
        switch type {
        case .wifi:
            return "Wi-Fi"
        case .cellular:
            return "行動網路"
        case .wiredEthernet:
            return "乙太網路"
        case .loopback:
            return "本地迴路"
        case .other:
            return "其他"
        @unknown default:
            return "未知網路類型"
        }
    }
    
    static func getSystemImageName(for type: NWInterface.InterfaceType) -> String {
        switch type {
        case .wifi:
            return "wifi"
        case .cellular:
            return "antenna.radiowaves.left.and.right"
        case .wiredEthernet:
            return "cable.connector"
        case .loopback:
            return "arrow.triangle.2.circlepath"
        case .other:
            return "network"
        @unknown default:
            return "questionmark.circle"
        }
    }
    
    // MARK: - 狀態相關
    static func getStatusColor(for type: NWInterface.InterfaceType, isConnected: Bool) -> UIColor {
        guard isConnected else { return .systemGray }
        
        switch type {
        case .wifi:
            return .systemBlue
        case .cellular:
            return .systemGreen
        case .wiredEthernet:
            return .systemIndigo
        default:
            return .systemGray
        }
    }
    
    // MARK: - 優先級
    static func getPriority(for type: NWInterface.InterfaceType) -> Int {
        switch type {
        case .wiredEthernet:
            return 100  // 最優先
        case .wifi:
            return 90
        case .cellular:
            return 50
        case .loopback:
            return 10
        case .other:
            return 0
        @unknown default:
            return 0
        }
    }
    
    // MARK: - 實用方法
    static func getBestAvailableInterface(from interfaces: [NWInterface]) -> NWInterface? {
        return interfaces.max { interface1, interface2 in
            let priority1 = getPriority(for: interface1.type)
            let priority2 = getPriority(for: interface2.type)
            return priority1 < priority2
        }
    }
    
    static func groupInterfacesByType(_ interfaces: [NWInterface]) -> [NWInterface.InterfaceType: [NWInterface]] {
        return Dictionary(grouping: interfaces) { $0.type }
    }
}