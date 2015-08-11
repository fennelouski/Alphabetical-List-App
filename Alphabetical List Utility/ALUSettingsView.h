//
//  ALUSettingsView.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/24/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALUSettingsViewDelegate <NSObject>

- (void)takePhoto;
- (void)pickPhoto;
- (void)useWebIcon;
- (void)removeListModeNumbersCurrentSelectedTextRange:(NSRange)range replacementText:(NSString *)text;
- (void)listModeChanged;
- (void)showListIconChanged;
- (void)listRenameSelected;
- (void)alphabetize;
- (void)sendEmail;
- (void)selectLocation;
- (void)selectContact;
- (void)showEmojiView;
- (void)showDrawingView;

@end

@interface ALUSettingsView : UIToolbar <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIToolbar *headerToolbar;

@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) UITableView *settingsTableView;

@property (nonatomic, strong) NSString *listName;

@property (nonatomic, strong) UIColor *listColor;

@property (nonatomic, strong) UIViewController *presentingViewController;

- (void)setSettingsTitles:(NSDictionary *)settingsTitles;


@property (nonatomic, strong) UISwitch *listModeSwitch;

@property (nonatomic, strong) UISwitch *showListIconSwitch;

@property (weak) id <ALUSettingsViewDelegate> delegateSettings;


- (void)hide;
- (void)show;
- (BOOL)isShowing;

@end
