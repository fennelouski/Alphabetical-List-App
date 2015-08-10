//
//  ALUMasterTableViewCell.h
//  Alphabetical List Utility
//
//  Created by HAI on 8/6/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALUMasterTableViewCell : UITableViewCell


- (void)setNoteTitle:(NSString *)noteTitle;
- (NSString *)noteTitle;

- (void)setColor:(UIColor *)color;
- (UIColor *)color;

- (void)setAccessoryImage:(UIImage *)accessoryImage;
- (UIImage *)accessoryImage;

- (void)setParallaxStrength:(CGFloat)parallaxIntensity;
- (CGFloat)parallaxStrength;

- (void)setNoteText:(NSString *)noteText;
- (NSString *)noteText;

- (void)setContentOffset:(CGPoint)contentOffset;
- (CGPoint)contentOffset;

@end
