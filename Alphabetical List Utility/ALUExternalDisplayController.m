//
//  ALUExternalDisplayController.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/22/26.
//  Copyright © 2026 HAI. All rights reserved.
//

#import "ALUExternalDisplayController.h"
#import "ALUDataManager.h"
#import "ALUNoteCardView.h"
#import "NKFColor.h"
#import "NKFColor+Companies.h"
#import "UIColor+AppColors.h"

@interface ALUExternalDisplayController ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *cardContentView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *idleLabel;

@property (nonatomic, copy) NSString *currentTitle;
@property (nonatomic, copy) NSString *currentText;

@end

@implementation ALUExternalDisplayController

+ (instancetype)sharedController {
	static ALUExternalDisplayController *shared;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[ALUExternalDisplayController alloc] init];
	});
	return shared;
}

- (void)start {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self
			   selector:@selector(screenDidConnect:)
				   name:UIScreenDidConnectNotification
				 object:nil];
	[center addObserver:self
			   selector:@selector(screenDidDisconnect:)
				   name:UIScreenDidDisconnectNotification
				 object:nil];

	for (UIScreen *screen in [UIScreen screens]) {
		if (screen != [UIScreen mainScreen]) {
			[self attachToScreen:screen];
			break;
		}
	}

#if DEBUG
	// Simulators cannot attach AirPlay displays. This flag overlays the external
	// view as a 16:9 strip at the top of the phone screen so it can be exercised.
	if ([[NSProcessInfo processInfo].arguments containsObject:@"-externalDisplayPreview"]) {
		CGRect mainBounds = [UIScreen mainScreen].bounds;
		UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0.0f,
																	  0.0f,
																	  mainBounds.size.width,
																	  mainBounds.size.width * 9.0f / 16.0f)];
		window.windowLevel = UIWindowLevelStatusBar + 1.0f;
		[self setUpWindow:window];
	}
#endif
}

#pragma mark - Screen lifecycle

- (void)screenDidConnect:(NSNotification *)notification {
	[self attachToScreen:notification.object];
}

- (void)screenDidDisconnect:(NSNotification *)notification {
	if (self.window.screen == notification.object) {
		self.window.hidden = YES;
		self.window = nil;
	}
}

- (void)attachToScreen:(UIScreen *)screen {
	UIWindow *window = [[UIWindow alloc] initWithFrame:screen.bounds];
	window.screen = screen;
	[self setUpWindow:window];
}

- (void)setUpWindow:(UIWindow *)window {
	window.userInteractionEnabled = NO;
	window.rootViewController = [[UIViewController alloc] init];

	// The root view lazy-loads at the *main* screen's size; force it to the window's
	// bounds before laying out, or the card is placed for a portrait phone.
	window.rootViewController.view.frame = window.bounds;
	[self buildViewHierarchyInView:window.rootViewController.view];

	self.window = window;
	window.hidden = NO;

	[self render];
}

#pragma mark - View setup

- (void)buildViewHierarchyInView:(UIView *)hostView {
	CGRect bounds = hostView.bounds;

	// A slow, pulsating sweep of the note's color keeps the backdrop alive without
	// competing with the note text.
	self.gradientLayer = [CAGradientLayer layer];
	self.gradientLayer.frame = bounds;
	self.gradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
	self.gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
	self.gradientLayer.locations = @[@(-0.5f), @0.0f, @0.5f];
	[hostView.layer insertSublayer:self.gradientLayer atIndex:0];

	CABasicAnimation *drift = [CABasicAnimation animationWithKeyPath:@"locations"];
	drift.fromValue = @[@(-0.5f), @0.0f, @0.5f];
	drift.toValue = @[@0.5f, @1.0f, @1.5f];
	drift.duration = 12.0;
	drift.autoreverses = YES;
	drift.repeatCount = HUGE_VALF;
	drift.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[self.gradientLayer addAnimation:drift forKey:@"drift"];

	// The reading card: roughly half the screen wide, centered, leaving the
	// full-bleed background color visible on both sides.
	CGFloat cardWidth = bounds.size.width * 0.55f;
	CGFloat cardHeight = bounds.size.height * 0.86f;
	CGFloat cornerRadius = bounds.size.height * 0.03f;
	self.cardView = [[UIView alloc] initWithFrame:CGRectMake((bounds.size.width - cardWidth) / 2.0f,
															 (bounds.size.height - cardHeight) / 2.0f,
															 cardWidth,
															 cardHeight)];
	// The outer view carries the drop shadow; the inner one clips to the rounded
	// corners (a single view can't do both).
	self.cardView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.cardView.layer.shadowOpacity = 0.45f;
	self.cardView.layer.shadowRadius = bounds.size.height * 0.025f;
	self.cardView.layer.shadowOffset = CGSizeMake(0.0f, bounds.size.height * 0.008f);
	self.cardView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.cardView.bounds cornerRadius:cornerRadius].CGPath;
	self.cardView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[hostView addSubview:self.cardView];

	self.cardContentView = [[UIView alloc] initWithFrame:self.cardView.bounds];
	self.cardContentView.layer.cornerRadius = cornerRadius;
	self.cardContentView.clipsToBounds = YES;
	[self.cardView addSubview:self.cardContentView];

	CGFloat headerHeight = cardHeight * 0.16f;
	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cardWidth, headerHeight)];
	[self.cardContentView addSubview:self.headerView];

	// The note's logo, large in the open margin to the right of the card.
	CGFloat marginWidth = (bounds.size.width - cardWidth) / 2.0f;
	CGFloat logoSide = MIN(marginWidth * 0.7f, bounds.size.height * 0.35f);
	self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(bounds.size.width - marginWidth / 2.0f - logoSide / 2.0f,
																	   (bounds.size.height - logoSide) / 2.0f,
																	   logoSide,
																	   logoSide)];
	self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
	self.logoImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
	[hostView addSubview:self.logoImageView];

	CGFloat inset = headerHeight * 0.25f;
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset,
																0.0f,
																cardWidth - inset * 2.0f,
																headerHeight)];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:headerHeight * 0.5f];
	self.titleLabel.adjustsFontSizeToFitWidth = YES;
	self.titleLabel.minimumScaleFactor = 0.4f;
	[self.headerView addSubview:self.titleLabel];

	// Big type for reading from across a room; non-interactive by construction.
	self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f,
																 headerHeight,
																 cardWidth,
																 cardHeight - headerHeight)];
	self.textView.editable = NO;
	self.textView.selectable = NO;
	self.textView.userInteractionEnabled = NO;
	self.textView.textContainerInset = UIEdgeInsetsMake(inset, inset, inset, inset);
	[self.cardContentView addSubview:self.textView];

	self.idleLabel = [[UILabel alloc] initWithFrame:bounds];
	self.idleLabel.text = @"A2Z Notes";
	self.idleLabel.textAlignment = NSTextAlignmentCenter;
	self.idleLabel.font = [UIFont boldSystemFontOfSize:bounds.size.height * 0.12f];
	self.idleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[hostView addSubview:self.idleLabel];
}

#pragma mark - Content

- (void)showNoteWithTitle:(NSString *)title text:(NSString *)text {
	self.currentTitle = title;
	self.currentText = text;
	[self render];
}

- (void)render {
	if (!self.window) {
		return;
	}

	UIView *hostView = self.window.rootViewController.view;
	NSString *title = self.currentTitle;

	if (title.length == 0) {
		UIColor *appColor = [NKFColor appColor];
		[self applyBackdropColor:[ALUNoteCardView mutedColor:appColor] toView:hostView];
		self.idleLabel.textColor = [appColor oppositeBlackOrWhite];
		self.idleLabel.hidden = NO;
		self.cardView.hidden = YES;
		self.logoImageView.hidden = YES;
		return;
	}

	self.idleLabel.hidden = YES;
	self.cardView.hidden = NO;
	self.logoImageView.hidden = NO;

	ALUDataManager *dataManager = [ALUDataManager sharedDataManager];
	NKFColor *color = [NKFColor colorForCompanyName:title];
	NSString *style = [dataManager cardStyleForListTitle:title];

	[self applyBackdropColor:[ALUNoteCardView mutedColor:color] toView:hostView];

	self.headerView.backgroundColor = color;
	self.titleLabel.text = title;
	self.titleLabel.textColor = [color oppositeBlackOrWhite];

	self.logoImageView.image = [dataManager showImageForListTitle:title] ? [dataManager imageForCompanyName:title] : nil;

	NSString *text = self.currentText ?: [dataManager listWithTitle:title];
	UIColor *cardBackground = [ALUNoteCardView backgroundColorForStyle:style] ?: [ALUNoteCardView mutedColor:color];
	self.cardContentView.backgroundColor = cardBackground;
	self.textView.backgroundColor = [UIColor clearColor];
	self.textView.textColor = [ALUNoteCardView textColorForStyle:style] ?: [cardBackground oppositeBlackOrWhite];
	self.textView.font = [UIFont boldSystemFontOfSize:self.window.bounds.size.height / 20.0f];
	self.textView.text = text;
}

// Solid base color plus a brighter band in the animated gradient above it.
- (void)applyBackdropColor:(UIColor *)color toView:(UIView *)hostView {
	hostView.backgroundColor = color;

	CGFloat hue = 0.0f, saturation = 0.0f, brightness = 0.0f, alpha = 1.0f;
	[color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	UIColor *glow = [UIColor colorWithHue:hue
							   saturation:MAX(0.0f, saturation - 0.15f)
							   brightness:MIN(1.0f, brightness + 0.18f)
									alpha:1.0f];

	self.gradientLayer.frame = hostView.bounds;
	self.gradientLayer.colors = @[(id)color.CGColor, (id)glow.CGColor, (id)color.CGColor];
}

@end
