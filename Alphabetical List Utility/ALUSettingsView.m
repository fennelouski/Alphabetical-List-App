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
#import "UIImage+ImageEffects.h"
#import "ALUTableViewCell.h"
#import "ALUDataManager.h"
#import "UIColor+AppColors.h"

#define kScreenWidth (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight (([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)

@implementation ALUSettingsView {
	NSDictionary *_settingsTitles;
	BOOL _isShowing;
	UIImageView *_blurredImageView;
	NSMutableArray *_blurredImageViews;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		_blurredImageViews = [[NSMutableArray alloc] init];
		self.layer.cornerRadius = 5.0f;
		self.clipsToBounds = YES;
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
		_settingsTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
		_settingsTableView.contentInset = UIEdgeInsetsMake(self.headerToolbar.frame.size.height, 0.0f, 0.0f, 0.0f);
		_settingsTableView.scrollIndicatorInsets = _settingsTableView.contentInset;
		_settingsTableView.delegate = self;
		_settingsTableView.dataSource = self;
		[_settingsTableView registerClass:[ALUTableViewCell class] forCellReuseIdentifier:@"SettingsTableViewCell"];
	}
	
	return _settingsTableView;
}

#pragma mark - Table View Buttons

- (UISwitch *)listModeSwitch {
	if (!_listModeSwitch) {
		_listModeSwitch = [[UISwitch alloc] init];
		_listModeSwitch.onTintColor = (self.listColor) ? self.listColor :[NKFColor appColor];
		_listModeSwitch.on = [[ALUDataManager sharedDataManager] listModeForListTitle:self.listName];
		[_listModeSwitch addTarget:self action:@selector(switchTouched:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return _listModeSwitch;
}

- (UISwitch *)showListIconSwitch {
	if (!_showListIconSwitch) {
		_showListIconSwitch = [[UISwitch alloc] init];
		_showListIconSwitch.onTintColor = (self.listColor) ? self.listColor :[NKFColor appColor];
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
		NSLog(@"Switch not recognized");
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
						 self.center = CGPointMake(self.center.x, kScreenHeight + self.bounds.size.height * 2.0f);
					 } completion:^(BOOL finished) {
						 
					 }];
}

- (void)show {
	NSTimeInterval animationDuration = 0.35f;
	[self staggeredBlurDuration:animationDuration];
	
	if (_isShowing) {
		return;
	} else {
		_isShowing = YES;
	}
	
	self.center = CGPointMake(self.center.x, kScreenHeight + self.bounds.size.height * 2.0f);
	[self.superview bringSubviewToFront:self];
	[self becomeFirstResponder];
	
	[UIView animateWithDuration:animationDuration
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 self.center = self.superview.center;
					 } completion:^(BOOL finished) {
						 
					 }];
}

- (BOOL)isShowing {
	return _isShowing;
}

- (void)staggeredBlurDuration:(NSTimeInterval)duration {
	float maxBlur = 7.5f;
	float iterations = 50.0f;
	float maxIterationsPerSecond = 20.0f;
	float minIterations = 5.0f;
	if (duration * maxIterationsPerSecond < iterations) {
		iterations = duration * maxIterationsPerSecond;
	}
	
	if (iterations < minIterations) {
		iterations = minIterations;
	}
	
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
		UIImage *blurredImage = [capturedImage applyBlurWithRadius:(maxBlur * i / iterations) tintColor:tintColor saturationDeltaFactor:1.2 maskImage:nil];
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
							 [self.superview insertSubview:blurredImageView belowSubview:self];
							 blurredImageView.alpha = 1.0f;
						 } completion:^(BOOL finished) {
							 
						 }];
	}
}

- (void)removeBlurredViews:(NSTimeInterval)duration {
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
	
	[self performSelector:@selector(resetBlurredViews) withObject:self afterDelay:duration];
}

- (void)resetBlurredViews {
	_blurredImageView = [_blurredImageViews lastObject];
	
	for (int i = 0; i + 1 < _blurredImageViews.count; i++) {
		UIImageView *blurredImageView = [_blurredImageViews objectAtIndex:i];
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
		NSLog(@"Cell manufacturing!");
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ALUTableViewCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	
	NSArray *settingsForSection = [_settingsTitles objectForKey:[_settingsTitles.allKeys objectAtIndex:indexPath.section]];
	
	cell.textLabel.text = [settingsForSection objectAtIndex:indexPath.row];
	
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
	
	if ([lowercaseCellText containsString:@"take photo"]) {
		[self takePhoto];
	} else if ([lowercaseCellText containsString:@"choose photo"]) {
		[self pickPhoto];
	} else if ([lowercaseCellText containsString:@"remove list mode number"]) {
		[self removeListNumbers];
	} else if ([lowercaseCellText containsString:@"rename"]) {
		[self rename];
	} else if ([lowercaseCellText containsString:@"alphabet"]) {
		[self alphabetize];
	} else {
		NSLog(@"Selected %@", cell.textLabel.text);
	}
}

#pragma mark - Settings Actions

- (void)takePhoto {
	if ([self.delegateSettings respondsToSelector:@selector(takePhoto)]) {
		[self.delegateSettings takePhoto];
	} else {
		NSLog(@"delegateSettings not set. Does not respond to \"takePhoto\"");
	}
}

- (void)pickPhoto {
	if ([self.delegateSettings respondsToSelector:@selector(pickPhoto)]) {
		[self.delegateSettings pickPhoto];
	} else {
		NSLog(@"delegateSettings not set. Does not respond to \"pickPhoto\"");
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

@end
