//
//  ALUPatternedView.m
//  Alphabetical List Utility
//
//  Created by Nathan Fennel on 8/9/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUPatternedView.h"
#import "NKFColor.h"

@implementation ALUPatternedView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    //// Rounded Rect drawing
    UIBezierPath *roundedrect = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(52.773, 74.375, 131.16, 131.16) cornerRadius:20];
    
    
    //Roundedrect color fill
    [[NKFColor randomColor] setFill];
    [roundedrect fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect.lineWidth = 1;
    [roundedrect stroke];
    
    //// Rounded Rect2 drawing
    UIBezierPath *roundedrect2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(128.76, 138.47, 125.77, 125.77) cornerRadius:20];
    
    
    //Roundedrect2 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect2 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect2.lineWidth = 1;
    [roundedrect2 stroke];
    
    //// Rounded Rect3 drawing
    UIBezierPath *roundedrect3 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(30.625, 187.64, 113.39, 113.39) cornerRadius:20];
    
    
    //Roundedrect3 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect3 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect3.lineWidth = 1;
    [roundedrect3 stroke];
    
    //// Rounded Rect4 drawing
    UIBezierPath *roundedrect4 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(102.16, 249.99, 102.52, 102.52) cornerRadius:20];
    
    
    //Roundedrect4 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect4 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect4.lineWidth = 1;
    [roundedrect4 stroke];
    
    //// Rounded Rect5 drawing
    UIBezierPath *roundedrect5 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(187.21, 188.06, 104.15, 104.15) cornerRadius:20];
    
    
    //Roundedrect5 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect5 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect5.lineWidth = 1;
    [roundedrect5 stroke];
    
    //// Rounded Rect6 drawing
    UIBezierPath *roundedrect6 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(189.99, 283.66, 81.211, 81.211) cornerRadius:20];
    
    
    //Roundedrect6 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect6 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect6.lineWidth = 1;
    [roundedrect6 stroke];
    
    //// Rounded Rect7 drawing
    UIBezierPath *roundedrect7 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(268.55, 277.77, 119.62, 119.62) cornerRadius:20];
    
    
    //Roundedrect7 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect7 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect7.lineWidth = 1;
    [roundedrect7 stroke];
    
    //// Rounded Rect8 drawing
    UIBezierPath *roundedrect8 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(253.4, 91.32, 191.82, 191.82) cornerRadius:20];
    
    
    //Roundedrect8 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect8 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect8.lineWidth = 1;
    [roundedrect8 stroke];
    
    //// Rounded Rect9 drawing
    UIBezierPath *roundedrect9 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(178.23, 45.219, 113.39, 113.39) cornerRadius:20];
    
    
    //Roundedrect9 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect9 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect9.lineWidth = 1;
    [roundedrect9 stroke];
    
    //// Rounded Rect10 drawing
    UIBezierPath *roundedrect10 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(274.7, -15.227, 111.92, 111.92) cornerRadius:20];
    
    
    //Roundedrect10 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect10 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect10.lineWidth = 1;
    [roundedrect10 stroke];
    
    //// Rounded Rect11 drawing
    UIBezierPath *roundedrect11 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(98.125, -24.703, 98.062, 98.062) cornerRadius:20];
    
    
    //Roundedrect11 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect11 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect11.lineWidth = 1;
    [roundedrect11 stroke];
    
    //// Rounded Rect12 drawing
    UIBezierPath *roundedrect12 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(236.35, -11.461, 67.43, 67.43) cornerRadius:20];
    
    
    //Roundedrect12 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect12 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect12.lineWidth = 1;
    [roundedrect12 stroke];
    
    //// Rounded Rect13 drawing
    UIBezierPath *roundedrect13 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(190.02, -14.227, 63.508, 63.508) cornerRadius:20];
    
    
    //Roundedrect13 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect13 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect13.lineWidth = 1;
    [roundedrect13 stroke];
    
    //// Rounded Rect14 drawing
    UIBezierPath *roundedrect14 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(143.7, 55.648, 50.273, 50.273) cornerRadius:20];
    
    
    //Roundedrect14 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect14 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect14.lineWidth = 1;
    [roundedrect14 stroke];
    
    //// Rounded Rect15 drawing
    UIBezierPath *roundedrect15 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-8.4219, -9.5, 111.15, 111.15) cornerRadius:20];
    
    
    //Roundedrect15 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect15 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect15.lineWidth = 1;
    [roundedrect15 stroke];
    
    //// Rounded Rect16 drawing
    UIBezierPath *roundedrect16 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-38.945, 87.273, 110.14, 110.14) cornerRadius:20];
    
    
    //Roundedrect16 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect16 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect16.lineWidth = 1;
    [roundedrect16 stroke];
    
    //// Rounded Rect17 drawing
    UIBezierPath *roundedrect17 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-39.25, 295.03, 149.95, 149.95) cornerRadius:20];
    
    
    //Roundedrect17 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect17 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect17.lineWidth = 1;
    [roundedrect17 stroke];
    
    //// Rounded Rect18 drawing
    UIBezierPath *roundedrect18 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(102.55, 380.16, 296.9, 296.9) cornerRadius:20];
    
    
    //Roundedrect18 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect18 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect18.lineWidth = 1;
    [roundedrect18 stroke];
    
    //// Rounded Rect19 drawing
    UIBezierPath *roundedrect19 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-38.18, 433.96, 146.48, 146.48) cornerRadius:20];
    
    
    //Roundedrect19 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect19 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect19.lineWidth = 1;
    [roundedrect19 stroke];
    
    //// Rounded Rect20 drawing
    UIBezierPath *roundedrect20 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-15.234, 569.44, 130.55, 130.55) cornerRadius:20];
    
    
    //Roundedrect20 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect20 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect20.lineWidth = 1;
    [roundedrect20 stroke];
    
    //// Rounded Rect21 drawing
    UIBezierPath *roundedrect21 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-14.062, 197.81, 55.656, 55.656) cornerRadius:20];
    
    
    //Roundedrect21 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect21 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect21.lineWidth = 1;
    [roundedrect21 stroke];
    
    //// Rounded Rect22 drawing
    UIBezierPath *roundedrect22 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-18.375, 252.84, 68.812, 68.812) cornerRadius:20];
    
    
    //Roundedrect22 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect22 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect22.lineWidth = 1;
    [roundedrect22 stroke];
    
    //// Rounded Rect23 drawing
    UIBezierPath *roundedrect23 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(99.273, 334.63, 84.133, 84.133) cornerRadius:20];
    
    
    //Roundedrect23 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect23 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect23.lineWidth = 1;
    [roundedrect23 stroke];
    
    //// Rounded Rect24 drawing
    UIBezierPath *roundedrect24 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(174.62, 334.7, 98.531, 98.531) cornerRadius:20];
    
    
    //Roundedrect24 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect24 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect24.lineWidth = 1;
    [roundedrect24 stroke];
    
    //// Rounded Rect25 drawing
    UIBezierPath *roundedrect25 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(156.21, 478.71, 135.32, 135.32) cornerRadius:20];
    
    
    //Roundedrect25 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect25 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect25.lineWidth = 1;
    [roundedrect25 stroke];
    
    //// Rounded Rect26 drawing
    UIBezierPath *roundedrect26 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(206.86, 400.28, 109.69, 109.69) cornerRadius:20];
    
    
    //Roundedrect26 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect26 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect26.lineWidth = 1;
    [roundedrect26 stroke];
    
    //// Rounded Rect27 drawing
    UIBezierPath *roundedrect27 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(334.33, 245.94, 64.203, 64.203) cornerRadius:20];
    
    
    //Roundedrect27 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect27 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect27.lineWidth = 1;
    [roundedrect27 stroke];
    
    //// Rounded Rect28 drawing
    UIBezierPath *roundedrect28 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(73.055, 26.953, 93.141, 93.141) cornerRadius:20];
    
    
    //Roundedrect28 color fill
    [[NKFColor randomColor] setFill];
    [roundedrect28 fill];
    
    [[NKFColor randomColor] setStroke];
    roundedrect28.lineWidth = 1;
    [roundedrect28 stroke];
}

@end
