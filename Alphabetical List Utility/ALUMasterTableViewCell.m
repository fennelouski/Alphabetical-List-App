//
//  ALUMasterTableViewCell.m
//  Alphabetical List Utility
//
//  Created by HAI on 8/6/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUMasterTableViewCell.h"
#import "ALUDataManager.h"

@interface ALUMasterTableViewCell ()

@property (nonatomic, strong) UIView *shadowView;

@end

@implementation ALUMasterTableViewCell

@synthesize cardView = _cardView;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];

	if (USE_CARDS) {
		if (editing) {
			[UIView animateWithDuration:0.35f
							 animations:^{
								 self.cardView.alpha = 0.0f;
								 self.shadowView.alpha = 0.0f;
								 self.textLabel.hidden = NO;
								 self.backgroundColor = [UIColor systemBackgroundColor];
							 }];
		} else {
			[UIView animateWithDuration:0.35f
							 animations:^{
								 self.cardView.alpha = 1.0f;
								 self.shadowView.alpha = 1.0f;
								 self.textLabel.hidden = YES;
								 self.backgroundColor = [UIColor clearColor];
							 }];
		}
	}
}

- (void)setCardShift:(CGFloat)shift {
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0f, shift);
	self.cardView.transform = transform;
	self.shadowView.transform = transform;
}

#pragma mark - Getters and Setters

- (void)setNoteTitle:(NSString *)noteTitle {
	self.cardView.noteTitle = noteTitle;
}

- (NSString *)noteTitle {
	return self.cardView.noteTitle;
}

- (void)setColor:(UIColor *)color {
	self.cardView.color = color;
}

- (UIColor *)color {
	return self.cardView.color;
}

- (void)setAccessoryImage:(UIImage *)accessoryImage {
	self.cardView.accessoryImage = accessoryImage;
}

- (UIImage *)accessoryImage {
	return self.cardView.accessoryImage;
}

- (void)setNoteText:(NSString *)noteText {
	self.cardView.noteText = noteText;
}

- (NSString *)noteText {
	return self.cardView.noteText;
}

- (void)findImage {
	[self.cardView findImage];
}

#pragma mark - Layout

- (void)layoutSubviews {
	[super layoutSubviews];

	if (USE_CARDS) {
		self.clipsToBounds = NO;
		self.contentView.clipsToBounds = NO;

		[self addSubview:self.shadowView];
		[self addSubview:self.cardView];
		// bounds + center, not frame: the card and shadow carry a translation from
		// the fan/parting effects, and assigning frame to a transformed view
		// recenters it — silently cancelling the shift.
		CGRect cardFrame = [self cardViewFrame];
		CGRect cardBounds = CGRectMake(0.0f, 0.0f, cardFrame.size.width, cardFrame.size.height);
		CGPoint cardCenter = CGPointMake(CGRectGetMidX(cardFrame), CGRectGetMidY(cardFrame));
		self.cardView.bounds = cardBounds;
		self.cardView.center = cardCenter;
		self.shadowView.bounds = cardBounds;
		self.shadowView.center = cardCenter;
		UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.shadowView.bounds];
		self.shadowView.layer.shadowPath = shadowPath.CGPath;
	} else {
		[self.cardView removeFromSuperview];
		[self.shadowView removeFromSuperview];
	}
}

// The card is deliberately taller than the row: the row height is only the visible
// "peek" strip, and the rest of the card body is overlapped by the next row's card.
- (CGRect)cardViewFrame {
	return CGRectMake(0.0f,
					  0.0f,
					  ((self.bounds.size.width > 100.0f) ? self.bounds.size.width : kScreenWidth),
					  SHORTER_SIDE - kStatusBarHeight);
}

#pragma mark - Subviews

- (ALUNoteCardView *)cardView {
	if (!_cardView) {
		_cardView = [[ALUNoteCardView alloc] initWithFrame:[self cardViewFrame]];
	}

	return _cardView;
}

- (UIView *)shadowView {
	if (!_shadowView) {
		_shadowView = [[UIView alloc] initWithFrame:[self cardViewFrame]];
		_shadowView.layer.cornerRadius = 22.0f;
		_shadowView.layer.masksToBounds = NO;
		_shadowView.layer.shadowOffset = CGSizeMake(1, -4);
		_shadowView.layer.shadowRadius = 5;
		_shadowView.layer.shadowOpacity = 0.5;
	}

	return _shadowView;
}

@end
