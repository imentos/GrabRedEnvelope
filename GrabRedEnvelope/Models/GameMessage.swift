//
//  GameMessage.swift
//  GrabRedEnvelope
//
//  Messages sent between devices
//

import Foundation

enum GameMessage: Codable {
    case playerJoined(Player)
    case playerLeft(UUID)  // Player ID who left
    case playersSync([Player])  // Full player list for synchronization
    case stateUpdate(GameState)
    case envelopeSpawned([Envelope])
    case envelopeClaimed(envelopeId: UUID, playerId: UUID, timestamp: Date)
    case envelopeOpened(envelopeId: UUID, coins: Int)
    case startRound
    case showResults
    case gamePaused(String)  // Pause reason
}
