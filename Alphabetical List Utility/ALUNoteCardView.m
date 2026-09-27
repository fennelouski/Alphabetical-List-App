//
//  ALUNoteCardView.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/22/26.
//  Copyright © 2026 HAI. All rights reserved.
//

#import "ALUNoteCardView.h"
#import "ALUDataManager.h"
#import "NKFColor.h"
#import "NKFColor+Companies.h"
#import "UIColor+AppColors.h"
#import "UIFont+AppFonts.h"
#import "UIImage+PixelInformation.h"
#import "NGAParallaxMotion.h"

static CGFloat const ALUNoteCardViewHeaderHeight = 44.0f;

static CGFloat const ALUNoteCardViewGradientHeight = 8.0f;

static CGFloat const ALUNoteCardViewCornerRadius = 10.0f;

static CGFloat const ALUNoteCardViewTextViewMaxFontSize = 30.0f;

static CGFloat const ALUNoteCardViewTextViewMinFontSize = 6.0f;

@interface ALUNoteCardView ()

@property (nonatomic, strong) UILabel *noteTitleLabel;
@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic, strong) UIView *styleOverlayView;

@end

@implementation ALUNoteCardView {
	NSString *_noteTitle;
	UIColor *_color;
	UIImage *_accessoryImage;
	NSString *_noteText;
	CGFloat _currentFontSize, _tempFontSize;
}

@synthesize headerView = _headerView;
@synthesize textView = _textView;
@synthesize accessoryImageView = _accessoryImageView;

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.layer.cornerRadius = ALUNoteCardViewCornerRadius;
		self.clipsToBounds = YES;
		// Subtle depth as the device tilts — vertical only, so the cards reveal a
		// sliver of themselves without sliding sideways out of the stack.
		self.parallaxIntensity = 9.0f;
		self.parallaxDirectionConstraint = NGAParallaxDirectionConstraintVertical;

		[self addSubview:self.textView];
		[self addSubview:self.headerView];
	}

	return self;
}

#pragma mark - Configuration

- (void)configureWithNoteTitle:(NSString *)noteTitle {
	self.noteTitle = noteTitle;
	self.color = [NKFColor colorForCompanyName:noteTitle];
	self.noteText = [[ALUDataManager sharedDataManager] listWithTitle:noteTitle];

	self.accessoryImage = nil;
	[self findImage];
	[self applyCardStyle];
}

+ (UIColor *)mutedColor:(UIColor *)color {
	CGFloat hue = 0.0f, saturation = 0.0f, brightness = 0.0f, alpha = 0.0f;
	if (![color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
		return color;
	}

	return [UIColor colorWithHue:hue
					  saturation:saturation * 0.42f
					  brightness:MAX(0.28f, MIN(0.62f, brightness))
						   alpha:alpha];
}

- (void)findImage {
	if (self.accessoryImage || self.noteTitle.length == 0) {
		return;
	}

	// Every card gets an icon (the monogram is the guaranteed fallback) unless the
	// user turned icons off for this note.
	if ([[ALUDataManager sharedDataManager] showImageForListTitle:self.noteTitle]) {
		self.accessoryImage = [[ALUDataManager sharedDataManager] imageForCompanyName:self.noteTitle];
	}
}

#pragma mark - Getters and Setters

- (void)setNoteTitle:(NSString *)noteTitle {
	_noteTitle = [noteTitle copy];
	if (!_noteTitle) {
		_noteTitle = @"";
	}

	self.noteTitleLabel.text = _noteTitle;
}

- (NSString *)noteTitle {
	return _noteTitle;
}

- (void)setColor:(UIColor *)color {
	_color = color;

	UIColor *mutedColor = [ALUNoteCardView mutedColor:_color];
	self.headerView.backgroundColor = mutedColor;
	self.noteTitleLabel.textColor = [mutedColor oppositeBlackOrWhite];
	self.textView.textColor = self.noteTitleLabel.textColor;

	UIColor *bodyColor = [mutedColor darkenColorBy:0.6f];
	self.backgroundColor = bodyColor;

	self.gradient.colors = [NSArray arrayWithObjects:(id)[mutedColor CGColor], (id)[bodyColor CGColor], nil];
	[self.layer insertSublayer:self.gradient atIndex:0];
}

- (UIColor *)color {
	return _color;
}

- (void)setNoteText:(NSString *)noteText {
	_noteText = [noteText copy];
	if (!_noteText) {
		_noteText = @"";
	}

	self.textView.text = _noteText;
}

- (NSString *)noteText {
	return _noteText;
}

- (void)setAccessoryImage:(UIImage *)accessoryImage {
	_accessoryImage = accessoryImage;
	self.accessoryImageView.image = accessoryImage;
	self.accessoryImageView.hidden = (accessoryImage == nil);

	if (_accessoryImage && [_accessoryImage cornersAreEmpty]) {
		self.accessoryImageView.layer.cornerRadius = 10.5f;
	} else {
		self.accessoryImageView.layer.cornerRadius = 0.0f;
	}
}

- (UIImage *)accessoryImage {
	return _accessoryImage;
}

#pragma mark - Layout

- (void)layoutSubviews {
	[super layoutSubviews];

	CGFloat width = self.bounds.size.width;

	self.headerView.frame = CGRectMake(0.0f, 0.0f, width, ALUNoteCardViewHeaderHeight);
	self.accessoryImageView.frame = CGRectMake(width - 50.0f, 2.0f, 40.0f, 40.0f);
	self.noteTitleLabel.frame = CGRectMake(10.0f,
										   0.0f,
										   self.accessoryImageView.frame.origin.x - 20.0f,
										   ALUNoteCardViewHeaderHeight);
	self.gradient.frame = CGRectMake(0.0f,
									 ALUNoteCardViewHeaderHeight,
									 width,
									 ALUNoteCardViewGradientHeight);

	CGFloat textViewYOrigin = ALUNoteCardViewHeaderHeight + ALUNoteCardViewGradientHeight;
	self.textView.frame = CGRectMake(10.0f,
									 textViewYOrigin,
									 width - 20.0f,
									 self.bounds.size.height - textViewYOrigin - 10.0f);
	self.styleOverlayView.frame = self.bounds;
}

#pragma mark - Subviews

- (UIView *)headerView {
	if (!_headerView) {
		_headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, ALUNoteCardViewHeaderHeight)];
		[_headerView addSubview:self.noteTitleLabel];
		[_headerView addSubview:self.accessoryImageView];
	}

	return _headerView;
}

- (UILabel *)noteTitleLabel {
	if (!_noteTitleLabel) {
		_noteTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f,
																	0.0f,
																	self.bounds.size.width - 40.0f,
																	ALUNoteCardViewHeaderHeight)];
		_noteTitleLabel.font = [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE];
		_noteTitleLabel.adjustsFontSizeToFitWidth = YES;
	}

	return _noteTitleLabel;
}

- (UIImageView *)accessoryImageView {
	if (!_accessoryImageView) {
		_accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 50.0f,
																			2.0f,
																			40.0f,
																			40.0f)];
		_accessoryImageView.clipsToBounds = YES;
		_accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
	}

	return _accessoryImageView;
}

- (UITextView *)textView {
	if (!_textView) {
		_textView = [[UITextView alloc] initWithFrame:self.bounds];
		_textView.editable = NO;
		_textView.selectable = NO;
		_textView.backgroundColor = [UIColor clearColor];
		_textView.userInteractionEnabled = NO;
		_textView.scrollEnabled = NO;

		if (_currentFontSize == 0 || _tempFontSize == 0) {
			_currentFontSize = [[ALUDataManager sharedDataManager] currentFontSizeForCardViews];
			_tempFontSize = _currentFontSize;

			if (_currentFontSize < 0 || _tempFontSize < 0) {
				_currentFontSize = -_currentFontSize;
				_tempFontSize = -_tempFontSize;
			}

			if (_currentFontSize == 0 || _tempFontSize == 0) {
				_currentFontSize = DEFAULT_FONT_SIZE * 0.8f;
				_tempFontSize = DEFAULT_FONT_SIZE * 0.8f;
			}
		}

		[_textView setFont:[UIFont boldSystemFontOfSize:_tempFontSize]];

		UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
		[self addGestureRecognizer:pinch];
	}

	return _textView;
}

- (CAGradientLayer *)gradient {
	if (!_gradient) {
		_gradient = [CAGradientLayer layer];
		_gradient.frame = CGRectMake(0.0f,
									 ALUNoteCardViewHeaderHeight,
									 self.bounds.size.width,
									 ALUNoteCardViewGradientHeight);
	}

	return _gradient;
}

#pragma mark - Card Styles

+ (NSArray<NSString *> *)cardStyleNames {
	return @[@"None", @"Paper", @"Sticky Note", @"Notebook", @"Index Card", @"Glass",
			 @"Metal", @"Stone", @"Vintage", @"Chalkboard", @"Plain Text"];
}

+ (UIColor *)backgroundColorForStyle:(NSString *)style {
	static NSDictionary *backgrounds;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		backgrounds = @{@"Paper"      : [UIColor colorWithRed:0.96f green:0.94f blue:0.89f alpha:1.0f],
						@"Sticky Note": [UIColor colorWithRed:1.0f green:0.95f blue:0.6f alpha:1.0f],
						@"Notebook"   : [UIColor colorWithRed:0.99f green:0.98f blue:0.96f alpha:1.0f],
						@"Index Card" : [UIColor whiteColor],
						@"Glass"      : [UIColor colorWithWhite:1.0f alpha:0.25f],
						@"Metal"      : [UIColor colorWithWhite:0.72f alpha:1.0f],
						@"Stone"      : [UIColor colorWithRed:0.36f green:0.35f blue:0.33f alpha:1.0f],
						@"Vintage"    : [UIColor colorWithRed:0.91f green:0.85f blue:0.69f alpha:1.0f],
						@"Chalkboard" : [UIColor colorWithRed:0.16f green:0.23f blue:0.2f alpha:1.0f],
						@"Plain Text" : [UIColor whiteColor]};
	});

	return style ? [backgrounds objectForKey:style] : nil;
}

+ (UIColor *)textColorForStyle:(NSString *)style {
	if ([style isEqualToString:@"Stone"] || [style isEqualToString:@"Chalkboard"]) {
		return [UIColor whiteColor];
	}
	if ([style isEqualToString:@"Vintage"]) {
		return [UIColor colorWithRed:0.35f green:0.25f blue:0.15f alpha:1.0f];
	}
	if ([style isEqualToString:@"Glass"]) {
		return nil; // keep the brand-derived text color over the blur
	}

	return [UIColor blackColor];
}

+ (UIFont *)fontForStyle:(NSString *)style size:(CGFloat)size {
	static NSDictionary *fontNames;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		fontNames = @{@"Sticky Note": @"MarkerFelt-Thin",
					  @"Notebook"   : @"Noteworthy-Light",
					  @"Vintage"    : @"Georgia",
					  @"Chalkboard" : @"ChalkboardSE-Regular",
					  @"Plain Text" : @"Menlo-Regular"};
	});

	NSString *fontName = style ? [fontNames objectForKey:style] : nil;
	return fontName ? [UIFont fontWithName:fontName size:size] : nil;
}

// A tiling image of ruled lines, so line spacing survives any card size for free.
+ (UIImage *)ruledLineTileWithColor:(UIColor *)lineColor {
	CGFloat spacing = 26.0f;
	UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(4.0f, spacing)];

	return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
		[lineColor setFill];
		[context fillRect:CGRectMake(0.0f, spacing - 1.0f, 4.0f, 1.0f)];
	}];
}

+ (UIView *)styleOverlayForStyle:(NSString *)style {
	UIView *overlay;

	if ([style isEqualToString:@"Glass"]) {
		overlay = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight]];
	} else if ([style isEqualToString:@"Metal"]) {
		UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(1.0f, 128.0f)];
		UIImage *gradientImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
			NSArray *colors = @[(id)[UIColor colorWithWhite:0.85f alpha:1.0f].CGColor,
								(id)[UIColor colorWithWhite:0.58f alpha:1.0f].CGColor,
								(id)[UIColor colorWithWhite:0.8f alpha:1.0f].CGColor];
			CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (__bridge CFArrayRef)colors, NULL);
			CGContextDrawLinearGradient(context.CGContext, gradient, CGPointZero, CGPointMake(0.0f, 128.0f), 0);
			CGGradientRelease(gradient);
		}];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:gradientImage];
		imageView.contentMode = UIViewContentModeScaleToFill;
		overlay = imageView;
	} else {
		overlay = [[UIView alloc] init];
		overlay.backgroundColor = [self backgroundColorForStyle:style];

		if ([style isEqualToString:@"Notebook"] || [style isEqualToString:@"Index Card"]) {
			UIColor *lineColor = [UIColor colorWithRed:0.6f green:0.75f blue:0.9f alpha:1.0f];
			UIView *lines = [[UIView alloc] init];
			lines.backgroundColor = [UIColor colorWithPatternImage:[self ruledLineTileWithColor:lineColor]];
			lines.frame = overlay.bounds;
			lines.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[overlay addSubview:lines];

			if ([style isEqualToString:@"Index Card"]) {
				UIView *headline = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 24.0f, 4000.0f, 1.5f)];
				headline.backgroundColor = [UIColor colorWithRed:0.9f green:0.4f blue:0.4f alpha:1.0f];
				[overlay addSubview:headline];
			}
		}
	}

	overlay.userInteractionEnabled = NO;
	return overlay;
}

- (void)applyCardStyle {
	[_styleOverlayView removeFromSuperview];
	_styleOverlayView = nil;

	// Restore base typography first so switching a style off works.
	CGFloat fontSize = self.textView.font.pointSize;
	self.textView.font = [UIFont boldSystemFontOfSize:fontSize];
	if (_color) {
		self.textView.textColor = [[ALUNoteCardView mutedColor:_color] oppositeBlackOrWhite];
	}

	NSString *style = [[ALUDataManager sharedDataManager] cardStyleForListTitle:self.noteTitle];
	CGFloat intensity = [[ALUDataManager sharedDataManager] cardStyleListIntensityForListTitle:self.noteTitle];
	if (![ALUNoteCardView backgroundColorForStyle:style] || intensity <= 0.02f) {
		return;
	}

	_styleOverlayView = [ALUNoteCardView styleOverlayForStyle:style];
	_styleOverlayView.alpha = intensity;
	_styleOverlayView.frame = self.bounds;
	[self insertSubview:_styleOverlayView belowSubview:self.textView];

	// Past half intensity the material dominates, so switch the type to match it.
	if (intensity >= 0.5f) {
		UIColor *styleTextColor = [ALUNoteCardView textColorForStyle:style];
		if (styleTextColor) {
			self.textView.textColor = styleTextColor;
		}
		UIFont *styleFont = [ALUNoteCardView fontForStyle:style size:fontSize];
		if (styleFont) {
			self.textView.font = styleFont;
		}
	}
}

#pragma mark - Gesture Actions

- (void)pinch:(UIPinchGestureRecognizer *)sender {
	if (sender.scale > 1) {
		_tempFontSize = _currentFontSize + sender.scale;
	} else if (sender.scale < 1) {
		_tempFontSize = _currentFontSize - (1 / sender.scale);
	}

	if (_tempFontSize > ALUNoteCardViewTextViewMaxFontSize) {
		_tempFontSize = ALUNoteCardViewTextViewMaxFontSize;
	} else if (_tempFontSize < ALUNoteCardViewTextViewMinFontSize) {
		_tempFontSize = ALUNoteCardViewTextViewMinFontSize;
	}

	[self.textView setFont:[UIFont boldSystemFontOfSize:_tempFontSize]];

	if (sender.state == UIGestureRecognizerStateEnded) {
		_currentFontSize = _tempFontSize;
		[[ALUDataManager sharedDataManager] saveAdjustedFontSizeForCardViews:_currentFontSize];
	}
}

@end
