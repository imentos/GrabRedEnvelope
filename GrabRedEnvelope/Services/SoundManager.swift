//
//  SoundManager.swift
//  GrabRedEnvelope
//
//  Sound effects manager
//

import AVFoundation
import SwiftUI

class SoundManager {
    static let shared = SoundManager()
    
    private var players: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // Generate system sounds for now (no audio files needed)
    func playTap() {
        AudioServicesPlaySystemSound(1104) // Tock
    }
    
    func playCoinCollect() {
        AudioServicesPlaySystemSound(1106) // Click
    }
    
    func playEnvelopeOpen() {
        AudioServicesPlaySystemSound(1111) // Pop
    }
    
    func playSuccess() {
        AudioServicesPlaySystemSound(1113) // Swish
    }
    
    func playGameStart() {
        AudioServicesPlaySystemSound(1102) // Beep beep
    }
}
