# AtoZ Notes 3.0.0, build 3003

Build 3003 replaces the Labs NET verse download and reproduction with one external
[Daily Bible passage link](https://www.bible.com/verse-of-the-day). Matching daily
Bible note titles keep their aliases. The app prepends the fixed link once,
appends the existing attributed note without flattening it, and uses the existing
plain-text/RTFD store. It does not fetch Bible text. Previously saved verses and
user edits remain in their notes. Settings also offers Read Daily Passage, which
opens the external site. The site and its current passage link were verified on
2026-10-01. There is no in-app browser or scraping of that page.

Web icons request `https://<allowlisted-origin>/favicon.ico` directly. Arbitrary
note titles, private domains, paths, credentials and note bodies cannot become
requests. Valid 16-pixel favicons are accepted. The existing per-note setting,
local saved-image cache, custom-icon protection and offline/local fallback stay
in place. Requests still use the existing ephemeral session with no cookies,
shared credentials or URL cache. Origin websites and their hosting providers
receive normal connection information and may retain request logs.

The owner authorized external Bible links and originating-site favicons, and
specified free availability in all possible countries. This records the intended
feature and distribution scope. It does not establish a blanket license for
third-party logos or supply the App Store necessary-rights legal attestation.
No NET text is bundled or downloaded by this build; historical user notes are
preserved. The privacy manifest retains the existing conservative Other Usage
Data and Coarse Location declarations. The final privacy answers require the
originating-site practices to be assessed; the old S2/Labs analysis cannot be
copied as current endpoint evidence.

Validation on the current owned Mac, with no verified idle alternate available:

- `sh Tests/ServicePrivacyChecks/run.sh` passed. It checks isolated networking,
  all daily Bible aliases, new/empty/historical notes, duplicate links and every
  valid allowlisted origin URL. These are host checks, not native UI tests.
- `plutil -lint` passed for the app plist and Xcode project; `git diff --check`
  passed. Removed verse formatter models have no remaining code/project callers.
- Release archive succeeded with Xcode 26.6. Four existing external-display
  deprecation warnings and one App Intents metadata notice remain.
- `codesign --verify --deep --strict` passed. Archive plist confirms 3.0.0,
  build 3003 and `com.nathanfennel.A2Z`.

Archive: `/Users/nathan/Library/Developer/Xcode/Archives/2026-10-01/AtoZ Notes 3.0.0-3003.xcarchive`

Build log: `/tmp/atoz-build3003-archive.log`

Executable SHA-256: `a6f57e9d961d09bd3398ed943ec8515540bb347b97c152dcda052f96d4711aec`

Build 3003 supersedes prepared build 3002. It has not been uploaded or selected.
Next native QA must exercise external link opening, one-time insertion and
restart, original RTFD formatting/attachments, direct-site favicon loading,
custom/cached icons, switch changes during requests, offline fallback, note
editing/deletion/search, location and Apple Intelligence flows, and accessibility.
Then verify screenshots/listing/privacy/rights, export, upload and select 3003.
No native UI, simulator preference changes, App Store API actions, upload or
submission occurred in this source/build pass.
