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

@implementation ALUCardNavigationBar

// UIKit positions the platters with plain frames (no margin or safe-area input we can
// set reaches them), so clamp any platter touching an edge back inside after layout.
// ponytail: matches the private "PlatterView" class name; if an iOS update renames it,
// the buttons fall back to flush-with-the-edge, nothing worse.
- (void)layoutSubviews {
	[super layoutSubviews];
	// The platters are created and placed by private bar internals after this pass
	// returns, so clamp on the next runloop turn, once they exist. Their frames stick
	// (they're autoresizing-translated), so this only re-runs when geometry changes.
	dispatch_async(dispatch_get_main_queue(), ^{
		[self insetPlattersInView:self];
	});
}

- (void)insetPlattersInView:(UIView *)view {
	static CGFloat const platterEdgeInset = 8.0f;
	for (UIView *subview in view.subviews) {
		if ([NSStringFromClass([subview class]) containsString:@"PlatterView"]) {
			CGRect frame = subview.frame;
			CGFloat containerWidth = CGRectGetWidth(view.bounds);
			if (CGRectGetMinX(frame) < platterEdgeInset) {
				frame.origin.x = platterEdgeInset;
				subview.frame = frame;
			} else if (CGRectGetMaxX(frame) > containerWidth - platterEdgeInset) {
				frame.origin.x = containerWidth - platterEdgeInset - CGRectGetWidth(frame);
				subview.frame = frame;
			}
		} else {
			[self insetPlattersInView:subview];
		}
	}
}

@end
