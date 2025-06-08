//
//  FriendsViewControllerVM.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Foundation
import Observation

@Observable
class FriendsViewControllerVM {
    
    var scenario: FriendPageScenario
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var user: User?
    var friends: [Friend] = []
    var inviteFriends: [Friend] = []
    
    init(scenario: FriendPageScenario = .noFriends) {
        self.scenario = scenario
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
            case .noFriends:
                friends = try await APIClient.shared.fetchEmptyFriendList()
            case .friends:
                friends = try await APIClient.shared.fetchAndMergeFriendLists()
            case .friendsWithInvitations:
                friends = try await APIClient.shared.fetchAndMergeFriendLists()
                inviteFriends = try await APIClient.shared.fetchFriendListWithInvites()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func selectScenario(_ scenario: FriendPageScenario) {
        self.scenario = scenario
        Task {
            await loadScenario()
        }
    }
}
