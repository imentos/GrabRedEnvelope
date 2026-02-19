//
//  GameState.swift
//  GrabRedEnvelope
//
//  Shared game state model
//

import Foundation

struct GameState: Codable, Equatable {
    var players: [Player]
    var envelopes: [Envelope]
    var gamePhase: GamePhase
    var roundNumber: Int
    
    enum GamePhase: String, Codable {
        case lobby
        case spawning
        case active
        case results
    }
    
    init() {
        self.players = []
        self.envelopes = []
        self.gamePhase = .lobby
        self.roundNumber = 0
    }
}
