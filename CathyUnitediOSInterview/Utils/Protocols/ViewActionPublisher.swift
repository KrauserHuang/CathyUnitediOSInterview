//
//  ViewActionPublisher.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/7/6.
//

import Combine
import Foundation

// MARK: - 畫面動作的 Publisher
protocol ViewActionPublisher {
    associatedtype Action
    var actionPublisher: AnyPublisher<Action, Never> { get }
}
