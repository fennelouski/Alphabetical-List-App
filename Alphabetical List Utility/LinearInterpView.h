//
//  LinearInterpView.h
//  FreehandDrawingTut
//
//  Created by A Khan on 11/10/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinearInterpView : UIView

@property (nonatomic, strong) UIColor *currentColor;

@property (nonatomic, strong) NSNumber *lineThickness;

- (void)undoLastLine;

@end
