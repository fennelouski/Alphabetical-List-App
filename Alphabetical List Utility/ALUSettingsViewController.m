//
//  ALUSettingsViewController.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/24/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUSettingsViewController.h"
#import "NKFColor.h"
#import "NKFColor+AppColors.h"
#import "NKFColor+Companies.h"
#import "UIColor+AppColors.h"
#import "ALUDataManager.h"
#import "ALUServicePrivacy.h"
#import "ALUNoteCardView.h"

#pragma mark - Row model

// One row: a title, an SF Symbol, and what to do when it is tapped. Rows carry their own
// action so nothing has to match on display strings — titles are free to change.
@interface ALUSettingRow : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, strong) UIView *accessory;
@property (nonatomic, assign) BOOL disclosure;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, copy) dispatch_block_t action;
@end

@implementation ALUSettingRow

+ (instancetype)rowWithTitle:(NSString *)title symbol:(NSString *)symbol action:(dispatch_block_t)action {
	ALUSettingRow *row = [[ALUSettingRow alloc] init];
	row.title = title;
	row.symbol = symbol;
	row.action = action;
	return row;
}

@end

static NSDictionary *ALUSection(NSString *title, NSArray *rows) {
	return @{@"title": title ?: @"", @"rows": rows};
}


#pragma mark - Settings view controller

// Every page in the stack carries the same note state so it can build its rows and
// answer the controls on it.
@interface ALUSettingsViewController ()
@property (nonatomic, copy) NSString *listName;
@property (nonatomic, strong) UIColor *accentColor;
@property (nonatomic, assign) BOOL hasNoteText;
@property (nonatomic, weak) id <ALUSettingsViewDelegate> settingsDelegate;
@end

@implementation ALUSettingsViewController {
	NSArray *_sections;
	NSArray *(^_builder)(void);
}

+ (void)presentForListName:(NSString *)listName
                     color:(UIColor *)color
               hasNoteText:(BOOL)hasNoteText
                  delegate:(id <ALUSettingsViewDelegate>)delegate
                      from:(UIViewController *)presenter {
	ALUSettingsViewController *settings = [[ALUSettingsViewController alloc] initWithTitle:listName builder:nil];
	settings.listName = listName;
	settings.hasNoteText = hasNoteText;
	settings.settingsDelegate = delegate;
	settings.accentColor = [self readableAccentColor:color forListName:listName];

	__weak ALUSettingsViewController *weakSettings = settings;
	settings->_builder = ^NSArray *{ return [weakSettings mainSections]; };

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settings];
	navigationController.view.tintColor = settings.accentColor;
	navigationController.navigationBar.tintColor = settings.accentColor;
	navigationController.navigationBar.prefersLargeTitles = YES;
	navigationController.sheetPresentationController.detents = @[[UISheetPresentationControllerDetent largeDetent]];
	navigationController.sheetPresentationController.prefersGrabberVisible = YES;

	[presenter presentViewController:navigationController animated:YES completion:nil];
}

// The list color doubles as the tint, but a pale brand color is unreadable on white.
// Walk the note's other brand colors for a dark enough one, then fall back to the app color.
+ (UIColor *)readableAccentColor:(UIColor *)color forListName:(NSString *)listName {
	if (color && ![color isLighterThan:0.5f]) {
		return color;
	}

	for (NKFColor *candidate in [NKFColor colorsForCompanyName:listName]) {
		if (![candidate isLighterThan:0.5f]) {
			return candidate;
		}
	}

	return [NKFColor appColor];
}

- (instancetype)initWithTitle:(NSString *)title builder:(NSArray *(^)(void))builder {
	self = [super initWithStyle:UITableViewStyleInsetGrouped];

	if (self) {
		self.title = title;
		_builder = [builder copy];
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;

	if (!self.navigationController.viewControllers.firstObject ||
	    self.navigationController.viewControllers.firstObject == self) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
		                                                                                      target:self
		                                                                                      action:@selector(done)];
	}

	[self reload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[ALUDataManager sharedDataManager] setMenuShowing:YES];
	[self reload];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	if (!self.presentingViewController) {
		[[ALUDataManager sharedDataManager] setMenuShowing:NO];
	}
}

// Every page is built from the same state, so a change on one (a switch, a chosen style)
// has to refresh the pages behind it too.
- (void)reload {
	NSArray *pages = self.navigationController.viewControllers ?: @[self];

	for (ALUSettingsViewController *page in pages) {
		if ([page isKindOfClass:[ALUSettingsViewController class]] && page->_builder) {
			page->_sections = page->_builder();
			[page.tableView reloadData];
		}
	}
}

- (void)done {
	[self dismissViewControllerAnimated:YES completion:nil];
}

// Actions that hand off to the note (photo pickers, the map, the drawing view) need the
// sheet out of the way first, so they run once it has finished dismissing.
- (void)dismissThen:(dispatch_block_t)action {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:action];
}

- (void)pushPageTitled:(NSString *)title builder:(NSArray *(^)(void))builder {
	ALUSettingsViewController *page = [[ALUSettingsViewController alloc] initWithTitle:title builder:builder];
	page.listName = self.listName;
	page.accentColor = self.accentColor;
	page.hasNoteText = self.hasNoteText;
	page.settingsDelegate = self.settingsDelegate;
	[self.navigationController pushViewController:page animated:YES];
}


#pragma mark - Pages

- (NSArray *)mainSections {
	ALUDataManager *dataManager = [ALUDataManager sharedDataManager];
	__weak typeof(self) weakSelf = self;

	// Rename, Insert Photo, and the Sort/Strip line actions live in the note's "…" overflow
	// menu — settings is for configuration, not one-shot actions on the note's contents.
	NSMutableArray *noteRows = [NSMutableArray array];
	if (self.hasNoteText) {
		[noteRows addObject:[ALUSettingRow rowWithTitle:@"Email This Note" symbol:@"envelope" action:^{
			[weakSelf dismissThen:^{ [weakSelf.settingsDelegate sendEmail]; }];
		}]];
	}

	BOOL numbered = [dataManager listModeForListTitle:self.listName];
	ALUSettingRow *numberedRow = [ALUSettingRow rowWithTitle:@"Numbered List" symbol:@"list.number" action:nil];
	numberedRow.accessory = [self switchOn:numbered action:@selector(listModeSwitched:)];

	NSArray *listRows = @[numberedRow];

	ALUSettingRow *iconRow = [ALUSettingRow rowWithTitle:@"Note Icon" symbol:@"photo.circle" action:^{
		[weakSelf pushPageTitled:@"Note Icon" builder:^NSArray *{ return [weakSelf iconSections]; }];
	}];
	iconRow.detail = [dataManager showImageForListTitle:self.listName] ? @"Shown" : @"Hidden";
	iconRow.disclosure = YES;

	NSString *style = [dataManager cardStyleForListTitle:self.listName];
	ALUSettingRow *styleRow = [ALUSettingRow rowWithTitle:@"Card Style" symbol:@"paintpalette" action:^{
		[weakSelf pushPageTitled:@"Card Style" builder:^NSArray *{ return [weakSelf cardStyleSections]; }];
	}];
	styleRow.detail = [ALUNoteCardView backgroundColorForStyle:style] ? style : @"None";
	styleRow.disclosure = YES;

	ALUSettingRow *locationRow = [ALUSettingRow rowWithTitle:@"Location Reminder" symbol:@"mappin.and.ellipse" action:^{
		[weakSelf pushPageTitled:@"Location Reminder" builder:^NSArray *{ return [weakSelf locationSections]; }];
	}];
	locationRow.detail = [self currentLocationName] ?: @"Off";
	locationRow.disclosure = YES;

	NSMutableArray *sections = [NSMutableArray array];
	if (noteRows.count) {
		[sections addObject:ALUSection(@"Note", noteRows)];
	}
	[sections addObject:ALUSection(@"List", listRows)];
	[sections addObject:ALUSection(@"Appearance", @[iconRow, styleRow])];
	[sections addObject:ALUSection(@"Reminders", @[locationRow])];
    ALUSettingRow *privacyRow = [ALUSettingRow rowWithTitle:@"Privacy Policy" symbol:@"hand.raised" action:^{
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://nathanfennel.com/a2z-notes/privacy.html"] options:@{} completionHandler:nil];
    }];
    ALUSettingRow *servicesRow = [ALUSettingRow rowWithTitle:@"Online Services & Credits" symbol:@"info.circle" action:^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Online services"
            message:@"Online icons come from recognized websites, which receive your IP address and may log the request. Note text is not uploaded.\n\nDaily Bible notes contain a link to the passage on Bible.com. It opens outside AtoZ; AtoZ does not download or insert Bible text. Websites you open follow their own privacy policies.\n\nLogos belong to their respective owners."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Read Daily Passage" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [UIApplication.sharedApplication openURL:ALUDailyBiblePassageURL() options:@{} completionHandler:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil]];
        [weakSelf presentViewController:alert animated:YES completion:nil];
    }];
    [sections addObject:ALUSection(@"Privacy", @[privacyRow, servicesRow])];
	return sections;
}

- (NSArray *)iconSections {
	ALUDataManager *dataManager = [ALUDataManager sharedDataManager];
	__weak typeof(self) weakSelf = self;

	ALUSettingRow *showRow = [ALUSettingRow rowWithTitle:@"Show Icon" symbol:@"eye" action:nil];
	showRow.accessory = [self switchOn:[dataManager showImageForListTitle:self.listName] action:@selector(showIconSwitched:)];

	if (![dataManager showImageForListTitle:self.listName]) {
		return @[ALUSection(@"", @[showRow])];
	}

	NSMutableArray *sourceRows = [NSMutableArray array];

	// One editor now covers every source — photo, camera, text/emoji, drawing, AI
	// generation — plus image effects, so the old per-source rows collapse to this.
	[sourceRows addObject:[ALUSettingRow rowWithTitle:@"Edit Icon…" symbol:@"paintbrush.pointed" action:^{
		[weakSelf.settingsDelegate editIcon];
	}]];

    ALUSettingRow *webRow = [ALUSettingRow rowWithTitle:@"Use Web Icon" symbol:@"globe" action:nil];
    webRow.accessory = [self switchOn:[dataManager useWebIconForListTitle:self.listName] action:@selector(webIconSwitched:)];
    [sourceRows addObject:webRow];
    [sourceRows addObject:[ALUSettingRow rowWithTitle:@"About Online Icons" symbol:@"info.circle" action:^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Online icons"
            message:@"For recognized titles, AtoZ requests favicon.ico directly from the matching website. The website receives your IP address and may retain request information under its privacy policy. Note text is not sent. Turning this off stops future lookups for this note; an icon already saved stays on your device. Logos belong to their respective owners."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil]];
        [weakSelf presentViewController:alert animated:YES completion:nil];
    }]];

	return @[ALUSection(@"", @[showRow]), ALUSection(@"Icon Source", sourceRows)];
}

- (NSArray *)cardStyleSections {
	ALUDataManager *dataManager = [ALUDataManager sharedDataManager];
	__weak typeof(self) weakSelf = self;

	// A note with no style set reads as "None", the first entry in the list.
	NSString *currentStyle = [dataManager cardStyleForListTitle:self.listName];
	BOOL hasStyle = [ALUNoteCardView backgroundColorForStyle:currentStyle] != nil;
	if (!hasStyle) {
		currentStyle = [[ALUNoteCardView cardStyleNames] firstObject];
	}

	NSMutableArray *styleRows = [NSMutableArray array];

	for (NSString *styleName in [ALUNoteCardView cardStyleNames]) {
		ALUSettingRow *row = [ALUSettingRow rowWithTitle:styleName symbol:nil action:^{
			[dataManager setCardStyle:styleName forListTitle:weakSelf.listName];
			[weakSelf.settingsDelegate cardStyleChanged];
			[weakSelf reload];
		}];
		row.checked = [styleName isEqualToString:currentStyle];
		[styleRows addObject:row];
	}

	if (!hasStyle) {
		return @[ALUSection(@"Style", styleRows)];
	}

	ALUSettingRow *listIntensity = [ALUSettingRow rowWithTitle:@"In the List" symbol:@"square.stack" action:nil];
	listIntensity.accessory = [self sliderWithValue:[dataManager cardStyleListIntensityForListTitle:self.listName]
	                                         action:@selector(listIntensityChanged:)];

	ALUSettingRow *editorIntensity = [ALUSettingRow rowWithTitle:@"In the Editor" symbol:@"textformat.size" action:nil];
	editorIntensity.accessory = [self sliderWithValue:[dataManager cardStyleEditorIntensityForListTitle:self.listName]
	                                           action:@selector(editorIntensityChanged:)];

	return @[ALUSection(@"Style", styleRows),
	         ALUSection(@"Strength", @[listIntensity, editorIntensity])];
}

- (NSArray *)locationSections {
	__weak typeof(self) weakSelf = self;
	NSString *locationName = [self currentLocationName];

	NSMutableArray *rows = [NSMutableArray array];
	[rows addObject:[ALUSettingRow rowWithTitle:(locationName ? @"Change Location" : @"Choose a Location")
	                                     symbol:@"map"
	                                     action:^{
		[weakSelf.settingsDelegate selectLocation];
	}]];

	if (locationName) {
		[rows addObject:[ALUSettingRow rowWithTitle:@"Remove Reminder" symbol:@"trash" action:^{
			[[ALUDataManager sharedDataManager] removeReminderForListTitle:weakSelf.listName];
			[weakSelf reload];
		}]];
	}

	return @[ALUSection(locationName ?: @"Remind me at a place", rows)];
}

// The stored name is sometimes a placeholder rather than a real address.
- (NSString *)currentLocationName {
	ALUDataManager *dataManager = [ALUDataManager sharedDataManager];

	if (![dataManager geolocationReminderExistsForTitle:self.listName]) {
		return nil;
	}

	NSString *name = [dataManager geolocationNameForTitle:self.listName];
	if (!name.length ||
	    [[name lowercaseString] containsString:@"(null)"] ||
	    [[name lowercaseString] containsString:@"add location"]) {
		return nil;
	}

	return name;
}


#pragma mark - Accessory controls

- (UISwitch *)switchOn:(BOOL)on action:(SEL)action {
	UISwitch *toggle = [[UISwitch alloc] init];
	toggle.on = on;
	toggle.onTintColor = self.accentColor;
	[toggle addTarget:self action:action forControlEvents:UIControlEventValueChanged];
	return toggle;
}

- (UISlider *)sliderWithValue:(CGFloat)value action:(SEL)action {
	UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 31.0f)];
	slider.value = value;
	[slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
	return slider;
}

- (void)listModeSwitched:(UISwitch *)toggle {
	[[ALUDataManager sharedDataManager] setListMode:toggle.on forListTitle:self.listName];
	[self.settingsDelegate listModeChanged];
	[self reload];
}

- (void)showIconSwitched:(UISwitch *)toggle {
	[[ALUDataManager sharedDataManager] setShowImage:toggle.on forListTitle:self.listName];
	[self.settingsDelegate showListIconChanged];
	[self reload];
}

- (void)webIconSwitched:(UISwitch *)toggle {
    [[ALUDataManager sharedDataManager] setUseWebIcon:toggle.on forListTitle:self.listName];
    [self.settingsDelegate showListIconChanged];
    [self reload];
}

- (void)listIntensityChanged:(UISlider *)slider {
	[[ALUDataManager sharedDataManager] setCardStyleListIntensity:slider.value forListTitle:self.listName];
	[self.settingsDelegate cardStyleChanged];
}

- (void)editorIntensityChanged:(UISlider *)slider {
	[[ALUDataManager sharedDataManager] setCardStyleEditorIntensity:slider.value forListTitle:self.listName];
	[self.settingsDelegate cardStyleChanged];
}


#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[_sections objectAtIndex:section] objectForKey:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = [[_sections objectAtIndex:section] objectForKey:@"title"];
	return title.length ? title : nil;
}

- (ALUSettingRow *)rowAtIndexPath:(NSIndexPath *)indexPath {
	return [[[_sections objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SettingsCell"];
	}

	ALUSettingRow *row = [self rowAtIndexPath:indexPath];

	UIListContentConfiguration *content = [UIListContentConfiguration valueCellConfiguration];
	content.text = row.title;
	content.secondaryText = row.detail;
	content.image = row.symbol ? [UIImage systemImageNamed:row.symbol] : nil;
	content.imageProperties.tintColor = self.accentColor;
	cell.contentConfiguration = content;

	cell.accessoryView = row.accessory;
	if (row.accessory) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else if (row.disclosure) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (row.checked) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	cell.selectionStyle = row.action ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	ALUSettingRow *row = [self rowAtIndexPath:indexPath];
	if (row.action) {
		row.action();
	}
}

@end
