//
//  ALUNavigationController.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/20/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUNavigationController.h"
#import "NKFColor.h"

@implementation ALUNavigationController

- (void)viewDidLoad {
	[super viewDidLoad];
}

// Decide the status bar style here rather than deferring to the pushed view controller:
// ALUApplyNavigationBarColor sets barStyle from the current bar colour's luminance, so the
// status bar always contrasts with the bar behind it.
- (UIViewController *)childViewControllerForStatusBarStyle {
	return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return (self.navigationBar.barStyle == UIBarStyleBlack) ? UIStatusBarStyleLightContent : UIStatusBarStyleDarkContent;
}

@end
