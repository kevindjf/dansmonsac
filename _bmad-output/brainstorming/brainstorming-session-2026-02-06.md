---
stepsCompleted: [1, 2, 3, 4]
inputDocuments: []
session_topic: 'Evolution strategique de DansMonSac - nouvelles fonctionnalites et monetisation'
session_goals: 'Identifier les manques, trouver des features engageantes, definir des pistes de monetisation (premium/abonnement), distinguer gratuit vs payant'
selected_approach: 'ai-recommended'
techniques_used: ['Role Playing', 'SCAMPER Method', 'Cross-Pollination']
ideas_generated: 23
context_file: '_bmad/bmm/data/project-context-template.md'
session_active: false
workflow_completed: true
---

# Brainstorming Session Results

**Facilitator:** Kevin
**Date:** 2026-02-06

## Session Overview

**Topic:** Evolution strategique de DansMonSac — nouvelles fonctionnalites a forte valeur ajoutee et strategie de monetisation (premium / abonnement)

**Goals:**
1. Identifier ce qui manque a l'app actuelle pour fideliser les utilisateurs
2. Trouver des fonctionnalites engageantes qui creent de la retention
3. Definir des pistes de monetisation credibles (features premium, abonnement)
4. Distinguer ce qui attire les utilisateurs (gratuit) vs ce qui justifie un paiement (premium)

### Context Guidance

_Session focalisee sur un produit educatif B2C (eleves) en V1 avec base fonctionnelle existante (emploi du temps, fournitures, check quotidien). Exploration orientee croissance et monetisation._

### Session Setup

_Kevin souhaite explorer l'evolution de DansMonSac au-dela de sa V1 actuelle. L'app a une base solide mais manque de fonctionnalites engageantes et d'un modele economique. Le brainstorming doit couvrir a la fois l'attractivite utilisateur et la justification d'un modele payant._

### V1 Current Features (baseline)

- Static timetable (manual entry)
- Supplies associated per subject
- Daily granular checklist (per supply or per subject)
- Share timetable via QR code / code
- Single notification reminder at user-chosen time
- Basic text color customization
- Default courses with supplies at onboarding (6 French subjects)

## Technique Selection

**Approach:** AI-Recommended Techniques
**Analysis Context:** Evolution strategique de DansMonSac avec focus sur features engageantes et monetisation

**Recommended Techniques:**

- **Role Playing (collaborative):** Explorer les besoins de chaque partie prenante (eleve, parent, enseignant, ecole) pour decouvrir les manques et opportunites
- **SCAMPER Method (structured):** Passer la V1 au crible des 7 lentilles pour generer des dizaines d'idees de features concretes
- **Cross-Pollination (creative):** Emprunter les modeles d'engagement et monetisation d'autres industries (fitness, gaming, edtech) pour trouver le bon modele economique

**AI Rationale:** Sequence progressive allant de la comprehension utilisateur (Role Playing) a la generation de features (SCAMPER) puis a la strategie de monetisation (Cross-Pollination). Chaque technique nourrit la suivante.

## Technique Execution Results

### Role Playing — Stakeholder Exploration

**Persona: Student**

- **Core pain point:** Fear of forgetting supplies → teacher marks a cross in the carnet de liaison → parents notified → stress chain
- **Current app value:** Certainty through granular checklist. "I checked everything, I'm safe."
- **Viral potential:** Students would tell friends to download "just to not forget anything" — utilitarian word-of-mouth

**Key ideas generated:**

**[Eleve #1]**: Locker / dual location management
- Track where each supply is (home vs school locker)
- Move from "static checklist" to "intelligent inventory" between two locations

**[Eleve #2]**: Back-to-school mode / learning mode
- First weeks of year: intensive companion mode to learn which supplies go with which subject
- App becomes a temporary coach, not just a passive tool

**[Eleve #3]**: Anti-overload / bag weight optimization
- Show ONLY what's needed for tomorrow
- Value inversion: not just "don't forget" but also "don't take too much"

**[Eleve #4]**: Smart evening notification
- Push: "Tomorrow you have Math, French and Science. Here's what you need."
- App comes to the student at the right time

**Persona: Parent**

- Schools ask parents to help pack bags together during the first month
- Pronote dominates school life management → DansMonSac must NOT compete with Pronote
- Parent is the natural PAYER while the student is the USER

**Key ideas generated:**

**[Parent #1]**: Family mode / soft supervision
- Parent linked to child's account, sees "bag done / not done"
- Trust bridge, not a control tool

**[Parent #2]**: Autonomy journey
- First month: parent co-validates. Then gradually, child does it alone.
- Visualize autonomy growth: "Week 4: your child packed their bag alone 5 out of 5 days"

**[Parent #3]**: Parent "bag ready" notification
- Evening push to parent: "Lucas packed his bag for tomorrow" or "It's 8pm, Lucas hasn't packed yet"
- Peace of mind without physically checking

**Persona: School**

- Teachers have no direct role in the app
- Schools CAN have a role by creating timetables and distributing via codes
- B2B2C model: school pays for admin tools, students use free app

**Key ideas generated:**

**[Ecole #1]**: School admin dashboard — timetable creation
- School creates official timetables per class on web portal
- Each class gets a code for students to scan and auto-import

**[Ecole #2]**: Viral distribution channel
- One CPE adopts → all students in the school download
- User acquisition by waves at each school year start

**[Ecole #3]**: School annual subscription
- School pays for admin portal (class management, timetables, supply lists)
- Recurring B2B revenue, much more stable than B2C

**[Ecole #4]**: Timetable import via PDF/image on admin portal
- School imports existing timetables (Pronote PDF, images) directly into portal
- Parsed and distributed to students via class codes — zero double entry

**Pronote Integration Exploration:**

**[Integration #1]**: Import via student Pronote credentials — dynamic timetable sync
**[Integration #2]**: Community API (Pronotepy) — fast but fragile/legally risky
**[Integration #3]**: OCR screenshot import — no API dependency, student in control
**[Integration #4]**: Partnership with Index Education — long-term strategy, need user base first
**[Integration #5]**: Multi-platform support (Pronote, EcoleDirecte, Skolengo) — universal "supply layer"

**Role Playing Energy:** High engagement, pragmatic filtering, clear stakeholder understanding

### SCAMPER Method — Systematic Feature Innovation

**S - Substitute:**

**[SCAMPER-S #1]**: Import timetable via photo/PDF (OCR) — ✅ VALIDATED
- Two sources: photo of carnet de liaison OR Pronote PDF
- Eliminates manual entry friction

**[SCAMPER-S #2]**: Granular check instead of binary → ALREADY EXISTS in V1
**[SCAMPER-S #3]**: Visual icons for supplies → REJECTED (not clear added value)

**C - Combine:**

**[SCAMPER-C #1]**: Share timetable between classmates → ALREADY EXISTS (QR code)
**[SCAMPER-C #2]**: Checklist + homework reminder → REJECTED (Pronote handles homework)
**[SCAMPER-C #3]**: Student check action + parent notification — ✅ VALIDATED
- One student gesture satisfies two people
- Foundation of parent premium model

**[SCAMPER-C #4]**: Timetable + back-to-school shopping list → REJECTED (not priority)

**A - Adapt:**

**[SCAMPER-A #1]**: Checkable home screen widget — ✅ VALIDATED
- Supply list directly checkable from home screen, like a weather widget
- Zero friction daily use

**[SCAMPER-A #2]**: Apple Watch → REJECTED (checking without verifying defeats purpose, not readable)

**M - Modify:**

**[SCAMPER-M #1b]**: List view alternative — ✅ VALIDATED
- Alternative to calendar view, more action-oriented

**[SCAMPER-M #2]**: Audience extension to lycee — ✅ VALIDATED (requires dynamic timetable)
**[SCAMPER-M #3]**: Premium personalization (themes, backgrounds) — ✅ VALIDATED
- Personal photos/downloaded images as timetable backgrounds
- Already has text color change; expand to full visual customization

**P - Put to other uses:**

**[SCAMPER-P #1]**: Other bag types (sport, travel) → REJECTED (no timetable structure for non-daily bags)
**[SCAMPER-P #2]**: Hub for extra-curricular → REJECTED (dilutes focus)

**E - Eliminate:**

**[SCAMPER-E #1]**: Pre-fill standard supplies per subject — ✅ VALIDATED
- Math → calculator, compass, protractor etc. auto-suggested
- Student DELETES what doesn't apply instead of ADDING everything
- Existing code base found: `DefaultCourses.frenchSchoolSubjects` in onboarding — needs extraction into reusable utility

**R - Reverse:**

**[SCAMPER-R #1]**: Show what to leave at home → REJECTED (student packs at home, needs to know what to PUT IN)

**SCAMPER Energy:** Efficient filtering, several features already existed revealing strong V1 foundation

### Cross-Pollination — Monetization & Engagement Models

**Domain: Habit Apps (Duolingo, Habitica, Streaks)**

**[Cross #1]**: Daily streak "bag packed" — ✅ VALIDATED
- Consecutive days counter, personal motivation
- Visible by parent (premium)

**[Cross #2b]**: Smart double reminder — ✅ VALIDATED
- 1st reminder at chosen time (exists). 2nd reminder 1-2h later IF bag not done
- "You still have 4 supplies to pack for tomorrow"

**[Cross #3]**: Badges/rewards → REJECTED (students won't pay for badges in this app)
**[Cross #3b]**: Personal photo/image customization — ✅ VALIDATED (authentic personalization over gamification)

**Domain: Freemium SaaS (Spotify, Canva)**

**[Cross #4]**: Generous free limits a la Canva — inspired FREE tier design
**[Cross #5]**: Family subscription a la Spotify — inspired multi-child parent dashboard
**[Cross #6]**: September free trial — ✅ VALIDATED
- Premium free all September (peak stress/motivation month)
- Natural conversion in October when habits are formed

**Cross-Pollination Energy:** Strong monetization insights, pragmatic pricing decisions

### Creative Facilitation Narrative

_Kevin demonstrated sharp product instincts throughout the session — consistently filtering ideas through the lens of "does this actually serve a college student?" He rejected over-gamification (badges, leaderboards) in favor of authentic personalization (personal photos). He immediately identified the parent as the natural payer and the school as the distribution channel. His pragmatic pricing at 1.99-2.99 EUR/year shows awareness that the app needs to prove value before charging premium prices. The session evolved naturally from user understanding to feature generation to monetization strategy._

### Session Highlights

**User Creative Strengths:** Pragmatic filtering, deep user empathy, strategic pricing instinct
**AI Facilitation Approach:** Progressive technique sequence, building each phase on previous insights
**Breakthrough Moments:** Triple monetization model (student/parent/school), parent-as-payer insight, September free trial strategy
**Energy Flow:** Consistent high engagement, efficient idea evaluation, clear yes/no decisions

## Idea Organization and Prioritization

### Theme 1: Onboarding Friction Reduction

- Import timetable via photo/PDF (OCR)
- Pre-fill suggested supplies per subject (existing code base in DefaultCourses)
- School code distribution for instant setup
- Back-to-school learning mode for first weeks

### Theme 2: Student Engagement & Retention

- Daily streak "bag packed"
- Smart double reminder with supply counter
- Checkable home screen widget
- Smart evening notification with next-day summary
- List view alternative

### Theme 3: Parent Premium (= Main Paywall)

- Real-time bag status view (per supply)
- "Bag ready / not ready" parent notification
- Autonomy tracking stats
- Multi-child dashboard
- Streak visibility
- ALL parent access is premium (free in September)

### Theme 4: School B2B Distribution

- Admin web portal for timetable creation
- Timetable import via PDF/image on admin portal
- Class codes for mass distribution
- Dynamic timetable updates pushed to students
- Anonymized stats (pack rates, forgotten items, trends by grade level)
- Zero identifiable data — full RGPD compliance

### Theme 5: Personalization & Soft Monetization

- Custom backgrounds (personal photos, downloaded images)
- Extended themes and visual customization
- Lycee extension (requires dynamic timetable)
- Pronote integration (multiple strategies: OCR, community API, partnership)

### Cross-Cutting Concepts

- **"September Free" strategy** — Full premium during September, convert in October
- **Triple pricing model** — Student (1.99-2.99 EUR/yr), Parent (1.99-2.99 EUR/yr), School (annual B2B subscription)
- **Clear positioning** — "Supply layer on top of timetable", NOT a Pronote competitor

### Prioritization Results

**Phase 1 — Short Term: Retain & Grow (V2)**

| Priority | Feature | Impact | Effort |
|----------|---------|--------|--------|
| 1 | Streak system | High retention, daily return | Low |
| 2 | Smart double reminder | Reduces forgotten items | Low |
| 3 | Custom background personalization | Engagement, "my app" feeling | Medium |
| 4 | Checkable home screen widget | Zero-friction daily use | Medium (native) |
| 5 | Suggested supplies per subject at setup | Better onboarding (existing code base) | Low |

**Goal:** Increase retention and organic word-of-mouth among students.

**Phase 2 — Medium Term: Monetize (Parent Premium)**

| Priority | Feature | Impact | Effort |
|----------|---------|--------|--------|
| 1 | Full parent access (real-time bag view) | Main paywall | Medium |
| 2 | Parent notification (bag ready/not ready) | Key selling point | Low |
| 3 | Autonomy tracking | Strong educational value | Medium |
| 4 | Multi-child dashboard | Family conversion | Medium |
| 5 | "September Free" trial strategy | Natural conversion | Low |

**Goal:** Launch economic model at 1.99-2.99 EUR/year. Parent pays for peace of mind.

**Phase 3 — Long Term: Scale (B2B School + OCR)**

| Priority | Feature | Impact | Effort |
|----------|---------|--------|--------|
| 1 | OCR photo/PDF import (student + school) | Game changer onboarding | High |
| 2 | School admin web portal | Viral distribution channel | High |
| 3 | Class codes + mass distribution | Massive acquisition | Medium |
| 4 | Anonymized school stats | B2B selling point | Medium |
| 5 | Dynamic Pronote integration | Ultimate goal | High |

**Goal:** Shift from organic to institutional growth. One school = hundreds of downloads.

### Technical Notes

- **Suggested supplies base exists:** `features/onboarding/lib/src/data/default_courses.dart` contains `DefaultCourses.frenchSchoolSubjects` with 6 subjects and associated supplies. Needs extraction into reusable utility for use beyond onboarding.
- **Share via QR code already exists** — can be leveraged for school distribution
- **Offline-first architecture already in place** (Drift/SQLite + SyncManager) — supports all proposed features

## Session Summary and Insights

**Key Achievements:**

- 23 ideas generated, evaluated, and organized across 3 techniques
- Clear triple monetization model defined (Student / Parent / School)
- 3-phase roadmap established with pragmatic prioritization
- Strong V1 foundation confirmed (several proposed features already exist)
- Technical feasibility assessed with existing codebase

**Strategic Positioning:**
- DansMonSac = "Intelligent supply layer on top of the school timetable"
- NOT a Pronote competitor — complementary tool focused exclusively on bag preparation
- Student uses free, Parent pays for visibility, School pays for distribution tools

**Critical Success Factors:**
1. Phase 1 must demonstrate retention improvement before monetization
2. September launch timing is critical for trial conversion
3. School adoption is the exponential growth lever
4. Pronote integration (any form) would be the ultimate competitive moat
