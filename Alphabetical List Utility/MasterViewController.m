//
//  MasterViewController.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ALUDataManager.h"
#import "UIFont+AppFonts.h"
#import "NKFColor.h"
#import "NKFColor+Companies.h"
#import "NKFColor+Dates.h"
#import "NKFColor+WikipediaColors.h"
#import "NKFColor+AppColors.h"
#import "ALUMasterTableViewCell.h"


typedef NS_ENUM(NSUInteger, ALUTableViewScrollDirection) {
	ALUTableViewScrollDirectionNone,
	ALUTableViewScrollDirectionUp,
	ALUTableViewScrollDirectionDown,
	ALUTableViewScrollDirectionFree
};


@interface MasterViewController () <DetailViewControllerDelegate>

@property NSArray *objects;
@end

static CGFloat const maximumYContentOffset = 15.0f;
static CGFloat const minimumYContentOffset = -15.0f;

static CGFloat const tableViewInset = 30.0f;

static CGSize const buttonSize = {44.0f, 44.0f};

static CGFloat const defaultRowHeight = 44.0f;

@implementation MasterViewController {
	UITextField *_alertTextField;
	NSDate *_lastReloadDate;
    BOOL _isKeyboardShowing;
	CGPoint _previousContentOffset;
	ALUTableViewScrollDirection _scrollDirection;
    NSDate *_lastTableViewFrameAdjustmentDate;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    [self configureNotifications];
    [self performSelector:@selector(reloadAfterDeleting) withObject:self afterDelay:0.25f];
    [self performSelector:@selector(moveHeaderForward) withObject:self afterDelay:0.35f];
}

- (void)moveHeaderForward {
    if (USE_CARDS) {
        [self.view.superview addSubview:self.headerToolbar];
        [self.view.superview bringSubviewToFront:self.headerToolbar];
        
        if (!self.backgroundView.superview) {
            [self.tableView.superview insertSubview:self.backgroundView belowSubview:self.tableView];
        }
    }
    
    [self performSelector:@selector(moveHeaderForward) withObject:self afterDelay:0.35f];
}

- (void)configureNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appDidBecomeActive:)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appWillEnterForeground:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
	self.tableView.frame = CGRectOffset(CGRectMake(0.0f, -tableViewInset, self.view.frame.size.width, self.view.frame.size.height + tableViewInset + 14.0f), 0.0f, -13.0f);
}

- (void)appWillEnterForeground:(NSNotification *)notification {
	self.tableView.frame = CGRectOffset(CGRectMake(0.0f, -tableViewInset, self.view.frame.size.width, self.view.frame.size.height + tableViewInset + 14.0f), 0.0f, -13.0f);
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
	self.addButton.center = CGPointMake(_inputAccessoryView.frame.size.width - _inputAccessoryView.frame.size.height * 0.5f, _inputAccessoryView.frame.size.height * 0.5f);
	self.editButton.center = CGPointMake(_inputAccessoryView.frame.size.height * 0.5f, _inputAccessoryView.frame.size.height * 0.5f);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationItem.leftBarButtonItem = self.editButtonItem;

	self.objects = [[ALUDataManager sharedDataManager] lists];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewListButtonTouched:)];
	self.navigationItem.rightBarButtonItem = addButton;
	self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	self.navigationItem.title = @"";
	self.view.backgroundColor = [NKFColor white];
	self.navigationController.navigationBar.tintColor = [NKFColor appColor];
	
	if (self.objects.count > 0) {
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	self.navigationController.navigationBar.translucent = YES;
	[self.splitViewController setNeedsStatusBarAppearanceUpdate];
	[self.tableView reloadData];
	[super viewWillAppear:animated];
	
	if (USE_CARDS) {
		[self updateCellContentOffset];
		[self.navigationController setNavigationBarHidden:YES animated:YES];
		
		[self.view.superview addSubview:self.headerToolbar];
		[self.view.superview bringSubviewToFront:self.headerToolbar];
		[ALUDataManager sharedDataManager].currentColorIsDark = YES;
		
		[self.parentViewController setNeedsStatusBarAppearanceUpdate];
	} else {
		[self.headerToolbar removeFromSuperview];
	}
    
    [self performSelector:@selector(adjustTableViewFrame) withObject:self afterDelay:0.1f];
	[self adjustTableViewFrame];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
    [self adjustTableViewFrame];
}

- (void)adjustTableViewFrame {
    if (_lastTableViewFrameAdjustmentDate && [_lastTableViewFrameAdjustmentDate  timeIntervalSinceNow] > -0.35f) {
        NSLog(@"Too little Adjustment delay: %f", [_lastTableViewFrameAdjustmentDate  timeIntervalSinceNow]);
        return;
    }
    
    NSLog(@"Adjustment delay: %f", [_lastTableViewFrameAdjustmentDate  timeIntervalSinceNow]);
    _lastTableViewFrameAdjustmentDate = [NSDate date];
    
    if (USE_CARDS) {
        self.headerToolbar.frame = CGRectMake(0.0f, -kStatusBarHeight, kScreenWidth, kStatusBarHeight);
        [self.view.superview addSubview:self.headerToolbar];
        [self animateStatusBar];
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + tableViewInset,
                                                      self.tableView.contentInset.left,
                                                      self.tableView.contentInset.bottom,
                                                      self.tableView.contentInset.right);
        self.tableView.contentInset = contentInsets;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
        
//        self.tableView.frame = CGRectOffset(CGRectMake(0.0f, -tableViewInset, self.view.frame.size.width, self.view.frame.size.height + tableViewInset + 14.0f), 0.0f, -13.0f);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - List Management

- (void)createNewListButtonTouched:(id)sender {
	UIAlertController *titleController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Note", nil)
																			 message:NSLocalizedString(@"Please give your Note a title", nil)
																	  preferredStyle:UIAlertControllerStyleAlert];
	[titleController addTextFieldWithConfigurationHandler:^(UITextField * __nonnull textField) {
		textField.placeholder = NSLocalizedString(@"Note Title", nil);
		textField.keyboardAppearance = UIKeyboardAppearanceLight;
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		textField.autocorrectionType = UITextAutocorrectionTypeYes;
		textField.delegate = self;
		_alertTextField = textField;
	}];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
														   style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * __nonnull action) {
															 
														 }];
	[titleController addAction:cancelAction];
	
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction * __nonnull action) {
														 if (_alertTextField.text.length > 0) {
															 [self insertNewList:_alertTextField.text];
														 }
													 }];
	[titleController addAction:okAction];
	
	[self presentViewController:titleController animated:YES completion:^{
		[_alertTextField becomeFirstResponder];
	}];
}

- (void)insertNewObject:(id)sender {
	if (!self.objects) {
	    self.objects = [[ALUDataManager sharedDataManager] lists];
	}
	[[ALUDataManager sharedDataManager] addList:[[NSDate date] description]];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertNewList:(NSString *)listTitle {
	if (!self.objects) {
		self.objects = [[ALUDataManager sharedDataManager] lists];
	}
	[[ALUDataManager sharedDataManager] addList:listTitle];
	[self reloadList];
}

- (void)reloadList {
	self.objects = [[ALUDataManager sharedDataManager] lists];
	[self.tableView reloadData];
}

#pragma mark - Input Accessory View

- (UIView *)inputAccessoryView {
	if (!_inputAccessoryView) {
		_inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kScreenHeight, self.view.frame.size.width, 64.0f)];
		self.navigationController.toolbarHidden = YES;
		
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
		longPress.minimumPressDuration = 1.0f;
		longPress.numberOfTouchesRequired = 2;
		[_inputAccessoryView addGestureRecognizer:longPress];
		
		[_inputAccessoryView addSubview:self.addButton];
		self.addButton.center = CGPointMake(_inputAccessoryView.frame.size.width - _inputAccessoryView.frame.size.height * 0.5f, _inputAccessoryView.frame.size.height * 0.5f);
		[_inputAccessoryView addSubview:self.editButton];
		self.editButton.center = CGPointMake(_inputAccessoryView.frame.size.height * 0.5f, _inputAccessoryView.frame.size.height * 0.5f);
	}
	
	return _inputAccessoryView;
}

- (UIButton *)addButton {
	if (!_addButton) {
		_addButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
																 0.0f,
																 buttonSize.width,
																 buttonSize.height)];
		[_addButton addTarget:self action:@selector(createNewListButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
		[_addButton setImage:[UIImage imageNamed:@"Plus-icon"] forState:UIControlStateNormal];
		[_addButton setTitleColor:[NKFColor white] forState:UIControlStateNormal];
		[_addButton setBackgroundColor:[NKFColor appColor]];
		_addButton.layer.cornerRadius = _addButton.frame.size.width * 0.5f;
		_addButton.titleLabel.font = [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE];
		_addButton.layer.borderWidth = 1.0f;
		CGFloat imageInset = 10.0f;
		_addButton.imageEdgeInsets = UIEdgeInsetsMake(imageInset, imageInset, imageInset, imageInset);
		_addButton.layer.borderColor = [[NKFColor appColor] lightenColor].CGColor;
	}
	
	return _addButton;
}

- (UIButton *)editButton {
	if (!_editButton) {
		_editButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
																 0.0f,
																 buttonSize.width,
																 buttonSize.height)];
		[_editButton setImage:[UIImage imageNamed:@"Edit-icon"] forState:UIControlStateNormal];
		[_editButton setTitleColor:[NKFColor white] forState:UIControlStateNormal];
		[_editButton setBackgroundColor:[NKFColor appColor]];
		_editButton.layer.cornerRadius = _editButton.frame.size.width * 0.5f;
		_editButton.titleLabel.font = [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE];
		CGFloat imageInset = 10.0f;
		_editButton.imageEdgeInsets = UIEdgeInsetsMake(imageInset, imageInset, imageInset, imageInset);
		[_editButton addTarget:self action:[self.navigationController.editButtonItem action] forControlEvents:UIControlEventTouchUpInside];
		_editButton.layer.borderWidth = 1.0f;
		_editButton.layer.borderColor = [[NKFColor appColor] lightenColor].CGColor;
	}
	
	return _editButton;
}

- (UIBarButtonItem *)flexibleSpace {
	return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
														 target:self
														 action:nil];
}

- (void)longPressed:(UILongPressGestureRecognizer *)sender {
	[[ALUDataManager sharedDataManager] setUseCardView:![[ALUDataManager sharedDataManager] useCardView]];
	
	NSString *message = @"Would you like to start using Card Views?";
	if (USE_CARDS) {
		message = @"You are currently using Card Views. Would you like to switch back to the normal list?";
	}
	
	UIAlertController *cardViewAlertController = [UIAlertController alertControllerWithTitle:@"Use Card View"
																					 message:message
																			  preferredStyle:UIAlertControllerStyleAlert];
	
	if (USE_CARDS) {
		UIAlertAction *stopCardsAction = [UIAlertAction actionWithTitle:@"Use Normal List"
																  style:UIAlertActionStyleDestructive
																handler:^(UIAlertAction *action) {
																	[[ALUDataManager sharedDataManager] setUseCardView:NO];
																}];
		[cardViewAlertController addAction:stopCardsAction];
	} else {
		UIAlertAction *useCardsACtion = [UIAlertAction actionWithTitle:@"Use Card Views"
																 style:UIAlertActionStyleDefault
															   handler:^(UIAlertAction *action) {
																   [[ALUDataManager sharedDataManager] setUseCardView:YES];
															   }];
		[cardViewAlertController addAction:useCardsACtion];
	}
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
														   style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction *action) {
															 
														 }];
	[cardViewAlertController addAction:cancelAction];
	
	[self presentViewController:cardViewAlertController
					   animated:YES
					 completion:^{
						 
					 }];
}

- (void)settingsButtonTouched {
	NSLog(@"Settings Button Touched");
}

- (BOOL)canBecomeFirstResponder {
	if (_alertTextField) {
		return NO;
	}
	
	return USE_CARDS;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
		[[ALUDataManager sharedDataManager] setNoteHasBeenSelectedOnce:YES];
		
	    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	    NSString *object = self.objects[indexPath.row];
		
		self.navigationController.navigationBar.barTintColor = [NKFColor colorForCompanyName:object];
		self.navigationController.navigationBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
		self.navigationController.navigationBar.tintColor = [(NKFColor *)self.navigationController.navigationBar.barTintColor oppositeBlackOrWhite];
		[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : self.navigationController.navigationBar.tintColor}];
		
		DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
		[controller setDelegate:self];
	    [controller setDetailItem:object];
	    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
	    controller.navigationItem.leftItemsSupplementBackButton = YES;
		controller.navigationController.navigationBar.barTintColor = [NKFColor colorForCompanyName:object];
		controller.navigationController.navigationBar.backgroundColor = controller.navigationController.navigationBar.barTintColor;
		controller.navigationController.navigationBar.tintColor = [(NKFColor *)self.navigationController.navigationBar.barTintColor oppositeBlackOrWhite];
		
		if ([(NKFColor *)self.navigationController.navigationBar.barTintColor isDark]) {
			[ALUDataManager sharedDataManager].currentColorIsDark = YES;
		} else {
			[ALUDataManager sharedDataManager].currentColorIsDark = NO;
		}
	} else {
		NSLog(@"Prepare Segue for \"%@\" won't do anything", sender);
	}
}

#pragma mark - Status Bar

- (UIView *)headerToolbar {
	if (!_headerToolbar) {
		_headerToolbar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScreenWidth, kStatusBarHeight)];
		_headerToolbar.backgroundColor = [NKFColor black];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0.0f,
                                         0.0f,
                                         LONGER_SIDE,
                                         _headerToolbar.frame.size.height);
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[[NKFColor black] CGColor], (id)[[NKFColor clearColor] CGColor], nil];
        gradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
        gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
        
        _headerToolbar.layer.mask = gradientLayer;
	}
	
	return _headerToolbar;
}

- (ALUBackgroundView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[ALUBackgroundView alloc] initWithFrame:self.view.frame];
        [_backgroundView layoutSubviews];
    }
    
    return _backgroundView;
}

- (void)animateStatusBar {
	[UIView animateWithDuration:0.25f
					 animations:^{
						 self.headerToolbar.frame = CGRectMake(0.0f, 0.0f, kScreenWidth, kStatusBarHeight);
					 }];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
	return self.navigationController.visibleViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
	return self.navigationController.visibleViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	if ([(NKFColor *)self.navigationController.navigationBar.barTintColor isDark]) {
		return UIStatusBarStyleLightContent;
	}
	
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (USE_CARDS) {
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.tableView.showsVerticalScrollIndicator = NO;
		self.view.backgroundColor = [NKFColor clearColor];
		self.view.superview.backgroundColor = [NKFColor black];
	} else {
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.tableView.showsHorizontalScrollIndicator = YES;
		self.view.backgroundColor = [UIColor whiteColor];
	}
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat heightForRow = (USE_CARDS) ? 100.0f : defaultRowHeight;
	
	if (USE_CARDS
		&&
		indexPath.section + 1 == [self numberOfSectionsInTableView:tableView]
		&&
		indexPath.row + 1 == [self tableView:tableView numberOfRowsInSection:indexPath.section]) {
		heightForRow = LONGER_SIDE - tableViewInset;
	}
	
	return heightForRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ALUMasterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	
	NSString *object = self.objects[indexPath.row];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE];
	cell.textLabel.attributedText = [NKFColor attributedStringForCompanyName:[object description]];
	
	if (USE_CARDS) {
		cell.noteTitle = self.objects[indexPath.row];
		cell.color = [NKFColor colorForCompanyName:cell.noteTitle];
		cell.noteText = [[ALUDataManager sharedDataManager] listWithTitle:cell.noteTitle];
		cell.textLabel.hidden = YES;
	} else {
		cell.textLabel.hidden = NO;
	}
	
	cell.backgroundColor = [UIColor clearColor];
	cell.opaque = NO;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	UIImage *companyLogoImage = [[ALUDataManager sharedDataManager] imageForCompanyName:cell.textLabel.text];
	
	if (USE_CARDS && !companyLogoImage) {
		NSLog(@"%@\t\t%@", cell.noteTitle, cell.textLabel.text);
	}
	
	if (companyLogoImage
        &&
            (
             [NKFColor strictColorForCompanyName:cell.textLabel.text]
             ||
             [[ALUDataManager sharedDataManager] imageSavedLocallyForCompanyName:cell.textLabel.text]
			 ||
			 [[ALUDataManager sharedDataManager] imageSavedLocallyForCompanyName:cell.noteTitle]
            )
        &&
        [[ALUDataManager sharedDataManager] showImageForListTitle:cell.textLabel.text]) {
        cell.accessoryView.hidden = NO;
		if (cell.accessoryView && [cell.accessoryView respondsToSelector:@selector(setImage:)]) {
			UIImageView *accessoryView = (UIImageView *)cell.accessoryView;
			accessoryView.image = companyLogoImage;
		} else {
			UIImageView *imageView = [[UIImageView alloc] initWithImage:companyLogoImage];
			imageView.contentMode = UIViewContentModeScaleAspectFit;
			CGFloat scale = 0.925f;
			CGRect frame = imageView.frame;
			frame.size.height = cell.frame.size.height * scale;
            frame.size.width = frame.size.height * scale;
            frame.origin.x = cell.frame.size.width - frame.size.width;
			imageView.frame = frame;
			imageView.clipsToBounds = YES;
			imageView.layer.cornerRadius = 2.0f;
			cell.accessoryView = imageView;
		}
		
		if (USE_CARDS) {
			cell.accessoryView.hidden = YES;
			cell.accessoryImage = companyLogoImage;
		}
	} else {
		cell.accessoryView.hidden = YES;
		cell.accessoryImage = nil;
	}
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
	    [[ALUDataManager sharedDataManager] removeList:self.objects[indexPath.row]];
		[[ALUDataManager sharedDataManager] removeReminderForListTitle:self.objects[indexPath.row]];
		self.objects = [[ALUDataManager sharedDataManager] lists];
	    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self performSelector:@selector(reloadAfterDeleting) withObject:self afterDelay:0.35f];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
	    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	[self reloadAfterDeleting];
}

- (void)reloadAfterDeleting {
	if (!_lastReloadDate || [_lastReloadDate timeIntervalSinceNow] < -1) {
		self.objects = [[ALUDataManager sharedDataManager] lists];
		[self.tableView reloadData];
		_lastReloadDate = [NSDate date];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *firstVisibleIndexPath = [tableView.indexPathsForVisibleRows firstObject];
	
	for (NSIndexPath *visibleIndexPath in tableView.indexPathsForVisibleRows) {
		if (firstVisibleIndexPath.row > visibleIndexPath.row) {
			firstVisibleIndexPath = visibleIndexPath;
		}
	}
	
	if ([cell isKindOfClass:[ALUMasterTableViewCell class]] &&
		[cell respondsToSelector:@selector(setParallaxStrength:)] &&
		[cell respondsToSelector:@selector(setContentOffset:)]) {
		
		ALUMasterTableViewCell *aluCell = (ALUMasterTableViewCell *)cell;
		aluCell.parallaxStrength = (indexPath.row - firstVisibleIndexPath.row) * 10;
		
		if (indexPath.row > [self middleIndexPath].row) {
			aluCell.contentOffset = CGPointMake(0.0f, maximumYContentOffset);
		} else if (indexPath.row < [self middleIndexPath].row) {
			aluCell.contentOffset = CGPointMake(0.0f, minimumYContentOffset);
		}
	}
}

- (NSIndexPath *)middleIndexPath {
	return [self.tableView indexPathForRowAtPoint:CGPointMake(self.tableView.frame.size.width * 0.5f, self.tableView.frame.size.height * 0.5f + self.tableView.contentOffset.y + tableViewInset)];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (!(self.isViewLoaded && self.view.window)) {
        return;
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + tableViewInset,
												  0.0,
												  kbSize.height,
												  0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight, 0.0f, 0.0f, 0.0f);
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.tableView.frame.origin) ) {
        [self.tableView scrollRectToVisible:self.tableView.frame animated:YES];
    }
    
    _isKeyboardShowing = YES;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)aNotification {
    if (!(self.isViewLoaded && self.view.window)) {
        return;
    }
    
	self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight,
												   0.0f,
												   ([self canBecomeFirstResponder]) ? self.inputAccessoryView.frame.size.height : 0.0f,
												   0.0f);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight,
															0.0f,
															([self canBecomeFirstResponder]) ? self.inputAccessoryView.frame.size.height : 0.0f,
															0.0f);
    
    _isKeyboardShowing = YES;
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if ([scrollView isEqual:self.tableView]) {
		CGFloat overScrolledDistance = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height + scrollView.contentInset.bottom;
		
		if (scrollView.contentOffset.y > _previousContentOffset.y && overScrolledDistance > 0.0f && scrollView.contentOffset.y > -30.0f) {
			self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollView.scrollIndicatorInsets.top,
																	scrollView.scrollIndicatorInsets.left,
																	0.0f,
																	scrollView.scrollIndicatorInsets.right);
			[self resignFirstResponder];
		} else if (overScrolledDistance > 0.0f) {
			[self becomeFirstResponder];
		}
		
		if (self.tableView.contentOffset.y > _previousContentOffset.y) {
			_scrollDirection = ALUTableViewScrollDirectionUp;
		} else if (self.tableView.contentOffset.y < _previousContentOffset.y) {
			_scrollDirection = ALUTableViewScrollDirectionDown;
		}
		
		[self updateCellContentOffset];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if ([scrollView isEqual:self.tableView]) {
		for (NSTimeInterval delayTime = 0.0f; delayTime < 0.35f; delayTime += 0.01f) {
			[self performSelector:@selector(updateCellContentOffset) withObject:self afterDelay:delayTime];
		}
	}
}

- (void)updateCellContentOffset {
	if (USE_CARDS && self.tableView.indexPathsForVisibleRows.count > 3) {
		NSArray *sortedIndexPaths = [[self.tableView indexPathsForVisibleRows] sortedArrayUsingSelector:@selector(compare:)];
		NSIndexPath *middlePath = [self middleIndexPath];
		
		CGFloat maximumChange = 1.9;
		CGFloat verticalScrollVelocity = self.tableView.contentOffset.y - _previousContentOffset.y;
		if (verticalScrollVelocity < 0) {
			verticalScrollVelocity *= -1.0f;
		}
		
		if (verticalScrollVelocity > 20) {
			maximumChange = verticalScrollVelocity * 0.1f;
		} else if (verticalScrollVelocity > 10) {
			maximumChange *= 0.2f;
		}
		
		for (int i = 0; i < sortedIndexPaths.count; i++) {
			NSIndexPath *path = [sortedIndexPaths objectAtIndex:i];
			ALUMasterTableViewCell *cell = (ALUMasterTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
			
			
			CGFloat adjustedYOffset = 0.0f;
			
			if (cell.contentOffset.y <= maximumYContentOffset) {
				if (path.row > middlePath.row) {
					if (cell.contentOffset.y + maximumChange > maximumYContentOffset) {
						adjustedYOffset = maximumYContentOffset;
					} else {
						adjustedYOffset = cell.contentOffset.y + maximumChange;
					}
				} else if (path.row == middlePath.row) {
					adjustedYOffset = cell.contentOffset.y;
				} else if (cell.contentOffset.y > minimumYContentOffset) {
					adjustedYOffset = cell.contentOffset.y - maximumChange;
				}
			} else if (path.row > middlePath.row) {
				adjustedYOffset = maximumYContentOffset;
			} else {
				adjustedYOffset = minimumYContentOffset;
			}
			
			switch (_scrollDirection) {
				case ALUTableViewScrollDirectionNone:
					adjustedYOffset = cell.contentOffset.y;
					break;
					
				case ALUTableViewScrollDirectionUp:
					if (adjustedYOffset > cell.contentOffset.y) {
						adjustedYOffset = cell.contentOffset.y;
					}
					break;
					
				case ALUTableViewScrollDirectionDown:
					if (adjustedYOffset < cell.contentOffset.y) {
						adjustedYOffset = cell.contentOffset.y;
					}
					break;
					
				default:
					break;
			}
			
			if (adjustedYOffset != cell.contentOffset.y) {
				if (adjustedYOffset - cell.contentOffset.y > maximumChange) {
					adjustedYOffset = cell.contentOffset.y + maximumChange;
				} else if (cell.contentOffset.y - adjustedYOffset > maximumChange) {
					adjustedYOffset = cell.contentOffset.y - maximumChange;
				}
			}
			
			cell.contentOffset = CGPointMake(cell.contentOffset.x,
											 adjustedYOffset);
		}
	}
	
	_previousContentOffset = self.tableView.contentOffset;
}

#pragma mark - Text Field Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[_alertTextField resignFirstResponder];
	_alertTextField = nil;
	[self becomeFirstResponder];
}

@end
