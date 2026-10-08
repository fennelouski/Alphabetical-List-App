# AtoZ feature restoration — build 3012

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

Off by default; opt-in asks for notifications and staged location permission. On-device matching recognizes store titles together with unfinished shopping items, including common plurals. Examples: Target plus milk/batteries, Costco plus groceries. Target Practice, sales-target prose and fully checked lists do not auto-match. An explicit store/place query overrides recognition; users can opt out per note.

Only the place query and search area go to Apple Maps, never the note body. Searches are deduplicated by store and refreshed after movement/elapsed time or relevant note changes. Nearby matching public places supply geofences. Existing manual geofences have priority within Apple's 20-region limit; remaining slots monitor the nearest automatic places. Significant-change monitoring refreshes the search while moving with Always authorization. Stale/deleted/completed/opted-out notes are rechecked before delivery. Notifications carry stable identity so taps can open the correct note after a rename; visit suppression and cooldown reduce duplicate alerts.

Delivery depends on iOS permissions, Background App Refresh, connectivity and timing. This is not a promise of instantaneous alerts at every store. A real-device arrival/background/relaunch/tap test is required before claiming release readiness.

## Verification

- Release iPhone Simulator compilation passed with no diagnostics in the final incremental build. No visionOS Simulator was opened.
- `bash Tests/NoteDetailsChecks/run.sh`: production metadata/attachment storage, rename, cold reload, corrupt and failed-write preservation, editable drawing data and store intent positive/negative/opt-out cases.
- `python3 Tests/NoteLineChecks/run.py`: actual attributed line methods.
- `python3 Tests/NotePolishChecks/run.py`: actual production polishing and state protection.
- `python3 Tests/IconQueueChecks/run.py`: actual icon queue behavior.
- `bash Tests/ServicePrivacyChecks/run.sh`: direct-origin favicon/Bible handling.
- Native simulator workflow: original five notes preserved, Target shopping note populated, metadata/tags saved, PencilKit drawing created, original synthetic photo/video imported, video preview opened, app stopped/relaunched, note renamed, all three attachments retained, editable drawing reopened.
- Native proof/fixture provenance: `/Users/nathan/Documents/GitHub/app-store-audit/2026-09-27-release/atoz/feature3012-native` and `feature3012-fixtures`.

Pending: owner answer to sensor-test permission question; simulated location/notifications, microphone recording, camera hardware, document-provider/audio import, iPad layout, VoiceOver and physical background arrival/relaunch/tap checks. No full original-feature or App Store readiness claim should bypass these qualifications. Refresh privacy/support copy and every supported marketing gallery from this exact candidate before a subsequent release; existing uploaded build 3010 evidence must not be relabeled as build 3012.
