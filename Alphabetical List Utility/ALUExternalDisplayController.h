//
//  ALUExternalDisplayController.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/22/26.
//  Copyright © 2026 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

// Owns the window on an AirPlay / HDMI screen. Instead of mirroring the phone, the
// external screen gets a non-interactive, 16:9-friendly reading view: the current
// note rendered large and centered on a full-bleed background, or an idle "A2Z
// Notes" screen when no note is open. DetailViewController reports what is on
// screen; nothing here accepts input.
@interface ALUExternalDisplayController : NSObject

+ (instancetype)sharedController;

// Registers for screen connect/disconnect and attaches to any screen that is
// already connected. Call once at launch.
- (void)start;

// nil title shows the idle screen. text overrides the saved note text so live
// typing shows up before the note is persisted; pass nil to read from the data
// manager.
- (void)showNoteWithTitle:(NSString *)title text:(NSString *)text;

@end
