//
//  FriendsViewControllerVM.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Combine
import Foundation
import Observation

class FriendsViewControllerVM: ObservableObject {
    
    var scenario: FriendPageScenario
    @Published var isLoading: Bool = false
    var errorMessage: String? = nil
    
    @Published var user: User?
    @Published var friends: [Friend] = []
    @Published var inviteFriends: [Friend] = []
    
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
        isLoading = true
        errorMessage = nil
        user = nil
        friends = []
        inviteFriends = []
        
        do {
            user = try await APIClient.shared.fetchUserData()
            
            switch scenario {
            case .noFriends:                // 無資料邀請/好友列表
                friends = try await APIClient.shared.fetchEmptyFriendList()
                
            case .friends:                  // 好友列表
                friends = try await APIClient.shared.fetchAndMergeFriendLists()
                
            case .friendsWithInvitations:   // 好友列表含邀請列表
                friends = try await APIClient.shared.fetchAndMergeFriendLists()
                inviteFriends = try await APIClient.shared.fetchFriendListWithInvites()
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
    }
    
    func reloadFriendList() async {
        isLoading = true
        do {
            friends = try await APIClient.shared.fetchAndMergeFriendLists()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
