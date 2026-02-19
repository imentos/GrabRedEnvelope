# 🧧 SharePlay Red Envelope – Concept

## Overview
A SharePlay-powered iOS app that recreates the Chinese New Year **red envelope (红包 / hóngbāo)** experience during FaceTime calls. Players see synchronized envelopes and compete to grab them in real time.

---
## Core Experience
- Start FaceTime call
- Launch SharePlay activity
- Random envelopes appear on all screens (synced)
- Players tap to grab envelopes
- Coins / rewards revealed instantly

---
## Primary Game Mode: 抢红包 (Grab Red Envelope)
### Flow
1. Host triggers envelope wave
2. Envelopes spawn simultaneously on all devices
3. Players tap to claim
4. Claims resolved deterministically
5. Results + animations shown live

---
## Sync Model
### Single Source of Truth
Host device controls:
- Envelope spawn timing
- Screen positions
- Envelope IDs
- Coin values

### Why Host-Controlled?
Prevents:
- Desynchronization
- Double claims
- Fairness disputes

---
## Envelope State Lifecycle
1. **Spawned**
2. **Available**
3. **Claimed**
4. **Opened**

---
## Claim Resolution
- Player tap → send CLAIM event
- Host receives events
- Resolve by timestamp / arbitration logic
- Broadcast winner + update state

Optional fairness buffer:
- Small delay window (100–300ms)
- Randomize near-simultaneous taps

---
## Gameplay Enhancements (Future)
- Lucky envelopes (rare / high value)
- Fake envelopes (empty / joke)
- Combo multipliers
- Leaderboards
- Zodiac / seasonal themes

---
## Visual / Interaction Ideas
- Shake to open
- Tear animation
- Fireworks / confetti
- Gold coin burst
- Festive sound effects

---
## Monetization Strategy
### Safe / App Store Friendly
- Virtual currency (coins)
- Premium envelope designs
- Animated effects
- Seasonal bundles

### Avoid (Complex)
- Real money transfer
- Financial compliance overhead

---
## MVP Scope
### Include
- SharePlay integration
- Host-controlled envelope spawning
- Tap-to-claim mechanic
- Basic animations

### Exclude (Later)
- Rain chaos mode
- Leaderboards
- Advanced effects

---
## Key Technical Components
- GroupSession
- GroupSessionMessenger
- Shared game state model
- Conflict resolution logic

---
## Design Goals
- Extremely simple UX
- Joyful & festive feel
- Fast rounds (5–15 sec)
- Fun even as spectator

---
## Target Moments
- Chinese New Year
- Family FaceTime calls
- Long-distance celebrations
- Casual party calls

---
## Differentiators
- Cultural ritual adaptation
- Real-time competitive fun
- Emotion-driven interaction
- Highly shareable moments

---
## Vision
Transform red envelope gifting from a transaction into a **shared, delightful experience**.

