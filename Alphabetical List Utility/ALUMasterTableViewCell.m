//
//  ALUMasterTableViewCell.m
//  Alphabetical List Utility
//
//  Created by HAI on 8/6/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUMasterTableViewCell.h"
#import "NGAParallaxMotion.h"
#import "UIColor+AppColors.h"
#import "NKFColor.h"
#import "NKFColor+Companies.h"
#import "ALUDataManager.h"
#import "UIImage+PixelInformation.h"

static CGFloat const ALUMasterTableViewCellTextViewMaxFontSize = 30.0f;

static CGFloat const ALUMasterTableViewCellTextViewMinFontSize = 6.0f;

@interface ALUMasterTableViewCell ()

@property (nonatomic, strong) UILabel *noteTitleLabel;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIImageView *accessoryImageView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *headerToolbar;
@property (nonatomic, strong) CAGradientLayer *gradient;

@end

@implementation ALUMasterTableViewCell {
	NSString *_noteTitle;
	UIColor *_color;
	UIImage *_accessoryImage;
	NSString *_noteText;
	NSArray *_colors;
	CGPoint _contentOffset;
    CGFloat _currentFontSize, _tempFontSize;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	if (USE_CARDS) {
		if (editing) {
			[UIView animateWithDuration:0.35f
							 animations:^{
								 self.cardView.alpha = 0.0f;
                                 self.shadowView.alpha = 0.0f;
								 self.textLabel.hidden = NO;
								 self.backgroundColor = [UIColor white];
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

#pragma mark - Getter and Setters

- (void)setNoteTitle:(NSString *)noteTitle {
	_noteTitle = noteTitle;
	if (!noteTitle) {
		_noteTitle = @"";
	}
    
    self.noteTitleLabel.text = _noteTitle;
	
	_colors = [NKFColor colorsForCompanyName:_noteTitle];
}

- (NSString *)noteTitle {
	return _noteTitle;
}

- (void)setColor:(UIColor *)color {
	_color = color;
	self.headerToolbar.backgroundColor = _color;
	self.noteTitleLabel.textColor = [_color oppositeBlackOrWhite];
	
	UIColor *otherColor = [_color darkenColorBy:0.92f];
    self.gradient.frame = CGRectMake(0.0f,
                                     self.headerToolbar.frame.size.height,
                                     LONGER_SIDE,
                                     8.0f);
	
	self.cardView.backgroundColor = otherColor;
    
	self.gradient.colors = [NSArray arrayWithObjects:(id)[_color CGColor], (id)[otherColor CGColor], nil];
    
	[self.cardView.layer insertSublayer:self.gradient atIndex:0];
}

- (UIColor *)color {
	return _color;
}

- (void)setAccessoryImage:(UIImage *)accessoryImage {
	_accessoryImage = accessoryImage;
	self.accessoryImageView.image = accessoryImage;
    
    if (_accessoryImage && [_accessoryImage cornersAreEmpty]) {
        self.accessoryImageView.layer.cornerRadius = 10.5f;
    } else {
        self.accessoryImageView.layer.cornerRadius = 0.0f;
    }
}

- (UIImage *)accessoryImage {
	return _accessoryImage;
}

- (void)setParallaxStrength:(CGFloat)parallaxIntensity {
	self.cardView.parallaxIntensity = -parallaxIntensity;
	self.cardView.parallaxDirectionConstraint = NGAParallaxDirectionConstraintVertical;
	self.shadowView.parallaxIntensity = -parallaxIntensity * 0.49f;
	self.shadowView.parallaxDirectionConstraint = NGAParallaxDirectionConstraintVertical;
}

- (CGFloat)parallaxStrength {
	return self.cardView.parallaxIntensity;
}

- (void)setNoteText:(NSString *)noteText {
	_noteText = noteText;
	if (!_noteText) {
		_noteText = @"";
	}
	self.textView.text = _noteText;
}

- (NSString *)noteText {
	return _noteText;
}

- (void)setContentOffset:(CGPoint)contentOffset {
	BOOL contentOffsetChanged = !(_contentOffset.x == contentOffset.x && _contentOffset.y == contentOffset.y);
	_contentOffset = contentOffset;
	
	if (contentOffsetChanged) {
		self.cardView.frame = [self cardViewFrame];
		self.shadowView.frame = CGRectOffset(self.cardView.frame, 0.0f, -1.0f);
		UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.shadowView.bounds];
		self.shadowView.layer.shadowPath = shadowPath.CGPath;
	}
}

- (CGPoint)contentOffset {
	return _contentOffset;
}

#pragma mark - Layout

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (USE_CARDS) {
		[self addSubview:self.shadowView];
		[self addSubview:self.cardView];
		self.cardView.frame = [self cardViewFrame];
		self.shadowView.frame = self.cardView.frame;
		self.accessoryImageView.frame = CGRectMake(self.bounds.size.width - 60.0f,
												   2.0f,
												   40.0f,
												   40.0f);
		
		
		CGFloat textViewYOrigin = self.noteTitleLabel.frame.size.height + self.noteTitleLabel.frame.origin.y;
		self.textView.frame = CGRectMake(10.0f,
										 textViewYOrigin,
										 self.cardView.frame.size.width - 20.0f,
										 self.cardView.frame.size.height - textViewYOrigin - 10.0f);
		self.textView.textColor = self.noteTitleLabel.textColor;
		
		
		self.noteTitleLabel.frame = CGRectMake(10.0f,
											   0.0f,
											   self.accessoryImageView.frame.origin.x - 10.0f,
											   44.0f);
	} else {
		[self.cardView removeFromSuperview];
		[self.headerToolbar removeFromSuperview];
	}
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self performSelector:@selector(findImage) withObject:self afterDelay:1.0f];
    });
}

- (void)findImage {
    if (!self.accessoryImageView.image) {
        if ([[ALUDataManager sharedDataManager] showImageForListTitle:self.noteTitle]) {
            UIImage *image = [[ALUDataManager sharedDataManager] imageForCompanyName:self.noteTitle];
            
            if (image) {
                self.accessoryImageView.image = image;
                self.accessoryImageView.hidden = NO;
            }
        }
    }
}

- (CGRect)cardViewFrame {
	return CGRectMake(_contentOffset.x,
					  _contentOffset.y,
					  ((self.bounds.size.width > 100.0f) ? self.bounds.size.width : kScreenWidth),
					  SHORTER_SIDE - kStatusBarHeight);
}


#pragma mark - Subviews

- (UILabel *)noteTitleLabel {
	if (!_noteTitleLabel) {
		_noteTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f,
																	0.0f,
																	self.bounds.size.width - 40.0f,
																	44.0f)];
		_noteTitleLabel.font = [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE];
		_noteTitleLabel.adjustsFontSizeToFitWidth = YES;
	}
	
	return _noteTitleLabel;
}

- (UIView *)cardView {
	if (!_cardView) {
		_cardView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
															 0.0f,
															 (self.bounds.size.width > 100.0f) ? self.bounds.size.width : kScreenWidth,
															 LONGER_SIDE - 44.0f)];
		_cardView.layer.cornerRadius = 10.0f;
		_cardView.clipsToBounds = YES;
		[_cardView addSubview:self.headerToolbar];
		[_cardView addSubview:self.textView];
	}
	
	return _cardView;
}

- (UIView *)shadowView {
	if (!_shadowView) {
		_shadowView = [[UIView alloc] initWithFrame:self.cardView.frame];
		_shadowView.layer.cornerRadius = 22.0f;
		_shadowView.layer.masksToBounds = NO;
		_shadowView.layer.shadowOffset = CGSizeMake(1, -4);
		_shadowView.layer.shadowRadius = 5;
		_shadowView.layer.shadowOpacity = 0.5;
	}
	
	return _shadowView;
}

- (UIImageView *)accessoryImageView {
	if (!_accessoryImageView) {
		_accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 60.0f,
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
		CGFloat textViewYOrigin = self.noteTitleLabel.frame.size.height + self.noteTitleLabel.frame.origin.y;
		_textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f,
																 textViewYOrigin,
																 self.cardView.frame.size.width - 20.0f,
																 self.cardView.frame.size.height - textViewYOrigin - 10.0f)];
		_textView.editable = NO;
		_textView.selectable = NO;
		_textView.backgroundColor = [UIColor clearColor];
		_textView.userInteractionEnabled = YES;
		_textView.scrollEnabled = NO;
		_textView.dataDetectorTypes = UIDataDetectorTypeAll;
        
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
        [_textView addGestureRecognizer:pinch];
	}
	
	return _textView;
}

- (UIView *)headerToolbar {
	if (!_headerToolbar) {
		_headerToolbar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScreenWidth + kScreenHeight, 44.0f)];
		[_headerToolbar addSubview:self.noteTitleLabel];
		[_headerToolbar addSubview:self.accessoryImageView];
	}
	
	return _headerToolbar;
}

- (CAGradientLayer *)gradient {
	if (!_gradient) {
		_gradient = [CAGradientLayer layer];
		_gradient.frame = CGRectMake(0.0f,
									self.headerToolbar.frame.size.height,
									LONGER_SIDE,
									8.0f);
	}
	
	return _gradient;
}

#pragma mark - Button and Gesture Actions

- (void)pinch:(UIPinchGestureRecognizer *)sender {
    if (sender.scale > 1) {
        _tempFontSize = _currentFontSize + sender.scale;
    } else if (sender.scale < 1) {
        _tempFontSize = _currentFontSize - (1/sender.scale);
    }
    
    if (_tempFontSize > ALUMasterTableViewCellTextViewMaxFontSize) {
        _tempFontSize = ALUMasterTableViewCellTextViewMaxFontSize;
    } else if (_tempFontSize < ALUMasterTableViewCellTextViewMinFontSize) {
        _tempFontSize = ALUMasterTableViewCellTextViewMinFontSize;
    }
    
    if (!self.textView.superview) {
        UIView *viewToShowTextOn = self;
        
        [viewToShowTextOn addSubview:self];
    }
    
    [self.textView setFont:[UIFont systemFontOfSize:_tempFontSize]];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        _currentFontSize = _tempFontSize;
        [[ALUDataManager sharedDataManager] saveAdjustedFontSizeForCardViews:_currentFontSize];
    }
}


@end
