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
#import "ALUDataManager.h"

@interface ALUDrawingViewController () <ALUColorPickerViewDelegate>

@property (nonatomic, strong) UIToolbar *inputAccessoryView;
@property (nonatomic, strong) UIBarButtonItem *clearButton, *cancelButton, *undoButton, *doneButton;
@property (nonatomic, strong) ALUBackgroundView *backgroundView;
@property (nonatomic, strong) UIToolbar *headerToolbar;

@property (nonatomic, strong) LinearInterpView *drawingView;
@property (nonatomic, strong) ALUColorPickerView *colorPickerView;

@property (nonatomic, strong) UIImageView *baseImageView;

@end

@implementation ALUDrawingViewController {
	UIImage *_image;
	BOOL _saving;
	BOOL _mouseSwiped;
	CGFloat brush;
	CGFloat opacity;
	CGPoint lastPoint;
    UIImage *_baseImage;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.view addSubview:self.backgroundView];
	[self.view addSubview:self.drawingView];
	[self.view addSubview:self.colorPickerView];
	
	[self performSelector:@selector(updateViewConstraints) withObject:self afterDelay:0.0f];
	[self performSelector:@selector(updateViewConstraints) withObject:self afterDelay:1.0f];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    self.backgroundView.frame = CGRectMake(0.0f, 0.0f, self.navigationController.navigationBar.frame.size.width, LONGER_SIDE);
    self.drawingView.frame = [self drawingViewFrame];
    self.colorPickerView.frame = [self colorPickerViewFrame];
	self.baseImageView.frame = self.drawingView.frame;
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
        
		_drawingView = [[LinearInterpView alloc] initWithFrame:[self drawingViewFrame]];
		_drawingView.backgroundColor = [NKFColor clearColor];
		_drawingView.layer.borderWidth = 1.0f;
		_drawingView.currentColor = self.currentColor;
		_drawingView.layer.borderColor = self.currentColor.CGColor;
	}
	
	return _drawingView;
}

- (CGRect)drawingViewFrame {
    CGFloat sideLength = (SHORTER_SIDE < self.view.bounds.size.height && SHORTER_SIDE < self.navigationController.navigationBar.frame.size.width) ? SHORTER_SIDE : (self.view.bounds.size.height < self.navigationController.navigationBar.frame.size.width) ? self.view.bounds.size.height : self.navigationController.navigationBar.frame.size.width;
    if (sideLength > 500.0f) {
        sideLength = 500.0f;
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

- (ALUColorPickerView *)colorPickerView {
	if (!_colorPickerView) {
		_colorPickerView = [[ALUColorPickerView alloc] initWithFrame:[self colorPickerViewFrame]];
		_colorPickerView.delegate = self;
	}
	
	return _colorPickerView;
}

- (CGRect)colorPickerViewFrame {
    CGRect frame = CGRectMake(self.drawingView.frame.origin.x,
                              self.drawingView.frame.origin.y + self.drawingView.frame.size.height,
                              self.drawingView.frame.size.width,
                              self.view.frame.size.height - self.drawingView.frame.origin.y - self.drawingView.frame.size.height - self.inputAccessoryView.frame.size.height);
    return frame;
}

- (UIImageView *)baseImageView {
    if (!_baseImageView) {
        _baseImageView = [[UIImageView alloc] initWithFrame:[self drawingViewFrame]];
        _baseImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _baseImageView;
}

#pragma mark - Input Accessory View

- (UIView *)inputAccessoryView {
	if (!_inputAccessoryView) {
		_inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, kScreenHeight, kScreenWidth, 44.0f)];
		_inputAccessoryView.tintColor = [NKFColor appColor];
		_inputAccessoryView.items = @[self.clearButton, [self flexibleSpace], self.cancelButton, [self flexibleSpace], self.undoButton, [self flexibleSpace], self.doneButton];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                              target:self
                                                                                              action:@selector(doneButtonTouched)];
	}
	
	return _inputAccessoryView;
}

- (UIBarButtonItem *)clearButton {
	if (!_clearButton) {
		_clearButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
																	 target:self
																	 action:@selector(clearButtonTouched)];
	}
	
	return _clearButton;
}

- (UIBarButtonItem *)cancelButton {
	if (!_cancelButton) {
		_cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																	  target:self
																	  action:@selector(cancelButtonTouched)];
	}
	
	return _cancelButton;
}

- (UIBarButtonItem *)undoButton {
	if (!_undoButton) {
		_undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
																	target:self
																	action:@selector(undoButtonTouched)];
	}
	
	return _undoButton;
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
	[self dismiss];
}

- (void)clearButtonTouched {
	[self.drawingView removeFromSuperview];
	self.drawingView = nil;
    self.drawingView.frame = [self drawingViewFrame];
	[self.view addSubview:self.drawingView];
    self.colorPickerView.frame = [self colorPickerViewFrame];
    [self.view addSubview:self.colorPickerView];
    [self.baseImageView removeFromSuperview];
}

- (void)undoButtonTouched {
	[self.drawingView undoLastLine];
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
	
	[self dismiss];
}

- (void)dismiss {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Export Image

- (void)updateImageWithDrawing {
	self.drawingView.layer.borderWidth = 0.0f;
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.drawingView.bounds];
    
    if (self.baseImageView.superview) {
        self.baseImageView.frame = containerView.bounds;
        [containerView addSubview:self.baseImageView];
        self.drawingView.frame = containerView.bounds;
        [containerView addSubview:self.drawingView];
        _image = [self imageWithView:containerView];
    } else {
        _image = [self imageWithView:self.drawingView];
        self.drawingView.layer.borderWidth = 1.0f;
    }
	
	[self.view addSubview:self.baseImageView];
	[self.view addSubview:self.drawingView];
	self.drawingView.frame = [self drawingViewFrame];
	self.colorPickerView.frame = [self colorPickerViewFrame];
}

- (UIImage *)image {
	return _image;
}

- (void)setBaseImage:(UIImage *)baseImage {
    self.baseImageView.image = baseImage;
    [self.view insertSubview:self.baseImageView belowSubview:self.drawingView];
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
	self.drawingView.layer.borderColor = color.CGColor;
}


#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
