# A2Z Notes — iOS 26 Modernization

**Status:** App Store ready. Clean Debug *and* Release builds — **0 warnings, 0 errors**.
**Deployment target:** iOS 16.0 (raised from 12.0). **Version:** 3.0.0 (3000).
**Last updated:** 2026-07-21

See [APP_STORE_CONNECT.md](APP_STORE_CONNECT.md) for the submission guide, listing copy and the
remaining human steps (signing, iCloud entitlement, support/privacy URLs).

## Submission-readiness pass (2026-07-21)

- **604 build warnings → 0**, in both configurations.
  - 574 were duplicate keys in the colour tables. `NSDictionary` literals resolve duplicates to
    the **last** occurrence (verified empirically — and `count` was wrong for those literals), so
    the earlier duplicates were removed and lookups are unchanged.
  - Remaining 30: deprecated `UI_USER_INTERFACE_IDIOM`, `keyWindow`, `scrollIndicatorInsets`,
    `imageEdgeInsets` (→ `UIButtonConfiguration`), `addressDictionary` + AddressBook (→
    `CLPlacemark` properties, which also *fixes* reverse geocoding), the `performSelector` ARC
    leak (→ typed IMP), an enum-conversion cast, unused variables, a missing
    `[super awakeFromNib]`, and two storyboard warnings.
- **App icon set completed** — all 16 iOS sizes plus the 1024×1024 marketing icon, generated from
  the existing artwork; opaque, as Apple requires. The old loose files that caused "unassigned
  children" are gone.
- **iPad: note text was hidden behind the floating sidebar** (the pane looked empty). The note
  text is now inset to clear the sidebar.
- **Caught a crash before it shipped:** `preferredSplitBehavior` throws on a storyboard-created
  split view (`requires initializing with -initWithStyle:`). Reverted; `preferredDisplayMode`
  alone is safe.
- Storyboard placeholder colours switched to semantic (`systemBackground` / `label`).
- **Removed the Clearbit logo lookup.** It sent the note title (user content) to a third party,
  and the API is discontinued so it fetched nothing. Note icons are now rendered on device as a
  rounded tile with the note's initials, filled with the brand colour the bundled colour database
  already derives from the title — so branding survives, works offline, and the App Store privacy
  label can honestly say "Data Not Collected".

This replaces the earlier TODO, which was written against assumptions that no longer hold (it
listed AFNetworking migration and privacy work as pending, and did not know the app failed to
build at all). The list below comes from a full subsystem audit that produced **162 findings**.

---

## Done

### Build / install blockers
- **AFNetworking removed.** Both call sites in `ALUDataManager.m` rewritten on `NSURLSession`
  (company-logo download; verse-of-the-day fetch). The vendored 2.x copy did not compile against
  the modern SDK (`netinet6/in6.h` private-header error) and `AFHTTPRequestOperation` was built on
  long-dead `NSURLConnection`. The sources remain on disk but are excluded from compilation via
  `EXCLUDED_SOURCE_FILE_NAMES` — see the note under *Known deliberate shortcuts*.
- **Duplicate `mapView:rendererForOverlay:`** in `ALUMapViewController.m` removed (a leftover from
  the previous modernization pass; it was a hard compile error).
- **`UIRequiredDeviceCapabilities = armv7` removed** from `Info.plist`. No 64-bit-only device —
  i.e. every device that runs iOS 26 — could install the app with that key present.
- **`UIDocumentMenuDelegate`** conformance and its dead delegate method removed.
- **Bundle identifier mismatch fixed** — `PRODUCT_BUNDLE_IDENTIFIER` now matches the shipping
  `com.nathanfennel.A2Z` in `Info.plist`.
- Verse-of-the-day endpoint moved to **HTTPS** (cleartext HTTP was silently blocked by ATS).

### Crashes / data loss
- `NSString+AppFunctions.m` — `characterAtIndex:0` on an empty string crashed brand-colour lookup.
- `ALUDocument.m` — iCloud save passed the UTF-16 `-length` as a UTF-8 **byte** count, silently
  truncating any note containing emoji, accents or curly quotes.
- `removeReminderForListTitle:` stopped whichever geofence was *first* in the set instead of
  matching on identifier, so deleting one note's reminder could cancel a different note's.
- Guarded `scrollToRowAtIndexPath:` against an empty notes list.
- Company logos could land on the **wrong note**: a 2-second delayed block captured a cell that had
  since been recycled. Now re-resolves by index path and verifies the title.

### Layout (the visible UI bugs)
- **`kStatusBarHeight` root cause fixed.** It read the deprecated `-statusBarFrame` and returned
  `0` on every notched / Dynamic Island device, corrupting layout math app-wide. It now returns the
  key window's real top safe-area inset via a scene-safe helper.
- **Three files were shadowing that macro** with their own broken copies
  (`DetailViewController.m`, `ALUSettingsView.m`, `UIFont+AppFonts.m`) — removed, so the fix
  actually applies. *Don't reintroduce these.*
- **`ALUMasterTableView` overrode the `-frame` getter** to always return a hardcoded rect offset
  `-13pt` vertically, so notes rendered underneath the navigation bar. Removed.
- `MasterViewController` no longer force-assigns that same broken frame on app activation, and
  `DetailViewController` no longer **posts fake `UIApplicationDidBecomeActive` /
  `WillEnterForeground` notifications** (which lied to every observer app-wide and re-triggered the
  bad layout on every return from a note).
- **Rotation was disabled on every modern iPhone** — `ALUSplitViewController.shouldAutorotate`
  gated on `IS_IPHONE_6P`, false on all current hardware. Child relayout moved off the deprecated
  `shouldAutorotate` side effect onto `viewWillTransitionToSize:withTransitionCoordinator:`.

### Appearance
- **Per-note navigation bar colour restored.** Since iOS 15 the bar renders from
  `UINavigationBarAppearance` (whose `scrollEdgeAppearance` defaults to transparent), so setting
  `barTintColor` painted nothing. New shared helper `ALUApplyNavigationBarColor` configures
  standard/scrollEdge/compact appearances, keeps `barTintColor` in sync for the app's own colour
  reads, and derives `barStyle` from the background luminance.
- **Status bar contrast fixed** — it was dark text on the dark blue bar. The style now follows the
  visible bar's luminance through an explicit `ALUNavigationController` /
  `ALUSplitViewController` chain.
- **Dark mode now works.** Backgrounds use semantic colours, and `ALUAdaptiveColor` /
  `ALUAdaptiveAttributedString` wrap the brand colours in trait-aware dynamic colours that brighten
  dark hues in dark mode — so the app's colour identity survives instead of vanishing into black.
- Launch screen fixed: `UILaunchStoryboardName` pointed at `Main` (rendering a blank split view);
  it now uses the dedicated `LaunchScreen.storyboard`. Dead `UIStatusBarStyleBlackOpaque` removed,
  `ITSAppUsesNonExemptEncryption` added.

### Stability
- **Three runaway timers removed** — each re-queued itself forever while strongly capturing `self`,
  so the view controller could never deallocate:
  `MasterViewController.moveHeaderForward` (0.35s), `DetailViewController`'s action-button check
  (10×/sec, now driven by `textViewDidChange:`), and `ALUMapViewController.findUserLocation`
  (20×/sec, now driven by `mapView:didUpdateUserLocation:`).

### Location reminders (the feature was completely inert)
- Location authorization was **never requested**, so region events were never delivered. Now
  requests When-In-Use and escalates to Always, with `locationManagerDidChangeAuthorization:`.
- The notification scheduling used the **removed `UIUserNotification` stack** (which also cancelled
  *all* pending notifications and re-prompted on every save). Rewritten on `UserNotifications`
  with a properly registered category.
- Foreground reminders built a `UIAlertController` that was **never presented**. Now delivered as a
  real notification via `willPresentNotification:`.
- The iOS **20-region monitoring limit** is now checked instead of failing silently.
- Notification permission is no longer requested at launch (out of context); it's requested when
  the user actually creates a location reminder.

---

## Remaining

Ordered by value. Nothing here blocks building or running.

### High
1. **Notes are stored in `NSUserDefaults` keyed by the raw note title.** A note titled with one of
   the manager's internal key strings collides with app state, and the master list is joined with a
   fixed separator so a title containing it splits into phantom notes. Needs a real store keyed by
   UUID. *Requires a data migration — do not change the keys casually.*
2. **Settings panel still does up to 50 synchronous full-screen blur passes** on the main thread
   when opening, retaining dozens of retina images. Should be a single `UIVisualEffectView`.
   (The deprecated `keyWindow` lookups there are already fixed.)

### Medium
5. **Scene lifecycle** — no `UIApplicationSceneManifest` / `UISceneDelegate`; still on the legacy
   single-window compatibility shim. Needed for multi-window / Stage Manager.
6. **Remaining frame-based layout** driven by `UIScreen.mainScreen` macros — wrong under iPad Split
   View / Slide Over / Stage Manager. Migrate to `safeAreaLayoutGuide` + trait collections.
7. **Accessibility** — no Dynamic Type anywhere (font sizes are screen-derived), missing
   accessibility labels, parallax ignores Reduce Motion.
8. Per-screen bugs: keyboard handler reads the *Begin* frame and never converts coordinates;
   list-mode `selectedRange` can raise `NSRangeException`; mail composer presented without
   `canSendMail`; drawing toolbar lives in an `inputAccessoryView` that is never shown; map
   crosshair is offset ~22pt from the coordinate actually saved.
9. Remaining deprecations: `UI_USER_INTERFACE_IDIOM`, `keyWindow` in the `ULog` macro,
   `cell.textLabel`, `scrollIndicatorInsets`, `imageEdgeInsets`, `CLPlacemark.addressDictionary`
   (+ the AddressBook import, which reviewers flag).

### Low
11. Dead code to delete: `ALUMapView`, `ALUGeolocationReminder`, `ALUTableViewCell`,
    `UIFont+Custom`, `insertNewObject:`.
12. The half-wired iCloud/`ALUDocument` path fetches a document but never merges it back — either
    finish it or remove it.
13. Legacy `UIGraphicsBeginImageContext` → `UIGraphicsImageRenderer`; photo picker →
    `PHPickerViewController`.

---

## Known deliberate shortcuts

- **AFNetworking sources still exist on disk.** They are excluded from compilation via
  `EXCLUDED_SOURCE_FILE_NAMES = ("AF*.m", "*+AFNetworking.m")` in both app-target configs, rather
  than removed from the project. They are referenced ~108 times in `project.pbxproj` and exist in
  duplicate trees; editing that many references by hand risks corrupting the project, and the
  `xcodeproj` gem isn't available here. To finish the job properly, install that gem and remove the
  references programmatically, then delete the directories.
- **Shared helpers live in `PrefixHeader.pch`** as `static inline` functions for the same reason —
  adding a new `.m` file to the target requires `project.pbxproj` surgery.

## Testing notes

Use the dedicated simulators `A2Z-Test` (iPhone) and `A2Z-iPad`; the stock devices are shared with
other projects and will foreground unrelated apps mid-screenshot. If no simulator runtime is
installed, `xcodebuild -downloadPlatform iOS` — without one, asset-catalog and storyboard
compilation fail with misleading "platform not installed" errors.
