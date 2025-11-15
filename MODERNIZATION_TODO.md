# iOS 17+ Modernization TODO

This document tracks the remaining modernization tasks for the Alphabetical List Utility app after the initial iOS 17+ compatibility update.

## Completed Tasks ✅

### Critical API Updates (iOS 12.0+ Support)
- [x] Updated deployment target from iOS 8.0 to iOS 12.0
- [x] Replaced deprecated AddressBook framework with Contacts framework
- [x] Replaced UILocalNotification with UserNotifications framework
- [x] Updated UIAlertView macro to use UIAlertController
- [x] Replaced MKOverlayView with MKOverlayRenderer
- [x] Fixed delegate property attributes (assign → weak)

### Modern API Replacements (2025-11-15)
- [x] **Replaced performSelector Calls with Modern APIs** - All `performSelector:withObject:afterDelay:` calls replaced with `dispatch_after` using GCD
  - Updated MasterViewController.m (7 instances)
  - Updated DetailViewController.m (7 instances)
  - Updated ALUSettingsView.m (2 instances)
  - Updated ALUSplitViewController.m (2 instances)
  - Updated ALUMasterTableViewCell.m (1 instance)
  - Updated ALUMapViewController.m (3 instances)
  - Updated ALUDrawingViewController.m (2 instances)
  - Updated ALUEmojiImageViewController.m (1 instance)
  - Updated ALUDataManager.m (2 instances)
  - Total: 27 instances replaced

### Privacy and App Store Compliance (2025-11-15)
- [x] **Privacy Manifest Created** - Added `PrivacyInfo.xcprivacy` with API usage declarations
  - Declared UserDefaults usage (CA92.1)
  - Declared File Timestamp usage (C617.1)
  - Declared System Boot Time usage (35F9.1)
  - Declared Disk Space usage (E174.1)
- [x] **Privacy Strings Added to Info.plist**
  - NSLocationWhenInUseUsageDescription
  - NSLocationAlwaysAndWhenInUseUsageDescription
  - NSContactsUsageDescription
  - NSCameraUsageDescription
  - NSPhotoLibraryUsageDescription

## High Priority Remaining Tasks

### 1. Update Device Detection to Use Trait Collections
**Priority:** HIGH
**Affected Files:**
- `Alphabetical List Utility/PrefixHeader.pch` (lines 27-39)
- `Alphabetical List Utility/DetailViewController.m` (lines 22-27)
- Multiple view controllers using device-specific macros

**Issue:** Hard-coded device detection macros (IS_IPHONE_6, IS_IPHONE_6P) are fragile and don't support modern devices or dynamic type.

**Solution:** Replace with modern trait collections and size classes.

**Example Replacements:**
```objc
// OLD:
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

// NEW: Use trait collections in view controllers
if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
    // Compact width logic
}
```

**Acceptance Criteria:**
- Remove device-specific macros from PrefixHeader.pch
- Update view controllers to use trait collections
- Implement `traitCollectionDidChange:` where needed
- Support all modern iPhone and iPad sizes dynamically

---

### 2. Modernize AFNetworking or Migrate to URLSession
**Priority:** HIGH
**Affected Files:**
- `AFNetworking/` (entire directory - vendored library)
- `UIKit+AFNetworking/` (entire directory)
- `Alphabetical List Utility/ALUDataManager+APICalls.m`

**Issue:** The project uses an old, vendored version of AFNetworking that contains deprecated APIs (NSURLConnection, UIAlertView).

**Solution Options:**
1. **Option A (Recommended):** Migrate to native URLSession
2. **Option B:** Update to latest AFNetworking via CocoaPods/SPM
3. **Option C:** Remove AFNetworking if not heavily used

**Investigation Needed:**
- Audit usage of AFNetworking in ALUDataManager+APICalls
- Determine scope of API calls
- Choose migration path

**Acceptance Criteria:**
- No deprecated networking APIs in use
- All API calls function correctly
- Network error handling modernized

---

### 3. Implement Auto Layout Constraints
**Priority:** MEDIUM
**Affected Files:**
- `Alphabetical List Utility/DetailViewController.m` (lines 22-27)
- All view controllers using frame-based layout
- Custom views with manual frame calculations

**Issue:** App uses frame-based layout with manual calculations, which doesn't support dynamic sizing, multitasking, or accessibility features.

**Solution:** Migrate to Auto Layout with constraints.

**Approach:**
1. Update storyboards to use Auto Layout
2. Replace manual frame calculations with constraints
3. Use stack views where appropriate
4. Support dynamic type for accessibility

**Acceptance Criteria:**
- All views use Auto Layout
- Support for multitasking/split view on iPad
- Dynamic Type support for text
- Rotation handled automatically

---

### 4. Update Build Settings for Modern Xcode
**Priority:** MEDIUM
**Affected Files:**
- `Alphabetical List Utility.xcodeproj/project.pbxproj`

**Build Settings to Update:**
- Enable "Modules" (CLANG_ENABLE_MODULES = YES) ✅ Already done
- Set SWIFT_VERSION if migrating to Swift
- Update code signing settings
- Enable Bitcode (if needed) or disable for modern builds
- Update recommended project settings warnings

**Acceptance Criteria:**
- Project builds without warnings in Xcode 15+
- No deprecated build settings
- Code signing configured correctly

---

## Medium Priority Tasks

### 5. Modernize Storyboard Segues and Navigation
**Priority:** MEDIUM
**Affected Files:**
- `Alphabetical List Utility/Base.lproj/Main.storyboard`
- Navigation controller implementations

**Issue:** May use deprecated segue types or navigation patterns.

**Solution:** Update to modern navigation patterns, consider programmatic UI for better maintainability.

**Acceptance Criteria:**
- All segues use modern types
- Navigation flows work correctly
- Consider migration to programmatic UI or SwiftUI

---

### 6. Update Color Management System
**Priority:** MEDIUM
**Affected Files:**
- `Alphabetical List Utility/NKFColor.m` and category files
- `Alphabetical List Utility/UIColor+AppColors.m`
- `Alphabetical List Utility/UIColor+BrandColors.m`

**Issue:** Custom color system doesn't support dark mode or semantic colors.

**Solution:** Implement semantic color names and dark mode support.

**Changes:**
1. Add dark mode variants for all colors
2. Use `UIColor.init(dynamicProvider:)` for adaptive colors
3. Update color categories to return dynamic colors
4. Test in light/dark mode

**Acceptance Criteria:**
- App supports dark mode
- Colors adapt automatically
- Maintains visual consistency

---

### 7. Improve Memory Management and Notification Cleanup
**Priority:** MEDIUM
**Affected Files:**
- All view controllers using NSNotificationCenter
- `Alphabetical List Utility/ALUDataManager.m`

**Issue:** 68 NSNotificationCenter observers registered; potential memory leaks if not properly removed.

**Solution:** Audit notification usage and ensure proper cleanup.

**Changes:**
1. Audit all `addObserver:` calls
2. Ensure `removeObserver:` in `dealloc` or use block-based observers
3. Consider using weak references in notification blocks
4. Migrate to closure-based observation where possible

**Acceptance Criteria:**
- No memory leaks from notification observers
- All observers properly cleaned up
- Memory profiler shows no leaks

---

### 8. Update Prefix Header Usage
**Priority:** LOW
**Affected Files:**
- `Alphabetical List Utility/PrefixHeader.pch`
- Build settings

**Issue:** Precompiled headers (PCH) are deprecated in favor of modules.

**Solution:** Migrate macros to Swift/Objective-C files, use modules for imports.

**Acceptance Criteria:**
- Remove or minimize PCH usage
- Use @import for framework imports
- Macros moved to appropriate header files

---

## Testing Requirements

### Functional Testing
- [ ] Test on iOS 12.0 (minimum deployment target)
- [ ] Test on iOS 17.0+ (latest)
- [ ] Test on iPhone (all sizes via simulator)
- [ ] Test on iPad (all sizes via simulator)
- [ ] Test multitasking on iPad
- [ ] Test rotation on all devices
- [ ] Test dark mode support
- [ ] Test accessibility features (VoiceOver, Dynamic Type)

### Feature-Specific Testing
- [ ] Geolocation reminders trigger correctly
- [ ] Contact picker integration works
- [ ] Notifications appear correctly
- [ ] Map view displays properly with overlays
- [ ] Drawing annotation functions correctly
- [ ] iCloud sync works (if enabled)
- [ ] Settings persist correctly
- [ ] Image upload/selection works

### Performance Testing
- [ ] App launch time < 2 seconds
- [ ] Memory usage reasonable (< 100MB idle)
- [ ] No memory leaks (Instruments profiling)
- [ ] Smooth scrolling in lists
- [ ] Responsive UI (60fps)

---

## Migration Path to Swift (Optional, Long-term)

### Phase 1: Prepare for Swift
- Update all Objective-C code to use modern syntax
- Ensure proper nullability annotations
- Use instancetype for initializers
- Adopt lightweight generics where appropriate

### Phase 2: Incremental Migration
- Create bridging header
- Migrate model classes first (ALUVerse, ALUPassage, etc.)
- Migrate utility classes and extensions
- Migrate view controllers last

### Phase 3: Full Swift Migration
- Migrate remaining Objective-C code
- Remove Objective-C files
- Update to Swift best practices
- Consider SwiftUI for new features

---

## Backwards Compatibility Notes

**Minimum Deployment Target:** iOS 12.0
- Provides modern API support (Contacts, UserNotifications)
- Maintains reasonable device coverage
- Allows for future iOS 13+ features (SwiftUI, Combine)

**Deprecated API Removals:**
- iOS 9: AddressBook framework
- iOS 10: UILocalNotification
- iOS 9: UIAlertView
- iOS 7: MKOverlayView

**Users on iOS 8-11:** Will need to stay on app version 2.3.3 or earlier. Consider showing update prompts for users on old iOS versions.

---

## App Store Submission Checklist

- [x] Privacy manifest created (PrivacyInfo.xcprivacy)
- [x] All privacy usage strings in Info.plist
- [ ] App builds without warnings
- [ ] Code signing configured
- [ ] Screenshots updated for latest iOS
- [ ] App description mentions iOS 12.0+ requirement
- [ ] TestFlight testing completed
- [x] No deprecated performSelector APIs in use
- [ ] Dark mode support (recommended)
- [ ] Accessibility audit passed

---

## Resources

### Apple Documentation
- [Contacts Framework](https://developer.apple.com/documentation/contacts)
- [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [Auto Layout Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/)
- [Privacy Manifest](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Migration Guides
- [Migrating from AddressBook](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AddressBook_iPhoneOS_ProgrammingGuide/Introduction.html)
- [Local Notifications Migration](https://developer.apple.com/documentation/usernotifications/deprecated_symbols_in_user_notifications)
- [URLSession Best Practices](https://developer.apple.com/documentation/foundation/url_loading_system)

---

**Document Version:** 1.1
**Last Updated:** 2025-11-15
**iOS Target:** iOS 12.0+ with iOS 17+ compatibility
**Project Status:** Critical modernization tasks complete (performSelector replacement, privacy compliance), ready for testing

## Recent Updates (2025-11-15)

### Completed in This Session
1. ✅ Replaced all 27 instances of `performSelector:withObject:afterDelay:` with modern `dispatch_after` GCD calls
2. ✅ Created iOS 17 Privacy Manifest (`PrivacyInfo.xcprivacy`) with required API declarations
3. ✅ Added all required privacy usage descriptions to Info.plist

### Next Recommended Steps
1. **Test the application** - Run on iOS 12.0 simulator and iOS 17+ device to verify functionality
2. **Device Detection Update** - Replace hard-coded device macros with trait collections
3. **AFNetworking Migration** - Evaluate migration to native URLSession for networking
4. **Auto Layout** - Migrate from frame-based layout to Auto Layout constraints for better multitasking support

### Known Issues to Address
- Still using deprecated device detection macros (IS_IPHONE_6, IS_IPHONE_6P, etc.)
- Old vendored AFNetworking library contains deprecated APIs
- Frame-based layout doesn't support dynamic type or multitasking optimally
- 68 NSNotificationCenter observers should be audited for proper cleanup
