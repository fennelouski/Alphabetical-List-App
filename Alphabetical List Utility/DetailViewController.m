//
//  DetailViewController.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "DetailViewController.h"
#import "ALUDataManager.h"
#import "UIColor+AppColors.h"
#import "UIColor+BrandColors.h"

#define kScreenWidth (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight (([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)

#define DEFAULT_FONT_SIZE ((((kScreenHeight + kScreenWidth) * 0.02f) < 18.0f) ? 18.0f : (((kScreenHeight + kScreenWidth) * 0.02f) > 25.0f) ? 25.0f : ((kScreenHeight + kScreenWidth) * 0.02f))

#define kViewControllerWidth self.view.frame.size.width
#define kViewControllerHeight self.view.frame.size.height

static NSString * const fontSizeKey = @"This is my font size Key and don't forget that I like Tacos";
@interface DetailViewController ()

@end

@implementation DetailViewController {
	CGFloat _tempFontSize, _currentFontSize;
	BOOL _isKeyboardShowing;
}

static CGFloat const borderWidth = 10.0f;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
	if (_detailItem != newDetailItem) {
	    _detailItem = newDetailItem;
	        
	    // Update the view.
	    [self configureView];
	}
}

- (void)configureView {
	// Update the user interface for the detail item.
	if (self.detailItem) {
	    self.detailDescriptionLabel.text = [self.detailItem description];
		self.navigationItem.title = self.detailItem;
	}
	
	UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTouched:)];
	self.navigationItem.rightBarButtonItem = actionButton;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
	
	[self.view addSubview:self.listItemTextView];
	self.navigationController.navigationBar.tintColor = [[UIColor black] colorForCompanyName:_detailItem];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(saveList)
												 name:UIApplicationWillResignActiveNotification object:nil];
	_isKeyboardShowing = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self saveList];
}

- (void)saveList {
	[[ALUDataManager sharedDataManager] saveList:self.listItemTextView.text withTitle:_detailItem];
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
	
	self.listItemTextView.frame = CGRectMake(borderWidth, 0.0f, kViewControllerWidth - borderWidth * 2.0f, kViewControllerHeight - borderWidth * 2.0f);
	self.listItemTextView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth, 0.0f, borderWidth, 0.0f);
	self.listItemTextView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth, -borderWidth * 2.0f, -borderWidth, -borderWidth);
}

- (UITextView *)listItemTextView {
	if (!_listItemTextView) {
		_listItemTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kViewControllerWidth, kViewControllerHeight)];
		_listItemTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
		_listItemTextView.keyboardType = UIKeyboardTypeAlphabet;
		_listItemTextView.text = [[ALUDataManager sharedDataManager] listWithTitle:_detailItem];
		_listItemTextView.tintColor = [UIColor appColor];
		_listItemTextView.clipsToBounds = NO;
		
		if (_currentFontSize == 0 || _tempFontSize == 0) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			_currentFontSize = [defaults floatForKey:fontSizeKey];
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
		
		[_listItemTextView setFont:[UIFont boldSystemFontOfSize:_tempFontSize]];
		
		UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
		[_listItemTextView addGestureRecognizer:pinch];

		if (_listItemTextView.text.length == 0) {
			[_listItemTextView becomeFirstResponder];
		}
	}
	
	return _listItemTextView;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
	NSDictionary *info = [aNotification userInfo];
	CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth, 0.0, kbSize.height, 0.0);
	self.listItemTextView.contentInset = contentInsets;
	self.listItemTextView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth, -borderWidth, kbSize.height, -borderWidth);
	
	// If active text field is hidden by keyboard, scroll it so it's visible
	// Your app might not need or want this behavior.
	CGRect aRect = self.view.frame;
	aRect.size.height -= kbSize.height;
	if (!CGRectContainsPoint(aRect, self.listItemTextView.frame.origin) ) {
		[self.listItemTextView scrollRectToVisible:self.listItemTextView.frame animated:YES];
	}
	
	_isKeyboardShowing = YES;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)aNotification {
	self.listItemTextView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth, 0.0f, borderWidth, 0.0f);
	self.listItemTextView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth, -borderWidth * 2.0f, -borderWidth, -borderWidth);
	
	_isKeyboardShowing = YES;
}

#pragma mark - Pinch/Rotate Gesture

- (void)pinch:(UIPinchGestureRecognizer *)sender {
	if (sender.scale > 1) {
		_tempFontSize = _currentFontSize + sender.scale;
		[self.listItemTextView setFont:[UIFont systemFontOfSize:_tempFontSize]];
	} else if (sender.scale < 1) {
		_tempFontSize = _currentFontSize - (1/sender.scale);
		[self.listItemTextView setFont:[UIFont systemFontOfSize:_tempFontSize]];
	}
	
	if (sender.state == UIGestureRecognizerStateEnded) {
		_currentFontSize = _tempFontSize;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setFloat:_tempFontSize forKey:fontSizeKey];
	}
}

#pragma mark - Action Button

- (void)actionButtonTouched:(id)sender {
	UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.listItemTextView.text] applicationActivities:nil];
	activityVC.excludedActivityTypes = @[]; //Exclude whichever aren't relevant
	[self presentViewController:activityVC animated:YES completion:nil];
}


@end
