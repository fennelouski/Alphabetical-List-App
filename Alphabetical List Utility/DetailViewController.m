//
//  DetailViewController.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "DetailViewController.h"
#import "ALUDataManager.h"
#import "NKFColor.h"
#import "NKFColor+Companies.h"
#import "NKFColor+AppColors.h"
#import "UIColor+AppColors.h"
#import "ALUMapViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "ALUSettingsView.h"
#import "ALUEmojiImageViewController.h"
#import "ALUDrawingViewController.h"

#define kScreenWidth (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight (([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)

#define kViewControllerWidth self.view.frame.size.width
#define kViewControllerHeight self.view.frame.size.height

static CGFloat const ALUDetailViewControllerMaxFontSize = 60.0f;

static CGFloat const ALUDetailViewControllerMinFontSize = 6.0f;

static NSString * const numericDelimeter = @".) ";

@interface DetailViewController () <ALUSettingsViewDelegate, ALUEmojiImageViewControllerDelegate, ALUDrawingViewControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *actionButton;

@property (nonatomic, strong) UIButton *titleViewButton;

@end

@implementation DetailViewController {
	CGFloat _tempFontSize, _currentFontSize;
	BOOL _isKeyboardShowing;
	UITextField *_alertTextField;
	ALUSettingsView *_settingsView;
    CGSize _previousScreenSize;
    NSDate *_lastOrientationChangeCheckDate;
    UIDeviceOrientation _lastDeviceOrientation;
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
		
		if (self.listItemTextView.text.length > 0 && _detailItem && [[ALUDataManager sharedDataManager] listWithTitle:_detailItem]) {
			[self.actionButton setEnabled:YES];
		} else {
			[self.actionButton setEnabled:NO];
		}
		
		if ([[ALUDataManager sharedDataManager] listModeForListTitle:_detailItem]) {
			[self updateTextWithLineNumbersRange:NSMakeRange(0, 0) replacementText:@""];
		}
	}
	
	self.navigationItem.rightBarButtonItem = self.actionButton;
	
	[self.navigationItem setTitleView:self.titleViewButton];
	[self.titleViewButton setTitleColor:[[NKFColor colorForCompanyName:_detailItem] oppositeBlackOrWhite] forState:UIControlStateNormal];
	[self.titleViewButton setTitle:_detailItem forState:UIControlStateNormal];
	self.navigationController.title = @"";
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	if (!_detailItem) {
		[self setDetailItem:[[[ALUDataManager sharedDataManager] lists] firstObject]];
	}
	
	[self configureView];
	
	[self.view addSubview:self.listItemTextView];
	self.navigationController.navigationBar.tintColor = [NKFColor colorForCompanyName:_detailItem];
	self.navigationController.navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(saveList)
												 name:UIApplicationWillResignActiveNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification
											   object:nil];
    _previousScreenSize = CGSizeMake(kScreenWidth, kScreenHeight);
	
	_isKeyboardShowing = NO;

	[self updateViewConstraints];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	    [self updateViewConstraints];
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	    [self updateViewConstraints];
	});
	[self findTextView];
	
	[self checkForActionButtonAbility];
    [self cameraWarning];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setNeedsStatusBarAppearanceUpdate];
	
	[self.splitViewController setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.navigationController.navigationBar.barTintColor) {
        self.navigationController.navigationBar.barTintColor = [NKFColor appColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self saveList];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:self];
}

- (void)findTextView {
	for (UIView *subview in self.view.subviews) {
		if ([subview isEqual:self.listItemTextView]) {
			[self updateViewConstraints];
		}
	}
}

- (void)saveList {
	NSString *list = self.listItemTextView.text;
	[[ALUDataManager sharedDataManager] saveList:list withTitle:_detailItem];
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
    
    if (!self.listItemTextView) {
        DLog(@"Missing text view");
    }
    
    for (UITextView *textView in self.view.subviews) {
        if ([textView respondsToSelector:@selector(text)] && [textView.text isEqualToString:[[ALUDataManager sharedDataManager] listWithTitle:_detailItem]]) {
            if (textView.frame.size.width < self.view.frame.size.width) {
                textView.frame = CGRectMake(textView.frame.origin.x,
                                            textView.frame.origin.y,
                                            self.view.frame.size.width,
                                            self.view.frame.size.height);
            }
        }
    }
	
	self.listItemTextView.frame = CGRectMake(borderWidth,
											 self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth,
											 kViewControllerWidth - borderWidth * 2.0f,
											 kViewControllerHeight - (self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth));
	
	for (UITextView *subview in self.view.subviews) {
		if ([subview isKindOfClass:[UITextView class]]) {
			if (![subview isEqual:self.listItemTextView] && [subview respondsToSelector:@selector(text)]) {
				subview.frame = CGRectMake(borderWidth,
										   self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth,
										   kViewControllerWidth - borderWidth * 2.0f,
										   kViewControllerHeight - (self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth));
			}
		}
	}

    [self checkForNavBarColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkForNavBarColor];
    });
}

- (void)checkForNavBarColor {
    if (!self.navigationController.navigationBar.barTintColor ||
        !self.navigationController.navigationBar.tintColor) {
        [self resetNavBarColors];
    } else if ([self.navigationController.navigationBar.barTintColor isLight] &&
               [self.navigationController.navigationBar.tintColor isLight]) {
        [self resetNavBarColors];
    }
	
	
	if ([[ALUDataManager sharedDataManager] noteHasBeenSelectedOnce]) {
		return;
	}
}

- (void)resetNavBarColors {
    DLog(@"Resetting nav bar colors");
    self.navigationController.navigationBar.barTintColor = [NKFColor appColor];
    self.navigationController.navigationBar.tintColor = [NKFColor whiteColor];
    self.navigationController.navigationController.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    self.navigationController.navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
}

- (void)orientationChanged:(NSNotification *)notification{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if ((((_lastDeviceOrientation == UIDeviceOrientationPortrait ||
         _lastDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) &&
        (orientation == UIDeviceOrientationPortrait ||
         orientation == UIDeviceOrientationPortraitUpsideDown)) ||
        ((_lastDeviceOrientation == UIDeviceOrientationLandscapeLeft ||
          _lastDeviceOrientation == UIDeviceOrientationLandscapeRight) &&
         (orientation == UIDeviceOrientationLandscapeLeft ||
          orientation == UIDeviceOrientationLandscapeRight))) ||
        orientation == 0 ||
        orientation == 6) {
//        DLog(@"Orientation: %zd\t\tLast Orientation: %zd", orientation, _lastDeviceOrientation);
//        DLog(@"Not actually rotating: %f\t\t%f", kScreenWidth - _previousScreenSize.width, kScreenHeight - _previousScreenSize.height);
        return;
    } else if (orientation == UIDeviceOrientationFaceDown ||
			   orientation == UIDeviceOrientationFaceUp) {
		DLog(@"Orientation change is face up/down");
		return;
	}
    
    if ([_lastOrientationChangeCheckDate timeIntervalSinceNow] < -3.0f) {
        DLog(@"Recent orientation check\t%f", [_lastOrientationChangeCheckDate timeIntervalSinceNow]);
    }
    
    _lastDeviceOrientation = orientation;
    _lastOrientationChangeCheckDate = [NSDate date];
    
    _previousScreenSize = CGSizeMake(kScreenWidth, kScreenHeight);
	
//	_settingsView.frame = CGRectOffset(CGRectInset(self.view.bounds, kScreenWidth * 0.01f, kScreenHeight * 0.15f), 0.0f, kScreenHeight);
	
    [self updateViewConstraints];
}


#pragma mark - Subviews

- (UITextView *)listItemTextView {
	if (!_listItemTextView) {
		_listItemTextView = [[UITextView alloc] initWithFrame:CGRectInset(self.view.bounds, borderWidth, 0.0f)];
		_listItemTextView.tag = 17;
		_listItemTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
		_listItemTextView.keyboardType = UIKeyboardTypeAlphabet;
		_listItemTextView.text = [[ALUDataManager sharedDataManager] listWithTitle:_detailItem];
		_listItemTextView.tintColor = [NKFColor appColor];
		_listItemTextView.clipsToBounds = NO;
		_listItemTextView.delegate = self;
		_listItemTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, -borderWidth * 2.0f, 0.0f, -borderWidth);
		
		if (_currentFontSize == 0 || _tempFontSize == 0) {
			_currentFontSize = [[ALUDataManager sharedDataManager] currentFontSize];
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

- (UIBarButtonItem *)actionButton {
	if (!_actionButton) {
		_actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTouched:)];
		_actionButton.enabled = NO;
	}
	
	return _actionButton;
}

- (UIButton *)titleViewButton {
	if (!_titleViewButton) {
		_titleViewButton = [[UIButton alloc] initWithFrame:self.navigationController.navigationBar.bounds];
		[_titleViewButton addTarget:self action:@selector(titleTapped:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return _titleViewButton;
}

- (ALUSettingsView *)settingsView {
	if (!_settingsView) {
		_settingsView = [[ALUSettingsView alloc] initWithFrame:CGRectInset(self.view.bounds, kViewControllerWidth * 0.05f, kViewControllerHeight * 0.05f)];
		_settingsView.listColor = self.navigationController.navigationBar.barTintColor;
		_settingsView.delegateSettings = self;
        _settingsView.presentingViewController = self.parentViewController;
        while (_settingsView.presentingViewController.parentViewController) {
            _settingsView.presentingViewController = _settingsView.presentingViewController.parentViewController;
        }
	}
	
	return _settingsView;
}

#pragma mark - Button Actions

- (void)titleTapped:(id)sender {
    if ([self settingsView].isShowing) {
        return;
    }
    
	if (![self settingsView].superview) {
		[self.view addSubview:[self settingsView]];
	}
	
	NSMutableDictionary *settingsTitles = [[NSMutableDictionary alloc] init];
	
    
	if (![[ALUDataManager sharedDataManager] listModeForListTitle:_detailItem]) {
		NSArray *listModeOptions = @[@"List Mode", @"Remove List Mode Numbers"];
		[settingsTitles setObject:listModeOptions forKey:@"List Mode"];
	} else {
		NSArray *listModeOptions = @[@"List Mode", @"Alphabetize List"];
		[settingsTitles setObject:listModeOptions forKey:@"List Mode"];
	}
	
	if ([[ALUDataManager sharedDataManager] showImageForListTitle:_detailItem]) {
		NSMutableArray *iconOptions = [[NSMutableArray alloc] initWithArray:@[@"Show list icon"]];
		
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [iconOptions addObject:@"Take Photo for Icon"];
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [iconOptions addObject:@"Choose Photo for Icon"];
        }
        
        [iconOptions addObject:@"Type text for Icon"];
		
		[iconOptions addObject:@"Draw Icon"];
		
        if ([[ALUDataManager sharedDataManager] useWebIconForListTitle:_detailItem]) {
            DLog(@"Use web icon added");
        } else {
            [iconOptions addObject:@"Use Web Icon"];
        }
		
		[settingsTitles setObject:iconOptions forKey:@"Icon"];
	} else {
		NSMutableArray *iconOptions = [[NSMutableArray alloc] initWithArray:@[@"Show list icon"]];
		[settingsTitles setObject:iconOptions forKey:@"Icon"];
	}
	
	NSMutableArray *renameOption = [[NSMutableArray alloc] initWithArray:@[@"Rename Note"]];
	[settingsTitles setObject:renameOption forKey:@"Rename Note"];
    
    if ([self.listItemTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        [settingsTitles setObject:@[@"Send email"] forKey:@"Messaging"];
    }
    
    if ([[ALUDataManager sharedDataManager] geolocationReminderExistsForTitle:_detailItem]) {
        NSString *addressString = [[ALUDataManager sharedDataManager] geolocationNameForTitle:_detailItem];
		if ([[addressString lowercaseString] rangeOfString:@"(null)"].location != NSNotFound) {
			[settingsTitles setObject:@[@"Add Location Reminder"] forKey:@"Location"];
		} else if ([[addressString lowercaseString] rangeOfString:@"add location"].location != NSNotFound){
			[settingsTitles setObject:@[addressString] forKey:@"Location"];
		} else {
			[settingsTitles setObject:@[addressString, @"Remove Location Reminder"] forKey:@"Location"];
		}
    } else {
        [settingsTitles setObject:@[@"Add Location Reminder"] forKey:@"Location"];
    }
    
	[self settingsView].listName = _detailItem;
	[[self settingsView] setSettingsTitles:settingsTitles];
	[[self settingsView] show];
	[self.listItemTextView resignFirstResponder];
}

- (void)delayedUpdateOfText {
	if (!self.listItemTextView) {
		DLog(@"What is wrong with this?");
	}
	
	if ([[ALUDataManager sharedDataManager] listModeForListTitle:_detailItem]) {
		[self updateTextWithLineNumbersRange:self.listItemTextView.selectedRange replacementText:@""];
	} else {
//		[self removeListModeNumbersRange:self.listItemTextView.selectedRange replacementText:@""];
	}
}

- (void)renameList {
	UIAlertController *titleController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Change Note Title",nil)
																			 message:NSLocalizedString(@"Please give your Note a title", nil)
																	  preferredStyle:UIAlertControllerStyleAlert];
	[titleController addTextFieldWithConfigurationHandler:^(UITextField * __nonnull textField) {
		textField.placeholder = NSLocalizedString(@"Note Title", nil);
		textField.keyboardAppearance = UIKeyboardAppearanceLight;
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		textField.autocorrectionType = UITextAutocorrectionTypeYes;
		textField.text = _detailItem;
		_alertTextField = textField;
	}];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
														   style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * __nonnull action) {
															 
														 }];
	[titleController addAction:cancelAction];
	
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Change Name", nil)
													   style:UIAlertActionStyleDestructive
													 handler:^(UIAlertAction * __nonnull action) {
														 if (_alertTextField.text.length > 0) {
															 if ([[ALUDataManager sharedDataManager] addList:_alertTextField.text]) {
																 NSString *textFieldText = _alertTextField.text;
																 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
																	 [self listAlreadyExistsWarning:textFieldText];
																 });
															 } else {
																 if ([[ALUDataManager sharedDataManager] geolocationReminderExistsForTitle:_detailItem]) {
																	 ALUPointAnnotation *annotation = [[ALUDataManager sharedDataManager] annotationForTitle:_detailItem];
																	 [[ALUDataManager sharedDataManager] removeReminderForListTitle:_detailItem];
																	 [[ALUDataManager sharedDataManager] setCoordinate:annotation.coordinate
																												radius:annotation.radius
																										  forListTitle:[_alertTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
																 }
																 
																 [[ALUDataManager sharedDataManager] removeList:_detailItem];
																 _detailItem = [_alertTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
																 [[ALUDataManager sharedDataManager] saveList:self.listItemTextView.text
																									withTitle:_detailItem];
																 [self configureView];
																 
																 if ([self.delegate respondsToSelector:@selector(reloadList)]) {
																	 [self.delegate reloadList];
																 }
															 }
														 }
													 }];
	[titleController addAction:okAction];
	
	[self presentViewController:titleController animated:YES completion:^{
		
	}];
}

- (void)listAlreadyExistsWarning:(NSString *)warningMessage {
	DLog(@"- (void)listAlreadyExistsWarning:(NSString *)warningMessage: %@", warningMessage);
	
	UIAlertController *warningController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Note already exists with the title", nil), warningMessage]
																			   message:NSLocalizedString(@"Each note title needs to be unique.", nil)
																		preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction *action) {
														 
													 }];
	[warningController addAction:okAction];
	
	[self presentViewController:warningController
					   animated:YES
					 completion:^{
						 
					 }];
}

#pragma mark - Memory warning

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Notifications

- (void)keyboardWasShown:(NSNotification*)aNotification {
	self.listItemTextView.frame = CGRectMake(borderWidth, 0.0f, kViewControllerWidth - borderWidth * 2.0f, kViewControllerHeight - (self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth));
	NSDictionary *info = [aNotification userInfo];
	CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth, 0.0, kbSize.height, 0.0);
	self.listItemTextView.contentInset = contentInsets;
	self.listItemTextView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight, -borderWidth * 2.0f, -borderWidth, -borderWidth);
	
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
	self.listItemTextView.frame = CGRectMake(borderWidth, 0.0f, kViewControllerWidth - borderWidth * 2.0f, kViewControllerHeight - borderWidth);
	self.listItemTextView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth, 0.0f, borderWidth, 0.0f);
	self.listItemTextView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight, -borderWidth * 2.0f, -borderWidth, -borderWidth);
	
	_isKeyboardShowing = YES;
}

#pragma mark - Pinch/Rotate Gesture

- (void)pinch:(UIPinchGestureRecognizer *)sender {
	if (sender.scale > 1) {
		_tempFontSize = _currentFontSize + sender.scale;
    } else if (sender.scale < 1) {
		_tempFontSize = _currentFontSize - (1/sender.scale);
	}
    
    if (_tempFontSize > ALUDetailViewControllerMaxFontSize) {
        _tempFontSize = ALUDetailViewControllerMaxFontSize;
    } else if (_tempFontSize < ALUDetailViewControllerMinFontSize) {
        _tempFontSize = ALUDetailViewControllerMinFontSize;
    }
    
    if (!self.listItemTextView.superview) {
        UIView *viewToShowTextOn = self.view;
        
        [viewToShowTextOn addSubview:self.listItemTextView];
        
        if (self.listItemTextView.contentInset.top > 0.0f) {
            self.listItemTextView.contentInset = UIEdgeInsetsMake(0.0f,
                                                                  self.listItemTextView.contentInset.left,
                                                                  self.listItemTextView.contentInset.bottom,
                                                                  self.listItemTextView.contentInset.right);
        }
    }
    
    [self.listItemTextView setFont:[UIFont systemFontOfSize:_tempFontSize]];
	
	if (sender.state == UIGestureRecognizerStateEnded) {
		_currentFontSize = _tempFontSize;
        [[ALUDataManager sharedDataManager] saveAdjustedFontSize:_currentFontSize];
    }
}

#pragma mark - Action Button

- (void)actionButtonTouched:(id)sender {
	if (self.listItemTextView.text.length > 0) {
		UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.listItemTextView.text] applicationActivities:nil];
		activityVC.popoverPresentationController.barButtonItem = self.actionButton;
		activityVC.excludedActivityTypes = @[UIActivityTypePostToFlickr,
                                             UIActivityTypePostToTwitter,
                                             UIActivityTypePostToVimeo,
                                             UIActivityTypePostToWeibo,
                                             UIActivityTypeSaveToCameraRoll]; //Exclude whichever activities aren't relevant
		
		[self presentViewController:activityVC animated:YES completion:nil];
	}
}


#pragma mark - Text View Delegate


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if (![textView isEqual:self.listItemTextView]) {
		self.listItemTextView.backgroundColor = [NKFColor randomColor];
		[self.listItemTextView removeFromSuperview];
		self.listItemTextView = textView;
	} else if ([text isEqualToString:@"\n"] && [[ALUDataManager sharedDataManager] listModeForListTitle:_detailItem]) {
        [self updateTextWithLineNumbersRange:range replacementText:text];
		return NO;
    }
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
	if (textView.text.length > 0) {
		if (![textView isEqual:self.listItemTextView]) {
			self.listItemTextView.backgroundColor = [NKFColor randomColor];
			[self.listItemTextView removeFromSuperview];
			self.listItemTextView = textView;
		}
		
		[self.actionButton setEnabled:YES];
	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if (![textView isEqual:self.listItemTextView]) {
		self.listItemTextView.backgroundColor = [NKFColor randomColor];
		[self.listItemTextView removeFromSuperview];
		self.listItemTextView = textView;
		[self updateViewConstraints];
	}
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self settingsView].isShowing) {
        return NO;
    }
    
    return YES;
}


#pragma mark - Line Numbers

- (void)updateTextWithLineNumbersRange:(NSRange)range replacementText:(NSString *)text {
	NSInteger cursorLine = [[self.listItemTextView.text substringToIndex:range.location] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].count;
	NSString *updatedText = [self.listItemTextView.text stringByReplacingCharactersInRange:range withString:text];
    NSArray *lines = [updatedText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSMutableArray *filteredLines = [[NSMutableArray alloc] init];
    NSMutableString *finalString = [[NSMutableString alloc] initWithCapacity:updatedText.length + lines.count * 5];
	
	NSInteger skippedLineCount = 0;
	
	int lineNumber = 0;
	for (NSString *line in lines) {
		if (line.length > 0 || cursorLine == lineNumber) {
			[filteredLines addObject:line];
		} else if (lineNumber <= cursorLine) {
			skippedLineCount++;
		}
		
		lineNumber++;
	}
	
    lineNumber = 1;
    for (NSString *line in filteredLines) {
        NSInteger breakLocation = [line rangeOfString:numericDelimeter].location;
		
		BOOL skipLine = NO;
		
        if (breakLocation < 4 && breakLocation != NSNotFound) {
			if (breakLocation > line.length) {
				breakLocation = line.length;
			}
			
            NSString *numericSubstring = [line substringToIndex:breakLocation];
            if ([numericSubstring rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet] options:0 range:NSMakeRange(0, breakLocation)].location != NSNotFound) {
				if (line.length <= breakLocation + numericDelimeter.length) {
					DLog(@"This will cause a problem if left without checking.");
				} else {
					if ([line substringFromIndex:breakLocation + numericDelimeter.length].length > 0) {
						[finalString appendFormat:@"%d%@%@", lineNumber, numericDelimeter, [line substringFromIndex:breakLocation + numericDelimeter.length]];
					} else {
						skipLine = YES;
						
						if (lineNumber < cursorLine) {
							skippedLineCount++;
						}
					}
				}
            } else {
				if (line.length < breakLocation + numericDelimeter.length) {
					DLog(@"This will cause a problem if left without checking.");
				} else {
					if ([line substringFromIndex:breakLocation + numericDelimeter.length].length > 0) {
						[finalString appendFormat:@"%d%@%@", lineNumber, numericDelimeter, [line substringFromIndex:breakLocation + numericDelimeter.length]];
					} else {
						skipLine = YES;
						
						if (lineNumber < cursorLine) {
							skippedLineCount++;
						}
					}
				}
            }
        } else {
			if (line.length > 0 || lineNumber == cursorLine + 1 || lineNumber == cursorLine) {
				[finalString appendFormat:@"%d%@%@", lineNumber, numericDelimeter, line];
			}
        }
		
		if (!skipLine) {
			[finalString appendString:@"\n"];
			
			lineNumber++;
		}
    }
	
	if (range.location + 2 > self.listItemTextView.text.length) {
		self.listItemTextView.text = finalString;
		
		self.listItemTextView.selectedRange = NSMakeRange(self.listItemTextView.text.length - 1, 0);
	} else {
		self.listItemTextView.text = finalString;
		
		NSRange textRange = NSMakeRange(range.location + 4 + [NSString stringWithFormat:@"%zd", cursorLine].length - skippedLineCount * (4 + [NSString stringWithFormat:@"%zd", cursorLine + 1].length), range.length);
		
		if (self.listItemTextView.text.length > textRange.location) {
			if ([[self.listItemTextView.text substringWithRange:NSMakeRange(textRange.location, 1)] containsString:@" "]) {
				textRange.location += 1;
			}
		}
		
		self.listItemTextView.selectedRange = textRange;
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	    [self delayedScroll:@(NO)];
	});
}

- (void)delayedScroll:(NSNumber *)animated {
	CGRect rect = [self.listItemTextView caretRectForPosition:self.listItemTextView.selectedTextRange.end];
	[self.listItemTextView scrollRectToVisible:rect
									  animated:animated.boolValue];
	DLog(@"Scroll to %f", rect.origin.y);
}

- (void)removeListModeNumbersCurrentSelectedTextRange:(NSRange)range replacementText:(NSString *)text {
	NSInteger cursorLine = [[self.listItemTextView.text substringToIndex:range.location] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].count;
	NSString *updatedText = [self.listItemTextView.text stringByReplacingCharactersInRange:range withString:text];
	NSArray *lines = [updatedText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSMutableArray *filteredLines = [[NSMutableArray alloc] init];
	NSMutableString *finalString = [[NSMutableString alloc] initWithCapacity:updatedText.length + lines.count * 5];
	
	NSInteger skippedLineCount = 0;
	
	int lineNumber = 0;
	for (NSString *line in lines) {
		if (line.length > 0 || cursorLine == lineNumber) {
			[filteredLines addObject:line];
		} else if (lineNumber <= cursorLine) {
			skippedLineCount++;
		}
		
		lineNumber++;
	}
	
	lineNumber = 1;
	for (NSString *line in filteredLines) {
		NSInteger breakLocation = [line rangeOfString:numericDelimeter].location;
		
		BOOL skipLine = NO;
		
		if (breakLocation < 4 && breakLocation != NSNotFound) {
			if (breakLocation > line.length) {
				breakLocation = line.length;
			}
			
			NSString *numericSubstring = [line substringToIndex:breakLocation];
			if ([numericSubstring rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet] options:0 range:NSMakeRange(0, breakLocation)].location != NSNotFound) {
				if (line.length <= breakLocation + numericDelimeter.length) {
					DLog(@"This will cause a problem if left without checking.");
				} else {
					if ([line substringFromIndex:breakLocation + numericDelimeter.length].length > 0) {
						[finalString appendFormat:@"%@", [line substringFromIndex:breakLocation + numericDelimeter.length]];
					} else {
						skipLine = YES;
						
						if (lineNumber < cursorLine) {
							skippedLineCount++;
						}
					}
				}
			} else {
				if (line.length < breakLocation + numericDelimeter.length) {
					DLog(@"This will cause a problem if left without checking.");
				} else {
					if ([line substringFromIndex:breakLocation + numericDelimeter.length].length > 0) {
						[finalString appendFormat:@"%@", [line substringFromIndex:breakLocation + numericDelimeter.length]];
					} else {
						skipLine = YES;
						
						if (lineNumber < cursorLine) {
							skippedLineCount++;
						}
					}
				}
			}
		} else {
			if (line.length > 0 || lineNumber == cursorLine + 1 || lineNumber == cursorLine) {
				[finalString appendFormat:@"%@", line];
			}
		}
		
		if (!skipLine) {
			[finalString appendString:@"\n"];
			
			lineNumber++;
		}
	}
	
	if (range.location + 2 > self.listItemTextView.text.length) {
		self.listItemTextView.text = finalString;
		
		self.listItemTextView.selectedRange = NSMakeRange(self.listItemTextView.text.length - 1, 0);
	} else {
		self.listItemTextView.text = finalString;
		
		NSRange textRange = NSMakeRange(range.location + (numericDelimeter.length + 1) + [NSString stringWithFormat:@"%zd", cursorLine].length - skippedLineCount * ((numericDelimeter.length + 1) + [NSString stringWithFormat:@"%zd", cursorLine + 1].length), range.length);
		
		if (self.listItemTextView.text.length > textRange.location) {
			if ([[self.listItemTextView.text substringWithRange:NSMakeRange(textRange.location, 1)] containsString:@" "]) {
				textRange.location += 1;
			}
		}
		
		self.listItemTextView.selectedRange = textRange;
	}
}

- (void)alphabetizeList {
    [self removeListModeNumbersCurrentSelectedTextRange:self.listItemTextView.selectedRange replacementText:@""];
    NSArray *lines = [self.listItemTextView.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSArray *sortedLines = [lines sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.listItemTextView.text = [sortedLines componentsJoinedByString:@"\n"];
    [self updateTextWithLineNumbersRange:self.listItemTextView.selectedRange replacementText:@""];
}

#pragma mark - Check For Button Validation

- (void)checkForActionButtonAbility {
	if (self.listItemTextView.text.length > 0 && _detailItem && [[ALUDataManager sharedDataManager] listWithTitle:_detailItem]) {
		[self.actionButton setEnabled:YES];
	} else {
		if (!_detailItem) {
			[self.actionButton setEnabled:NO];
		} else if (![[ALUDataManager sharedDataManager] listWithTitle:_detailItem]) {
			[[ALUDataManager sharedDataManager] saveList:self.listItemTextView.text withTitle:_detailItem];
		} else {
			[self.actionButton setEnabled:NO];
		}
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	    [self checkForActionButtonAbility];
	});
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
	if ([(NKFColor *)self.navigationController.navigationBar.barTintColor isDark]) {
		return UIStatusBarStyleLightContent;
	}
	
	return UIStatusBarStyleLightContent;
}

#pragma mark - Camera

- (void)cameraWarning {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *noCameraAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"Device has no camera"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                         }];
        [noCameraAlert addAction:okAction];
        
        noCameraAlert.popoverPresentationController.sourceView = self.view;
        noCameraAlert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
        [self presentViewController:noCameraAlert animated:YES completion:^{
            
        }];
    }
}

#pragma mark - Photo Taking

- (void)takePhoto {
    DLog(@"Take Photo");
	
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		return;
	}
	
	[[self settingsView] hide];
	
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)pickPhoto {
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		return;
	}
	
	[[self settingsView] hide];
	
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = YES;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self presentViewController:picker animated:YES completion:NULL];
}

- (void)useWebIcon {
    [[ALUDataManager sharedDataManager] setUseWebIcon:YES forListTitle:_detailItem];
    [[ALUDataManager sharedDataManager] removeImageForCompanyName:_detailItem];
    if ([self.delegate respondsToSelector:@selector(reloadList)]) {
        [self.delegate reloadList];
    }
}

#pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [[ALUDataManager sharedDataManager] saveImage:chosenImage forCompanyName:_detailItem];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [[ALUDataManager sharedDataManager] setUseWebIcon:NO forListTitle:_detailItem];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Settings Delegate

- (void)showListIconChanged {
	DLog(@"List icon changed");
}

- (void)listModeChanged {
	[self configureView];
}

- (void)listRenameSelected {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	    [self renameList];
	});
}

- (void)alphabetize {
	[self alphabetizeList];
	[[ALUDataManager sharedDataManager] setAlphabetize:YES forListTitle:_detailItem];
}

- (void)sendEmail {
    [self showEmail:YES];
}

- (void)selectLocation {
    [[self settingsView] hide];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        if ([[[ALUDataManager sharedDataManager] locationManager] respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [[[ALUDataManager sharedDataManager] locationManager] requestAlwaysAuthorization];
        }
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        DLog(@"Ask user to grant location permission");
        return;
    } else {
        [[ALUDataManager sharedDataManager] locationManager];
    }
    
    DLog(@"Select Location");
    
    ALUMapViewController *mapViewController = [[ALUMapViewController alloc] init];
    mapViewController.title = _detailItem;
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)selectContact {
    DLog(@"Select Contact");

    CNContactStore *contactStore = [[CNContactStore alloc] init];

    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CNContactPickerViewController *contactPickerViewController = [[CNContactPickerViewController alloc] init];
                contactPickerViewController.delegate = self;
                [self presentViewController:contactPickerViewController animated:YES completion:nil];
            });
        } else {
            DLog(@"Contact access denied: %@", error);
        }
    }];
}

- (void)showEmojiView {
    ALUEmojiImageViewController *emojiViewController = [[ALUEmojiImageViewController alloc] init];
    emojiViewController.delegate = self;
	[self.navigationController pushViewController:emojiViewController animated:YES];
}

- (void)showDrawingView {
	ALUDrawingViewController *drawingViewController = [[ALUDrawingViewController alloc] init];
	drawingViewController.delegate = self;
	drawingViewController.currentColor = self.titleViewButton.titleLabel.textColor;
    
    if ([[ALUDataManager sharedDataManager] showImageForListTitle:_detailItem]) {
        UIImage *image = [[ALUDataManager sharedDataManager] imageForCompanyName:_detailItem];
        
        if (image) {
            [drawingViewController setBaseImage:image];
        }
    }
	
	[self.navigationController pushViewController:drawingViewController animated:YES];
}

#pragma mark - Messaging Delegate

- (void)showEmail:(BOOL)includeAttachments {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"%@\t\t%@", _detailItem, nowDateString];
    
    // Email Content
    NSMutableAttributedString *messageBody = [[NSMutableAttributedString alloc] initWithAttributedString:[self textViewAttributedString]];
    
    NSDictionary *documentAttributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSData *htmlData = [messageBody dataFromRange:NSMakeRange(0, messageBody.length)
                               documentAttributes:documentAttributes error:NULL];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:htmlString isHTML:YES];
    
    UIImage *companyImage = [[ALUDataManager sharedDataManager] imageForCompanyName:_detailItem];
    
    if (includeAttachments && companyImage && [[ALUDataManager sharedDataManager] showImageForListTitle:_detailItem]) {
        CGFloat compressionAmount = (companyImage.size.width > 1600.0f) ? 16.0f : companyImage.size.width / 100.0f;
        if (compressionAmount < 1.0f) {
            compressionAmount = 1.0f;
        }
        
        NSString *imageName = [[ALUDataManager sharedDataManager] companyNameURLStringForCompanyName:_detailItem];
        if (![[ALUDataManager sharedDataManager] useWebIconForListTitle:_detailItem]) {
            imageName = [NSString stringWithFormat:@"%@ Icon", _detailItem];
        }
        
        NSData *imageData = UIImageJPEGRepresentation(companyImage, compressionAmount);
        [mc addAttachmentData:imageData
                     mimeType:@"image/png"
                     fileName:imageName];
    }
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (NSAttributedString *)textViewAttributedString {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:[NKFColor attributedStringForCompanyName:_detailItem]];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n\n" attributes:@{}]];
    [attributedText appendAttributedString:self.listItemTextView.attributedText];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n" attributes:@{}]];
    return attributedText;
}

#pragma mark - Messaging Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Contact Delegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    DLog(@"Got a person %@", [self formattedNameForContact:contact]);
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    [picker dismissViewControllerAnimated:YES
                                     completion:^{
                                         DLog(@"Cancelled people picker");
                                     }];
}

- (NSString *)formattedNameForContact:(CNContact *)contact {
    NSMutableString *formattedName = [[NSMutableString alloc] init];

    [self conditionallyAppendString:contact.givenName toMutableString:formattedName];
    [self conditionallyAppendString:contact.nickname toMutableString:formattedName];
    [self conditionallyAppendString:contact.familyName toMutableString:formattedName];

    NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
    DLog(@"Name: %@", name);

    if (contact.emailAddresses.count > 0) {
        [formattedName appendString:@"\n"];
        [self conditionallyAppendString:name toMutableString:formattedName];
    }

    NSString *personId = contact.identifier;
    [formattedName appendString:@"\n"];
    [self conditionallyAppendString:personId toMutableString:formattedName];

    return formattedName;
}

- (void)conditionallyAppendString:(NSString *)string toMutableString:(NSMutableString *)mutableString {
    if (![string respondsToSelector:@selector(length)]) {
        DLog(@"This isn't right...%@\t\t\"%@\"", [string class], string);
        return;
    }
    
    if (![mutableString respondsToSelector:@selector(length)]) {
        DLog(@"This isn't right...mutable...%@\t\t\"%@\"", [string class], mutableString);
        return;
    }
    
    if (!string || string.length == 0 || !mutableString) {
        return;
    }
    
    if ([mutableString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [mutableString appendString:string];
        return;
    }
    
    [mutableString appendFormat:@" %@", string];
}


#pragma mark - Emoji Delegate

- (void)emojiImage:(UIImage *)image {
    if (image) {
        [[ALUDataManager sharedDataManager] saveImage:image forCompanyName:_detailItem];
        [[ALUDataManager sharedDataManager] setUseWebIcon:NO forListTitle:_detailItem];
    }
}

#pragma mark - Drawing Delegate

- (void)drawnImage:(UIImage *)image {
	if (image) {
		[[ALUDataManager sharedDataManager] saveImage:image forCompanyName:_detailItem];
		[[ALUDataManager sharedDataManager] setUseWebIcon:NO forListTitle:_detailItem];
	}
}

@end
