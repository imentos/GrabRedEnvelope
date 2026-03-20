//
//  ContentView.swift
//  GrabRedEnvelope
//
//  Created by Kuo, Ray on 2/18/26.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var sharePlayService = SharePlayService()
    @State private var debugTapCount = 0
    @State private var isSoloMode = false
    @State private var lastTapTime: Date = Date.distantPast
    
    var body: some View {
        ZStack {
            // Dark gray background for all screens
            Color(red: 0.2, green: 0.2, blue: 0.2)
                .ignoresSafeArea()
            
            switch sharePlayService.gameState.gamePhase {
            case .lobby:
                LobbyView(
                    sharePlayService: sharePlayService, 
                    isSoloMode: $isSoloMode,
                    onDebugTap: handleDebugTap
                )
            case .spawning, .active:
                GameView(sharePlayService: sharePlayService)
            case .results:
                ResultsView(sharePlayService: sharePlayService)
            }
        }
    }
    
    private func handleDebugTap() {
        let now = Date()
        
        // Debounce: Ignore taps within 0.2 seconds of the last tap
        if now.timeIntervalSince(lastTapTime) < 0.2 {
            print("⏭️ Tap ignored (debounce)")
            return
        }
        
        lastTapTime = now
        debugTapCount += 1
        print("👆 Tap \(debugTapCount)/5")
        
        // Reset counter after 2 seconds of inactivity
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if Date().timeIntervalSince(self.lastTapTime) >= 2 {
                self.debugTapCount = 0
            }
        }
        
        // Toggle FaceTime simulation after 5 taps
        if debugTapCount >= 5 {
            debugTapCount = 0
            
            if !isSoloMode {
                // Enter FaceTime simulation mode - start with ON
                isSoloMode = true
                sharePlayService.isSoloMode = true
                sharePlayService.isFaceTimeAvailable = true
                print("🛠️ FaceTime Simulator: ON (Shows Multiplayer button)")
            } else {
                // Toggle simulated FaceTime status
                sharePlayService.isFaceTimeAvailable.toggle()
                print(sharePlayService.isFaceTimeAvailable 
                    ? "🛠️ FaceTime Simulator: ON (Shows Multiplayer button)" 
                    : "🛠️ FaceTime Simulator: OFF (Shows Solo button)")
            }
        }
    }
}

// MARK: - Lobby View

struct LobbyView: View {
    @ObservedObject var sharePlayService: SharePlayService
    @Binding var isSoloMode: Bool
    let onDebugTap: () -> Void
    
    var body: some View {
        ZStack {
            // Tap capture layer - captures all taps in lobby
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    onDebugTap()
                }
            
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 10) {
                    Text("🧧")
                        .font(.system(size: 100))
                
                Text(String(localized: "app.title"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(String(localized: "app.title.chinese"))
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Players list
            if !sharePlayService.gameState.players.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "lobby.players.title", defaultValue: "Players (\(sharePlayService.gameState.players.count))"))
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(sharePlayService.gameState.players) { player in
                        HStack {
                            Text(player.nickname)
                                .foregroundColor(.white)
                            
                            if player.id == sharePlayService.localPlayer?.id {
                                Text(String(localized: "lobby.player.you"))
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            if player.isHost {
                                Text(String(localized: "lobby.player.host"))
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                            
                            Spacer()
                            
                            Text("\(player.totalCoins) 💰")
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Game Instructions (always show in lobby)
            if !sharePlayService.isConnected {
                VStack(spacing: 16) {
                    Text(String(localized: "lobby.howto.title"))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        if sharePlayService.isFaceTimeAvailable {
                            // SharePlay multiplayer instructions
                            InstructionRow(number: "1", text: String(localized: "instructions.multiplayer.step1"))
                            InstructionRow(number: "2", text: String(localized: "instructions.multiplayer.step2"))
                            InstructionRow(number: "3", text: String(localized: "instructions.multiplayer.step3"))
                            InstructionRow(number: "4", text: String(localized: "instructions.multiplayer.step4"))
                            InstructionRow(number: "5", text: String(localized: "instructions.multiplayer.step5"))
                        } else {
                            // Solo play instructions
                            InstructionRow(number: "1", text: String(localized: "instructions.solo.step1"))
                            InstructionRow(number: "2", text: String(localized: "instructions.solo.step2"))
                            InstructionRow(number: "3", text: String(localized: "instructions.solo.step3"))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 16) {
                if !sharePlayService.isConnected {
                    // Show appropriate button based on FaceTime status
                    if sharePlayService.isFaceTimeAvailable {
                        // FaceTime is active - show multiplayer only
                        VStack(spacing: 8) {
                            Text(String(localized: "status.facetime_detected"))
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.bottom, 4)
                            
                            Button(action: {
                                Task {
                                    await sharePlayService.startSharePlay()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "shareplay")
                                    Text(String(localized: "button.play_friends"))
                                }
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 40)
                        }
                    } else {
                        // No FaceTime - show solo play only
                        VStack(spacing: 8) {
                            Button(action: {
                                sharePlayService.enableSoloMode()
                                SoundManager.shared.playGameStart()
                            }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                    Text(String(localized: "button.play_solo"))
                                }
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 40)
                            
                            Text(String(localized: "status.facetime_hint"))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                        }
                    }
                }
                
                // Start Game button - shown for all players
                if sharePlayService.gameState.players.count >= 1 {
                    // Show warning if not enough players
                    if sharePlayService.gameState.players.count < 2 && !isSoloMode {
                        Text(String(localized: "status.need_players"))
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .padding(.bottom, 4)
                    }
                    
                    // Show waiting message for non-hosts
                    if sharePlayService.localPlayer?.isHost != true && !isSoloMode {
                        Text("⏳ Waiting for host to start the game...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 4)
                    }
                    
                    // Always show button state info for debugging
                    Text("You: \(sharePlayService.localPlayer?.nickname ?? "Unknown") \(sharePlayService.localPlayer?.isHost == true ? "(Host)" : "")")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 4)
                    
                    Button(action: {
                        SoundManager.shared.playGameStart()
                        sharePlayService.spawnEnvelopes()
                    }) {
                        Text(String(localized: "button.start_game"))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((sharePlayService.localPlayer?.isHost == true || isSoloMode) && (sharePlayService.gameState.players.count >= 2 || isSoloMode) ? Color.green : Color.gray)
                            .cornerRadius(16)
                    }
                    .disabled((sharePlayService.localPlayer?.isHost != true && !isSoloMode) || (sharePlayService.gameState.players.count < 2 && !isSoloMode))
                    .padding(.horizontal, 40)
                }
            }
            }
            .padding()
            .task {
                // Check FaceTime availability when view appears
                await sharePlayService.checkFaceTimeAvailability()
            }
            .onAppear {
                // Periodically check FaceTime status
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                    Task {
                        await sharePlayService.checkFaceTimeAvailability()
                    }
                }
            }
        }
    }
}

// MARK: - Game View

struct GameView: View {
    @ObservedObject var sharePlayService: SharePlayService
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Player stats bar at top
                VStack {
                    HStack(spacing: 8) {
                        ForEach(sharePlayService.gameState.players) { player in
                            VStack(spacing: 4) {
                                HStack(spacing: 2) {
                                    // Extract player number from nickname (e.g., "Player 1" -> "P1")
                                    Text(player.nickname.replacingOccurrences(of: "Player ", with: "P"))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    
                                    if player.id == sharePlayService.localPlayer?.id {
                                        Text("★")
                                            .font(.system(size: 10))
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                Text("\(player.totalCoins) 💰")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.yellow)
                                    .lineLimit(1)
                            }
                            .frame(width: 60, height: 60)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                
                // Envelopes
                ForEach(sharePlayService.gameState.envelopes) { envelope in
                    EnvelopeView(envelope: envelope, sharePlayService: sharePlayService)
                        .position(
                            x: envelope.x * geometry.size.width,
                            y: envelope.y * geometry.size.height
                        )
                }
            }
        }
    }
}

// MARK: - Envelope View

struct EnvelopeView: View {
    let envelope: Envelope
    @ObservedObject var sharePlayService: SharePlayService
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -10
    @State private var showConfetti = false
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            // Envelope background
            RoundedRectangle(cornerRadius: 12)
                .fill(envelopeColor)
                .frame(width: 100, height: 100)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            
            // Content based on state
            if envelope.state == .opened {
                // Opened state - show coins in gold box
                VStack(spacing: 2) {
                    Text("💰")
                        .font(.system(size: 40))
                    Text("+\(envelope.coins)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.yellow)
                        )
                }
            } else {
                // Unopened state - show red envelope
                Text("🧧")
                    .font(.system(size: 50))
            }
            
            // Confetti effect
            if showConfetti {
                ConfettiView()
            }
        }
        .scaleEffect(isPressed ? 0.95 : scale)
        .rotationEffect(.degrees(rotation))
        .frame(width: 120, height: 120)  // Larger tap area
        .contentShape(Rectangle())  // Make entire frame tappable
        .onTapGesture {
            if envelope.state == .available {
                // Immediate visual feedback
                isPressed = true
                withAnimation(.easeOut(duration: 0.1)) {
                    isPressed = false
                }
                
                SoundManager.shared.playTap()
                sharePlayService.claimEnvelope(envelope)
            }
        }
        .allowsHitTesting(envelope.state == .available)  // Only allow taps when available
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                rotation = 0
            }
        }
        .onChange(of: envelope.state) { _, newState in
            if newState == .claimed {
                SoundManager.shared.playEnvelopeOpen()
                withAnimation(.easeIn(duration: 0.2)) {
                    scale = 1.2
                }
            } else if newState == .opened {
                SoundManager.shared.playCoinCollect()
                showConfetti = true
                withAnimation(.spring(response: 0.4)) {
                    rotation = 360
                }
                
                // Hide confetti after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showConfetti = false
                }
            }
        }
    }
    
    private var envelopeColor: Color {
        switch envelope.state {
        case .spawned, .available:
            return Color.red
        case .claimed:
            return Color.orange
        case .opened:
            return Color.yellow.opacity(0.5)
        }
    }
}

// MARK: - Results View

struct ResultsView: View {
    @ObservedObject var sharePlayService: SharePlayService
    @State private var showFireworks = false
    
    var sortedPlayers: [Player] {
        sharePlayService.gameState.players.sorted { $0.totalCoins > $1.totalCoins }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text(String(localized: "results.title"))
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .onAppear {
                    SoundManager.shared.playSuccess()
                    showFireworks = true
                }
            
            // Leaderboard
            VStack(spacing: 16) {
                ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                    PlayerResultRow(player: player, rank: index + 1)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Play again button for host or solo mode
            if sharePlayService.localPlayer?.isHost == true || sharePlayService.isSoloMode {
                Button(action: {
                    SoundManager.shared.playGameStart()
                    sharePlayService.startNewRound()
                }) {
                    Text(String(localized: "button.play_again"))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
            }
        }
        .padding()
        .overlay(
            Group {
                if showFireworks {
                    FireworksView()
                }
            }
        )
    }
}

// MARK: - Player Result Row Component

struct PlayerResultRow: View {
    let player: Player
    let rank: Int
    
    var body: some View {
        HStack {
            // Rank
            Text("\(rank)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40)
            
            // Medal for top 3
            medalView
            
            // Player name
            Text(player.nickname)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            // Coins
            Text("\(player.totalCoins) 💰")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.yellow)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var medalView: some View {
        if rank == 1 {
            Text("🥇")
                .font(.system(size: 30))
        } else if rank == 2 {
            Text("🥈")
                .font(.system(size: 30))
        } else if rank == 3 {
            Text("🥉")
                .font(.system(size: 30))
        } else {
            Spacer()
                .frame(width: 30)
        }
    }
    
    private var backgroundColor: Color {
        rank == 1 ? Color.yellow.opacity(0.3) : Color.white.opacity(0.2)
    }
}

// MARK: - Instruction Row Component

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 32, height: 32)
                
                Text(number)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ContentView()
}
