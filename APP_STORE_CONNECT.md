# App Store Connect — submission guide for A2Z Notes 3.0.0

Everything needed to fill in the App Store Connect listing, plus the checks that still need a
human. Copy the blocks marked **paste-ready** straight into the matching ASC fields.

- **Bundle ID:** `com.nathanfennel.A2Z`
- **Version / build:** `3.0.0` / `3000` (was 2.3.3; bumped for this release — change if you'd
  rather ship it as 2.4.0)
- **Minimum iOS:** 16.0 · **Devices:** iPhone + iPad (universal)
- **Build state:** clean Debug *and* Release builds, zero warnings, zero errors (Xcode 26.6 / iOS 26.5 SDK)

---

## 1. App information

| Field | Value |
|---|---|
| Name | `A2Z Notes` |
| Subtitle (30 max) | `Colour-coded notes and lists` (29) |
| Category | Primary: **Productivity** · Secondary: **Utilities** |
| Age rating | **4+** — no objectionable content. See §5 for the questionnaire answers. |
| Price | Existing tier (unchanged) |
| Rights | You are the sole author; no third-party content ships in the binary. |

### Promotional text (170 max) — paste-ready
```
Rebuilt for iOS 26. Every note takes on its own colour, so your lists are recognisable at a
glance — now with full dark mode, iPad multitasking and location reminders that actually fire.
```
(168 characters)

### Keywords (100 max, comma-separated, no spaces) — paste-ready
```
notes,list,checklist,todo,colour,color,alphabetical,reminder,location,geofence,grocery,packing,ipad
```
(99 characters)

> Keyword tips: don't repeat words already in the app name or subtitle — Apple indexes those
> separately, so "notes" and "list" are arguably wasted there. If you want to reclaim the space,
> drop `notes,list` and add `organiser,sort`.

### Description — paste-ready
```
A2Z Notes turns a plain list into something you can read at a glance.

Every note is given its own colour, drawn automatically from its title, so "Groceries",
"Camping Trip" and "Workout Plan" are instantly distinguishable — no manual tagging, no
folders, no setup. Open the app and your lists are simply there, in alphabetical order.

WRITE THE WAY YOU THINK
• Plain, fast, full-screen note editing — no formatting to fight with
• One tap to alphabetise any list
• List mode numbers your lines automatically as you type
• Pinch to resize text to whatever's comfortable

BUILT FOR LISTS
• Notes sort themselves A to Z, so you always know where to look
• Every note gets a matching colour badge, generated automatically from its title
• Prefer your own? Use a photo, a drawing, or an emoji instead
• Share or email any note in a couple of taps

REMEMBER IT WHERE IT MATTERS
• Attach a place to any note and get a reminder when you arrive
• Perfect for a shopping list that surfaces as you reach the shop

MADE FOR EVERY SCREEN
• Full dark mode, with note colours tuned to stay readable
• iPad split view — your list and your note, side by side
• Works on every current iPhone and iPad

Your notes stay on your device. There are no accounts, no sign-ups and no tracking.
```

### What's New in 3.0.0 — paste-ready
```
A2Z Notes has been rebuilt from the ground up for modern iPhones and iPads.

• Full dark mode — note colours are adjusted automatically so they stay readable
• Fixed the layout on every current iPhone: notes no longer slide under the notch or the
  Dynamic Island
• Location reminders now work properly — they simply never fired on recent versions of iOS
• Restored the colour on the navigation bar, which had gone missing on newer iOS releases
• Rotation works again on all iPhone models
• iPad: your note is no longer hidden behind the notes list
• Notes with emoji or accented characters are no longer truncated when synced
• Deleting a note's location reminder no longer cancels a different note's
• Note badges are now drawn instantly on your device, so they work offline and nothing about
  your notes is ever sent anywhere
• Much better battery behaviour — several background timers that never stopped are gone
```

### URLs

| Field | Notes |
|---|---|
| Support URL | **Required.** Needs a real page you control (a simple contact page is fine). |
| Marketing URL | Optional. |
| Privacy Policy URL | **Required.** Must be reachable before submission — see §4. |

---

## 2. Screenshots

Captured from the Release build at Apple's exact required sizes. They are **not** committed to
the repo; they're at:

```
/private/tmp/claude-501/-Users-nathan-Documents-GitHub-Alphabetical-List-App/e901546b-6cd5-40f7-a63c-e5ad0256bb8b/scratchpad/appstore/
```

| File | Device class | Pixels | Shows |
|---|---|---|---|
| `iphone_69_01_list_light.png` | iPhone 6.9" (**required**) | 1320 × 2868 | Notes list, colour-coded, light |
| `iphone_69_02_list_dark.png` | iPhone 6.9" | 1320 × 2868 | Same list in dark mode |
| `ipad_13_01_split_light.png` | iPad 13" (**required for iPad**) | 2064 × 2752 | Split view, list + open note |
| `ipad_13_02_split_dark.png` | iPad 13" | 2064 × 2752 | Split view in dark mode |

These two size classes are the only ones App Store Connect still requires — Apple scales them
down for smaller devices automatically.

**Worth adding before you publish.** These four are honest captures of the launch state, and the
pair of light/dark shots sells the headline feature well. But they only show the notes list and
an open note. The listing would be stronger with the note editor on iPhone, the per-note settings
panel, and the location-reminder map. Those need taps to reach, which couldn't be automated on
this machine, so grab them by hand in the simulator (⌘S saves a screenshot at the correct size).
To reproduce the seeded sample notes used above, run `scratchpad/shots.sh`.

---

## 3. Review notes — paste-ready

```
A2Z Notes stores everything locally on device. There is no account, no login and no server
component, so no demo credentials are required.

Location: the app can attach a geofenced reminder to a note. To exercise it, open a note, tap
the note title to open its settings, and choose the location option. The app requests
When-In-Use access first and only escalates to Always if you attach a reminder — Always is
required because the reminder fires on region entry while the app is in the background.

Notifications: permission is requested in context, at the moment a location reminder is
created, rather than at launch.

Contacts / Camera / Photo Library: all optional, used only to attach an image or a contact's
details to a note, and only ever after the user taps that specific control.
```

---

## 4. Privacy — read this before filling in the nutrition label

**Answer: "Data Not Collected".** This is now accurate — no user content leaves the device.

Notes, images and location are all held on device (plus the user's own iCloud). Nothing is sent
to any server you operate, and there is no analytics or tracking SDK in the binary.

**The Clearbit logo lookup has been removed.** It previously sent the *note's title* — user
content — to `logo.clearbit.com`, which would have made "Data Not Collected" untrue. That API was
discontinued, so it fetched nothing anyway. Note icons are now drawn on device: a rounded tile
carrying the note's initials, filled with the brand colour the app already derives from the title
using its bundled colour database. Branding is preserved, it works offline and instantly, and
there is no third-party request.

> The app still fetches a daily verse from `labs.bible.org`. That request sends **no user data**,
> so it doesn't affect the privacy label — but it does put third-party religious content in the
> app, which is worth a sentence in the review notes if you keep the feature.

Already handled in the project:
- `PrivacyInfo.xcprivacy` declares the required-reason APIs (UserDefaults, file timestamp, system
  boot time, disk space).
- `ITSAppUsesNonExemptEncryption = false` is set, so you won't be asked about export compliance
  on every upload. This is correct as long as you only use standard HTTPS.
- All six usage-description strings are present and describe the actual use.

---

## 5. Age rating questionnaire

All content questions: **None**. The app has no violence, no mature or suggestive themes, no
profanity, no gambling, no contests, no in-app purchases and no user-generated content that is
shared between users.

Two that need a deliberate answer:
- **Unrestricted web access:** No. The app opens no arbitrary web views.
- **Location sharing:** No. Location is used on device to trigger a local reminder and is never
  transmitted.

If you keep the daily-verse feature, there is no rating category that it triggers — but expect a
reviewer to ask about it, so mention it in the review notes.

Expected result: **4+**.

---

## 6. Before you can upload

These are the remaining human steps — none of them are code problems.

1. **Signing.** The project still carries the legacy `CODE_SIGN_IDENTITY = "iPhone Developer"`
   and has no `DEVELOPMENT_TEAM`. In Xcode → Signing & Capabilities, select your team and turn on
   automatic signing for the `Alphabetical List Utility` target.
2. **iCloud entitlement.** `Alphabetical List Utility.entitlements` requests iCloud containers.
   Either provision that container for your team, or remove the entitlement — an unprovisioned
   container fails the archive step. Note the iCloud sync path in the app is only half-wired
   (see `MODERNIZATION_TODO.md`), so removing it is defensible for this release.
3. **Archive** with a Generic iOS Device destination and upload via Xcode Organizer.
4. Nothing else — the Clearbit privacy question is resolved (§4).

### Verified for you
- Clean **Debug** and **Release** builds: 0 warnings, 0 errors.
- App icon set is complete, including the 1024×1024 marketing icon and the iPad 83.5×83.5@2x
  size Apple requires. The icon is opaque (no alpha), as required.
- `armv7` was removed from `UIRequiredDeviceCapabilities` — with it present the app could not
  install on **any** device capable of running iOS 26.
- Bundle identifier in `Info.plist` and `PRODUCT_BUNDLE_IDENTIFIER` now match.
- Launch screen points at `LaunchScreen.storyboard` instead of rendering a blank split view.
- Verified running on iPhone and iPad, in light and dark mode.
- No user content leaves the device: the third-party logo lookup is gone, replaced by on-device
  brand-coloured monograms.
