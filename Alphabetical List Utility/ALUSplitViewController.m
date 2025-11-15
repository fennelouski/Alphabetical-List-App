//
//  ALUSplitViewController.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/20/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUSplitViewController.h"
#import "ALUDataManager.h"


@implementation ALUSplitViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	if ([ALUDataManager sharedDataManager].currentColorIsDark) {
		return UIStatusBarStyleLightContent;
	}
	
	return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
	return ![[ALUDataManager sharedDataManager] shouldShowStatusBar];
}

- (BOOL)shouldAutorotate {
	for (UIViewController *viewController in self.childViewControllers) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		    [viewController updateViewConstraints];
		});

		for (UIViewController *subViewController in viewController.childViewControllers) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			    [subViewController updateViewConstraints];
			});
		}
	}

	return ([[ALUDataManager sharedDataManager] noteHasBeenSelectedOnce] &&
			![[ALUDataManager sharedDataManager] menuShowing] &&
			(IS_IPHONE_6P || IS_IPAD));
}

@end
