//
//  ALUBackgroundView.m
//  Alphabetical List Utility
//
//  Created by Nathan Fennel on 8/9/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUBackgroundView.h"
#import "ALUPatternedView.h"
#import "UIImage+ImageEffects.h"
#import "NKFColor.h"
#import "NKFColor+AppColors.h"
#import "NKFColor+WikipediaColors.h"
#import "UIColor+AppColors.h"

@interface ALUBackgroundView ()

@property (nonatomic, strong) ALUPatternedView *patternedView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ALUBackgroundView {
    UIImage *_blurredImage;
    CAGradientLayer *_animatedGradientLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.blurredImageView.frame = self.bounds;
    [self addSubview:self.blurredImageView];
    [self.layer addSublayer:[self animatedGradientLayer]];
    _animatedGradientLayer.frame = self.bounds;
    self.titleLabel.frame = [self titleLabelFrame];
    [self addSubview:self.titleLabel];
}

// A translucent tint that slowly drifts between two color washes, so the background
// feels alive instead of being a static blur.
- (CAGradientLayer *)animatedGradientLayer {
    if (!_animatedGradientLayer) {
        _animatedGradientLayer = [CAGradientLayer layer];
        _animatedGradientLayer.frame = self.bounds;
        _animatedGradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
        _animatedGradientLayer.endPoint = CGPointMake(1.0f, 1.0f);

        UIColor *appColor = [NKFColor appColor];
        NSArray *fromColors = @[(id)[[appColor lightenColor] colorWithAlphaComponent:0.16f].CGColor,
                                (id)[[UIColor clearColor] CGColor],
                                (id)[[appColor darkenColorBy:0.5f] colorWithAlphaComponent:0.22f].CGColor];
        NSArray *toColors = @[(id)[[appColor darkenColorBy:0.5f] colorWithAlphaComponent:0.22f].CGColor,
                              (id)[[UIColor clearColor] CGColor],
                              (id)[[appColor lightenColor] colorWithAlphaComponent:0.16f].CGColor];
        _animatedGradientLayer.colors = fromColors;

        CABasicAnimation *drift = [CABasicAnimation animationWithKeyPath:@"colors"];
        drift.fromValue = fromColors;
        drift.toValue = toColors;
        drift.duration = 14.0;
        drift.autoreverses = YES;
        drift.repeatCount = HUGE_VALF;
        [_animatedGradientLayer addAnimation:drift forKey:@"colorDrift"];
    }

    return _animatedGradientLayer;
}

- (UIImageView *)blurredImageView {
    if (!_blurredImageView) {
        
        _blurredImageView = [[UIImageView alloc] initWithImage:[self image]];
		_blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return _blurredImageView;
}

- (UIImage *)image {
    self.patternedView.frame = self.bounds;
    [self.patternedView setNeedsDisplay];
    
    if (_blurredImage && _blurredImage.size.width >= self.bounds.size.width && _blurredImage.size.height > self.bounds.size.height) {
        return _blurredImage;
    }
    
    UIImage *capturedImage = [self imageWithView:self.patternedView];
    
    UIColor *tintColor = [[[NKFColor appColor] darkenColorBy:0.25f] colorWithAlphaComponent:0.92f];
    _blurredImage = [capturedImage applyBlurWithRadius:8.2f
                                             tintColor:tintColor
                                 saturationDeltaFactor:1.2f
                                             maskImage:nil];
    return _blurredImage;
}

- (ALUPatternedView *)patternedView {
    if (!_patternedView) {
        _patternedView = [[ALUPatternedView alloc] initWithFrame:self.bounds];
    }
    
    return _patternedView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:[self titleLabelFrame]];
        _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"A to Z Notes" attributes:@{
                                                                                                       NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
                                                                                                       NSFontAttributeName : [UIFont boldSystemFontOfSize:20.0f],
                                                                                                       
                                                                                                       NSForegroundColorAttributeName : [[NKFColor appColor] colorWithAlphaComponent:0.5f]
                                                                                                       }];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.alpha = 0.3f;
    }
    
    return _titleLabel;
}

- (CGRect)titleLabelFrame {
    CGRect frame = CGRectMake(0.0f, kScreenHeight * 0.25f, self.bounds.size.width, 50.0f);
    
    return frame;
}

- (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}



@end
