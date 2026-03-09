---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-03-success', 'step-04-journeys', 'step-05-domain', 'step-06-innovation-skipped', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish']
classification:
  projectType: mobile_app
  domain: edtech
  complexity: medium
  projectContext: brownfield
inputDocuments:
  - '_bmad-output/brainstorming/brainstorming-session-2026-02-06.md'
  - 'features/common/claude.md'
  - 'features/course/claude.md'
  - 'features/main/claude.md'
  - 'features/onboarding/claude.md'
  - 'features/schedule/claude.md'
  - 'features/sharing/claude.md'
  - 'features/supply/claude.md'
  - 'docs/QUICK_START.md'
  - 'docs/SUPABASE_SETUP.md'
  - 'docs/WEEK_AB_IMPLEMENTATION.md'
workflowType: 'prd'
documentCounts:
  briefs: 0
  research: 0
  brainstorming: 1
  projectDocs: 10
---

# Product Requirements Document - DansMonSac

**Author:** Kevin
**Date:** 2026-02-06

## Executive Summary

**DansMonSac** is a mobile app that helps French collège students prepare their school bag every evening. The student enters their timetable and supplies once, and the app tells them exactly what to pack each night — subject by subject, supply by supply. When everything is checked, the student gets a "Bag Ready" confirmation.

**Target users:** Primarily 6ème students (11-12 years) entering collège, secondarily their parents who want visibility on bag preparation.

**Product differentiator:** Anonymous by design (zero PII, no account creation), offline-first, frictionless daily habit tool. Not a Pronote competitor — a complementary "supply layer" on top of the timetable.

**Current state:** V1 published on iOS and Android (zero users). V2 focuses on retention (streak, smart notifications) and first monetization (0.99€ student personalization), with parent-child linking foundations for future parent premium (V2.5).

**Business model:** Dual-tier — student personalization (0.99€ one-time) and parent premium subscription (1.99-2.99€/year). If parent pays, child gets premium free.

**Solo developer** building with Claude Code assistance. Phased sub-releases (V2a → V2b → V2c) to ship incrementally and validate assumptions.

## Success Criteria

### User Success

- **"Bag Ready" confirmation**: Student checks all supplies and receives clear confirmation that their bag is complete for tomorrow — core value moment creating relief and trust
- **Daily habit formation**: Student uses the app 4-5 evenings per week (every evening before a school day)
- **Smart streak**: Consecutive school-day counter that doesn't break on weekends, holidays, or days without classes — builds sense of accomplishment
- **Zero forgotten supplies**: The ultimate promise — when a student trusts the app, no more "croix" in the carnet de liaison
- **Anonymous by default**: Student never needs to provide name, email, or personal data — the app works with device-level identity only

### Business Success

- **Pre-September 2026**: 100 downloads (iOS + Android combined)
- **September 2026 back-to-school**: 500+ downloads via organic word-of-mouth and ASO
- **30-day retention**: 25%+ of downloaders still active after 30 days
- **Weekly active usage**: 60%+ of retained users complete bag check at least 4 times per week
- **Premium student conversion**: 5-10% of active users purchase personalization (0.99€)
- **In-app payment validation**: Successful purchase flow on both stores confirmed before parent premium launch

### Technical Success

- **Firebase Analytics**: Key events tracked — app open, bag check completed, streak count, onboarding completion, premium purchase
- **Streak accuracy**: Correctly detects school vs non-school days from student's timetable data
- **Offline-first maintained**: All V2 features work offline with sync (existing Drift/SyncManager architecture)
- **Performance**: Cold start under 3s, checklist interactions feel instant
- **Privacy-first architecture**: Zero PII collected from students, device_id only, RGPD-compliant by design

### Measurable Outcomes

| Metric | Target | Measurement |
|--------|--------|-------------|
| Downloads (pre-Sept) | 100 | Store Console |
| Downloads (Sept 2026) | 500+ | Store Console |
| D30 retention | 25%+ | Firebase Analytics |
| Weekly active rate | 60%+ of retained | Firebase Analytics |
| Avg bag checks/week | 4+ per active user | Firebase Analytics |
| Premium student conversion | 5-10% | Store + Firebase |
| Avg streak length | 5+ school days | Firebase Analytics |

## Product Scope

### MVP — V2

- **Streak system**: Smart consecutive school-day counter, visible on home screen, doesn't penalize non-school days
- **Smart double reminder**: 2nd push notification if bag not done, with supply count ("You still have 4 items to pack for tomorrow")
- **Premium personalization** (0.99€): Custom photo/image backgrounds for timetable and "Mon Sac" screens
- **Suggested supplies per subject**: Auto-suggest common supplies at course creation (extract `DefaultCourses` into reusable utility)
- **Firebase Analytics**: Full event tracking for all key user actions
- **Smart evening notification**: Enhanced push showing tomorrow's subjects and supply count
- **Parent-child linking foundations**: Student generates pairing code (reuses existing 6-char code pattern). Parent enters code in parent app, assigns child's first name locally. Code usable 2-3 times max. Student remains fully anonymous — zero PII on student side.

### Growth Features (Post-MVP / V2.5)

- **Parent premium** (1.99-2.99€/year): Real-time bag status, "bag ready/not ready" notification, autonomy tracking, multi-child dashboard — includes student personalization for free (if parent pays, child gets premium unlocked)
- **Checkable home screen widget**: Supply list directly checkable from home screen (native iOS/Android)
- **List view alternative**: Action-oriented view as alternative to calendar

### Vision (Future / V3+)

See [Project Scoping — V3+ Vision](#v3--vision) for detailed feature list with effort estimates. Key directions: School B2B portal, OCR timetable import, Pronote integration, September free trial strategy.

### Core Product Principles

- **Anonymous by default**: No PII collected from students — device_id only, no name, no email, no account creation
- **Privacy-first**: RGPD/CNIL compliant by design for minor users
- **Not a Pronote competitor**: Complementary "supply layer" on top of the timetable
- **Parent = payer, Student = user**: Two distinct user roles, one product
- **Parent-child pairing respects anonymity**: Parent names children on their side only, student never provides personal data

## User Journeys

### Journey 1: Leo, 11 ans — "My First Week with DansMonSac" (Onboarding)

Leo just started 6ème at collège Jean Moulin. Eight subjects, different supplies for each, a timetable he hasn't memorized yet. Monday morning, he forgot his compass for math — the teacher marked a "croix." At lunch, his friend Enzo tells him: "Get DansMonSac, I never forget anything now."

That evening, Leo downloads the app. No account to create — he just picks his school year, sets his bag prep time (7pm), and allows notifications. Enzo shows his share code: Leo scans it and imports the full timetable instantly. He adjusts a couple of PE options and he's ready.

At 7pm, the notification hits: "Tomorrow you have Math, French and Biology. 7 supplies to prepare." Leo opens the app, sees the list, checks each supply as he puts it in his bag. Last item checked — the screen shows "Bag Ready!" and his streak goes to 1.

**Capabilities revealed**: Zero-account onboarding, code/QR timetable import, smart notification with next-day summary, granular checklist, "bag ready" confirmation, streak initialization.

### Journey 2: Leo, 3 weeks later — "The Evening Routine" (Daily Happy Path)

It's a Tuesday evening, Leo has built the habit. His streak is at 12 school days. At 7pm, the notification arrives: "Tomorrow you have English, History-Geography and Technology. 9 supplies to prepare." He opens the app, checks methodically. Calculator — check. English notebook — check. Done in 2 minutes. "Bag Ready!" — streak hits 13.

Leo unlocked premium last week for 0.99€. He set a photo of his favorite football player as his timetable background. His friends think it's cool.

Wednesday evening — Leo doesn't have school on Thursday (public holiday). No notification, no pressure. Thursday morning, his streak is still at 13 — the app knows he had no classes.

**Capabilities revealed**: Daily contextual notification, quick checklist flow, smart streak (skips non-school days), premium personalization backgrounds, public holiday / no-class detection.

### Journey 3: Leo — "Oops, I Forgot" (Edge Case / Double Reminder)

Thursday evening, Leo is gaming online with friends. The 7pm notification comes — he ignores it. At 8pm, second notification: "You still have 9 supplies to prepare for tomorrow." Leo drops his game, opens the app, checks everything in 3 minutes. Bag ready, streak saved.

What if Leo hadn't reacted? Next morning, his streak breaks. But the app shows: "You had a 13-day streak! Let's start again?" — no guilt, just motivation to rebuild.

**Capabilities revealed**: Double reminder with supply count, configurable delay (user time + 1h), streak break with encouraging reset UX, second notification only when bag is not done.

### Journey 4: Sophie, Leo's mother — "Peace of Mind" (Parent Linking)

Sophie helped Leo prepare his bag all through September. Now that he's autonomous, she just wants to know if it's done. Leo tells her "Mom, there's a parent thing in the app." Leo generates a pairing code in his app and shows it to Sophie.

Sophie downloads the parent app, enters the code, and types "Leo" as the child's name. Linked. That evening at 7:15pm, Sophie receives a notification: "Leo prepared his bag for tomorrow." She smiles and moves on.

Another evening — it's 8pm and still nothing. Sophie gets: "Warning — Leo hasn't prepared his bag yet." She calls down the hall: "Leo, your bag!" Leo opens the app, checks everything, and Sophie gets the confirmation.

Sophie has two kids in collège. She adds Emma with a second code. Her dashboard shows: Leo — bag ready. Emma — pending.

**Capabilities revealed**: Parent-child pairing code (2-3 uses max), parent-side child naming, "bag ready" parent notification, "bag not ready" parent alert (child's time + 1h), multi-child dashboard.

### Journey Requirements Summary

| Journey | Key Capabilities Revealed |
|---------|--------------------------|
| Leo — Onboarding | Zero-account setup, code/QR import, smart notification, checklist, streak init |
| Leo — Daily routine | Contextual notification, quick checklist, smart streak (skip non-school days), premium personalization |
| Leo — Double reminder | 2nd reminder with supply count, streak break/reset UX, configurable delay |
| Sophie — Parent | Pairing code, parent-side naming, "bag done" notification, "bag not done" alert, multi-child dashboard |

**Cross-cutting capabilities**: Firebase Analytics events on every key action (bag check, streak milestone, premium purchase, parent link created).

## Domain-Specific Requirements

### Compliance & Regulatory

- **RGPD/CNIL (minor users)**: Zero PII collected from students. Device-id only, no name, no email. Anonymous by design. No consent flow needed since no personal data is processed.
- **Store classification**: Standard Education category (not Kids category). Avoids Apple Kids restrictions on third-party analytics and advertising SDKs.
- **In-app purchases by minors**: Relies on native iOS/Android parental controls for purchase authorization. No additional in-app age gate required.
- **Data storage**: Timetable and supply data stored locally (Drift/SQLite) with Supabase sync. No personal data in cloud — only device_id-scoped data.

### Technical Constraints

- **Firebase Analytics**: Allowed under standard Education category. Must NOT collect PII — use device_id and anonymous event tracking only. No user-id, no email, no name in analytics events.
- **Parent-child data flow**: Pairing codes link parent device to student device via anonymous identifiers. Parent-side first name stored only on parent's device/account, never on student side.
- **Offline-first requirement**: All core features (checklist, streak, notifications) must work without internet. Sync when available.

### Accessibility (V2 scope)

- **Font sizing**: Support dynamic type / system font scaling (iOS and Android) for visually impaired or dyslexic users
- **Color contrast**: Ensure WCAG AA contrast ratios (4.5:1 minimum) on all text, especially in dark theme
- **Screen reader**: Core flows (checklist, streak, bag ready confirmation) must be accessible via VoiceOver (iOS) and TalkBack (Android)
- **Touch targets**: Minimum 44x44pt touch targets for checkboxes and interactive elements (critical for young users on small screens)

### Risk Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| App mistakenly listed in Kids category | Firebase/IAP blocked by Apple | Verify category during App Store Connect submission |
| Firebase tracking captures PII accidentally | RGPD violation | Code review: never pass name/email to Analytics, use device_id only |
| Streak logic error on holiday detection | User frustration, broken streaks | Detect "no classes tomorrow" from timetable data, not from external holiday calendar |
| Accessibility gaps block school adoption | Lost distribution channel (schools value inclusion) | Basic WCAG AA from V2, progressive enhancement in V2.5 |

## Mobile App Specific Requirements

### Project-Type Overview

Cross-platform mobile application built with Flutter, targeting iOS and Android. Brownfield project with existing V1 architecture. V2 builds on established patterns without architectural rewrites.

### Platform Requirements

| Aspect | Requirement |
|--------|------------|
| Framework | Flutter (Dart) |
| iOS minimum | iOS 15+ (covers 95%+ of active devices) |
| Android minimum | API 24+ (Android 7.0) with 16KB page alignment for native libs |
| Distribution | App Store + Google Play, Education category |
| Build format | iOS: IPA, Android: App Bundle (AAB) |

### Device Permissions

| Permission | Feature | V2 Scope |
|------------|---------|----------|
| Camera | QR code scanner (mobile_scanner) | Existing V1 |
| Notifications | Local push reminders | Existing V1 + V2 enhancements |
| Photo gallery | Premium background images | V2 new |
| Internet | Supabase sync, Firebase Analytics | Existing + V2 additions |

### Offline Mode Strategy

- **Architecture**: Drift (SQLite) local database as primary data source, Supabase as sync target
- **SyncManager**: Queues operations in PendingOperations table, syncs when connectivity returns
- **V2 features offline**: Streak counter stored locally, checklist state local, notifications are local scheduled — all work without internet
- **What requires connectivity**: Firebase Analytics event upload (buffered), premium purchase validation, timetable import via code

### Push Notification Strategy

**V2 — Local notifications only:**
- **Primary reminder**: Scheduled local notification at user-chosen time. Content: "Tomorrow you have [subjects]. [N] supplies to prepare."
- **Double reminder**: Second local notification scheduled at user_time + 1 hour. Auto-cancelled if bag marked as done before trigger. Content: "You still have [N] supplies to prepare for tomorrow."
- **No-school detection**: If no classes found in timetable for tomorrow, no notifications scheduled. Streak unaffected.
- **Implementation**: flutter_local_notifications package (already in V1)

**V2.5 — Server push (parent notifications):**
- **Requires**: Firebase Cloud Messaging (FCM) setup
- **Trigger**: Student marks bag as done → Supabase function → FCM push to linked parent device(s)
- **Timeout trigger**: Student's reminder time + 1h, bag still not done → FCM push "warning" to parent
- **Not in V2 scope**: Only technical foundations (pairing data model) are laid in V2

### Store Compliance

- **Category**: Education (standard, not Kids)
- **In-App Purchases**: Non-consumable (student personalization 0.99€), auto-renewable subscription (parent premium 1.99-2.99€/year — V2.5)
- **16KB alignment**: Verify all native plugins (.so) are 16KB-aligned for Android (Google Play requirement)
- **Privacy labels**: Both stores require privacy nutrition labels — declare: no PII collected, device_id for analytics, no tracking across apps

### Implementation Considerations

- **Code generation**: Riverpod (`@riverpod`) and Drift tables require `build_runner` after modifications
- **Feature modules**: New features follow existing modular pattern in `features/` directory
- **State management**: Riverpod with annotations + code generation, consistent with V1
- **Premium/IAP**: New module needed for in-app purchase management (RevenueCat recommended for cross-platform IAP abstraction, or native StoreKit/Google Play Billing)

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Problem-solving MVP — deliver the minimum feature set that makes students say "I can't go back to preparing my bag without this app."

**Resource:** Solo developer with Claude Code assistance. Phased sub-releases to ship fast, measure, iterate.

**Core User Journeys Supported by MVP (V2a+V2b):**
- Journey 1 (Leo — Onboarding): Fully supported
- Journey 2 (Leo — Daily routine): Fully supported including premium
- Journey 3 (Leo — Double reminder): Supported in V2b
- Journey 4 (Sophie — Parent): Foundations only in V2c, full experience in V2.5

### V2a — Core Release (Ship First)

| Feature | Effort | Rationale |
|---------|--------|-----------|
| Streak system (smart, school-days only) | Medium | The killer retention feature. Makes the app sticky. |
| Smart evening notification (enhanced text) | Low | Upgrade existing V1 notification text to include subjects + supply count. Near-zero effort. |
| Firebase Analytics | Low | Instrument key events. Without measurement, all other decisions are blind. |
| Suggested supplies per subject | Low | Extract existing `DefaultCourses` into reusable utility. Better onboarding experience. |

**V2a validates:** Do students come back daily? Does the streak create habit formation?

### V2b — Monetisation Release

| Feature | Effort | Rationale |
|---------|--------|-----------|
| Premium personalization (0.99€) | Medium | First revenue stream. IAP setup on both stores. Custom backgrounds for timetable and "Mon Sac." |
| Smart double reminder | Low-Medium | 2nd notification at user_time + 1h if bag not done. Auto-cancelled if done. Retention safety net. |

**V2b validates:** Will students pay 0.99€? Does the double reminder reduce missed bag preps?

### V2c — Parent Foundations

| Feature | Effort | Rationale |
|---------|--------|-----------|
| Parent-child linking foundations | Medium-High | Pairing code system, anonymous linking data model, parent-side child naming. No parent notifications yet (no FCM). |

**V2c validates:** Can we technically link parent and student devices while preserving student anonymity?

### V2.5 — Engagement & Parent Premium

| Feature | Effort | Rationale |
|---------|--------|-----------|
| Parent premium (1.99-2.99€/year) | High | FCM setup, server-side push, "bag ready/not ready" notifications, multi-child dashboard. If parent pays → child gets premium free. |
| Checkable home screen widget | Medium | Native iOS/Android widget. Zero-friction daily use. |
| List view alternative | Low | Action-oriented view as alternative to calendar. |

### V3+ — Vision

| Feature | Effort |
|---------|--------|
| School B2B admin portal | High |
| OCR timetable import (photo/PDF) | High |
| Pronote integration | High |
| September Free trial strategy | Low |

### Risk Mitigation Strategy

**Technical Risks:**

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Streak logic bugs (wrong school-day detection) | Medium | High — user trust destroyed | Derive from timetable data only, extensive edge case testing (weekends, holidays, empty days) |
| IAP setup complexity (two stores) | Medium | Medium — delays monetisation | Consider RevenueCat for cross-platform abstraction, or implement one store first |
| Parent linking data model wrong | Low | High — costly to change later | Design schema carefully in V2c, even if parent features launch in V2.5 |

**Market Risks:**

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Students don't build daily habit | Medium | High — product fails | Streak + double reminder designed to create habit. Firebase Analytics measures D7/D30 retention. |
| 0.99€ conversion too low | Medium | Low — small revenue expected | At this price, even 5% conversion validates the mechanism. Real revenue comes from parent premium. |
| Word-of-mouth doesn't spread | Medium | Medium — slow growth | Share code/QR already exists. Streak screenshots are shareable. Focus on back-to-school timing. |

**Resource Risks:**

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Solo dev burnout | Medium | High | Sub-releases prevent big-bang pressure. Ship V2a first, breathe, then V2b. |
| Claude Code limitations on native widgets | Low | Medium | Widget is V2.5 — by then, tooling may have improved. Can also use home_widget package. |
| Store review delays | Medium | Low | Submit early, expect 1-2 rejection rounds. Factor into timeline. |

## Functional Requirements

### Bag Preparation & Checklist

- **FR1**: Student can view a list of all supplies needed for the next school day, grouped by subject
- **FR2**: Student can check/uncheck individual supplies as they pack their bag
- **FR3**: Student can see a clear "Bag Ready" confirmation when all supplies for tomorrow are checked
- **FR4**: System can determine tomorrow's subjects from the student's timetable
- **FR5**: System can detect no-class days (weekend, holiday, empty timetable) and suppress the checklist

### Streak & Habit Tracking

- **FR6**: System can track consecutive school days where the student completed bag preparation
- **FR7**: System can distinguish school days from non-school days using timetable data (streak counts school-day evenings only)
- **FR8**: Student can view their current streak count
- **FR9**: System can detect a broken streak and display an encouraging reset message with the previous streak length
- **FR10**: System can persist streak data locally and sync when connected

### Notifications & Reminders

- **FR11**: Student can set their preferred bag preparation time
- **FR12**: System can send a contextual notification at the student's chosen time showing tomorrow's subjects and supply count
- **FR13**: System can send a second reminder notification if the bag is not marked as done within a configurable delay after the first
- **FR14**: System can auto-cancel the second reminder if the student completes their bag before it triggers
- **FR15**: System can suppress all notifications when there are no classes the next day

### Timetable Management

- **FR16**: Student can create and manage their weekly timetable with subjects, time slots, rooms, and week type (A/B/both)
- **FR17**: Student can import a timetable from another student via share code or QR code
- **FR18**: Student can share their timetable with other students via share code or QR code
- **FR19**: System can handle week A/B alternation based on school year start date

### Supply Management

- **FR20**: Student can add, edit, and delete supplies associated with each subject
- **FR21**: System can suggest common supplies when a student creates a new subject
- **FR22**: Student can accept, modify, or dismiss suggested supplies during subject creation

### Personalization & Premium

- **FR23**: Student can purchase a personalization upgrade (in-app purchase)
- **FR24**: Premium student can set a custom background image (from photo gallery or device storage) for the timetable screen
- **FR25**: Premium student can set a custom background image for the "Mon Sac" (bag preparation) screen
- **FR26**: System can verify and restore premium purchase status across app reinstalls
- **FR27**: System can unlock premium personalization for a student whose linked parent has an active parent subscription

### Parent-Child Linking

- **FR28**: Student can generate a pairing code for parent linking
- **FR29**: Parent can enter a pairing code to link to a student's device
- **FR30**: Parent can assign a first name to each linked child (stored parent-side only)
- **FR31**: Pairing code can be used a maximum of 2-3 times (multiple parents/guardians)
- **FR32**: Student remains fully anonymous — no personal data transmitted during pairing

### Analytics & Measurement

- **FR33**: System can track key user events anonymously (app open, bag check completed, streak milestone, premium purchase, onboarding completion)
- **FR34**: System can report analytics without collecting any personally identifiable information
- **FR35**: System can buffer analytics events when offline and upload when connectivity returns

### Onboarding & Setup

- **FR36**: Student can complete initial setup without creating an account (no email, no name, no password)
- **FR37**: Student can configure school year parameters (week A/B start date) during onboarding
- **FR38**: Student can set their preferred notification time during onboarding
- **FR39**: Student can optionally import a timetable during onboarding via code or QR scan
- **FR40**: System can create default subjects with suggested supplies for new users

### Accessibility

- **FR41**: Student can use the app with system-level font size adjustments (dynamic type)
- **FR42**: Student can navigate and complete core flows (checklist, streak view, bag ready) using screen reader (VoiceOver/TalkBack)
- **FR43**: All interactive elements provide sufficient touch target size for young users

## Non-Functional Requirements

### Performance

- **NFR1**: Checklist interactions (check/uncheck supply) must feel instant — under 100ms response (local DB operation)
- **NFR2**: Tomorrow's supply list must load in under 500ms (local Drift query)
- **NFR3**: App cold start must complete in under 3 seconds on mid-range devices (2020+)
- **NFR4**: Screen transitions must complete in under 300ms
- **NFR5**: Notification scheduling (compute tomorrow's subjects + schedule local push) must complete in under 1 second

### Security & Privacy

- **NFR6**: Zero personally identifiable information collected from students — device_id is the only identifier
- **NFR7**: All network communication must use HTTPS (TLS 1.2+)
- **NFR8**: Supabase data encrypted at rest (Supabase default)
- **NFR9**: Firebase Analytics events must never contain PII (no name, email, phone, or location)
- **NFR10**: Pairing codes must be non-guessable (6-char alphanumeric, limited to 2-3 uses)
- **NFR11**: IAP validation must use store-signed receipts only — no custom payment processing
- **NFR12**: No third-party tracking or advertising SDKs permitted in the app

### Reliability

- **NFR13**: Streak data must persist through normal app lifecycle — zero data loss on app restart, update, or background kill
- **NFR14**: All core features (checklist, streak, notifications) must function fully offline without internet
- **NFR15**: Local notifications must fire within ±1 minute of the scheduled time (OS-dependent)
- **NFR16**: Sync queue (PendingOperations) must survive app restart and resume on next connectivity
- **NFR17**: Local database (Drift) is authoritative — if sync conflict occurs, local data takes precedence until conflict resolution is implemented
- **NFR18**: App must handle Drift database migration gracefully between versions without data loss

### Accessibility

- **NFR19**: All text must meet WCAG AA contrast ratio (4.5:1 minimum), especially in dark theme
- **NFR20**: App must support dynamic type / system font scaling on iOS and Android
- **NFR21**: All interactive elements must have minimum 44x44pt touch targets
- **NFR22**: Core flows (checklist, streak, bag ready) must be navigable via VoiceOver (iOS) and TalkBack (Android)
- **NFR23**: Information must not rely on color alone — always provide text or icon alternatives
