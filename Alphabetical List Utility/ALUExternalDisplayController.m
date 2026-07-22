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
@property (nonatomic, strong) UIView *cardView;
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
	window.userInteractionEnabled = NO;
	window.rootViewController = [[UIViewController alloc] init];

	[self buildViewHierarchyInView:window.rootViewController.view];

	self.window = window;
	window.hidden = NO;

	[self render];
}

#pragma mark - View setup

- (void)buildViewHierarchyInView:(UIView *)hostView {
	CGRect bounds = hostView.bounds;

	// The reading card: roughly half the screen wide, centered, leaving the
	// full-bleed background color visible on both sides.
	CGFloat cardWidth = bounds.size.width * 0.55f;
	CGFloat cardHeight = bounds.size.height * 0.86f;
	self.cardView = [[UIView alloc] initWithFrame:CGRectMake((bounds.size.width - cardWidth) / 2.0f,
															 (bounds.size.height - cardHeight) / 2.0f,
															 cardWidth,
															 cardHeight)];
	self.cardView.layer.cornerRadius = bounds.size.height * 0.03f;
	self.cardView.clipsToBounds = YES;
	[hostView addSubview:self.cardView];

	CGFloat headerHeight = cardHeight * 0.16f;
	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cardWidth, headerHeight)];
	[self.cardView addSubview:self.headerView];

	CGFloat logoSide = headerHeight * 0.6f;
	self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cardWidth - logoSide - headerHeight * 0.2f,
																	   (headerHeight - logoSide) / 2.0f,
																	   logoSide,
																	   logoSide)];
	self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.headerView addSubview:self.logoImageView];

	CGFloat inset = headerHeight * 0.25f;
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset,
																0.0f,
																cardWidth - logoSide - inset * 3.0f,
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
	[self.cardView addSubview:self.textView];

	self.idleLabel = [[UILabel alloc] initWithFrame:bounds];
	self.idleLabel.text = @"A2Z Notes";
	self.idleLabel.textAlignment = NSTextAlignmentCenter;
	self.idleLabel.font = [UIFont boldSystemFontOfSize:bounds.size.height * 0.12f];
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
		hostView.backgroundColor = [ALUNoteCardView mutedColor:appColor];
		self.idleLabel.textColor = [appColor oppositeBlackOrWhite];
		self.idleLabel.hidden = NO;
		self.cardView.hidden = YES;
		return;
	}

	self.idleLabel.hidden = YES;
	self.cardView.hidden = NO;

	ALUDataManager *dataManager = [ALUDataManager sharedDataManager];
	NKFColor *color = [NKFColor colorForCompanyName:title];
	NSString *style = [dataManager cardStyleForListTitle:title];

	hostView.backgroundColor = [ALUNoteCardView mutedColor:color];

	self.headerView.backgroundColor = color;
	self.titleLabel.text = title;
	self.titleLabel.textColor = [color oppositeBlackOrWhite];

	self.logoImageView.image = [dataManager showImageForListTitle:title] ? [dataManager imageForCompanyName:title] : nil;

	NSString *text = self.currentText ?: [dataManager listWithTitle:title];
	UIColor *cardBackground = [ALUNoteCardView backgroundColorForStyle:style] ?: [ALUNoteCardView mutedColor:color];
	self.cardView.backgroundColor = cardBackground;
	self.textView.backgroundColor = [UIColor clearColor];
	self.textView.textColor = [ALUNoteCardView textColorForStyle:style] ?: [cardBackground oppositeBlackOrWhite];
	self.textView.font = [UIFont boldSystemFontOfSize:self.window.bounds.size.height / 20.0f];
	self.textView.text = text;
}

@end
