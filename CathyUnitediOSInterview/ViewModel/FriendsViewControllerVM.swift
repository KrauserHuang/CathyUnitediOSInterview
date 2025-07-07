//
//  FriendsViewControllerVM.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Combine
import Network
import Observation
import UIKit

class FriendsViewControllerVM: ObservableObject {
    
    var scenario: FriendPageScenario
    @Published var isLoading: Bool = false      // 載入狀態
    @Published var errorMessage: String? = nil  // 錯誤訊息
    @Published var currentError: Error? = nil   // 原始錯誤物件
    @Published var hasError: Bool = false       // 是否有錯誤
    
    @Published var user: User?                  // 使用者資料
    @Published var friends: [Friend] = []       // 好友列表
    @Published var inviteFriends: [Friend] = [] // 邀請列表
    
    var searchText: String = ""
    var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return friends
        } else {
            return friends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    init(scenario: FriendPageScenario = .noFriends) {
        self.scenario = scenario
        Task {
            await loadScenario()
        }
    }
    
    func loadScenario() async {
        await MainActor.run {               // 1. 重置所有狀態（在主線程）
            isLoading = true
            errorMessage = nil
            currentError = nil
            hasError = false
            user = nil
            friends = []
            inviteFriends = []
        }
        
        do {                                // 2. 非同步載入資料
            user = try await APIClient.shared.fetchUserData()
            
            switch scenario {               // 3. 根據場景載入不同資料
            case .noFriends:                // 無資料邀請/好友列表
                friends = try await APIClient.shared.fetchEmptyFriendList()
                
            case .friends:                  // 好友列表
                friends = try await APIClient.shared.fetchAndMergeFriendLists()
                
            case .friendsWithInvitations:   // 好友列表含邀請列表
                friends = try await APIClient.shared.fetchAndMergeFriendLists()
                inviteFriends = try await APIClient.shared.fetchFriendListWithInvites()
            }
            
            await MainActor.run {           // 4. 更新成功狀態
                isLoading = false
                hasError = false
            }
        } catch {
            await MainActor.run {           // 5. 錯誤處理
                isLoading = false
                errorMessage = error.localizedDescription
                currentError = error
                hasError = true
            }
        }
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
    }
    
    func reloadFriendList() async {
        await MainActor.run {
            isLoading = true
            hasError = false
            currentError = nil
            errorMessage = nil
        }
        
        do {
            friends = try await APIClient.shared.fetchAndMergeFriendLists()
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                currentError = error
                hasError = true
            }
        }
    }
    
    func retry() async {
        await loadScenario()
    }
    
    func clearError() {
        hasError = false
        currentError = nil
        errorMessage = nil
    }
}

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
