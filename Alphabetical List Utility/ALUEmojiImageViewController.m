//
//  ALUEmojiImageViewController.m
//  Alphabetical List Utility
//
//  Created by Nathan Fennel on 8/10/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUEmojiImageViewController.h"
#import "NKFColor.h"
#import "NKFColor+AppColors.h"
#import "ALUBackgroundView.h"

@interface ALUEmojiImageViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIToolbar *inputAccessoryView;
@property (nonatomic, strong) UIBarButtonItem *editButton, *cancelButton, *doneButton;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) ALUBackgroundView *backgroundView;

@end

static CGFloat const ALUEmojiImageViewControllerTextFieldHeight = 44.0f;

@implementation ALUEmojiImageViewController {
    UIImage *_image;
    BOOL _saving;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.imageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textField becomeFirstResponder];
    
    _saving = NO;
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
	
	self.imageView.frame = [self imageViewFrame];
	self.backgroundView.frame = CGRectMake(0.0f, 0.0f, self.navigationController.navigationBar.frame.size.width, LONGER_SIDE);
	[self.backgroundView layoutSubviews];
	self.textField.frame = [self textFieldFrame];
}

#pragma mark - Subviews

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:[self textFieldFrame]];
        _textField.delegate = self;
        _textField.placeholder = @"Text for icon";
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
		_textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.inputAccessoryView = self.inputAccessoryView;
        _textField.textColor = [NKFColor blackColor];
		_textField.backgroundColor = [NKFColor whiteColor];
		_textField.tintColor = [NKFColor appColor];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0.0f,
                                         0.0f,
                                         LONGER_SIDE,
                                         _textField.frame.size.height);
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[[[NKFColor whiteColor] colorWithAlphaComponent:0.5f] CGColor], (id)[[NKFColor clearColor] CGColor], nil];
        gradientLayer.startPoint = CGPointMake(0.0f, 0.7f);
        gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
        
        _textField.layer.mask = gradientLayer;
    }
    
    return _textField;
}

- (CGRect)textFieldFrame {
	CGRect frame = CGRectMake(0.0f,
							  self.navigationController.navigationBar.frame.size.height + kStatusBarHeight,
							  self.navigationController.navigationBar.frame.size.width,
							  ALUEmojiImageViewControllerTextFieldHeight);
	
	return frame;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:[self imageViewFrame]];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imageView;
}

- (CGRect)imageViewFrame {
	CGFloat sideLength = (SHORTER_SIDE < self.view.bounds.size.height && SHORTER_SIDE < self.navigationController.navigationBar.frame.size.width) ? SHORTER_SIDE : (self.view.bounds.size.height < self.navigationController.navigationBar.frame.size.width) ? self.view.bounds.size.height : self.navigationController.navigationBar.frame.size.width;
	if (sideLength > 414.0f) {
		sideLength = 414.0f;
	}
	
	CGFloat xOrigin = (self.navigationController.navigationBar.frame.size.width - sideLength) * 0.5f;
	
	if (IS_IPAD && self.navigationController.navigationBar.frame.size.width > self.view.frame.size.height) {
		xOrigin = 0.0f;
	}
	
	CGFloat yOrigin = self.navigationController.navigationBar.frame.size.height + kStatusBarHeight;
	
	if (yOrigin < 50.0f) {
		yOrigin = kStatusBarHeight + 44.0f;
	}
	
	CGRect frame = CGRectMake(xOrigin,
							  yOrigin,
							  sideLength,
							  sideLength);
	
	return frame;
}


- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:self.imageView.frame];
        _label.font = [UIFont boldSystemFontOfSize:self.imageView.frame.size.height];
        _label.adjustsFontSizeToFitWidth = YES;
        _label.textColor = [UIColor whiteColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.contentMode = UIViewContentModeCenter;
    }
    
    return _label;
}

- (ALUBackgroundView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[ALUBackgroundView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.navigationController.navigationBar.frame.size.width, LONGER_SIDE)];
    }
    
    return _backgroundView;
}

- (UIView *)inputAccessoryView {
    if (!_inputAccessoryView) {
        _inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, kScreenHeight, kScreenWidth, ALUEmojiImageViewControllerTextFieldHeight)];
        _inputAccessoryView.tintColor = [NKFColor appColor];
        _inputAccessoryView.items = @[self.editButton, [self flexibleSpace], self.cancelButton, [self flexibleSpace], self.doneButton];
    }
    
    return _inputAccessoryView;
}

- (UIBarButtonItem *)editButton {
    if (!_editButton) {
        _editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                    target:self
                                                                    action:@selector(editButtonTouched)];
        _editButton.tintColor = [NKFColor appColor];
    }
    
    return _editButton;
}

- (UIBarButtonItem *)cancelButton {
	if (!_cancelButton) {
		_cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																	  target:self
																	  action:@selector(cancelButtonTouched)];
	}
	
	return _cancelButton;
}

- (UIBarButtonItem *)doneButton {
    if (!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(doneButtonTouched)];
        _doneButton.tintColor = [NKFColor appColor];
    }
    
    return _doneButton;
}

- (UIBarButtonItem *)flexibleSpace {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                         target:self
                                                         action:nil];
}

- (BOOL)canBecomeFirstResponder {
    return !_saving;
}

#pragma mark - Button Actions

- (void)editButtonTouched {
    DLog(@"Edit");
    [self.textField becomeFirstResponder];
}

- (void)cancelButtonTouched {
	[self dismiss];
}

- (void)doneButtonTouched {
    DLog(@"Done");
    _saving = YES;
    
    if ([self.delegate respondsToSelector:@selector(emojiImage:)]) {
        if (!_image) {
            DLog(@"No image set.");
            [self updateImageWithText];
        }
        
        [self.delegate emojiImage:_image];
    } else {
        DLog(@"%s", __PRETTY_FUNCTION__);
        DLog(@"Delegate does not respond properly to \"emojiImage:\"");
    }
    
    [self resignFirstResponder];
    
	[self dismiss];
}

- (void)dismiss {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.textField]) {
        [self.textField resignFirstResponder];
        [self becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isEqual:self.textField]) {
        [self performSelector:@selector(updateImageWithText) withObject:self afterDelay:0.1f];
    }
    
    return YES;
}

#pragma mark - Image

- (UIImage *)image {
    if (!_image) {
        _image = self.imageView.image;
    }
    
    return _image;
}

- (void)updateImageWithText {
    NSString *truncatedText = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!truncatedText || truncatedText.length == 0) {
        DLog(@"No text to change!");
    }
    
    self.label.text = truncatedText;
    _image = [self imageWithView:self.label];
    self.imageView.image = _image;
}

- (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}


@end
