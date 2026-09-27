//
//  ALUMasterTableViewCell.h
//  Alphabetical List Utility
//
//  Created by HAI on 8/6/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALUNoteCardView.h"

// A row in the Wallet-style stack. The card view extends below the row's height so
// the next row's card overlaps it, leaving just this card's top strip visible.
@interface ALUMasterTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) ALUNoteCardView *cardView;

// Vertical rolodex shift applied by the table during scrolling; moves the card and
// its shadow together.
- (void)setCardShift:(CGFloat)shift;

- (void)setNoteTitle:(NSString *)noteTitle;
- (NSString *)noteTitle;

- (void)setColor:(UIColor *)color;
- (UIColor *)color;

- (void)setAccessoryImage:(UIImage *)accessoryImage;
- (UIImage *)accessoryImage;

- (void)setNoteText:(NSString *)noteText;
- (NSString *)noteText;

- (void)findImage;

@property BOOL hasSearchedForImage;

@end
