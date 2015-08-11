//
//  ALUDrawingViewController.m
//  Alphabetical List Utility
//
//  Created by HAI on 8/11/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUDrawingViewController.h"
#import "ALUBackgroundView.h"
#import "NKFColor.h"
#import "NKFColor+AppColors.h"
#import "LinearInterpView.h"
#import "ALUColorPickerView.h"

@interface ALUDrawingViewController () <ALUColorPickerViewDelegate>

@property (nonatomic, strong) UIToolbar *inputAccessoryView;
@property (nonatomic, strong) UIBarButtonItem *cancelButton, *clearButton, *doneButton;
@property (nonatomic, strong) ALUBackgroundView *backgroundView;

@property (nonatomic, strong) LinearInterpView *drawingView;
@property (nonatomic, strong) ALUColorPickerView *colorPickerView;

@end

@implementation ALUDrawingViewController {
	UIImage *_image;
	BOOL _saving;
	BOOL _mouseSwiped;
	CGFloat brush;
	CGFloat opacity;
	CGPoint lastPoint;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.view addSubview:self.backgroundView];
	[self.view addSubview:self.drawingView];
	[self.view addSubview:self.colorPickerView];
}



#pragma mark - Subviews

- (ALUBackgroundView *)backgroundView {
	if (!_backgroundView) {
		_backgroundView = [[ALUBackgroundView alloc] initWithFrame:self.view.bounds];
	}
	
	return _backgroundView;
}

- (LinearInterpView *)drawingView {
	if (!_drawingView) {
		_drawingView = [[LinearInterpView alloc] initWithFrame:CGRectMake(0.0f,
																		  0.0f,
																		  self.view.bounds.size.width,
																		  self.view.bounds.size.width)];
		_drawingView.center = CGPointMake(self.view.bounds.size.width * 0.5f,
										  self.view.bounds.size.width * 0.5f + kStatusBarHeight);
		_drawingView.backgroundColor = [NKFColor clearColor];
		_drawingView.layer.borderColor = [[[NKFColor appColor] lightenColor] colorWithAlphaComponent:0.5f].CGColor;
		_drawingView.layer.borderWidth = 1.0f;
		_drawingView.currentColor = self.currentColor;
	}
	
	return _drawingView;
}

- (ALUColorPickerView *)colorPickerView {
	if (!_colorPickerView) {
		_colorPickerView = [[ALUColorPickerView alloc] initWithFrame:CGRectMake(0.0f,
																				self.drawingView.frame.origin.y + self.drawingView.frame.size.height,
																				self.drawingView.frame.size.width,
																				self.view.frame.size.height - self.drawingView.frame.origin.y - self.drawingView.frame.size.height - self.inputAccessoryView.frame.size.height)];
		_colorPickerView.delegate = self;
	}
	
	return _colorPickerView;
}

#pragma mark - Input Accessory View

- (UIView *)inputAccessoryView {
	if (!_inputAccessoryView) {
		_inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, kScreenHeight, kScreenWidth, 44.0f)];
		_inputAccessoryView.tintColor = [NKFColor appColor];
		_inputAccessoryView.items = @[self.cancelButton, [self flexibleSpace], self.clearButton, [self flexibleSpace], self.doneButton];
	}
	
	return _inputAccessoryView;
}

- (UIBarButtonItem *)cancelButton {
	if (!_cancelButton) {
		_cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																	  target:self
																	  action:@selector(cancelButtonTouched)];
	}
	
	return _cancelButton;
}

- (UIBarButtonItem *)clearButton {
	if (!_clearButton) {
		_clearButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
																	 target:self
																	 action:@selector(clearButtonTouched)];
	}
	
	return _clearButton;
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

- (void)cancelButtonTouched {
	[self dismissViewControllerAnimated:YES
							 completion:^{
								 
							 }];
}

- (void)clearButtonTouched {
	[self.drawingView removeFromSuperview];
	self.drawingView = nil;
	[self.view addSubview:self.drawingView];
}

- (void)doneButtonTouched {
	DLog(@"Done");
	_saving = YES;
	
	if ([self.delegate respondsToSelector:@selector(drawnImage:)]) {
		if (!_image) {
			DLog(@"No image set.");
			[self updateImageWithDrawing];
		}
		
		[self.delegate drawnImage:_image];
	} else {
		DLog(@"%s", __PRETTY_FUNCTION__);
		DLog(@"Delegate does not respond properly to \"drawnImage:\"");
	}
	
	[self resignFirstResponder];
	
	[self dismissViewControllerAnimated:YES
							 completion:^{
								 
							 }];
}

#pragma mark - Export Image

- (void)updateImageWithDrawing {
	self.drawingView.layer.borderWidth = 0.0f;
	_image = [self imageWithView:self.drawingView];
	self.drawingView.layer.borderWidth = 1.0f;
}

- (UIImage *)image {
	return _image;
}

- (UIImage *)imageWithView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return img;
}


#pragma mark - Color Picker Delegate

- (void)colorPicked:(UIColor *)color {
	self.currentColor = color;
	self.drawingView.currentColor = color;
}


#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
