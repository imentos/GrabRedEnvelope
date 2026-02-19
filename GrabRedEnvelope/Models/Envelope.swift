//
//  Envelope.swift
//  GrabRedEnvelope
//
//  Red envelope model
//

import Foundation

struct Envelope: Codable, Identifiable, Equatable {
    let id: UUID
    let x: Double  // Normalized 0-1 screen position
    let y: Double
    let coins: Int
    var state: EnvelopeState
    var claimedBy: UUID?  // Player ID who claimed it
    
    enum EnvelopeState: String, Codable {
        case spawned
        case available
        case claimed
        case opened
    }
    
    init(id: UUID = UUID(), x: Double, y: Double, coins: Int, state: EnvelopeState = .spawned) {
        self.id = id
        self.x = x
        self.y = y
        self.coins = coins
        self.state = state
        self.claimedBy = nil
    }
}
