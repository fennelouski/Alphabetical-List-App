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

#define kScreenWidth (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight (([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)

#define DEFAULT_FONT_SIZE ((((kScreenHeight + kScreenWidth) * 0.02f) < 18.0f) ? 18.0f : (((kScreenHeight + kScreenWidth) * 0.02f) > 25.0f) ? 25.0f : ((kScreenHeight + kScreenWidth) * 0.02f))

#define kViewControllerWidth self.view.frame.size.width
#define kViewControllerHeight self.view.frame.size.height

static NSString * const fontSizeKey = @"This is my font size Key and don't forget that I like Tacos";

static CGFloat const maxFontSize = 60.0f;

static CGFloat const minFontSize = 6.0f;

static NSString * const numericDelimeter = @".) ";

@interface DetailViewController ()

@property (nonatomic, strong) UIBarButtonItem *actionButton;

@property (nonatomic, strong) UIButton *titleViewButton;

@end

@implementation DetailViewController {
	CGFloat _tempFontSize, _currentFontSize;
	BOOL _isKeyboardShowing;
	UITextField *_alertTextField;
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
	_isKeyboardShowing = NO;
	
	[self performSelector:@selector(updateViewConstraints) withObject:self afterDelay:0.5f];
	[self findTextView];
	
	[self checkForActionButtonAbility];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setNeedsStatusBarAppearanceUpdate];
	
	[self.splitViewController setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self saveList];
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
	
	self.listItemTextView.frame = CGRectMake(10.0f, self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth, kViewControllerWidth - borderWidth * 2.0f, kViewControllerHeight - (self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + borderWidth));
}

- (UITextView *)listItemTextView {
	if (!_listItemTextView) {
		_listItemTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kViewControllerWidth, kViewControllerHeight)];
		_listItemTextView.tag = 17;
		_listItemTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
		_listItemTextView.keyboardType = UIKeyboardTypeAlphabet;
		_listItemTextView.text = [[ALUDataManager sharedDataManager] listWithTitle:_detailItem];
		_listItemTextView.tintColor = [NKFColor appColor];
		_listItemTextView.clipsToBounds = NO;
		_listItemTextView.delegate = self;
		_listItemTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, -borderWidth * 2.0f, 0.0f, -borderWidth);
		
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

#pragma mark - Button Actions

- (void)titleTapped:(id)sender {
	UIAlertController *titleAlertController = [UIAlertController alertControllerWithTitle:_detailItem
																				  message:nil
																		   preferredStyle:UIAlertControllerStyleActionSheet];
	
	titleAlertController.popoverPresentationController.sourceView = self.titleViewButton;
	UIButton *button = (UIButton *)sender;
	if ([button isKindOfClass:[UIButton class]]) {
		titleAlertController.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width * 0.2f,
																				   self.navigationController.navigationBar.frame.size.height * 0.85f,
																				   0.0f,
																				   0.0f);
	}
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
														   style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction *action) {
															 
														 }];
	[titleAlertController addAction:cancelAction];
	
	if (![[ALUDataManager sharedDataManager] listModeForListTitle:_detailItem]) {
		UIAlertAction *enableListModeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Enable List Mode", @"Add a number at the beginning of each line to keep track of items in the list/note")
																	   style:UIAlertActionStyleDefault
																	 handler:^(UIAlertAction *action) {
																		 [[ALUDataManager sharedDataManager] setListMode:YES
																											forListTitle:_detailItem];
																		 [self updateTextWithLineNumbersRange:self.listItemTextView.selectedRange replacementText:@""];
																		 [self performSelector:@selector(delayedUpdateOfText) withObject:self afterDelay:0.1f];
																	 }];
		[titleAlertController addAction:enableListModeAction];
		
		UIAlertAction *removeListModeNumbersAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Remove List Numbers", @"If present, remove the numbers at the beginning of each line")
																			  style:UIAlertActionStyleDefault
																			handler:^(UIAlertAction *action) {
																				[self removeListModeNumbersRange:self.listItemTextView.selectedRange replacementText:@""];
																			}];
		[titleAlertController addAction:removeListModeNumbersAction];
	} else {
		UIAlertAction *disableListModeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Disable List Mode", @"Disable adding numbers at the beginning of each line")
																	   style:UIAlertActionStyleDefault
																	 handler:^(UIAlertAction *action) {
																		 [[ALUDataManager sharedDataManager] setListMode:NO
																											forListTitle:_detailItem];
																		 [self performSelector:@selector(delayedUpdateOfText) withObject:self afterDelay:0.1f];
																	 }];
		[titleAlertController addAction:disableListModeAction];
	}
	
	UIAlertAction *renameAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rename List", @"change the title of the list/note")
														   style:UIAlertActionStyleDestructive
														 handler:^(UIAlertAction *action) {
															 [self performSelector:@selector(renameList) withObject:self afterDelay:0.1f];
														 }];
	[titleAlertController addAction:renameAction];
	
	[self presentViewController:titleAlertController
					   animated:YES
					 completion:^{
						   
					   }];
}

- (void)delayedUpdateOfText {
	if (!self.listItemTextView) {
		NSLog(@"What is wrong with this?");
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
																 [self performSelector:@selector(listAlreadyExistsWarning:) withObject:_alertTextField.text afterDelay:0.1f];
															 } else {
																 [[ALUDataManager sharedDataManager] removeList:_detailItem];
																 _detailItem = _alertTextField.text;
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
	NSLog(@"%@", warningMessage);
	
	UIAlertController *warningController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Note already exists with the title", nil), warningMessage]
																			   message:NSLocalizedString(@"Each list title needs to be unique.", nil)
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
    
    if (_tempFontSize > maxFontSize) {
        _tempFontSize = maxFontSize;
    } else if (_tempFontSize < minFontSize) {
        _tempFontSize = minFontSize;
    }
    
    [self.listItemTextView setFont:[UIFont systemFontOfSize:_tempFontSize]];
	
	if (sender.state == UIGestureRecognizerStateEnded) {
		_currentFontSize = _tempFontSize;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setFloat:_tempFontSize forKey:fontSizeKey];
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
	}
    
    if ([text isEqualToString:@"\n"] && [[ALUDataManager sharedDataManager] listModeForListTitle:_detailItem]) {
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
					NSLog(@"This will cause a problem if left without checking.");
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
					NSLog(@"This will cause a problem if left without checking.");
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
		
		if ([[self.listItemTextView.text substringWithRange:NSMakeRange(textRange.location, 1)] containsString:@" "]) {
			textRange.location += 1;
		}
		
		self.listItemTextView.selectedRange = textRange;
	}
}

- (void)removeListModeNumbersRange:(NSRange)range replacementText:(NSString *)text {
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
					NSLog(@"This will cause a problem if left without checking.");
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
					NSLog(@"This will cause a problem if left without checking.");
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
		
		if ([[self.listItemTextView.text substringWithRange:NSMakeRange(textRange.location, 1)] containsString:@" "]) {
			textRange.location += 1;
		}
		
		self.listItemTextView.selectedRange = textRange;
	}
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
	
	[self performSelector:@selector(checkForActionButtonAbility) withObject:self afterDelay:0.1f];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
	if ([(NKFColor *)self.navigationController.navigationBar.barTintColor isDark]) {
		return UIStatusBarStyleLightContent;
	}
	
	return UIStatusBarStyleLightContent;
}

@end
