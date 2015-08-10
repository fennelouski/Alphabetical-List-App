//
//  UIImage+PixelInformation.h
//  Alphabetical List Utility
//
//  Created by Nathan Fennel on 8/9/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PixelInformation)

- (BOOL)cornersAreEmpty;
- (UIColor *)colorAtPixel:(CGPoint)point;

@end
