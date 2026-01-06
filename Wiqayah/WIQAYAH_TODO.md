# Wiqayah - Project TODO & Planning Document

**Last Updated:** January 5, 2026  
**Project Status:** Pre-Development  
**Target Launch:** TBD

---

## Table of Contents
1. [Project Setup](#project-setup)
2. [Phase 1: Core Foundation (No Screen Time)](#phase-1-core-foundation)
3. [Phase 2: Screen Time Integration](#phase-2-screen-time-integration)
4. [Phase 3: Polish & Launch Prep](#phase-3-polish--launch-prep)
5. [Phase 4: Post-Launch](#phase-4-post-launch)
6. [Infrastructure & DevOps](#infrastructure--devops)
7. [Marketing & Business](#marketing--business)
8. [Future Enhancements](#future-enhancements)

---

## Project Setup

### Environment & Accounts
- [ ] Purchase Apple Developer Account ($99/year)
- [ ] Set up Xcode on Mac (latest stable version)
- [ ] Create GitHub/GitLab repository for version control
- [ ] Set up Google Cloud account for Speech-to-Text API
- [ ] Enable Speech-to-Text API in Google Cloud Console
- [ ] Generate and secure API key for Google Speech-to-Text
- [ ] Set up App Store Connect account
- [ ] Create Wiqayah app listing in App Store Connect
- [ ] Set up TestFlight for beta testing

### Project Initialization
- [ ] Create Xcode project (iOS App, SwiftUI)
- [ ] Configure project settings (Bundle ID: com.yourname.wiqayah)
- [ ] Set deployment target to iOS 17.0
- [ ] Add .gitignore for Swift/Xcode
- [ ] Initialize Git repository
- [ ] Create basic README.md
- [ ] Set up folder structure per architecture spec

### Design Assets
- [ ] Design app icon (1024x1024)
- [ ] Create blocked app icons/placeholders
- [ ] Design launch screen
- [ ] Define color palette in Assets.xcassets
- [ ] Create Islamic geometric patterns for backgrounds
- [ ] Design waveform animation assets
- [ ] Create success/failure icons

---

## Phase 1: Core Foundation (No Screen Time)

**Goal:** Build fully functional app with simulated blocking

### Data Layer

#### Core Data Setup
- [ ] Create WiqayahDataModel.xcdatamodeld
- [ ] Define UserProfile entity
  - [ ] Add all attributes (id, isPremium, dailyLimitMinutes, etc.)
  - [ ] Set validation rules
- [ ] Define BlockedApp entity
  - [ ] Add all attributes
  - [ ] Create relationship to UsageSession
- [ ] Define UsageSession entity
  - [ ] Add all attributes
  - [ ] Create relationship to BlockedApp
- [ ] Define DhikrSession entity
  - [ ] Add all attributes
- [ ] Create CoreDataManager.swift
  - [ ] Implement initialization
  - [ ] Add CRUD methods for UserProfile
  - [ ] Add CRUD methods for BlockedApp
  - [ ] Add CRUD methods for UsageSession
  - [ ] Add CRUD methods for DhikrSession
  - [ ] Add fetch/query methods
  - [ ] Add error handling
- [ ] Test Core Data persistence
  - [ ] Create sample data
  - [ ] Verify data persists across app restarts
  - [ ] Test migrations (if needed)

#### JSON Data Files
- [ ] Create adhkar.json
  - [ ] Add simple adhkar (Subhanallah, Alhamdulillah, etc.)
  - [ ] Add Ayat al-Kursi
  - [ ] Add first 5 ayat of Surah al-Kahf
  - [ ] Add morning adhkar set
  - [ ] Add evening adhkar set
  - [ ] Include Arabic, transliteration, repetitions, thresholds
- [ ] Create blocked_apps.json
  - [ ] Add TikTok (bundle ID, name, icon)
  - [ ] Add Instagram
  - [ ] Add YouTube
  - [ ] Add Facebook
  - [ ] Add Snapchat
  - [ ] Add Twitter/X
- [ ] Create DhikrLibrary.swift to load JSON files
  - [ ] Parse adhkar.json
  - [ ] Parse blocked_apps.json
  - [ ] Create in-memory cache
  - [ ] Add error handling for missing files

#### Models
- [ ] Create User.swift
  - [ ] Define all properties
  - [ ] Add computed properties (e.g., canUnlock)
  - [ ] Add Codable conformance
- [ ] Create BlockedApp.swift
  - [ ] Define all properties
  - [ ] Add Identifiable conformance
- [ ] Create UsageSession.swift
  - [ ] Define all properties
  - [ ] Add duration calculation method
- [ ] Create DhikrRequirement.swift
  - [ ] Define all properties
  - [ ] Add validation methods
- [ ] Create DailyStats.swift
  - [ ] Define all properties
  - [ ] Add aggregate calculation methods
- [ ] Create VerificationResult.swift enum
  - [ ] Define cases: success, partial, failure
  - [ ] Add associated values for partial matches

### Services Layer

#### AppBlockerService (Simulated)
- [ ] Create AppBlockerService.swift
- [ ] Implement blockApp() method (simulated)
- [ ] Implement unblockApp() method (simulated)
- [ ] Implement isAppBlocked() method
- [ ] Add simulation mode toggle in settings
- [ ] Create mock data for testing

#### SpeechRecognitionService
- [ ] Create SpeechRecognitionService.swift
- [ ] Add microphone permission request
- [ ] Implement audio recording setup
  - [ ] Configure AVAudioSession
  - [ ] Set up AVAudioRecorder
  - [ ] Handle recording interruptions
- [ ] Implement startRecording() method
- [ ] Implement stopRecording() method
- [ ] Integrate Google Speech-to-Text API
  - [ ] Create API request structure
  - [ ] Handle audio encoding (BASE64)
  - [ ] Add error handling for network failures
  - [ ] Add retry logic
- [ ] Implement verifyDhikr() method
  - [ ] Normalize Arabic text (remove diacritics if needed)
  - [ ] Calculate similarity score
  - [ ] Apply threshold logic
  - [ ] Count repetitions
  - [ ] Return VerificationResult
- [ ] Add Arabic text normalization utilities
  - [ ] Remove extra whitespace
  - [ ] Handle different Arabic characters (e.g., ة vs ه)
- [ ] Test with various pronunciations
  - [ ] Native Arabic speakers
  - [ ] Non-native speakers
  - [ ] Background noise scenarios

#### UsageTrackingService
- [ ] Create UsageTrackingService.swift
- [ ] Implement recordUsage() method
  - [ ] Create new UsageSession
  - [ ] Update total minutes used
  - [ ] Save to Core Data
- [ ] Implement getTodayUsage() method
  - [ ] Query sessions for current day
  - [ ] Calculate total duration
- [ ] Implement getUsageByApp() method
  - [ ] Filter by app bundle ID
  - [ ] Aggregate duration
- [ ] Implement canUnlock() method
  - [ ] Check daily limit
  - [ ] Check unlock count (free tier)
  - [ ] Check if premium user
  - [ ] Return boolean + reason if blocked
- [ ] Add reset logic at Fajr
  - [ ] Schedule daily reset
  - [ ] Clear daily counters
  - [ ] Reset emergency bypasses
- [ ] Implement getDhikrRequirement() algorithm
  - [ ] Calculate based on minutes used
  - [ ] Apply debt multiplier if applicable
  - [ ] Return appropriate DhikrRequirement

#### PrayerTimeService
- [ ] Create PrayerTimeService.swift
- [ ] Add location permission request
- [ ] Integrate Adhan library (or implement calculation)
  - [ ] Add via Swift Package Manager
  - [ ] Configure calculation method (ISNA, MWL, etc.)
- [ ] Implement calculateFajrTime() method
  - [ ] Get user location
  - [ ] Calculate prayer times for date
  - [ ] Return Fajr time
- [ ] Implement getNextResetTime() method
  - [ ] Get next Fajr time
  - [ ] Handle timezone properly
- [ ] Add manual time override (for testing)
- [ ] Test across different timezones
- [ ] Test edge cases (polar regions, etc.)

#### SubscriptionService
- [ ] Create SubscriptionService.swift
- [ ] Set up StoreKit configuration
  - [ ] Create product ID in App Store Connect
  - [ ] Configure subscription (monthly, $2.99)
- [ ] Implement checkSubscriptionStatus() method
  - [ ] Query StoreKit
  - [ ] Update local user profile
  - [ ] Handle expired subscriptions
- [ ] Implement purchaseSubscription() method
  - [ ] Present payment sheet
  - [ ] Handle successful purchase
  - [ ] Handle cancellation
  - [ ] Handle errors (payment failed, etc.)
- [ ] Implement restorePurchases() method
  - [ ] Query past purchases
  - [ ] Restore premium status
- [ ] Add receipt validation
- [ ] Test with sandbox accounts
  - [ ] Test purchase flow
  - [ ] Test restore flow
  - [ ] Test subscription renewal
  - [ ] Test subscription cancellation

#### NotificationService
- [ ] Create NotificationService.swift
- [ ] Add notification permission request
- [ ] Implement scheduleUsageWarning() method
  - [ ] Trigger at 50 minutes
  - [ ] Customize message
- [ ] Implement scheduleFajrReminder() method
  - [ ] Schedule daily at Fajr time
  - [ ] Update daily when time changes
- [ ] Add notification actions (optional)
- [ ] Test notification delivery
  - [ ] Foreground
  - [ ] Background
  - [ ] Locked screen

### Managers

#### AuthManager
- [ ] Create AuthManager.swift
- [ ] Implement Sign in with Apple
  - [ ] Configure in Xcode capabilities
  - [ ] Handle authorization request
  - [ ] Store user identifier in Keychain
  - [ ] Create/fetch user profile
- [ ] Implement logout functionality
- [ ] Add session management
- [ ] Handle authentication errors
- [ ] Test sign-in flow
- [ ] Test sign-out flow

### Views Layer

#### Onboarding Flow
- [ ] Create OnboardingContainerView.swift
  - [ ] Page view controller logic
  - [ ] Progress indicators
  - [ ] Skip/Next buttons
- [ ] Create WelcomeView.swift
  - [ ] App logo
  - [ ] Tagline
  - [ ] "Get Started" button
- [ ] Create HowItWorksView.swift
  - [ ] Explain dhikr unlock mechanism
  - [ ] Visual illustrations
  - [ ] Example flow diagram
- [ ] Create SelectAppsView.swift
  - [ ] List of blockable apps
  - [ ] Checkboxes for selection
  - [ ] "Select All" option
  - [ ] Default: all selected
- [ ] Create SetLimitView.swift
  - [ ] Slider (30-120 min)
  - [ ] Visual feedback of selected time
  - [ ] Recommendation text
- [ ] Create PermissionsView.swift
  - [ ] Microphone permission explanation + request
  - [ ] Notifications permission explanation + request
  - [ ] Location permission explanation + request (optional)
  - [ ] Sign in with Apple button
  - [ ] Handle permission denials gracefully
- [ ] Add onboarding completion flag
  - [ ] Save to UserDefaults
  - [ ] Skip onboarding on subsequent launches

#### Main App Screens
- [ ] Create HomeView.swift
  - [ ] Header with app name/logo
  - [ ] Usage progress bar (visual, animated)
  - [ ] "X/60 minutes used today" label
  - [ ] Unlocks used counter
    - [ ] Show "7/15" for free users
    - [ ] Show "Unlimited ✓" for premium users
  - [ ] Emergency bypasses remaining (X/3)
  - [ ] Quick stats cards
    - [ ] Total dhikr completed today
    - [ ] Current streak
  - [ ] Settings gear icon (top right)
  - [ ] "Simulate Block" button (for testing)
- [ ] Create StatsView.swift
  - [ ] Tab bar navigation (if needed)
  - [ ] 7-day usage graph (bar chart or line chart)
  - [ ] Per-app breakdown (pie chart or list)
  - [ ] Dhikr completion rate (percentage)
  - [ ] Streak counter with icon
  - [ ] Total time saved vs. previous week
  - [ ] Export stats option (future enhancement)
- [ ] Create SettingsView.swift
  - [ ] Account section
    - [ ] User email/name (from Sign in with Apple)
    - [ ] Sign out button
  - [ ] Blocked Apps section
    - [ ] List with toggles
    - [ ] Add/remove apps
  - [ ] Daily Limit section
    - [ ] Slider to adjust (30-120 min)
    - [ ] Current value display
  - [ ] Prayer Times section
    - [ ] Auto-detect location toggle
    - [ ] Manual Fajr time override (for testing)
  - [ ] Premium section
    - [ ] Subscription status
    - [ ] "Upgrade to Premium" button (if free)
    - [ ] "Manage Subscription" link
  - [ ] Notifications section
    - [ ] Toggle for usage warnings
    - [ ] Toggle for Fajr reminders
  - [ ] About section
    - [ ] App version
    - [ ] Privacy policy link
    - [ ] Terms of service link
    - [ ] Contact support

#### Blocker Overlay Screens
- [ ] Create BlockerOverlayView.swift
  - [ ] App icon being blocked (large, centered)
  - [ ] App name
  - [ ] Usage stats
    - [ ] "Time used today: X/60 min"
    - [ ] "Time remaining: Y min"
  - [ ] Current dhikr requirement display
    - [ ] Arabic text (large, clear)
    - [ ] Transliteration below
    - [ ] Repetitions needed
  - [ ] 🎤 "Tap to Recite" button (prominent)
  - [ ] "Emergency Bypass" link (bottom, subtle)
  - [ ] Background: calming Islamic geometric pattern
- [ ] Create RecordingView.swift
  - [ ] "Listening..." header
  - [ ] Waveform animation (real-time amplitude)
  - [ ] Dhikr text displayed (Arabic + transliteration)
  - [ ] Cancel button
  - [ ] Timer (optional, to show recording duration)
- [ ] Create VerificationResultView.swift
  - [ ] Success state
    - [ ] Green checkmark animation
    - [ ] "Barakallahu feek" message
    - [ ] Haptic feedback
  - [ ] Failure state
    - [ ] Red X or sad icon
    - [ ] "Please try again" message
    - [ ] Retry button
  - [ ] Partial match state
    - [ ] "2/3 detected" message
    - [ ] "Please repeat once more" instruction
    - [ ] Retry button
- [ ] Create PostRecitationView.swift
  - [ ] Rotating motivational messages
    - [ ] Load from MotivationalMessages.swift
    - [ ] Display for 5 seconds
    - [ ] Fade in/out animation
  - [ ] Auto-dismiss timer
  - [ ] "Continue" button (optional, for user control)
- [ ] Create LimitReachedView.swift
  - [ ] "Daily Limit Reached" title
  - [ ] Icon (lock or stop sign)
  - [ ] Stats summary
    - [ ] Total time used today
    - [ ] Apps accessed
    - [ ] Dhikr completed
  - [ ] Reset time display
    - [ ] "Resets at Fajr (5:47 AM)"
    - [ ] Countdown timer (optional)
  - [ ] "View Stats" button
  - [ ] Upgrade to Premium CTA (for free users)
  - [ ] No bypass option

#### Emergency Bypass Flow
- [ ] Create EmergencyBypassDialog.swift
  - [ ] Confirmation alert
  - [ ] "Are you sure?" message
  - [ ] Bypasses remaining counter
  - [ ] Warning about debt ("You will owe 2x dhikr")
  - [ ] Cancel button
  - [ ] Confirm button
- [ ] Add debt notification on next unlock
  - [ ] "You owe: 6x Subhanallah" message
  - [ ] Visual indicator (debt badge)

#### Component Views
- [ ] Create ProgressBar.swift
  - [ ] Configurable fill percentage
  - [ ] Color gradient (green → yellow → red)
  - [ ] Animation on update
- [ ] Create AppIconView.swift
  - [ ] Load from Assets or system
  - [ ] Circular frame
  - [ ] Shadow/border
- [ ] Create WaveformView.swift
  - [ ] Real-time audio amplitude visualization
  - [ ] Smooth animation
  - [ ] Configurable color
- [ ] Create PremiumBadge.swift
  - [ ] Gold/special icon
  - [ ] Used in HomeView for premium users

### Utilities

#### Constants
- [ ] Create Constants.swift
  - [ ] API keys (placeholder for Google)
  - [ ] Color definitions (hex codes)
  - [ ] Default limits (60 min, 15 unlocks)
  - [ ] Pricing tiers ($2.99)
  - [ ] App bundle IDs for blocked apps
  - [ ] Threshold values (0.7, 0.75, etc.)

#### HapticManager
- [ ] Create HapticManager.swift
  - [ ] Success haptic (notification type)
  - [ ] Error haptic (notification type)
  - [ ] Warning haptic (notification type)
  - [ ] Selection haptic (for UI interactions)

#### MotivationalMessages
- [ ] Create MotivationalMessages.swift
  - [ ] Array of 20-30 messages
  - [ ] Mix of Quranic quotes, Hadith, wisdom
  - [ ] Time-aware messages (if needed)
  - [ ] Random selection method

### Testing (Phase 1)
- [ ] Test onboarding flow end-to-end
- [ ] Test simulated app blocking
- [ ] Test dhikr recording with mic
- [ ] Test Google Speech-to-Text integration
  - [ ] Record and verify simple adhkar
  - [ ] Test with background noise
  - [ ] Test with different accents
- [ ] Test verification logic
  - [ ] Success cases
  - [ ] Failure cases
  - [ ] Partial match cases
- [ ] Test daily limit enforcement
  - [ ] Reach limit
  - [ ] Verify hard block
  - [ ] Verify reset at Fajr
- [ ] Test emergency bypass
  - [ ] Use bypass
  - [ ] Verify debt accumulation
  - [ ] Verify debt payment on next unlock
- [ ] Test free tier limits
  - [ ] Hit 15 unlocks
  - [ ] Verify upgrade prompt
- [ ] Test payment flow (sandbox)
  - [ ] Purchase subscription
  - [ ] Restore purchases
  - [ ] Cancel subscription
- [ ] Test data persistence
  - [ ] Kill app, relaunch
  - [ ] Verify stats remain
- [ ] Test UI on different devices
  - [ ] iPhone SE (small screen)
  - [ ] iPhone 15 Pro (standard)
  - [ ] iPhone 15 Pro Max (large)
- [ ] Test accessibility
  - [ ] VoiceOver compatibility
  - [ ] Dynamic type support
  - [ ] High contrast mode

---

## Phase 2: Screen Time Integration

**Goal:** Replace simulation with real app blocking

### Developer Account Setup
- [ ] Complete Apple Developer enrollment
- [ ] Verify account is active
- [ ] Add provisioning profiles for development
- [ ] Enable necessary capabilities in App ID

### Screen Time API Integration
- [ ] Enable FamilyControls capability in Xcode
- [ ] Add FamilyControls framework to project
- [ ] Add ManagedSettings framework to project
- [ ] Request Screen Time authorization
  - [ ] Add permission description to Info.plist
  - [ ] Implement authorization request flow
  - [ ] Handle user denial
- [ ] Update AppBlockerService.swift
  - [ ] Replace simulated logic with FamilyControls API
  - [ ] Implement blockApp() using DeviceActivityMonitor
  - [ ] Implement unblockApp() with time-based shield removal
  - [ ] Configure ManagedSettings for blocked apps
- [ ] Implement ShieldConfigurationProvider
  - [ ] Create app extension for shield customization
  - [ ] Design shield screen layout
    - [ ] Test what UI elements are actually allowed
    - [ ] Work within Apple's constraints
  - [ ] Add dhikr prompt to shield screen
  - [ ] Add microphone trigger button (if possible)
  - [ ] Add emergency bypass link
- [ ] Test shield configuration limits
  - [ ] Determine if custom mic recording works
  - [ ] Find workarounds if needed
- [ ] Handle shield action callbacks
  - [ ] When user taps mic button → open main app
  - [ ] Main app shows RecordingView
  - [ ] After verification → temporarily lift shield
- [ ] Implement timed unlock mechanism
  - [ ] After successful dhikr → allow access for X minutes
  - [ ] Re-block after time expires
  - [ ] Track active unlock sessions

### Testing (Phase 2)
- [ ] Test on physical iPhone (required for Screen Time)
- [ ] Install and block real social media apps
  - [ ] TikTok
  - [ ] Instagram
  - [ ] YouTube
- [ ] Test shield screen appearance
- [ ] Test dhikr unlock flow with real apps
- [ ] Test timed unlock (verify re-blocking)
- [ ] Test daily limit with real usage
- [ ] Test Fajr reset with real time
- [ ] Test edge cases
  - [ ] App updates
  - [ ] iOS updates
  - [ ] VPN usage
  - [ ] Airplane mode

### Backup Plan (If Shield Limitations Are Too Severe)
- [ ] Design alternate flow
  - [ ] Shield screen shows basic "Open Wiqayah to unlock"
  - [ ] User opens main app
  - [ ] Main app shows BlockerOverlayView
  - [ ] After verification → generates unlock token
  - [ ] Token lifts shield for X minutes
- [ ] Implement token-based unlocking
- [ ] Test alternate flow

---

## Phase 3: Polish & Launch Prep

### UI/UX Polish
- [ ] Refine animations
  - [ ] Smooth transitions between views
  - [ ] Loading states
  - [ ] Error states
- [ ] Add skeleton screens for loading data
- [ ] Improve error messages (user-friendly)
- [ ] Add empty states
  - [ ] No stats yet
  - [ ] No blocked apps selected
- [ ] Optimize performance
  - [ ] Reduce API calls where possible
  - [ ] Cache dhikr text locally
  - [ ] Lazy load images
- [ ] Dark mode support
  - [ ] Update color palette
  - [ ] Test all screens in dark mode
- [ ] Localization (optional for v1)
  - [ ] English
  - [ ] Arabic (UI right-to-left)

### App Store Assets
- [ ] Take screenshots for all required device sizes
  - [ ] 6.7" (iPhone 15 Pro Max)
  - [ ] 6.5" (iPhone 14 Plus)
  - [ ] 5.5" (iPhone 8 Plus)
- [ ] Create App Preview video (optional but recommended)
- [ ] Write App Store description
  - [ ] Compelling headline
  - [ ] Feature list
  - [ ] Benefits/value proposition
  - [ ] Keywords for ASO
- [ ] Design promotional artwork
- [ ] Prepare privacy policy page
  - [ ] Host on website or use App Privacy Details
  - [ ] Detail data collection (mic, location, etc.)
- [ ] Prepare terms of service
- [ ] Create support page/email

### App Store Connect Setup
- [ ] Complete app metadata
  - [ ] Name: Wiqayah
  - [ ] Subtitle
  - [ ] Category: Productivity or Health & Fitness
  - [ ] Age rating (4+)
- [ ] Upload screenshots
- [ ] Upload app icon
- [ ] Set pricing (free with IAP)
- [ ] Configure in-app purchase
  - [ ] Product ID
  - [ ] Price: $2.99/month
  - [ ] Localized descriptions
- [ ] Fill out App Privacy Details
  - [ ] Microphone usage
  - [ ] Location (optional)
  - [ ] User data handling
- [ ] Submit for review

### Beta Testing
- [ ] Recruit beta testers (10-20 people)
  - [ ] Muslim community members
  - [ ] Mix of tech-savvy and non-tech users
  - [ ] Different age groups
- [ ] Set up TestFlight
  - [ ] Upload beta build
  - [ ] Write testing instructions
  - [ ] Create feedback form
- [ ] Collect feedback
  - [ ] Usability issues
  - [ ] Bugs
  - [ ] Feature requests
- [ ] Iterate based on feedback
  - [ ] Fix critical bugs
  - [ ] Address UX concerns
  - [ ] Refine dhikr verification thresholds

### Final QA
- [ ] Full regression testing
  - [ ] All user flows
  - [ ] All edge cases
  - [ ] All device sizes
- [ ] Performance testing
  - [ ] App launch time
  - [ ] Memory usage
  - [ ] Battery drain
  - [ ] Network usage (API calls)
- [ ] Security audit
  - [ ] API key protection
  - [ ] User data encryption
  - [ ] Keychain usage
- [ ] Accessibility audit
  - [ ] VoiceOver
  - [ ] Dynamic Type
  - [ ] Color contrast
- [ ] Fix all critical bugs
- [ ] Create final release build

---

## Phase 4: Post-Launch

### Monitoring & Analytics
- [ ] Integrate analytics (optional)
  - [ ] Firebase, Mixpanel, or similar
  - [ ] Track key events (unlocks, purchases, etc.)
  - [ ] Respect user privacy
- [ ] Set up crash reporting
  - [ ] Crashlytics or similar
  - [ ] Monitor for issues
- [ ] Create dashboard for metrics
  - [ ] Daily active users
  - [ ] Unlock frequency
  - [ ] Conversion rate (free → paid)
  - [ ] Retention (7-day, 30-day)
  - [ ] Dhikr completion rate

### User Support
- [ ] Set up support email
- [ ] Create FAQ page
- [ ] Monitor App Store reviews
  - [ ] Respond to negative reviews
  - [ ] Thank positive reviews
- [ ] Create in-app feedback mechanism
  - [ ] Bug report form
  - [ ] Feature request form

### Iterate & Improve
- [ ] Analyze user behavior data
- [ ] Identify drop-off points
- [ ] A/B test features (if applicable)
  - [ ] Dhikr thresholds
  - [ ] Unlock limits
  - [ ] Messaging
- [ ] Regular updates
  - [ ] Bug fixes
  - [ ] Performance improvements
  - [ ] New features based on feedback

### Marketing & Growth
- [ ] Launch announcement
  - [ ] Social media (Twitter, Instagram)
  - [ ] Islamic communities (Reddit, forums)
  - [ ] Mosques/Islamic centers
- [ ] Content marketing
  - [ ] Blog posts about digital wellbeing in Islam
  - [ ] Hadith/Quran on time management
- [ ] Influencer outreach
  - [ ] Islamic content creators
  - [ ] Digital wellness advocates
- [ ] ASO (App Store Optimization)
  - [ ] Keyword optimization
  - [ ] A/B test screenshots
  - [ ] Encourage reviews from happy users

---

## Infrastructure & DevOps

### Version Control
- [ ] Set up Git branching strategy
  - [ ] main (production)
  - [ ] develop (active development)
  - [ ] feature/* (new features)
- [ ] Write commit message conventions
- [ ] Set up code review process (if team)

### CI/CD (Optional but Recommended)
- [ ] Set up Fastlane for automation
  - [ ] Automated builds
  - [ ] Automated screenshots
  - [ ] Automated TestFlight uploads
- [ ] Set up GitHub Actions or similar
  - [ ] Run tests on commit
  - [ ] Build on pull request

### Documentation
- [ ] Write developer documentation
  - [ ] Setup instructions
  - [ ] Architecture overview
  - [ ] API documentation
- [ ] Document environment variables
  - [ ] Google API key
  - [ ] StoreKit configuration
- [ ] Create troubleshooting guide

### Security
- [ ] Never commit API keys to Git
  - [ ] Use .gitignore
  - [ ] Use environment variables or Config.xcconfig
- [ ] Secure Keychain usage for sensitive data
- [ ] Enable App Transport Security
- [ ] Validate all user inputs
- [ ] Implement rate limiting on API calls (if needed)

---

## Marketing & Business

### Pre-Launch
- [ ] Create landing page
  - [ ] Waitlist signup
  - [ ] Feature overview
  - [ ] Screenshots/mockups
- [ ] Build email list
- [ ] Create social media accounts
  - [ ] Twitter/X
  - [ ] Instagram
  - [ ] TikTok (ironically)
- [ ] Prepare launch materials
  - [ ] Press release
  - [ ] Media kit

### Launch Strategy
- [ ] Launch on Product Hunt (optional)
- [ ] Post in relevant subreddits
  - [ ] r/muslimtechnet
  - [ ] r/digitalminimalism
  - [ ] r/islam
- [ ] Reach out to Islamic blogs/websites
- [ ] Contact app review sites
- [ ] Launch discount/promo (first month free?)

### Monetization
- [ ] Track revenue
- [ ] Calculate LTV (Lifetime Value)
- [ ] Monitor churn rate
- [ ] Experiment with pricing
  - [ ] A/B test $2.99 vs $4.99
  - [ ] Offer annual plan ($24.99/year)
- [ ] Consider freemium adjustments
  - [ ] Increase free unlocks to 20?
  - [ ] Add more premium features?

### Legal & Compliance
- [ ] Consult lawyer (if needed)
- [ ] Ensure GDPR compliance (if EU users)
- [ ] Ensure CCPA compliance (California users)
- [ ] Review Apple's guidelines thoroughly
- [ ] Trademark "Wiqayah" (optional)

---

## Future Enhancements

### V1.1 - Quick Wins
- [ ] CloudKit sync (multi-device)
- [ ] iPad support
- [ ] Widget for home/lock screen
  - [ ] Show stats
  - [ ] Quick unlock button
- [ ] Siri Shortcuts integration
  - [ ] "Unlock TikTok" → triggers dhikr prompt
- [ ] More adhkar options
  - [ ] User-submitted adhkar
  - [ ] Seasonal adhkar (Ramadan, Hajj)
- [ ] Streak rewards/gamification
  - [ ] Badges for milestones
  - [ ] Share achievements

### V1.2 - Deeper Features
- [ ] Custom dhikr schedules
  - [ ] Morning routine
  - [ ] Evening routine
  - [ ] Bedtime routine
- [ ] Focus modes integration
  - [ ] Automatic blocking during prayer times
  - [ ] Study mode (stricter limits)
- [ ] Qur'an memorization integration
  - [ ] Unlock by reciting daily portion
- [ ] Parental controls
  - [ ] Parents manage kids' limits
  - [ ] Family sharing of subscriptions
- [ ] Haram content detection (experimental)
  - [ ] On-device ML model
  - [ ] Warn user before viewing
  - [ ] Privacy-preserving

### V2.0 - Major Expansion
- [ ] Android version
- [ ] Web dashboard
  - [ ] View stats on desktop
  - [ ] Configure settings remotely
- [ ] Community features
  - [ ] Leaderboards (anonymous)
  - [ ] Accountability partners
  - [ ] Group challenges
- [ ] AI-powered insights
  - [ ] Personalized dhikr recommendations
  - [ ] Usage pattern analysis
  - [ ] Behavioral coaching
- [ ] Offline mode improvements
  - [ ] Local speech recognition for simple adhkar
  - [ ] Reduce API costs
- [ ] Enterprise/School version
  - [ ] Bulk licensing for Islamic schools
  - [ ] Teacher dashboards
  - [ ] Curriculum integration

### V3.0 - Ecosystem
- [ ] Wiqayah for Desktop (macOS)
  - [ ] Block distracting websites
  - [ ] Dhikr before social media access
- [ ] Wiqayah for Web
  - [ ] Browser extension (Chrome, Safari)
  - [ ] Block websites with dhikr barrier
- [ ] API for third-party integrations
  - [ ] Other Islamic apps
  - [ ] Digital wellness platforms
- [ ] Merchandise (optional)
  - [ ] Physical dhikr counters
  - [ ] Prayer mats with QR codes → app

---

## Success Criteria

### Launch Goals (First Month)
- [ ] 1,000 downloads
- [ ] 100 active daily users
- [ ] 5% conversion to paid (50 subscribers)
- [ ] 4.0+ App Store rating
- [ ] <5% crash rate

### 6-Month Goals
- [ ] 10,000 downloads
- [ ] 1,000 active daily users
- [ ] 10% conversion to paid (1,000 subscribers)
- [ ] 4.5+ App Store rating
- [ ] Featured in App Store (aspirational)

### 1-Year Goals
- [ ] 50,000 downloads
- [ ] 5,000 active daily users
- [ ] 15% conversion to paid (7,500 subscribers)
- [ ] Sustainable revenue ($15k+/month)
- [ ] Positive user testimonials
- [ ] Begin work on Android version

---

## Notes & Reminders

### Technical Debt to Address
- [ ] Optimize API calls to reduce costs
- [ ] Implement proper error logging
- [ ] Add comprehensive unit tests
- [ ] Refactor large view files
- [ ] Document complex algorithms

### Known Limitations
- iOS only (Android planned for v2)
- Requires iOS 17+ (may limit audience)
- Google API costs scale with users
- Screen Time API constraints (TBD)

### Risks & Mitigation
- **Risk:** Apple rejects app due to Screen Time usage
  - **Mitigation:** Follow guidelines closely, have backup approach
- **Risk:** Google API costs too high
  - **Mitigation:** Implement local speech recognition for common adhkar
- **Risk:** Low conversion rate (free → paid)
  - **Mitigation:** A/B test limits, pricing, messaging
- **Risk:** Users find workarounds
  - **Mitigation:** Make the app valuable, not just restrictive
- **Risk:** Privacy concerns with mic access
  - **Mitigation:** Clear messaging, no data retention, privacy policy

---

**This TODO document should be treated as a living document. Update regularly as tasks are completed, priorities shift, or new features are identified.**

**Last Updated:** January 5, 2026  
**Next Review:** Weekly during active development
