//
//  ALUSplitViewController.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/20/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUSplitViewController.h"

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

@end
