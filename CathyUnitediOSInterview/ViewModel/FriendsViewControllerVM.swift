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
    
    @Published var searchText: String = ""
    
    var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return friends
        } else {
            return friends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var filteredInviteFriends: [Friend] {
        if searchText.isEmpty {
            return inviteFriends
        } else {
            return inviteFriends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    init(scenario: FriendPageScenario = .noFriends) {
        self.scenario = scenario
        Task {
            await loadScenario()
        }
    }
    
    func loadScenario() async {
        await resetState()                  // 1. 重置所有狀態
        
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
            
            await setSuccessState()         // 4. 更新成功狀態
        } catch {
            await setErrorState(error)      // 5. 錯誤處理
        }
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
    }
    
    func reloadFriendList() async {
        await resetLoadingState()           // 重置載入狀態
        
        do {
            friends = try await APIClient.shared.fetchAndMergeFriendLists()
            
            // 根據當前場景也重新載入邀請列表
            if scenario == .friendsWithInvitations {
                inviteFriends = try await APIClient.shared.fetchFriendListWithInvites()
            }
            
            await setSuccessState()         // 設置成功狀態
        } catch {
            await setErrorState(error)      // 統一錯誤處理
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
    
    // MARK: - Private Helper Methods
    
    private func resetState() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            currentError = nil
            hasError = false
            user = nil
            friends = []
            inviteFriends = []
        }
    }
    
    private func resetLoadingState() async {
        await MainActor.run {
            isLoading = true
            hasError = false
            currentError = nil
            errorMessage = nil
        }
    }
    
    private func setSuccessState() async {
        await MainActor.run {
            isLoading = false
            hasError = false
        }
    }
    
    private func setErrorState(_ error: Error) async {
        await MainActor.run {
            isLoading = false
            errorMessage = error.localizedDescription
            currentError = error
            hasError = true
        }
    }
}

