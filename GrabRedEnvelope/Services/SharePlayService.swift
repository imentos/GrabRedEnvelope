//
//  SharePlayService.swift
//  GrabRedEnvelope
//
//  SharePlay session management
//

import Foundation
import GroupActivities
import Combine

@MainActor
class SharePlayService: ObservableObject {
    @Published var gameState: GameState = GameState()
    @Published var isConnected: Bool = false
    @Published var localPlayer: Player?
    @Published var isDebugMode: Bool = false
    
    private var session: GroupSession<RedEnvelopeActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
    private var localParticipantID: UUID?
    private var activeParticipants: Set<Participant> = []
    
    // MARK: - Initialization
    
    init() {
        Task {
            await configureGroupSessions()
        }
    }
    
    // MARK: - GroupSession Setup
    
    private func configureGroupSessions() async {
        print("🎯 Listening for SharePlay sessions...")
        for await session in RedEnvelopeActivity.sessions() {
            print("📱 New SharePlay session detected")
            self.session = session
            
            let messenger = GroupSessionMessenger(session: session, deliveryMode: .reliable)
            self.messenger = messenger
            
            // Store local participant ID for host determination
            self.localParticipantID = session.localParticipant.id
            print("🆔 Local participant ID: \(session.localParticipant.id)")
            
            session.$state
                .sink { [weak self] state in
                    guard let self = self else { return }
                    let wasConnected = self.isConnected
                    self.isConnected = (state == .joined)
                    
                    // When SharePlay disconnects, reset the game
                    if wasConnected && !self.isConnected {
                        Task { @MainActor in
                            print("🔌 SharePlay disconnected, resetting game")
                            
                            // Cancel all subscriptions and tasks
                            self.subscriptions.removeAll()
                            self.tasks.forEach { $0.cancel() }
                            self.tasks.removeAll()
                            
                            // Reset game state
                            self.gameState.players.removeAll()
                            self.gameState.envelopes.removeAll()
                            self.gameState.gamePhase = .lobby
                            self.localPlayer = nil
                            self.activeParticipants.removeAll()
                            
                            // Clear session references
                            self.session = nil
                            self.messenger = nil
                            self.localParticipantID = nil
                            
                            print("✅ Game reset complete, ready for new session")
                        }
                    }
                }
                .store(in: &subscriptions)
            
            // Store initial participants
            self.activeParticipants = session.activeParticipants
            
            session.$activeParticipants
                .sink { [weak self] participants in
                    Task { @MainActor in
                        await self?.handleParticipantsChanged(participants)
                    }
                }
                .store(in: &subscriptions)
            
            session.join()
            print("✅ Session joined, listening for messages and participants")
            
            // Listen for messages
            let task = Task { [weak self] in
                for await (message, _) in messenger.messages(of: GameMessage.self) {
                    await self?.handleMessage(message)
                }
            }
            tasks.insert(task)
            
            // Create local player after session setup
            await createLocalPlayer(participants: session.activeParticipants)
        }
    }
    
    // MARK: - Player Management
    
    private func createLocalPlayer(participants: Set<Participant>) async {
        print("🔍 createLocalPlayer called with \(participants.count) participants")
        print("   Current localPlayer: \(localPlayer?.nickname ?? "nil")")
        
        guard localPlayer == nil else {
            print("⚠️ createLocalPlayer blocked: localPlayer already exists")
            return
        }
        
        print("✅ Creating new local player...")
        
        // Determine host based on participant ID ordering (smallest UUID = host)
        // This ensures deterministic assignment across all devices
        let sortedParticipantIDs = participants.map { $0.id }.sorted()
        print("   📋 Sorted participant IDs:")
        for (index, id) in sortedParticipantIDs.enumerated() {
            let isMe = id == localParticipantID
            print("      \(index + 1). \(id) \(isMe ? "← ME" : "")")
        }
        
        let hostID = sortedParticipantIDs.first
        let isHost = hostID == localParticipantID
        
        print("   🏆 Host ID (smallest): \(hostID?.uuidString ?? "unknown")")
        print("   👤 My ID: \(localParticipantID?.uuidString ?? "unknown")")
        print("   👑 Am I host?: \(isHost)")
        
        // Assign player number: Host is always Player 1, others numbered by sorted position
        let playerNumber: Int
        if isHost {
            playerNumber = 1
        } else {
            // Find position among non-host participants
            let nonHostIDs = sortedParticipantIDs.filter { $0 != hostID }
            if let index = nonHostIDs.firstIndex(of: localParticipantID ?? UUID()) {
                playerNumber = index + 2  // +2 because host is Player 1
            } else {
                playerNumber = 2
            }
        }
        
        let player = Player(
            id: localParticipantID ?? UUID(),
            nickname: "Player \(playerNumber)",
            totalCoins: 0,
            isHost: isHost
        )
        
        localPlayer = player
        gameState.players.append(player)
        
        // Broadcast to others
        try? await messenger?.send(GameMessage.playerJoined(player))
        
        // Also broadcast full player list to ensure sync
        await broadcastPlayerList()
        
        print("🎮 Local player created: \(player.nickname), isHost: \(isHost), ID: \(player.id)")
        print("👥 Total participants: \(sortedParticipantIDs.count), My number: \(playerNumber)")
        print("🏆 Host ID: \(hostID?.uuidString ?? "unknown")")
    }
    
    /// Recalculates player nicknames based on current sorted order
    /// This ensures consistent player numbering across all devices
    private func recalculatePlayerNumbers() {
        print("🔢 Recalculating player numbers...")
        print("   Before: localPlayer = \(localPlayer?.nickname ?? "nil"), isHost = \(localPlayer?.isHost ?? false)")
        
        // Sort players: host first, then by ID
        gameState.players.sort { player1, player2 in
            if player1.isHost != player2.isHost {
                return player1.isHost
            }
            return player1.id.uuidString < player2.id.uuidString
        }
        
        // Renumber all players
        for (index, player) in gameState.players.enumerated() {
            let playerNumber = index + 1
            gameState.players[index].nickname = "Player \(playerNumber)"
            
            // Update local player reference to match the updated player in gameState
            if player.id == localPlayer?.id {
                localPlayer = gameState.players[index]
                print("   ✅ Found and updated localPlayer at index \(index)")
            }
        }
        
        print("🔢 Recalculated player numbers: \(gameState.players.map { $0.nickname }.joined(separator: ", "))")
        if let localPlayer = localPlayer {
            print("👤 After: localPlayer = \(localPlayer.nickname), isHost: \(localPlayer.isHost)")
        } else {
            print("⚠️ After: localPlayer is nil!")
        }
    }
    
    private func handleParticipantsChanged(_ participants: Set<Participant>) async {
        let oldParticipants = activeParticipants
        activeParticipants = participants
        
        print("👥 Active participants changed: \(oldParticipants.count) -> \(participants.count)")
        
        // Detect new participants who joined
        let newParticipants = participants.subtracting(oldParticipants)
        
        if !newParticipants.isEmpty {
            print("👋 \(newParticipants.count) new participant(s) joined")
            // Broadcast player list so new joiners get the full player list
            await broadcastPlayerList()
        }
        
        // Detect participants who left
        let leftParticipants = oldParticipants.subtracting(participants)
        
        if !leftParticipants.isEmpty {
            print("👋 \(leftParticipants.count) participant(s) left")
            
            // Remove players who left
            for participant in leftParticipants {
                if let playerIndex = gameState.players.firstIndex(where: { $0.id == participant.id }) {
                    let leftPlayer = gameState.players[playerIndex]
                    gameState.players.remove(at: playerIndex)
                    print("🚪 \(leftPlayer.nickname) left the game")
                }
            }
            
            // Recalculate player numbers after removals
            recalculatePlayerNumbers()
            
            // Broadcast updated player list to sync all devices
            await broadcastPlayerList()
            
            // Check if we have minimum players during active game
            if gameState.gamePhase == .active && gameState.players.count < 2 {
                print("⚠️ Not enough players (\(gameState.players.count)/2), pausing game")
                gameState.gamePhase = .lobby
                try? await messenger?.send(GameMessage.gamePaused("Not enough players. Need at least 2 players."))
            }
        }
        
        // Update host status when participants change
        guard let localParticipantID = localParticipantID,
              let localPlayerIndex = gameState.players.firstIndex(where: { $0.id == localParticipantID }) else {
            return
        }
        
        let sortedParticipantIDs = participants.map { $0.id }.sorted()
        let shouldBeHost = sortedParticipantIDs.first == localParticipantID
        
        if gameState.players[localPlayerIndex].isHost != shouldBeHost {
            gameState.players[localPlayerIndex].isHost = shouldBeHost
            // Update local player reference to match
            localPlayer = gameState.players[localPlayerIndex]
            print("🔄 Host status changed to: \(shouldBeHost)")
            print("   Updated localPlayer: \(localPlayer?.nickname ?? "nil"), isHost: \(localPlayer?.isHost ?? false)")
            // Broadcast updated host status
            await broadcastPlayerList()
        }
    }
    
    /// Broadcasts the current player list to all devices for synchronization
    private func broadcastPlayerList() async {
        guard let messenger = messenger else {
            print("⚠️ Cannot broadcast player list: messenger is nil")
            return
        }
        
        do {
            let playerSummary = gameState.players.map { "\($0.nickname)(Host:\($0.isHost))" }.joined(separator: ", ")
            try await messenger.send(GameMessage.playersSync(gameState.players))
            print("📤 Broadcast player list with \(gameState.players.count) players: \(playerSummary)")
        } catch {
            print("❌ Failed to broadcast player list: \(error)")
        }
    }
    
    // MARK: - Message Handling
    
    private func handleMessage(_ message: GameMessage) async {
        switch message {
        case .playerJoined(let player):
            if !gameState.players.contains(where: { $0.id == player.id }) {
                gameState.players.append(player)
                print("👋 \(player.nickname) joined the game (Host: \(player.isHost))")
                
                // Recalculate player numbers after adding new player
                recalculatePlayerNumbers()
                
                // Broadcast updated player list so everyone sees the new player
                await broadcastPlayerList()
            }
            
        case .playerLeft(let playerId):
            if let index = gameState.players.firstIndex(where: { $0.id == playerId }) {
                let leftPlayer = gameState.players[index]
                gameState.players.remove(at: index)
                print("🚪 \(leftPlayer.nickname) left the game (synced from remote)")
            }
            
            // Check if we have minimum players during active game
            if gameState.gamePhase == .active && gameState.players.count < 2 {
                print("⚠️ Not enough players after player left, returning to lobby")
                gameState.gamePhase = .lobby
            }
            
        case .playersSync(let players):
            // Received synchronized player list from another device
            print("📥 Received playersSync with \(players.count) players:")
            for player in players {
                print("   - \(player.nickname) (ID: \(player.id), Host: \(player.isHost))")
            }
            print("   My ID: \(localPlayer?.id ?? UUID())")
            
            var updatedPlayers: [Player] = []
            
            // Add all received players except ourselves
            for receivedPlayer in players {
                if receivedPlayer.id != localPlayer?.id {
                    updatedPlayers.append(receivedPlayer)
                }
            }
            
            // Ensure our local player is in the list
            if let localPlayer = self.localPlayer {
                // Check if we're in the received list (update our host status if needed)
                if let receivedLocalPlayer = players.first(where: { $0.id == localPlayer.id }) {
                    var updatedLocalPlayer = localPlayer
                    updatedLocalPlayer.isHost = receivedLocalPlayer.isHost
                    updatedLocalPlayer.totalCoins = receivedLocalPlayer.totalCoins
                    updatedPlayers.append(updatedLocalPlayer)
                    self.localPlayer = updatedLocalPlayer
                    print("✅ Synced local player from remote: Host=\(updatedLocalPlayer.isHost), Coins=\(updatedLocalPlayer.totalCoins)")
                } else {
                    // We're not in the received list, add ourselves
                    updatedPlayers.append(localPlayer)
                }
            }
            
            // Sort players to maintain consistent order (host first, then by ID)
            updatedPlayers.sort { player1, player2 in
                if player1.isHost != player2.isHost {
                    return player1.isHost
                }
                return player1.id.uuidString < player2.id.uuidString
            }
            
            gameState.players = updatedPlayers
            
            // Recalculate player numbers to ensure consistent naming
            recalculatePlayerNumbers()
            
            print("🔄 Synced player list complete: \(gameState.players.count) players")
            print("   Final player list: \(gameState.players.map { "\($0.nickname)(Host:\($0.isHost))" }.joined(separator: ", "))")
            print("   Final localPlayer: \(localPlayer?.nickname ?? "nil"), isHost: \(localPlayer?.isHost ?? false)")
            
        case .stateUpdate(let state):
            gameState = state
            
        case .gamePaused(let reason):
            gameState.gamePhase = .lobby
            print("⏸️ Game paused: \(reason)")
            
        case .envelopeSpawned(let envelopes):
            print("📥 Received \(envelopes.count) envelopes from host")
            for envelope in envelopes {
                print("  📍 Envelope ID: \(envelope.id), Position: (\(envelope.x), \(envelope.y)), Coins: \(envelope.coins)")
            }
            gameState.envelopes.append(contentsOf: envelopes)
            gameState.gamePhase = .active
            
        case .envelopeClaimed(let envelopeId, let playerId, _):
            if let index = gameState.envelopes.firstIndex(where: { $0.id == envelopeId }) {
                gameState.envelopes[index].state = .claimed
                gameState.envelopes[index].claimedBy = playerId
            }
            
        case .envelopeOpened(let envelopeId, let coins):
            if let index = gameState.envelopes.firstIndex(where: { $0.id == envelopeId }),
               let claimedBy = gameState.envelopes[index].claimedBy,
               let playerIndex = gameState.players.firstIndex(where: { $0.id == claimedBy }) {
                gameState.envelopes[index].state = .opened
                gameState.players[playerIndex].totalCoins += coins
                
                // Check if all envelopes are opened (host only triggers auto-show-results)
                if localPlayer?.isHost == true {
                    let allOpened = gameState.envelopes.allSatisfy { $0.state == .opened }
                    if allOpened && !gameState.envelopes.isEmpty {
                        print("🎉 All envelopes opened! Showing results...")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.showResults()
                        }
                    }
                }
            }
            
        case .startRound:
            // Non-host players receive this message and prepare for new round
            // but don't spawn envelopes themselves
            if localPlayer?.isHost != true {
                gameState.envelopes.removeAll()
                gameState.gamePhase = .spawning
                gameState.roundNumber += 1
                print("🔄 Non-host: New round started, waiting for envelopes...")
            }
            
        case .showResults:
            gameState.gamePhase = .results
        }
    }
    
    // MARK: - Game Actions
    
    func enableDebugMode() {
        isDebugMode = true
        
        // Create 5 mock players for layout testing
        let player1 = Player(
            id: UUID(),
            nickname: "Player 1",
            totalCoins: 0,
            isHost: true
        )
        
        let player2 = Player(
            id: UUID(),
            nickname: "Player 2",
            totalCoins: 50,
            isHost: false
        )
        
        let player3 = Player(
            id: UUID(),
            nickname: "Player 3",
            totalCoins: 100,
            isHost: false
        )
        
        let player4 = Player(
            id: UUID(),
            nickname: "Player 4",
            totalCoins: 150,
            isHost: false
        )
        
        let player5 = Player(
            id: UUID(),
            nickname: "Player 5",
            totalCoins: 200,
            isHost: false
        )
        
        localPlayer = player1
        gameState.players = [player1, player2]//, player3, player4, player5]
        isConnected = true  // Pretend connected
    }
    
    func startSharePlay() async {
        do {
            let activity = RedEnvelopeActivity()
            
            switch await activity.prepareForActivation() {
            case .activationPreferred:
                try await activity.activate()
            case .activationDisabled:
                break
            case .cancelled:
                break
            @unknown default:
                break
            }
        } catch {
            print("Failed to start SharePlay: \(error)")
        }
    }
    
    func spawnEnvelopes(count: Int = 5) {
        // Debug logging
        print("🎮 spawnEnvelopes called")
        print("   localPlayer: \(localPlayer?.nickname ?? "nil")")
        print("   localPlayer.isHost: \(localPlayer?.isHost ?? false)")
        print("   isDebugMode: \(isDebugMode)")
        print("   players.count: \(gameState.players.count)")
        print("   All players: \(gameState.players.map { "\($0.nickname) (Host: \($0.isHost))" }.joined(separator: ", "))")
        
        guard localPlayer?.isHost == true || isDebugMode else {
            print("⚠️ Non-host tried to spawn envelopes - rejected")
            return
        }
        
        // Check minimum players
        if gameState.players.count < 2 && !isDebugMode {
            print("⚠️ Need at least 2 players to start game (current: \(gameState.players.count))")
            return
        }
        
        print("🧧 Host spawning \(count) envelopes")
        
        var newEnvelopes: [Envelope] = []
        let minDistance = 0.25 // Minimum distance between envelopes (as fraction of screen)
        
        for _ in 0..<count {
            var position: (x: Double, y: Double)
            var attempts = 0
            let maxAttempts = 50
            
            // Keep trying to find a position that doesn't overlap with existing envelopes
            repeat {
                position = (
                    x: Double.random(in: 0.15...0.85),
                    y: Double.random(in: 0.25...0.75)
                )
                attempts += 1
                
                // Check if this position is far enough from all existing envelopes
                let isFarEnough = newEnvelopes.allSatisfy { existingEnvelope in
                    let distance = sqrt(pow(position.x - existingEnvelope.x, 2) + pow(position.y - existingEnvelope.y, 2))
                    return distance >= minDistance
                }
                
                if isFarEnough || attempts >= maxAttempts {
                    break
                }
            } while true
            
            let envelope = Envelope(
                x: position.x,
                y: position.y,
                coins: [10, 20, 50, 100, 200].randomElement() ?? 50,
                state: .available
            )
            newEnvelopes.append(envelope)
            print("  📍 Envelope ID: \(envelope.id), Position: (\(envelope.x), \(envelope.y)), Coins: \(envelope.coins)")
        }
        
        // Add to local state first
        gameState.envelopes.append(contentsOf: newEnvelopes)
        gameState.gamePhase = .active
        
        // Broadcast to others (skip in debug mode)
        if !isDebugMode {
            Task {
                do {
                    try await messenger?.send(GameMessage.envelopeSpawned(newEnvelopes))
                    print("✅ Envelopes broadcasted to other players")
                } catch {
                    print("❌ Failed to broadcast envelopes: \(error)")
                }
            }
        }
    }
    
    func claimEnvelope(_ envelope: Envelope) {
        guard let localPlayer = localPlayer else {
            print("⚠️ claimEnvelope: No local player")
            return
        }
        guard envelope.state == .available else {
            print("⚠️ claimEnvelope: Envelope \(envelope.id) not available (state: \(envelope.state))")
            return
        }
        
        print("🎯 Claiming envelope \(envelope.id)")
        
        // Send claim to host (skip in debug mode)
        if !isDebugMode {
            let timestamp = Date()
            Task {
                try? await messenger?.send(
                    GameMessage.envelopeClaimed(
                        envelopeId: envelope.id,
                        playerId: localPlayer.id,
                        timestamp: timestamp
                    )
                )
            }
        }
        
        // Update local state optimistically
        if let index = gameState.envelopes.firstIndex(where: { $0.id == envelope.id }) {
            guard gameState.envelopes[index].state == .available else {
                print("⚠️ Race condition: Envelope already claimed")
                return
            }
            
            gameState.envelopes[index].state = .claimed
            gameState.envelopes[index].claimedBy = localPlayer.id
            print("✅ Envelope \(envelope.id) claimed locally")
            
            // Open envelope after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.openEnvelope(envelope)
            }
        }
    }
    
    private func openEnvelope(_ envelope: Envelope) {
        guard let index = gameState.envelopes.firstIndex(where: { $0.id == envelope.id }) else { return }
        
        let coins = gameState.envelopes[index].coins
        gameState.envelopes[index].state = .opened
        
        // Update player coins
        if let claimedBy = gameState.envelopes[index].claimedBy,
           let playerIndex = gameState.players.firstIndex(where: { $0.id == claimedBy }) {
            gameState.players[playerIndex].totalCoins += coins
            
            // Broadcast (skip in debug mode)
            if !isDebugMode {
                Task {
                    try? await messenger?.send(
                        GameMessage.envelopeOpened(envelopeId: envelope.id, coins: coins)
                    )
                }
            }
        }
        
        // Check if all envelopes are opened, then automatically show results (host or debug mode only)
        if localPlayer?.isHost == true || isDebugMode {
            let allOpened = gameState.envelopes.allSatisfy { $0.state == .opened }
            if allOpened && !gameState.envelopes.isEmpty {
                print("🎉 All envelopes opened! Showing results...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.showResults()
                }
            }
        }
    }
    
    func startNewRound() {
        guard localPlayer?.isHost == true || isDebugMode else { return }
        
        gameState.envelopes.removeAll()
        gameState.gamePhase = .spawning
        gameState.roundNumber += 1
        
        // Broadcast (skip in debug mode)
        if !isDebugMode {
            Task {
                try? await messenger?.send(GameMessage.startRound)
            }
        }
        
        // Spawn envelopes after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.spawnEnvelopes()
        }
    }
    
    func showResults() {
        guard localPlayer?.isHost == true || isDebugMode else { return }
        
        gameState.gamePhase = .results
        
        if !isDebugMode {
            Task {
                try? await messenger?.send(GameMessage.showResults)
            }
        }
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        // Notify others that this player is leaving
        if let localPlayer = localPlayer, !isDebugMode {
            Task {
                try? await messenger?.send(GameMessage.playerLeft(localPlayer.id))
            }
        }
        
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        subscriptions.removeAll()
        session?.leave()
    }
}
