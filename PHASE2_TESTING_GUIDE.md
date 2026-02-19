# Phase 2: Simulator + Device Testing Guide

## Prerequisites
- ✅ Code compiled successfully
- ✅ One physical iOS device (iPhone/iPad)
- ✅ Mac with Xcode

---

## Step 1: Configure SharePlay Entitlement

1. **Open Xcode**
2. **Select Project** → GrabRedEnvelope target
3. **Go to Signing & Capabilities tab**
4. **Click "+ Capability"**
5. **Search for "Group Activities"**
6. **Add it**

This adds the SharePlay entitlement to your app.

---

## Step 2: Set Up Signing

### For Physical Device:
1. **Signing & Capabilities** → Select your team
2. **Bundle Identifier**: Change to unique ID (e.g., `com.yourname.GrabRedEnvelope`)
3. **Make sure "Automatically manage signing" is checked**

---

## Step 3: Run on Simulator

1. **Select Target**: iPhone 15 Pro (or any simulator)
2. **Press ⌘R** to run
3. App should launch in simulator
4. **Tap screen 5 times** to enable debug mode
5. **Leave it running**

---

## Step 4: Run on Physical Device

1. **Connect iPhone/iPad via USB**
2. **Select your device** from device dropdown
3. **Press ⌘R** again
4. App will build and install on your device
5. **Tap screen 5 times** to enable debug mode

---

## Step 5: Test SharePlay (Without FaceTime)

Since FaceTime between simulator and device requires different Apple IDs and is complex, **use Debug Mode** to simulate multiplayer:

### Test Scenario 1: Solo Flow
**On Device:**
1. Tap screen 5 times → Debug mode
2. Tap "Start Solo Game"
3. Tap envelopes to grab them
4. Verify animations work
5. Tap "Show Results"
6. Tap "Play Again"

### Test Scenario 2: State Management
**On Simulator:**
1. Enable debug mode
2. Start game
3. Watch state changes in Xcode console

**On Device:**
1. Do the same
2. Verify both behave identically

---

## Step 6: Test Real SharePlay (Advanced)

### Requirements:
- Two different Apple IDs
- Both devices signed in to FaceTime
- Both devices on same WiFi

### Steps:
1. **Start FaceTime call**: Device #1 calls Device #2
2. **Both devices**: Launch GrabRedEnvelope app
3. **First device**: Follow the on-screen instructions:
   - ✅ You'll see 5-step instructions on how to play
   - ✅ Reminder to be on FaceTime call first
   - Tap "Start SharePlay" button
4. **Second device**: Accept SharePlay invitation that pops up
5. **Wait for sync**: Both devices should show the same player list
6. **Host taps "Start Game"** (must have at least 2 players)
7. **Both grab envelopes simultaneously**

### Test Scenario: Player Leaving
1. **During active game**: One player leaves SharePlay (close app or end FaceTime)
2. **Verify**: Other player sees warning "Waiting for more players... (1/2)"
3. **Verify**: Game returns to lobby automatically
4. **Verify**: Player list updates on remaining device
5. **Verify**: When player rejoins, they get a new player number
6. **Try to start game with 1 player**: Should show "Need at least 2 players to start"

---

## What to Test

### ✅ Core Mechanics (Debug Mode)
- [ ] Envelope spawning at random positions
- [ ] Tap detection and claiming
- [ ] Coin reveal animation
- [ ] Player score updates
- [ ] Results screen shows correct ranking
- [ ] Play again resets state

### ✅ SharePlay Sync (If Testing with 2nd Apple ID)
- [ ] Session creation
- [ ] Player join detection
- [ ] **Only ONE player is designated as host** (check console logs)
- [ ] **Envelope positions match exactly on both devices** (same x, y coordinates)
- [ ] **Envelope coin values match exactly** (same amounts in same envelopes)
- [ ] **Envelope IDs are identical** across devices
- [ ] Claims sync across devices
- [ ] Scores update on both sides
- [ ] Results match
- [ ] **Player leaving is detected** and synced across all devices
- [ ] **Game pauses when players drop below 2** during active game
- [ ] **Player list updates correctly** when someone leaves
- [ ] **Host can't start game with less than 2 players**

**Synchronization Verification:**
Check Xcode console for these log messages:
- `🎮 Local player created: Player X, isHost: true/false, ID: <UUID>`
- `🧧 Host spawning X envelopes` (should only appear on host device)
- `📥 Received X envelopes from host` (should appear on non-host device)
- `📍 Envelope ID: <UUID>, Position: (x, y), Coins: <amount>` (values should match)
- `👥 Active participants changed: X -> Y` (when someone joins/leaves)
- `🚪 Player X left the game` (when someone disconnects)
- `⚠️ Not enough players (1/2), pausing game` (game state changes)

### ✅ UI/UX
- [ ] Red festive background looks good
- [ ] Envelope animations smooth
- [ ] Text readable
- [ ] Buttons responsive
- [ ] No layout issues on different screen sizes
- [ ] **5-step instructions visible** when not connected to SharePlay
- [ ] **FaceTime reminder** shows above SharePlay button
- [ ] **"Need at least 2 players" warning** appears when host tries to start alone
- [ ] **"Waiting for more players" overlay** appears if someone leaves during game
- [ ] Start Game button turns gray when disabled

---

## Common Issues

### "Untrusted Developer"
**Solution:** Settings → General → VPN & Device Management → Trust developer

### "Failed to verify code signature"
**Solution:** Clean build folder (⇧⌘K) and rebuild

### "No signing certificate"
**Solution:** Xcode → Preferences → Accounts → Download Manual Profiles

### SharePlay button does nothing
**Expected:** SharePlay requires FaceTime call to be active first

---

## Next Steps After Phase 2

1. **Fix any bugs** found during testing
2. **Add sound effects** (envelope open, coin collect)
3. **Polish animations** (confetti, fireworks)
4. **TestFlight beta** with friends/family
5. **App Store submission**

---

## Tips

- Keep Xcode console open to see debug logs
- Use breakpoints to inspect state
- Test on different iOS versions if possible
- Test landscape orientation
- Test with poor network (airplane mode on/off)
