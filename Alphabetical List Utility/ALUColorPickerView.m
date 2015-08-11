//
//  ALUColorPickerView.m
//  Alphabetical List Utility
//
//  Created by HAI on 8/11/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUColorPickerView.h"
#import "UIImage+PixelInformation.h"

@interface ALUColorPickerView ()

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation ALUColorPickerView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.contentMode = UIViewContentModeScaleToFill;
		self.image = [UIImage imageNamed:@"Color-gradient"];
		[self addGestureRecognizer:self.tap];
		self.userInteractionEnabled = YES;
	}
	
	return self;
}

- (instancetype)initWithImage:(UIImage *)image {
	self = [super initWithImage:image];
	
	if (self) {
		[self addGestureRecognizer:self.tap];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
}


#pragma mark - Gesture Recognizer

- (UITapGestureRecognizer *)tap {
	if (!_tap) {
		_tap = [[UITapGestureRecognizer alloc] initWithTarget:self
													   action:@selector(tapped:)];
	}
	
	return _tap;
}

- (void)tapped:(UITapGestureRecognizer *)tap {
	CGPoint point = [tap locationInView:tap.view];
	UIImage *image = [self imageWithView:tap.view];
	UIColor *color = [image colorAtPixel:point];
	
	if ([self.delegate respondsToSelector:@selector(colorPicked:)] && color) {
		[self.delegate colorPicked:color];
	}
}

- (UIImage *)imageWithView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return img;
}



@end
