# GrabRedEnvelope - Chinese Localization Guide

## ✅ What Was Implemented

Chinese localization has been added to GrabRedEnvelope with support for:
- **🇨🇳 Simplified Chinese (简体中文)** - `zh-Hans`
- **🇭🇰 Traditional Chinese (繁體中文)** - `zh-Hant`
- **🇺🇸 English** - `en`

## 📁 Files Created

### Localization Structure
```
GrabRedEnvelope/
├── en.lproj/
│   ├── Localizable.strings      # English UI strings
│   └── InfoPlist.strings        # English app name
├── zh-Hans.lproj/
│   ├── Localizable.strings      # Simplified Chinese UI strings
│   └── InfoPlist.strings        # Simplified Chinese app name (抢红包)
└── zh-Hant.lproj/
    ├── Localizable.strings      # Traditional Chinese UI strings
    └── InfoPlist.strings        # Traditional Chinese app name (搶紅包)
```

### Modified Files
- **project.pbxproj** - Added `zh-Hans` and `zh-Hant` to known regions
- **ContentView.swift** - Updated all UI strings to use `String(localized:)`
- **RedEnvelopeActivity.swift** - Updated SharePlay metadata to use localized strings

## 🌐 Localized Components

### App Name
- English: "Grab Red Envelopes"
- Simplified Chinese: "抢红包"
- Traditional Chinese: "搶紅包"

### UI Strings Localized
- ✅ Main app title and subtitle
- ✅ Player list (Players, You, Host indicators)
- ✅ How to Play instructions (both multiplayer and solo)
- ✅ All button labels (Play with Friends, Play Solo, Start Game, Play Again)
- ✅ Status messages (FaceTime detected, need players, etc.)
- ✅ Results screen
- ✅ SharePlay activity metadata

## 🛠️ Xcode Setup Instructions

### Step 1: Add Localization Files to Xcode

1. Open `GrabRedEnvelope.xcodeproj` in Xcode
2. In the Project Navigator, select each `.lproj` folder
3. Right-click → "Add Files to GrabRedEnvelope"
4. Select all three `.lproj` folders:
   - `en.lproj`
   - `zh-Hans.lproj`
   - `zh-Hant.lproj`
5. Make sure "Create folder references" is selected
6. Click "Add"

### Step 2: Verify Localization Settings

1. Select the project in Project Navigator
2. Select the "GrabRedEnvelope" target
3. Go to the "Info" tab
4. Under "Localizations", verify you see:
   - ✅ English (en) - Development Language
   - ✅ Chinese, Simplified (zh-Hans)
   - ✅ Chinese, Traditional (zh-Hant)

### Step 3: Add InfoPlist.strings to Build

1. Select `InfoPlist.strings` in each `.lproj` folder
2. In the File Inspector (right panel), check the box next to "GrabRedEnvelope" target
3. Repeat for all three InfoPlist.strings files

### Step 4: Test Localization

#### In Simulator:
1. Go to Settings → General → Language & Region
2. Add Chinese (Simplified) or Chinese (Traditional)
3. Set as primary language
4. Relaunch the app

#### In Xcode:
1. Product → Scheme → Edit Scheme
2. Run → Options tab
3. Application Language → Choose "Chinese, Simplified" or "Chinese, Traditional"
4. Run the app

## 📱 Expected Behavior

### English (Default)
- App name: "Grab Red Envelopes"
- Title screen: "Grab Red Envelopes" / "抢红包"
- All UI in English

### Simplified Chinese (简体中文)
- App name on home screen: "抢红包"
- Title screen: "抢红包" / "Grab Red Envelopes"
- All UI in Simplified Chinese:
  - "与朋友一起玩" (Play with Friends)
  - "单人游戏" (Play Solo)
  - "开始游戏！" (Start Game!)

### Traditional Chinese (繁體中文)
- App name on home screen: "搶紅包"
- Title screen: "搶紅包" / "Grab Red Envelopes"
- All UI in Traditional Chinese:
  - "與朋友一起玩" (Play with Friends)
  - "單人遊戲" (Play Solo)
  - "開始遊戲！" (Start Game!)

## 🎯 App Store Localization

When submitting to App Store Connect, you can now provide:

### Chinese (Simplified) - 🇨🇳
**App Name:** 抢红包 - SharePlay

**Subtitle:** 多人派对游戏

**Keywords (100 chars):**
```
shareplay,facetime,红包,微信红包,春节,除夕,过年,多人游戏,派对游戏,家庭游戏,新年,农历新年
```

**Description:**
- Use Chinese description emphasizing:
  - 经典的抢红包游戏
  - FaceTime SharePlay 多人在线
  - 春节必备游戏
  - 完全免费，无广告

### Chinese (Traditional) - 🇭🇰 🇹🇼
**App Name:** 搶紅包 - SharePlay

**Subtitle:** 多人派對遊戲

**Keywords (100 chars):**
```
shareplay,facetime,紅包,利是,春節,除夕,過年,多人遊戲,派對遊戲,家庭遊戲,新年,農曆新年
```

**Description:**
- Use Traditional Chinese description
- Hong Kong/Taiwan specific terms:
  - 利是 (lai see - red envelope in Cantonese)
  - 農曆新年 (Lunar New Year)

## 🔧 Adding More Strings

If you add new UI strings, add them to all three `Localizable.strings` files:

### Example:
```swift
// In your Swift code:
Text(String(localized: "new.string.key"))

// In en.lproj/Localizable.strings:
"new.string.key" = "English text";

// In zh-Hans.lproj/Localizable.strings:
"new.string.key" = "简体中文文本";

// In zh-Hant.lproj/Localizable.strings:
"new.string.key" = "繁體中文文本";
```

## ✅ Validation Checklist

- [ ] All three `.lproj` folders added to Xcode
- [ ] `Localizable.strings` files visible in Project Navigator
- [ ] `InfoPlist.strings` files visible in Project Navigator
- [ ] Target membership checked for all localization files
- [ ] App builds without errors
- [ ] Chinese language selected in simulator/device settings
- [ ] App name displays in Chinese on home screen
- [ ] All UI text displays in Chinese when language is Chinese
- [ ] SharePlay card shows Chinese title in FaceTime

## 🎨 Translation Notes

### Simplified vs Traditional Differences
| English | Simplified (简体) | Traditional (繁體) |
|---------|------------------|-------------------|
| Grab Red Envelopes | 抢红包 | 搶紅包 |
| Players | 玩家 | 玩家 |
| Start Game | 开始游戏 | 開始遊戲 |
| Play with Friends | 与朋友一起玩 | 與朋友一起玩 |
| Instructions | 玩法说明 | 玩法說明 |

### Regional Variants
- **Mainland China (Simplified)**: 红包 (hongbao)
- **Hong Kong (Traditional)**: 利是 (lai see)
- **Taiwan (Traditional)**: 紅包 (hongbao in Traditional characters)

## 📊 Market Impact

Adding Chinese localization is critical for this app because:
- ✅ Red envelopes (hongbao/红包) are a Chinese cultural tradition
- ✅ Target audience includes Chinese-speaking users worldwide
- ✅ Chinese New Year is a peak usage time
- ✅ Improves App Store discoverability in Chinese markets
- ✅ Separate keyword fields = 300 keywords instead of 100

## 🚀 Next Steps

1. **Test thoroughly** in both Chinese variants
2. **Update App Store metadata** with Chinese localizations
3. **Create screenshots** with Chinese UI for App Store
4. **Target release** before Chinese New Year for maximum impact
5. **Consider additional localizations**:
   - 🇯🇵 Japanese (similar tradition with "otoshidama")
   - 🇰🇷 Korean (Seollal tradition)
   - 🇻🇳 Vietnamese (Tet tradition with "lì xì")

## 📝 Notes

- The emoji 🧧 (red envelope) displays the same in all languages
- Coin emoji 💰 is universal and doesn't need localization
- FaceTime and SharePlay brand names should remain in English
- Player nicknames (Player 1, Player 2) remain in English for multiplayer consistency

---

**Created:** March 19, 2026  
**Languages:** English, Simplified Chinese, Traditional Chinese  
**Status:** ✅ Complete and ready for testing
