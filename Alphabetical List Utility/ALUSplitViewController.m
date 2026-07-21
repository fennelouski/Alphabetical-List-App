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

	// Show the notes list beside the note rather than floating over it. The default on iPad is
	// an overlay sidebar, which covers the left edge of the note text.
	// NB: do not set preferredSplitBehavior here — that API requires a column-style split view
	// controller (-initWithStyle:) and throws for this storyboard-instantiated one.
	self.preferredDisplayMode = UISplitViewControllerDisplayModeOneBesideSecondary;

	[self setNeedsStatusBarAppearanceUpdate];
}

// Contrast the status bar against whatever colour the navigation bar is currently showing.
// ALUApplyNavigationBarColor sets barStyle from the bar's luminance, so we just read it back.
- (UIStatusBarStyle)preferredStatusBarStyle {
	for (UIViewController *viewController in self.viewControllers) {
		if ([viewController isKindOfClass:[UINavigationController class]]) {
			UINavigationBar *navigationBar = ((UINavigationController *)viewController).navigationBar;
			return (navigationBar.barStyle == UIBarStyleBlack) ? UIStatusBarStyleLightContent : UIStatusBarStyleDarkContent;
		}
	}

	if ([ALUDataManager sharedDataManager].currentColorIsDark) {
		return UIStatusBarStyleLightContent;
	}

	return UIStatusBarStyleDarkContent;
}

- (BOOL)prefersStatusBarHidden {
	return ![[ALUDataManager sharedDataManager] shouldShowStatusBar];
}

- (BOOL)shouldAutorotate {
	// Previously gated on IS_IPHONE_6P, which is false on every modern iPhone, so rotation
	// was effectively disabled on all current hardware.
	return ![[ALUDataManager sharedDataManager] menuShowing];
}

// Relayout children after a rotation/size change. This used to be driven as a side effect
// of -shouldAutorotate, which the system calls at unpredictable times.
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

	[coordinator animateAlongsideTransition:nil
								 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
									 for (UIViewController *viewController in self.childViewControllers) {
										 [viewController updateViewConstraints];

										 for (UIViewController *subViewController in viewController.childViewControllers) {
											 [subViewController updateViewConstraints];
										 }
									 }
								 }];
}

@end
