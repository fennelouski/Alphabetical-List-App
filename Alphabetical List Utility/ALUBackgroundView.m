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

@interface ALUBackgroundView ()

@property (nonatomic, strong) ALUPatternedView *patternedView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ALUBackgroundView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self addSubview:self.patternedView];
    [self addSubview:self.blurredImageView];
    [self addSubview:self.titleLabel];
}

- (UIImageView *)blurredImageView {
    if (!_blurredImageView) {
        UIImage *capturedImage = [self imageWithView:self.patternedView];
        
        UIColor *tintColor = [[[NKFColor appColor] darkenColorBy:0.25f] colorWithAlphaComponent:0.92f];
        UIImage *blurredImage = [capturedImage applyBlurWithRadius:8.2f
                                                         tintColor:tintColor
                                             saturationDeltaFactor:1.2f
                                                         maskImage:nil];
        
        _blurredImageView = [[UIImageView alloc] initWithImage:blurredImage];
    }
    
    return _blurredImageView;
}

- (ALUPatternedView *)patternedView {
    if (!_patternedView) {
        _patternedView = [[ALUPatternedView alloc] initWithFrame:self.bounds];
    }
    
    return _patternedView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 150.0f, self.bounds.size.width, 50.0f)];
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

- (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}



@end
