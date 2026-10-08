# AtoZ feature restoration — build 3014

The authoritative shipping identity remains `com.nathanfennel.A2Z`, Apple ID 1016741170. The recovered 2015 `a2z-notes` repository and this repository's earlier UIKit implementations were compared against the SwiftUI library. Existing note bodies, RTFD images, icons, settings and manual reminder coordinates retain their original storage. This candidate is not uploaded or submitted.

## Original feature inventory

| Feature | Result and evidence |
| --- | --- |
| Alphabetical library, create, search, rename, share, delete | Preserved. Native creation, searching, cold reload and rename checked. Delete was not exercised on existing notes. |
| Automatic title colors, multi-color branded titles, icons | Restored to the SwiftUI library. Target red editor/library, Google blue editor and multi-color title plus originating-site favicon verified in the actual app. Per-source icon settings and card styles are retained. |
| Note settings: numbered lists, alphabetical lines, card style/intensity, font controls | Preserved. Separate sorting/numbering caches fixed. Actual production line-formatting tests preserve attributed images, styles, selection and newline behavior. |
| Rich text and inline images | Existing RTFD retained. Rename copies the existing RTFD bytes rather than risking a conversion failure. |
| Manual place reminders | Preserved with radius/presence/cache-key fixes, correct region ownership, unified notification delivery and tap routing. Reading or renaming a note no longer requests location. Physical arrival and background delivery are unverified. |
| Contact picker | Restored selected contact names, phones and emails into the note; system picker avoids broad contact-library access. Source/build checked, actual contact selection unverified. |
| Emoji/drawing note icons | Existing editor retained. New full drawings attach separately and remain editable. |
| Polish, Undo/Redo, external Bible passage links | Existing implementations retained; production polish and service privacy checks pass. Foundation Models availability remains device-dependent. |
| External-display reading/scrolling | Existing native controller retained; no connected AirPlay/HDMI device tested. |
| iCloud | Historical source is half-wired and does not establish working synchronization. No new cloud-sync claim is made. |

## Added metadata and attachments

Additive Application Support index uses stable UUIDs for note details and attachment folders. New notes have real creation/edit dates; existing notes display unknown creation dates rather than fabricated history. Text changes, rename, tags, place preferences and attachment changes update metadata. Merely opening unchanged notes does not mark a text edit. Tags, word/character counts, attachment sizes and inferred or selected places are visible in Note Details.

Drawings use PencilKit and retain both an original editable drawing and its PNG preview. The system photo picker imports selected images and videos without broad Photos access; camera capture is offered only when available. Audio uses native microphone permission and an AAC recorder. Files import through the native document picker with security-scoped access; preview and sharing use Quick Look and ShareLink. Updates to drawings preserve the previous manifest on write failure. Corrupt index bytes and orphaned files are retained to avoid destructive recovery guesses.

## Nearby note recommendations

Off by default; opt-in asks for notifications and staged location permission. On-device matching derives a business query from the note title together with unfinished shopping items or errands, including common plurals. Business discovery uses the real Apple Maps directory rather than a closed list of chains. Known spelling and business-name aliases cover Costco Wholesale/Business Center, Starbucks Coffee Company, Trader Joe's and others. Common place titles such as Library, Gym, Pharmacy and Grocery store use Maps point-of-interest categories and reject other categories. Named businesses require a matching name; completed lists and per-note opt-outs stop automatic recommendations. Examples: Target plus milk/batteries, Costco plus groceries. Target Practice, sales-target prose and fully checked lists do not auto-match. An explicit store/place query overrides recognition; users can opt out per note.

Only the place query and search area go to Apple Maps, never the note body. Searches are deduplicated by store and refreshed after movement/elapsed time or relevant note changes. Nearby matching public places supply geofences. Search requests require the region on iOS 18+, and results are distance-checked within 20 km on every supported version. Offline cached branches also must remain within that distance. Existing manual geofences have priority within Apple's 20-region limit; remaining slots monitor the nearest automatic places. Significant-change monitoring refreshes the search while moving with Always authorization. Stale/deleted/completed/opted-out notes are rechecked before delivery. Notifications carry stable identity so taps can open the correct note after a rename; visit suppression and cooldown reduce duplicate alerts.

Delivery depends on iOS permissions, Background App Refresh, connectivity and timing. This is not a promise of instantaneous alerts at every store. A real-device arrival/background/relaunch/tap test is required before claiming release readiness.

## Editor accessibility follow-up (3014)

The rich-text editor now follows Dynamic Type while preserving the user's stored font sizes, mixed bold/italic runs, links and inline media. Font scaling is for display; saving reverses the reading-size factor. Native trait observations update the open editor, and Writing Tools defers those changes until its accepted text is settled. Pinch sizing still uses the user's canonical font size.

The lazy text-view getter previously read `self.view.bounds` before assigning its result. That loaded the controller and reentered the getter through `viewDidLoad`, producing two editors. Starting with `CGRectZero` lets the existing layout set its frame and keeps the displayed editor and the saved editor identical. Actual native typing and live text-size changes now affect the retained visible editor.

- `python3 Tests/NoteFontChecks/run.py`: the actual production font transform, using native AppKit attributed strings, preserves distinct sizes, bold/italic/underline, links and attachments through 20 display/save round trips. This is not a UIKit rendering test.
- Final build 3014 Release Simulator compilation and cold launch passed. On the dedicated iPhone, the note visibly shrank when changing the open editor from serve-sim Text Size 6 to 3. These are the largest standard size exposed by that control and its default, not the largest accessibility category.
- Native typing appended a test character to the visible Target note and removed it before Done. All eight note bodies and metadata records remained equal; four attachment files and one icon remained byte-for-byte equal. All four stored RTFD bodies compared semantically equal, including canonical font runs and inline attachments.
- Final native QA images are `atoz/qa3014-2026-10-08/editor-text-size6-final.png` and `editor-default-final.png` in the release audit. Earlier files in that directory are intermediate diagnosis, not qualified marketing captures. The test device's text size was restored to default. Sensors and nearby reminders stayed off.

## Verification

- Build 3012's final incremental Release Simulator compilation passed with no diagnostics. Build 3013's full build passed with the four existing external-display deprecations listed below. No visionOS Simulator was opened.
- `bash Tests/NoteDetailsChecks/run.sh`: production metadata/attachment storage, rename, cold reload, corrupt and failed-write preservation, editable drawing data, named-business aliases, category matching, distance rejection, completion and opt-out cases.
- `bash Tests/PlaceDiscoveryChecks/run.sh`: live Apple Maps integration using production intent inference, request construction and result matching. Fixed public Cupertino coordinates, no GPS/sensor permission. Found 14 Target branches, 8 Costco branches, 17 Starbucks, 11 Philz Coffee, 25 libraries and 25 grocery stores. These are real service results, not substituted fixtures, and counts can change. Receipt: `app-store-audit/2026-09-27-release/atoz/place-discovery3013-live-2026-10-08.json`.
- Build 3013 Release compilation and cold launch passed. Four existing external-display API deprecation warnings remain. Original note files and attachment bytes were preserved, and metadata records compared equal after the update.
- `python3 Tests/NoteLineChecks/run.py`: actual attributed line methods.
- `python3 Tests/NotePolishChecks/run.py`: actual production polishing and state protection.
- `python3 Tests/IconQueueChecks/run.py`: actual icon queue behavior.
- `bash Tests/ServicePrivacyChecks/run.sh`: direct-origin favicon/Bible handling.
- Native simulator workflow: original five notes preserved, Target shopping note populated, metadata/tags saved, PencilKit drawing created, original synthetic photo/video imported, video preview opened, app stopped/relaunched, note renamed, all three attachments retained, editable drawing reopened.
- Build 3013 native Note Details showed automatic Costco matching with eight fictional shopping entries and no manually saved place. Global nearby reminders remained off; no sensor permissions changed. Proof: `app-store-audit/2026-09-27-release/atoz/discovery3013-native/costco-matching-place.png`.
- Prior build 3012 native proof/fixture provenance: `/Users/nathan/Documents/GitHub/app-store-audit/2026-09-27-release/atoz/feature3012-native` and `feature3012-fixtures`.

Pending: owner answer to sensor-test permission question; simulated location/notifications, microphone recording, camera hardware, document-provider/audio import, iPad layout, VoiceOver and physical background arrival/relaunch/tap checks. No full original-feature or App Store readiness claim should bypass these qualifications. Refresh privacy/support copy and every supported marketing gallery from this exact candidate before a subsequent release; existing uploaded build 3010 evidence must not be relabeled as build 3014.

Automatic errand vocabulary currently covers English and Dutch. Explicit place queries support other languages through Maps. Places absent or incorrectly named/category-tagged in Apple Maps cannot be inferred reliably. No claim of guaranteed notification delivery or full location-runtime verification is made from the live search test.
