//
//  APIClient.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Combine
import Foundation
import Network

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
    case timeout
    case networkUnavailable
    case tooManyRetries
    
    var errorTitle: String {
        switch self {
        case .invalidURL: return "URL格式錯誤"
        case .noData: return "無資料"
        case .decodingError(let error): return "資料格式錯誤，\(error.localizedDescription)"
        case .networkError(let error): return "網路錯誤，\(error.localizedDescription)"
        case .timeout: return "連線逾時"
        case .networkUnavailable: return "網路連線異常"
        case .tooManyRetries: return "重試次數過多"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "😵😵 Invalid URL"
        case .noData: return "🙅🙅 No Data"
        case .decodingError(let error): return "❌❌ Decoding failed: \(error.localizedDescription)"
        case .networkError(let error): return "🛜🛜 Network failed: \(error.localizedDescription)"
        case .timeout: return "⏰⏰ Request timeout"
        case .networkUnavailable: return "📡📡 Network unavailable"
        case .tooManyRetries: return "🔄🔄 Too many retries"
        }
    }
}

class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder = JSONDecoder()
    private var subscriptions: Set<AnyCancellable> = []
    private let networkMonitor = NetworkMonitor.shared
    private let retryConfiguration = RetryConfiguration.default
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchUserData() async throws -> User? {
        let response: UserResponse = try await performRequest(for: .userData)
        let user = response.response.first
        return user
    }
    
    func fetchFriendList(type: APIEndpoint = .friendList1) async throws -> [Friend] {
        let response: FriendResponse = try await performRequest(for: type)
        return response.friends
    }
    
    // 3. 同時抓取 friendList1 與 friendList2，並整合
    func fetchAndMergeFriendLists() async throws -> [Friend] {
        async let list1: FriendResponse = performRequest(for: .friendList1)
        async let list2: FriendResponse = performRequest(for: .friendList2)
        let (response1, response2) = try await (list1, list2)
        let allFriends = response1.friends + response2.friends
        
        // 以 fid 分組，取 formattedUpdateDate 較新者
        let merged = Dictionary(grouping: allFriends, by: { $0.fid })
            .compactMap { $0.value.max(by: { $0.formattedUpdateDate < $1.formattedUpdateDate }) }
        
        // 為了確保每次刷新後順序一致，依 fid 由小到大進行排序
        let sorted = merged.sorted { $0.fid < $1.fid }
        return sorted
    }
    
    // 4. 取得 friendListWithInvites
    func fetchFriendListWithInvites() async throws -> [Friend] {
        let response: FriendResponse = try await performRequest(for: .friendListWithInvites)
        return response.friends
    }
    
    // 5. 取得 emptyFriendList
    func fetchEmptyFriendList() async throws -> [Friend] {
        let response: FriendResponse = try await performRequest(for: .emptyFriendList)
        return response.friends
    }
    
    private func performRequest<T: Codable>(for endpoint: APIEndpoint) async throws -> T {
        guard networkMonitor.isConnected else {
            throw APIError.networkUnavailable
        }
        
        do {
            let (data, response) = try await session.dataWithRetry(
                from: endpoint.url,
                configuration: retryConfiguration
            )
            
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
            if let urlError = error as? URLError {
                switch urlError.code {
                case .timedOut:
                    throw APIError.timeout
                case .notConnectedToInternet, .networkConnectionLost:
                    throw APIError.networkUnavailable
                default:
                    throw APIError.networkError(urlError)
                }
            } else if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error)
            }
        }
    }
    
    var isNetworkAvailable: Bool {
        return networkMonitor.isConnected
    }
    
    var networkStatus: NetworkStatus {
        return networkMonitor.networkStatus
    }
    
    func networkStatusPublisher() -> AnyPublisher<NetworkStatus, Never> {
        return networkMonitor.$networkStatus
            .eraseToAnyPublisher()
    }
}
