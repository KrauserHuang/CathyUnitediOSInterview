//
//  APIClient.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Combine
import Foundation

/*
 使用者資料 → https://dimanyen.github.io/man.json
 好友列表1 → https://dimanyen.github.io/friend1.json
 好友列表2 → https://dimanyen.github.io/friend2.json
 好友列表含邀請列表 → https://dimanyen.github.io/friend3.json
 無資料邀請/好友列表 → https://dimanyen.github.io/friend4.json
 */

enum APIEndpoint {
    case userData
    case friendList1
    case friendList2
    case friendListWithInvites
    case emptyFriendList
    
    var url: URL {
        let baseUrl = "https://dimanyen.github.io/"
        switch self {
        case .userData: return URL(string: baseUrl + "man.json")!
        case .friendList1: return URL(string: baseUrl + "friend1.json")!
        case .friendList2: return URL(string: baseUrl + "friend2.json")!
        case .friendListWithInvites: return URL(string: baseUrl + "friend3.json")!
        case .emptyFriendList: return URL(string: baseUrl + "friend4.json")!
        }
    }
}

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "😵😵 Invalid URL"
        case .noData: return "🙅🙅 No Data"
        case .decodingError(let error): return "❌❌ Decoding failed: \(error.localizedDescription)"
        case .networkError(let error): return "🛜🛜 Network failed: \(error.localizedDescription)"
        }
    }
}

class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder = JSONDecoder()
    private var subscriptions: Set<AnyCancellable> = []
    
    private init() {
        self.session = URLSession.shared
    }
    
    func fetchUserData() async throws -> UserResponse {
        return try await performRequest(for: .userData)
    }
    
    func fetchFriendList(type: APIEndpoint = .friendList1) async throws -> [Friend] {
        let response: FriendResponse = try await performRequest(for: type)
        return response.friends
    }
    
    private func performRequest<T: Codable>(for endpoint: APIEndpoint) async throws -> T {
        do {
            let (data, response) = try await session.data(from: endpoint.url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.networkError(URLError(.badServerResponse))
            }
            
            guard !data.isEmpty else {
                throw APIError.noData
            }
            
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch {
                throw APIError.decodingError(error)
            }
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error)
            }
        }
    }
}
