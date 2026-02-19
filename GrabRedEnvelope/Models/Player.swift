//
//  Player.swift
//  GrabRedEnvelope
//
//  Player model
//

import Foundation

struct Player: Codable, Identifiable, Equatable {
    let id: UUID
    var nickname: String
    var totalCoins: Int
    var isHost: Bool
    
    init(id: UUID = UUID(), nickname: String = "Player", totalCoins: Int = 0, isHost: Bool = false) {
        self.id = id
        self.nickname = nickname
        self.totalCoins = totalCoins
        self.isHost = isHost
    }
}
