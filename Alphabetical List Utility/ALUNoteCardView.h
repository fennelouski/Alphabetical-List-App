//
//  ALUNoteCardView.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/22/26.
//  Copyright © 2026 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

// One note rendered as a Wallet-style card: a colored header strip with the note's
// title and logo, above a darkened body showing the note text. Used by the cells in
// the card stack and by MasterViewController for the expanded / full-screen card, so
// the two always look identical while animating between states.
@interface ALUNoteCardView : UIView

@property (nonatomic, copy) NSString *noteTitle;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy) NSString *noteText;
@property (nonatomic, strong) UIImage *accessoryImage;

@property (nonatomic, strong, readonly) UIView *headerView;
@property (nonatomic, strong, readonly) UITextView *textView;
@property (nonatomic, strong, readonly) UIImageView *accessoryImageView;

// Pulls the color, note text and any saved logo for the title from the data manager
// and the color engine in one step. Also applies the note's card style.
- (void)configureWithNoteTitle:(NSString *)noteTitle;

// Brand colors toned down for card surfaces — desaturated and brightness-limited so
// the list doesn't read as a wall of saturated primaries.
+ (UIColor *)mutedColor:(UIColor *)color;

// Design effects ("Paper", "Glass", …). Index 0 is "None".
+ (NSArray<NSString *> *)cardStyleNames;
+ (UIColor *)backgroundColorForStyle:(NSString *)style;
+ (UIColor *)textColorForStyle:(NSString *)style;

// Looks up a logo for the current title if one has not been set yet.
- (void)findImage;

@end
