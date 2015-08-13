//
//  UIImage+PixelInformation.m
//  Alphabetical List Utility
//
//  Created by Nathan Fennel on 8/9/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "UIImage+PixelInformation.h"
#import "UIColor+AppColors.h"

@implementation UIImage (PixelInformation)

- (BOOL)cornersAreEmpty {
    CGFloat insetAmount = 7.0f;
    CGPoint topLeft = CGPointMake(insetAmount, insetAmount);
    CGPoint topRight = CGPointMake(self.size.width - insetAmount, insetAmount);
    CGPoint bottomLeft = CGPointMake(insetAmount, self.size.height - insetAmount);
    CGPoint bottomRight = CGPointMake(self.size.width - insetAmount, self.size.height - insetAmount);
    
    NSArray *points = @[[NSValue valueWithCGPoint:topLeft],
                        [NSValue valueWithCGPoint:topRight],
                        [NSValue valueWithCGPoint:bottomLeft],
                        [NSValue valueWithCGPoint:bottomRight]];
    
    for (NSValue *pointValue in points) {
        CGPoint point = [pointValue CGPointValue];
        
        UIColor *color = [self colorAtPixel:point];
        
        if (!color) {
            NSLog(@"Missing point (%f, %f) is outside of size w: %f\th: %f", point.x, point.y, self.size.width, self.size.height);
            break;
        }
        
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        
        CGFloat alphaThreshold  = 0.2f;
        CGFloat redThreshold    = 0.925f;
        CGFloat greenThreshold  = 0.9f;
        CGFloat blueThreshold   = 0.95f;
        
        if (alpha > alphaThreshold && (red < redThreshold && green < greenThreshold && blue < blueThreshold)) {
            return NO;
        }
    }
    
    return YES;
}

- (UIColor *)colorAtPixel:(CGPoint)point {
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return [UIColor clearColor];
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


@end
