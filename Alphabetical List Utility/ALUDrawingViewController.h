//
//  ALUDrawingViewController.h
//  Alphabetical List Utility
//
//  Created by HAI on 8/11/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALUDrawingViewControllerDelegate <NSObject>

@required
- (void)drawnImage:(UIImage *)image;

@end

@interface ALUDrawingViewController : UIViewController

- (UIImage *)image;

- (void)setBaseImage:(UIImage *)baseImage;

@property (assign) id <ALUDrawingViewControllerDelegate> delegate;

@property (nonatomic, strong) UIColor *currentColor;

@end
