//
//  ALUSettingsView.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/24/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUSettingsView.h"
#import "NKFColor.h"
#import "NKFColor+AppColors.h"
#import "NKFColor+Companies.h"
#import "UIImage+ImageEffects.h"
#import "ALUTableViewCell.h"
#import "ALUDataManager.h"
#import "UIColor+AppColors.h"
#import "NGAParallaxMotion.h"

#define kScreenWidth (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight (([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)

@implementation ALUSettingsView {
	NSDictionary *_settingsTitles;
	BOOL _isShowing;
	UIImageView *_blurredImageView;
	NSMutableArray *_blurredImageViews;
    UIView *_coverUpView;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		_blurredImageViews = [[NSMutableArray alloc] init];
		self.layer.cornerRadius = 5.0f;
		self.clipsToBounds = YES;
        _coverUpView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScreenWidth + kScreenHeight, kScreenHeight + kScreenWidth)];
        _coverUpView.backgroundColor = [NKFColor white];
        self.parallaxIntensity = (kScreenWidth + kScreenHeight) / 100.0f;
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self addSubview:self.settingsTableView];
	[self insertSubview:self.headerToolbar aboveSubview:self.settingsTableView];
	self.settingsTableView.frame = self.bounds;
	self.headerToolbar.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 44.0f);
	
	for (UIView *subview in _blurredImageViews) {
		subview.frame = subview.superview.bounds;
	}
}


#pragma mark - Subviews

- (UIToolbar *)headerToolbar {
	if (!_headerToolbar) {
		_headerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 44.0f)];
		UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
		fixedSpace.width = 10.0f;
		
		UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithTitle:self.listName style:UIBarButtonItemStylePlain target:self action:@selector(rename)];
		titleItem.tintColor = (self.listColor) ? self.listColor :[NKFColor appColor];
        if ([titleItem.tintColor isLighterThan:0.5f]) {
            if (!self.listName) {
                titleItem.tintColor = [NKFColor appColor];
                self.doneButton.tintColor = [NKFColor appColor];
            } else {
                NSArray *potentialColors = [NKFColor colorsForCompanyName:self.listName];
                for (int i = 0; i < potentialColors.count && [titleItem.tintColor isLighterThan:0.5f]; i++) {
                    NKFColor *color = [potentialColors objectAtIndex:i];
                    titleItem.tintColor = color;
                    self.doneButton.tintColor = color;
                }
                
                if ([titleItem.tintColor isLighterThan:0.5f]) {
                    titleItem.tintColor = [NKFColor appColor];
                    self.doneButton.tintColor = [NKFColor appColor];
                }
            }
        }
		
		[_headerToolbar setItems:@[fixedSpace, titleItem, self.flexibleSpace, self.doneButton, fixedSpace]];
	}
	
	return _headerToolbar;
}

- (UIBarButtonItem *)doneButton {
	if (!_doneButton) {
		_doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTouched:)];
		_doneButton.tintColor = (self.listColor) ? self.listColor :[NKFColor appColor];
	}
	
	return _doneButton;
}

- (UIBarButtonItem *)flexibleSpace {
	return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
}

- (UITableView *)settingsTableView {
	if (!_settingsTableView) {
		_settingsTableView = [[UITableView alloc] initWithFrame:self.bounds
                                                          style:UITableViewStyleGrouped];
		_settingsTableView.contentInset = UIEdgeInsetsMake(self.headerToolbar.frame.size.height,
                                                           0.0f,
                                                           0.0f,
                                                           0.0f);
		_settingsTableView.scrollIndicatorInsets = _settingsTableView.contentInset;
		_settingsTableView.delegate = self;
		_settingsTableView.dataSource = self;
		[_settingsTableView registerClass:[ALUTableViewCell class]
                   forCellReuseIdentifier:@"SettingsTableViewCell"];
	}
	
	return _settingsTableView;
}

#pragma mark - Table View Buttons

- (UISwitch *)listModeSwitch {
	if (!_listModeSwitch) {
		_listModeSwitch = [[UISwitch alloc] init];
		_listModeSwitch.onTintColor = (self.listColor) ? self.listColor : [NKFColor appColor];
        
        if ([_listModeSwitch.onTintColor isLighterThan:0.75f]) {
            if (!self.listName) {
                _listModeSwitch.onTintColor = [NKFColor appColor];
            } else {
                NSArray *potentialColors = [NKFColor colorsForCompanyName:self.listName];
                for (int i = 0; i < potentialColors.count && [_listModeSwitch.onTintColor isLighterThan:0.75f]; i++) {
                    NKFColor *color = [potentialColors objectAtIndex:i];
                    _listModeSwitch.onTintColor = color;
                }
                
                if ([_listModeSwitch.onTintColor isLighterThan:0.75f]) {
                    _listModeSwitch.onTintColor = [NKFColor appColor];
                }
            }
        }

        
		_listModeSwitch.on = [[ALUDataManager sharedDataManager] listModeForListTitle:self.listName];
		[_listModeSwitch addTarget:self action:@selector(switchTouched:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return _listModeSwitch;
}

- (UISwitch *)showListIconSwitch {
	if (!_showListIconSwitch) {
		_showListIconSwitch = [[UISwitch alloc] init];
		_showListIconSwitch.onTintColor = (self.listColor) ? self.listColor :[NKFColor appColor];
        
        if ([_showListIconSwitch.onTintColor isLighterThan:0.75f]) {
            if (!self.listName) {
                _showListIconSwitch.onTintColor = [NKFColor appColor];
            } else {
                NSArray *potentialColors = [NKFColor colorsForCompanyName:self.listName];
                for (int i = 0; i < potentialColors.count && [_showListIconSwitch.onTintColor isLighterThan:0.75f]; i++) {
                    NKFColor *color = [potentialColors objectAtIndex:i];
                    _showListIconSwitch.onTintColor = color;
                }
                
                if ([_showListIconSwitch.onTintColor isLighterThan:0.75f]) {
                    _showListIconSwitch.onTintColor = [NKFColor appColor];
                }
            }
        }
        
		_showListIconSwitch.on = [[ALUDataManager sharedDataManager] showImageForListTitle:self.listName];
		[_showListIconSwitch addTarget:self action:@selector(switchTouched:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return _showListIconSwitch;
}


#pragma mark - Private Properties

- (void)setSettingsTitles:(NSDictionary *)settingsTitles {
	_settingsTitles = settingsTitles;
	[self.settingsTableView reloadData];
}


#pragma mark - Button Actions

- (void)doneButtonTouched:(id)sender {
	[self hide];
}


#pragma mark - Table View Cell Accessory View Actions

- (void)switchTouched:(UISwitch *)switchTouched {
	if ([switchTouched isEqual:self.listModeSwitch]) {
		[[ALUDataManager sharedDataManager] setListMode:switchTouched.on forListTitle:self.listName];
		if ([self.delegateSettings respondsToSelector:@selector(listModeChanged)]) {
			[self.delegateSettings listModeChanged];
		}
	} else if ([switchTouched isEqual:self.showListIconSwitch]) {
		[[ALUDataManager sharedDataManager] setShowImage:switchTouched.on forListTitle:self.listName];
		if ([self.delegateSettings respondsToSelector:@selector(showListIconChanged)]) {
			[self.delegateSettings showListIconChanged];
		}
	} else {
		DLog(@"Switch not recognized");
	}
}


#pragma mark - Hide / Show

- (void)hide {
	_isShowing = NO;
	NSTimeInterval animationDuration = 0.35f;
	[self removeBlurredViews:animationDuration];
	[UIView animateWithDuration:animationDuration
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _blurredImageView.alpha = 0.0f;
						 self.center = CGPointMake(self.center.x,
                                                   kScreenHeight + self.bounds.size.height * 2.0f);
					 } completion:^(BOOL finished) {
                         self.hidden = YES;
						 [[ALUDataManager sharedDataManager] setMenuShowing:NO];
					 }];
}

- (void)show {
	[[ALUDataManager sharedDataManager] setMenuShowing:YES];
    self.hidden = NO;
	NSTimeInterval animationDuration = 0.35f;
	[self staggeredBlurDuration:animationDuration];
	
	if (_isShowing) {
		return;
	} else {
		_isShowing = YES;
	}
	
	
	while (self.frame.size.height > 600.0f) {
		self.frame = CGRectInset(self.frame, 0.0f, kScreenHeight * 0.01f);
	}
	while (self.frame.size.width > 450.0f) {
		self.frame = CGRectInset(self.frame, kScreenWidth * 0.01f, 0.0f);
	}
	
	
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        self.center = CGPointMake(kScreenWidth * 0.5f,
                                  kScreenHeight + self.bounds.size.height * 2.0f);
    } else {
        self.center = CGPointMake(kScreenHeight * 0.5f,
                                  kScreenHeight + self.bounds.size.height * 2.0f);
    }
    
	[self.superview bringSubviewToFront:self];
	[self becomeFirstResponder];
    
    CGPoint center = self.center;
    CGRect frame = self.frame;
    while (frame.size.height > self.superview.frame.size.height) {
        frame.size.height *= 0.9f;
        frame.size.width *= 1.1f;
    }
    while (frame.size.width > self.superview.frame.size.width) {
        frame.size.width *= 0.9f;
        frame.size.height *= 1.1f;
    }
    self.frame = frame;
    center.x = self.superview.center.x;
    self.center = center;
    
    // moves view down proportionate to the status bar to accomodate for in-call status bar
    CGPoint finalCenter = self.superview.center;
    finalCenter.y += kStatusBarHeight * 0.5f;
	
	[UIView animateWithDuration:animationDuration
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 self.center = finalCenter;
					 } completion:^(BOOL finished) {
						 
					 }];
}

- (BOOL)isShowing {
	return _isShowing;
}

- (void)staggeredBlurDuration:(NSTimeInterval)duration {
	float maxBlur = 7.5f;
	float iterations = 50.0f;
	float maxIterationsPerSecond = 60.0f;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float maxIterationsTotal = [defaults floatForKey:@"maxIterationsTotalKey"];
    if (maxIterationsTotal == 0) {
        maxIterationsTotal = 1.0f;
    }
    
	float minIterations = 1.0f;
	if (duration * maxIterationsPerSecond < iterations) {
		iterations = duration * maxIterationsPerSecond;
	}
	
    if (iterations > maxIterationsTotal) {
        iterations = maxIterationsTotal;
    }

    if (iterations < minIterations) {
        iterations = minIterations;
    }
    
    NSDate *beforeDate = [NSDate date];
	for (float i = 1.0f; i <= iterations; i++) {
		CGRect screenCaptureRect = [UIScreen mainScreen].bounds;
		UIView *viewWhereYouWantToScreenCapture = [[UIApplication sharedApplication] keyWindow];
		
		//screen capture code
		UIGraphicsBeginImageContextWithOptions(screenCaptureRect.size, NO, [UIScreen mainScreen].scale);
		[viewWhereYouWantToScreenCapture drawViewHierarchyInRect:screenCaptureRect afterScreenUpdates:NO];
		UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		//blur code
		UIColor *tintColor = [[self.listColor darkenColorBy:0.72f] colorWithAlphaComponent:0.5f * (i / iterations)];
		UIImage *blurredImage = [capturedImage applyBlurWithRadius:(maxBlur * i / iterations)
                                                         tintColor:tintColor
                                             saturationDeltaFactor:1.2f
                                                         maskImage:nil];
		//or use [capturedImage applyLightAffect] but I thought that was too much for me
		
		UIImageView *blurredImageView = [[UIImageView alloc] initWithImage:blurredImage];
		
		[_blurredImageViews addObject:blurredImageView];
		blurredImageView.alpha = 0.0f;
	}
	
	for (float i = 1.0f; i <= iterations && i - 1 < _blurredImageViews.count; i++) {
		__weak UIImageView *blurredImageView = [_blurredImageViews objectAtIndex:i - 1];
		[UIView animateWithDuration:(duration / iterations)
							  delay:(duration / iterations * (i - 1))
							options:UIViewAnimationOptionCurveLinear
						 animations:^{
							 [[[UIApplication sharedApplication] keyWindow] addSubview:self];
							 [self.superview insertSubview:blurredImageView
                                              belowSubview:self];
							 blurredImageView.alpha = 1.0f;
						 } completion:^(BOOL finished) {
							 
						 }];
	}
    
    NSDate *afterDate = [NSDate date];
    
    NSTimeInterval totalTimeTranspired = [afterDate timeIntervalSinceDate:beforeDate];
    
    NSTimeInterval tooLongToWaitTime = 0.22f;
    NSTimeInterval maxTimeToWaitForSingleBlur = 0.4f;
    NSTimeInterval reasonableTimeToWait = 0.18f;
    
    if (totalTimeTranspired > tooLongToWaitTime) {
        if (totalTimeTranspired < maxTimeToWaitForSingleBlur && iterations > minIterations) {
            [defaults setFloat:(iterations - 1) forKey:@"maxIterationsTotalKey"];
            DLog(@"Decreasing the number of blur transitions to improve transition time when showing the settings view %f \t\t%d", totalTimeTranspired, (int)maxIterationsTotal);
        } else {
            DLog(@"We're a little behind now and there's not much that can be done...unfortunately %f", totalTimeTranspired);
        }
    } else if (totalTimeTranspired < reasonableTimeToWait) {
        [defaults setFloat:(iterations + 1) forKey:@"maxIterationsTotalKey"];
        DLog(@"Increasing the number of blur transitions to improve the appearance of the settings view %f \t\t%f", totalTimeTranspired, maxIterationsTotal);
    } else {
//        DLog(@"We're good %f \t\t%f", totalTimeTranspired, maxIterationsTotal);
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addCoverUpView];
    });
}

- (void)addCoverUpView {
    _coverUpView.hidden = NO;
    
    if (_coverUpView.gestureRecognizers.count == 0) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [_coverUpView addGestureRecognizer:tap];
    }
    
    [self.presentingViewController.view addSubview:_coverUpView];
}


- (void)tapped {
    if (self.isShowing && !self.isHidden) {
        DLog(@"Hiding from tap!");
        [self hide];
    }
}

- (void)removeBlurredViews:(NSTimeInterval)duration {
    _coverUpView.hidden = YES;
	float iterations = (float)_blurredImageViews.count;
	for (float i = iterations - 1; i >= 0 && i < _blurredImageViews.count; i--) {
		__weak UIImageView *blurredImageView = [_blurredImageViews objectAtIndex:i];
		[UIView animateWithDuration:(duration / iterations)
							  delay:(duration / iterations * (iterations - i - 1))
							options:UIViewAnimationOptionCurveLinear
						 animations:^{
							 [[[UIApplication sharedApplication] keyWindow] addSubview:self];
							 blurredImageView.alpha = 0.0f;
						 } completion:^(BOOL finished) {
							 
						 }];
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	    [self resetBlurredViews];
	});
}

- (void)resetBlurredViews {
	_blurredImageView = [_blurredImageViews lastObject];
    [_blurredImageViews removeObject:_blurredImageView];
    
    for (UIImageView *blurredImageView in _blurredImageViews) {
        [blurredImageView removeFromSuperview];
    }
	
	[_blurredImageViews removeAllObjects];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _settingsTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *settingsForSection = [_settingsTitles objectForKey:[_settingsTitles.allKeys objectAtIndex:section]];
	return settingsForSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
	
	if (!cell) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ALUTableViewCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	
	NSArray *settingsForSection = [_settingsTitles objectForKey:[self tableView:tableView titleForHeaderInSection:indexPath.section]];
	
	cell.textLabel.text = [settingsForSection objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
	
	if ([[cell.textLabel.text lowercaseString] containsString:@"list mode"] && ![[cell.textLabel.text lowercaseString] containsString:@"remove"]) {
		cell.accessoryView = self.listModeSwitch;
	} else if ([[cell.textLabel.text lowercaseString] containsString:@"show list icon"]) {
		cell.accessoryView = self.showListIconSwitch;
	} else {
		cell.accessoryView = nil;
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [_settingsTitles.allKeys objectAtIndex:section];
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	NSString *lowercaseCellText = [cell.textLabel.text lowercaseString];
    NSString *lowercaseSectionText = [[self tableView:self.settingsTableView titleForHeaderInSection:indexPath.section] lowercaseString];
	
	if ([lowercaseCellText containsString:@"take photo"]) {
		[self takePhoto];
	} else if ([lowercaseCellText containsString:@"choose photo"]) {
		[self pickPhoto];
	} else if ([lowercaseCellText containsString:@"use web icon"]) {
		[self useWebIcon];
    } else if ([lowercaseCellText containsString:@"remove list mode number"]) {
        [self removeListNumbers];
	} else if ([lowercaseCellText containsString:@"rename"]) {
		[self rename];
	} else if ([lowercaseCellText containsString:@"alphabet"]) {
		[self alphabetize];
    } else if ([lowercaseCellText containsString:@"send email"]) {
        [self sendEmail];
	} else if ([lowercaseCellText containsString:@"remove location"]) {
		[self removeLocation];
    } else if ([lowercaseSectionText containsString:@"location"]) {
        [self selectLocation];
    } else if ([lowercaseCellText containsString:@"contact"]) {
        [self selectContact];
    } else if ([lowercaseCellText containsString:@"text for icon"]) {
        [self showEmojiController];
	} else if ([lowercaseCellText containsString:@"draw"]) {
		[self showDrawingController];
	} else {
		DLog(@"Selected %@", cell.textLabel.text);
	}
}

#pragma mark - Settings Actions

- (void)takePhoto {
	if ([self.delegateSettings respondsToSelector:@selector(takePhoto)]) {
		[self.delegateSettings takePhoto];
	} else {
		DLog(@"delegateSettings not set. Does not respond to \"takePhoto\"");
	}
}

- (void)pickPhoto {
	if ([self.delegateSettings respondsToSelector:@selector(pickPhoto)]) {
		[self.delegateSettings pickPhoto];
	} else {
		DLog(@"delegateSettings not set. Does not respond to \"pickPhoto\"");
	}
}

- (void)useWebIcon {
    if ([self.delegateSettings respondsToSelector:@selector(useWebIcon)]) {
        [self.delegateSettings useWebIcon];
        [self hide];
    } else {
        DLog(@"delegateSettings not set. Does not respond to \"useWebIcon\"");
    }
}

- (void)removeListNumbers {
	if ([self.delegateSettings respondsToSelector:@selector(removeListModeNumbersCurrentSelectedTextRange:replacementText:)]) {
		[self.delegateSettings removeListModeNumbersCurrentSelectedTextRange:NSMakeRange(0, 0) replacementText:@""];
		[self hide];
	}
}

- (void)rename {
	if ([self.delegateSettings respondsToSelector:@selector(listRenameSelected)]) {
		[self.delegateSettings listRenameSelected];
		[self hide];
	}
}

- (void)alphabetize {
	if ([self.delegateSettings respondsToSelector:@selector(alphabetize)]) {
		[self.delegateSettings alphabetize];
		[self hide];
	}
}

- (void)sendEmail {
    if ([self.delegateSettings respondsToSelector:@selector(sendEmail)]) {
        [self.delegateSettings sendEmail];
        [self hide];
    }
}

- (void)selectLocation {
    if ([self.delegateSettings respondsToSelector:@selector(selectLocation)]) {
        [self.delegateSettings selectLocation];
        [self hide];
    }
}

- (void)selectContact {
    if ([self.delegateSettings respondsToSelector:@selector(selectContact)]) {
        [self.delegateSettings selectContact];
        [self hide];
    }
}

- (void)removeLocation {
	if (self.listName) {
		[[ALUDataManager sharedDataManager] removeReminderForListTitle:self.listName];
	} else {
		DLog(@"There's no listName!");
	}
	[self hide];
}

- (void)showEmojiController {
    if ([self.delegateSettings respondsToSelector:@selector(showEmojiView)]) {
        [self.delegateSettings showEmojiView];
        [self hide];
    }
}

- (void)showDrawingController {
	if ([self.delegateSettings respondsToSelector:@selector(showDrawingView)]) {
		[self.delegateSettings showDrawingView];
		[self hide];
	}
}


@end
