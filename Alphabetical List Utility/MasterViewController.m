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
#import "ALUNavigationController.h"
#import "UIFont+AppFonts.h"
#import "NKFColor.h"
#import "NKFColor+Companies.h"
#import "NKFColor+Dates.h"
#import "NKFColor+WikipediaColors.h"
#import "NKFColor+AppColors.h"
#import "ALUMasterTableViewCell.h"
#import "ALUMasterTableView.h"
#import "ALUNoteCardView.h"
#import "ALUExternalDisplayController.h"
#import "UIColor+AppColors.h"


// The card list lives in one of three states, all inside this view controller —
// selecting a note never pushes onto the navigation stack.
typedef NS_ENUM(NSUInteger, ALUCardStackState) {
	// The Wallet-style stack: every card shows just its top strip.
	ALUCardStackStateStack,
	// One card enlarged over the stack; the stack peeks in from the bottom edge.
	ALUCardStackStateExpanded,
	// The enlarged card grown to fill the view, hosting the note editor as a child.
	ALUCardStackStateFullScreen
};

@interface MasterViewController () <DetailViewControllerDelegate>

@property NSArray *objects;

@property (nonatomic, strong) ALUNoteCardView *activeCardView;
@property (nonatomic, strong) UIControl *dimmingControl;

@end

static CGFloat const tableViewInset = 30.0f;

static CGSize const buttonSize = {44.0f, 44.0f};

static CGFloat const defaultRowHeight = 44.0f;

// Wallet-style stack metrics.
static CGFloat const minimumCardPeekHeight = 64.0f;
static CGFloat const maximumCardPeekHeight = 140.0f;
static CGFloat const cardStackBottomStripHeight = 72.0f;
static CGFloat const expandedCardSideInset = 14.0f;
static CGFloat const expandedCardTopInset = 20.0f;
static CGFloat const noteCardCornerRadius = 10.0f;

@implementation MasterViewController {
	UITextField *_alertTextField;
	NSDate *_lastReloadDate;
    BOOL _isKeyboardShowing;
	CGPoint _previousContentOffset;
    NSDate *_lastTableViewFrameAdjustmentDate;

	ALUCardStackState _cardStackState;
	NSString *_activeNoteTitle;
	ALUNavigationController *_embeddedNoteNavigationController;
	DetailViewController *_embeddedDetailViewController;
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
	_cardStackState = ALUCardStackStateStack;
    [self configureNotifications];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadAfterDeleting];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self moveHeaderForward];
    });
}

- (void)moveHeaderForward {
    if (USE_CARDS) {
        [self.view.superview addSubview:self.headerToolbar];
        [self.view.superview bringSubviewToFront:self.headerToolbar];

        if (!self.backgroundView.superview) {
            [self.tableView.superview insertSubview:self.backgroundView belowSubview:self.tableView];
        }
    }
}

- (void)configureNotifications {
	if (USE_CARDS) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWasShown:)
													 name:UIKeyboardDidShowNotification object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWasHidden:)
													 name:UIKeyboardWillHideNotification object:nil];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appDidBecomeActive:)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appWillEnterForeground:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appDidBecomeActive:)
												 name:ALUNoteIconDidLoadNotification
											   object:nil];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

	self.addButton.center = CGPointMake(_inputAccessoryView.frame.size.width - _inputAccessoryView.frame.size.height * 0.5f, _inputAccessoryView.frame.size.height * 0.5f);

	// Setting the frame recenters the view, which would silently cancel the slide
	// transform the table carries while a card is out of the stack.
	if (_cardStackState == ALUCardStackStateStack) {
		self.tableView.frame = self.view.bounds;
		[self.tableView reloadData];
	}
	[self.backgroundView layoutSubviews];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	// Deleting a note now lives in the detail view's overflow menu, so there is
	// no Edit button here.
	self.objects = [[ALUDataManager sharedDataManager] lists];

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewListButtonTouched:)];
	self.navigationItem.rightBarButtonItem = addButton;
	self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	self.navigationItem.title = @"A2Z Notes";
	self.view.backgroundColor = [NKFColor appColor];
	ALUApplyNavigationBarColor(self.navigationController.navigationBar, [NKFColor appColor], [NKFColor whiteColor]);

	if (self.objects.count > 0) {
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
	}

    for (NSTimeInterval t = 0.0f; t < 20.0f; t +=  ((t > 0) ? 2.1f * t : 2.1f)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self delayedReload];
        });
    }
}

- (void)viewWillAppear:(BOOL)animated {
	self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
	// Note: barStyle is set by ALUApplyNavigationBarColor based on the bar's luminance,
	// so it correctly drives light/dark status-bar content. Don't override it here.
	[self.splitViewController setNeedsStatusBarAppearanceUpdate];
	[self.tableView reloadData];
	[super viewWillAppear:animated];

	if (USE_CARDS) {
        if (!IS_IPAD) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [self.view.superview addSubview:self.headerToolbar];
            [self.view.superview bringSubviewToFront:self.headerToolbar];
        }

		[ALUDataManager sharedDataManager].currentColorIsDark = YES;

		[self.parentViewController setNeedsStatusBarAppearanceUpdate];
	} else {
		[self.headerToolbar removeFromSuperview];
	}

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjustTableViewFrame];
    });
	[self adjustTableViewFrame];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

    [self adjustTableViewFrame];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	// Keep the enlarged card tracking the view through rotation and size changes.
	switch (_cardStackState) {
		case ALUCardStackStateExpanded:
			self.activeCardView.frame = [self expandedCardFrame];
			self.dimmingControl.frame = [self cardOverlayHostView].bounds;
			break;

		case ALUCardStackStateFullScreen:
			self.activeCardView.frame = [self fullScreenCardFrame];
			self.dimmingControl.frame = [self cardOverlayHostView].bounds;
			break;

		default:
			break;
	}
}

- (void)adjustTableViewFrame {
    if (_lastTableViewFrameAdjustmentDate && [_lastTableViewFrameAdjustmentDate  timeIntervalSinceNow] > -0.35f) {
        DLog(@"Too little Adjustment delay: %f", [_lastTableViewFrameAdjustmentDate  timeIntervalSinceNow]);
        return;
    }

    DLog(@"Adjustment delay: %f", [_lastTableViewFrameAdjustmentDate  timeIntervalSinceNow]);
    _lastTableViewFrameAdjustmentDate = [NSDate date];

    if (USE_CARDS) {
        [UIView animateWithDuration:0.35f
                         animations:^{
                             self.headerToolbar.frame = CGRectMake(0.0f,
                                                                   -kStatusBarHeight,
                                                                   kScreenWidth,
                                                                   kStatusBarHeight);
                             [self.view.superview addSubview:self.headerToolbar];
                             [self animateStatusBar];

                             UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + tableViewInset,
                                                                          self.tableView.contentInset.left,
                                                                          self.tableView.contentInset.bottom,
                                                                          self.tableView.contentInset.right);
                             self.tableView.contentInset = contentInsets;

                             static dispatch_once_t onceToken;
                             dispatch_once(&onceToken, ^{
                                 // Guard: scrolling to row 0 raises when there are no notes yet.
                                 if (self.objects.count > 0) {
                                     [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                                 }
                             });
                         }];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
	}

	self.addButton.center = CGPointMake(_inputAccessoryView.frame.size.width - _inputAccessoryView.frame.size.height * 0.5f, _inputAccessoryView.frame.size.height * 0.5f);

	return _inputAccessoryView;
}

- (UIButton *)addButton {
	if (!_addButton) {
		_addButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
																 0.0f,
																 buttonSize.width,
																 buttonSize.height)];
		[_addButton addTarget:self action:@selector(createNewListButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

		// imageEdgeInsets is ignored under UIButtonConfiguration; express the inset as
		// contentInsets instead. The background stays on the layer so the circular shape and
		// border below still apply.
		UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
		configuration.image = [UIImage systemImageNamed:@"plus"
									  withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:17.0f weight:UIImageSymbolWeightSemibold]];
		configuration.baseForegroundColor = [NKFColor white];
		configuration.background.backgroundColor = [UIColor clearColor];
		_addButton.configuration = configuration;

		[_addButton setBackgroundColor:[[NKFColor appColor] colorWithAlphaComponent:0.7f]];
		_addButton.layer.cornerRadius = _addButton.frame.size.width * 0.5f;
	}

	return _addButton;
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
	DLog(@"Settings Button Touched");
}

- (BOOL)canBecomeFirstResponder {
	return USE_CARDS && !IS_IPAD && _cardStackState == ALUCardStackStateStack;
}

#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	// In the card stack, selecting a note expands its card in place instead of
	// pushing the detail screen.
	if ([identifier isEqualToString:@"showDetail"] && [self usesCardStackInteraction]) {
		return NO;
	}

	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
		[[ALUDataManager sharedDataManager] setNoteHasBeenSelectedOnce:YES];

	    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	    NSString *object = self.objects[indexPath.row];

		NKFColor *noteColor = (NKFColor *)[NKFColor colorForCompanyName:object];
		UIColor *contrastColor = [noteColor oppositeBlackOrWhite];
		ALUApplyNavigationBarColor(self.navigationController.navigationBar, noteColor, contrastColor);

		DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
		[controller setDelegate:self];
	    [controller setDetailItem:object];
	    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
	    controller.navigationItem.leftItemsSupplementBackButton = YES;
		ALUApplyNavigationBarColor(controller.navigationController.navigationBar, noteColor, contrastColor);

		if ([noteColor isDark]) {
			[ALUDataManager sharedDataManager].currentColorIsDark = YES;
		} else {
			[ALUDataManager sharedDataManager].currentColorIsDark = NO;
		}
	} else {
		DLog(@"Prepare Segue for \"%@\" won't do anything", sender);
	}
}

#pragma mark - Card Stack

// The in-place card interaction runs where the master list is the whole screen
// (iPhone). In a split view (iPad) the detail column already shows the note
// side-by-side, so selection keeps its existing behavior there.
- (BOOL)usesCardStackInteraction {
	return USE_CARDS && self.splitViewController.isCollapsed;
}

// self.view IS the table view (UITableViewController), and the table gets translated
// while a card is expanded — so the overlay card and dimming layer live in the
// navigation controller's root view. That view stays put, and (unlike the table's
// direct superview, a UIViewControllerWrapperView) it reliably propagates safe-area
// insets into the full-screen card, so the embedded editor's bar clears the status bar.
- (UIView *)cardOverlayHostView {
	return self.navigationController.view ?: (self.view.superview ?: self.view);
}

// The view controller whose view hierarchy hosts the overlay card. The full-screen
// editor must be added as a child of this controller — parenting it to self while
// its view lands in another controller's hierarchy trips UIKit's containment check.
- (UIViewController *)cardOverlayHostViewController {
	UIResponder *responder = [self cardOverlayHostView].nextResponder;
	while (responder && ![responder isKindOfClass:[UIViewController class]]) {
		responder = responder.nextResponder;
	}

	return (UIViewController *)responder ?: self;
}

- (CGFloat)noteCardHeight {
	return SHORTER_SIDE - kStatusBarHeight;
}

- (ALUMasterTableView *)masterTableView {
	return (ALUMasterTableView *)self.tableView;
}

- (CGFloat)cardStackAvailableHeight {
	CGFloat topInset = self.navigationController.navigationBar.frame.size.height + kStatusBarHeight + tableViewInset;
	return self.view.bounds.size.height - topInset;
}

// How much of each card's top strip shows in the stack. Fewer notes → taller
// strips, so more of every card is visible.
- (CGFloat)cardStackPeekHeight {
	NSInteger count = (self.objects.count > 0) ? (NSInteger)self.objects.count : 1;
	CGFloat peek = ([self cardStackAvailableHeight] - cardStackBottomStripHeight) / count;

	if (peek < minimumCardPeekHeight) {
		return minimumCardPeekHeight;
	}
	if (peek > maximumCardPeekHeight) {
		return maximumCardPeekHeight;
	}

	return peek;
}

// "Full screen" is a sheet pinned just below the status bar: the editor's navigation
// bar then starts at the card's top edge, deterministically clear of the clock,
// without depending on UIKit propagating safe-area insets into the card.
- (CGRect)fullScreenCardFrame {
	CGRect hostBounds = [self cardOverlayHostView].bounds;

	return CGRectMake(0.0f,
					  kStatusBarHeight,
					  hostBounds.size.width,
					  hostBounds.size.height - kStatusBarHeight);
}

- (CGRect)expandedCardFrame {
	CGRect hostBounds = [self cardOverlayHostView].bounds;
	CGFloat top = kStatusBarHeight + expandedCardTopInset;
	CGFloat bottom = hostBounds.size.height - cardStackBottomStripHeight - expandedCardTopInset;

	return CGRectMake(expandedCardSideInset,
					  top,
					  hostBounds.size.width - expandedCardSideInset * 2.0f,
					  bottom - top);
}


- (void)expandCardAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row >= self.objects.count || _cardStackState != ALUCardStackStateStack) {
		return;
	}

	_activeNoteTitle = self.objects[indexPath.row];
	[[ALUDataManager sharedDataManager] setNoteHasBeenSelectedOnce:YES];

	// The card stack shows a note without any DetailViewController, so it has to
	// report to the external screen itself.
	[[ALUExternalDisplayController sharedController] showNoteWithTitle:_activeNoteTitle text:nil];

	UIView *hostView = [self cardOverlayHostView];
	ALUMasterTableViewCell *cell = (ALUMasterTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	CGRect startFrame = [self expandedCardFrame];
	if (cell) {
		startFrame = [cell convertRect:cell.cardView.frame toView:hostView];
	}

	self.activeCardView = [[ALUNoteCardView alloc] initWithFrame:startFrame];
	[self.activeCardView configureWithNoteTitle:_activeNoteTitle];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activeCardTapped:)];
	[self.activeCardView addGestureRecognizer:tap];

	// While the card is focused: swipe down drops it back into the stack, swipe up
	// opens the editor with the keyboard ready.
	UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(activeCardSwipedDown:)];
	swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
	[self.activeCardView addGestureRecognizer:swipeDown];

	UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(activeCardSwipedUp:)];
	swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
	[self.activeCardView addGestureRecognizer:swipeUp];

	self.dimmingControl.frame = hostView.bounds;
	self.dimmingControl.alpha = 0.0f;
	[hostView addSubview:self.dimmingControl];
	[hostView addSubview:self.activeCardView];

	_cardStackState = ALUCardStackStateExpanded;
	self.tableView.scrollEnabled = NO;
	[self resignFirstResponder];

	[UIView animateWithDuration:0.5f
						  delay:0.0f
		 usingSpringWithDamping:0.85f
		  initialSpringVelocity:0.4f
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.activeCardView.frame = [self expandedCardFrame];
						 [self.activeCardView layoutIfNeeded];
						 self.dimmingControl.alpha = 1.0f;
						 // Part the stack: cards behind leave through the top,
						 // cards in front through the bottom.
						 [self masterTableView].partedRow = indexPath.row;
						 [self.tableView setNeedsLayout];
						 [self.tableView layoutIfNeeded];
					 }
					 completion:nil];
}

- (void)activeCardTapped:(UITapGestureRecognizer *)sender {
	if (_cardStackState != ALUCardStackStateExpanded) {
		return;
	}

	// A tap on the note's text opens the full-screen editor; a tap anywhere else
	// on the card drops it back into the stack.
	CGPoint location = [sender locationInView:self.activeCardView];
	if (CGRectContainsPoint(self.activeCardView.textView.frame, location)) {
		[self presentFullScreenNote];
	} else {
		[self collapseActiveCard];
	}
}

- (void)activeCardSwipedDown:(UISwipeGestureRecognizer *)sender {
	if (_cardStackState == ALUCardStackStateExpanded) {
		[self collapseActiveCard];
	}
}

- (void)activeCardSwipedUp:(UISwipeGestureRecognizer *)sender {
	if (_cardStackState == ALUCardStackStateExpanded) {
		[self presentFullScreenNote];
		[_embeddedDetailViewController.listItemTextView becomeFirstResponder];
	}
}

- (void)presentFullScreenNote {
	if (_cardStackState != ALUCardStackStateExpanded || !_activeNoteTitle) {
		return;
	}

	_cardStackState = ALUCardStackStateFullScreen;

	DetailViewController *detailViewController = [[DetailViewController alloc] init];
	detailViewController.delegate = self;
	// Set the note before anything touches .view: loading the view with no detailItem
	// makes the editor fall back to the first note in the list.
	detailViewController.detailItem = _activeNoteTitle;
	// Built in code rather than from the storyboard, so the view needs the opaque
	// background the storyboard scene used to provide.
	detailViewController.view.backgroundColor = [UIColor systemBackgroundColor];
	detailViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.down"]
																							 style:UIBarButtonItemStylePlain
																							target:self
																							action:@selector(dismissFullScreenNote)];
	detailViewController.navigationItem.leftItemsSupplementBackButton = NO;

	ALUNavigationController *noteNavigationController = [[ALUNavigationController alloc] initWithNavigationBarClass:[ALUCardNavigationBar class] toolbarClass:nil];
	noteNavigationController.viewControllers = @[detailViewController];
	_embeddedDetailViewController = detailViewController;
	_embeddedNoteNavigationController = noteNavigationController;

	// Dragging the editor's navigation bar pulls the note down toward the
	// middle (expanded) state.
	UIPanGestureRecognizer *barPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenNoteBarPanned:)];
	[noteNavigationController.navigationBar addGestureRecognizer:barPan];

	UIColor *noteColor = [ALUNoteCardView mutedColor:[NKFColor colorForCompanyName:_activeNoteTitle]];
	UIColor *contrastColor = [noteColor oppositeBlackOrWhite];
	ALUApplyNavigationBarColor(noteNavigationController.navigationBar, noteColor, contrastColor);
	// The main bar stays hidden, but its color drives this controller's status bar style.
	ALUApplyNavigationBarColor(self.navigationController.navigationBar, noteColor, contrastColor);
	[ALUDataManager sharedDataManager].currentColorIsDark = [(NKFColor *)noteColor isDark];

	UIViewController *hostViewController = [self cardOverlayHostViewController];
	[hostViewController addChildViewController:noteNavigationController];
	noteNavigationController.view.frame = self.activeCardView.bounds;
	noteNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	noteNavigationController.view.alpha = 0.0f;
	[self.activeCardView addSubview:noteNavigationController.view];

	[UIView animateWithDuration:0.4f
					 animations:^{
						 self.activeCardView.frame = [self fullScreenCardFrame];
						 noteNavigationController.view.alpha = 1.0f;
						 [self.activeCardView layoutIfNeeded];
					 }
					 completion:^(BOOL finished) {
						 [noteNavigationController didMoveToParentViewController:hostViewController];
						 [self setNeedsStatusBarAppearanceUpdate];
					 }];
}

- (void)fullScreenNoteBarPanned:(UIPanGestureRecognizer *)sender {
	if (_cardStackState != ALUCardStackStateFullScreen) {
		return;
	}

	UIView *hostView = [self cardOverlayHostView];
	CGFloat translation = [sender translationInView:hostView].y;

	switch (sender.state) {
		case UIGestureRecognizerStateChanged: {
			// The card tracks the finger downward; upward drags get logarithmic
			// resistance so the card feels pinned at the top.
			CGRect frame = [self fullScreenCardFrame];
			frame.origin.y += (translation > 0.0f) ? translation : -3.0f * log1p(-translation * 0.1f);
			self.activeCardView.frame = frame;
			break;
		}

		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled: {
			CGFloat velocity = [sender velocityInView:hostView].y;
			if (translation > 100.0f || velocity > 600.0f) {
				// dismissFullScreenNote animates from wherever the drag left the
				// card, so this continues smoothly into the middle state.
				[_embeddedDetailViewController.listItemTextView resignFirstResponder];
				[self dismissFullScreenNote];
			} else {
				[UIView animateWithDuration:0.3f animations:^{
					self.activeCardView.frame = [self fullScreenCardFrame];
				}];
			}
			break;
		}

		default:
			break;
	}
}

- (void)dismissFullScreenNote {
	if (_cardStackState != ALUCardStackStateFullScreen) {
		return;
	}

	// Persist edits before reading the note back for the card preview. The note may
	// also have been renamed in the editor's settings.
	[_embeddedDetailViewController saveList];
	if ([_embeddedDetailViewController.detailItem isKindOfClass:[NSString class]]) {
		_activeNoteTitle = _embeddedDetailViewController.detailItem;
	}

	ALUNavigationController *noteNavigationController = _embeddedNoteNavigationController;
	[noteNavigationController willMoveToParentViewController:nil];
	_embeddedNoteNavigationController = nil;
	_embeddedDetailViewController = nil;

	_cardStackState = ALUCardStackStateExpanded;
	[self.activeCardView configureWithNoteTitle:_activeNoteTitle];
	[self reloadList];

	ALUApplyNavigationBarColor(self.navigationController.navigationBar, [NKFColor appColor], [NKFColor whiteColor]);
	[ALUDataManager sharedDataManager].currentColorIsDark = YES;
	[self setNeedsStatusBarAppearanceUpdate];

	[UIView animateWithDuration:0.35f
					 animations:^{
						 self.activeCardView.frame = [self expandedCardFrame];
						 noteNavigationController.view.alpha = 0.0f;
						 [self.activeCardView layoutIfNeeded];
					 }
					 completion:^(BOOL finished) {
						 [noteNavigationController.view removeFromSuperview];
						 [noteNavigationController removeFromParentViewController];
						 // The editor's teardown reports "no note"; the card is
						 // still showing this one, so re-report it afterwards.
						 [[ALUExternalDisplayController sharedController] showNoteWithTitle:self->_activeNoteTitle text:nil];
					 }];
}

// DetailViewControllerDelegate: the open note was deleted from the editor's
// overflow menu. Unwind whatever card state is showing; the deleted title no
// longer has a row, so the collapse fades the card out instead of docking it.
- (void)noteWasDeleted {
	if (_cardStackState == ALUCardStackStateFullScreen) {
		[self dismissFullScreenNote];
	}
	[self collapseActiveCard];
}

- (void)collapseActiveCard {
	if (_cardStackState == ALUCardStackStateFullScreen) {
		[self dismissFullScreenNote];
		return;
	}

	if (_cardStackState != ALUCardStackStateExpanded) {
		return;
	}

	_cardStackState = ALUCardStackStateStack;
	self.tableView.scrollEnabled = YES;

	// The note may have been renamed while open, so find its row again by title.
	NSUInteger row = [self.objects indexOfObject:_activeNoteTitle];
	BOOL hasTargetRow = (row != NSNotFound);
	CGRect targetFrame = CGRectZero;

	if (hasTargetRow) {
		NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:row inSection:0];

		// While the stack is still parted off-screen, quietly re-center the target
		// row so the card returns into the middle of the rolodex.
		[self masterTableView].partedRow = (NSInteger)row;
		[self.tableView scrollToRowAtIndexPath:targetIndexPath
							  atScrollPosition:UITableViewScrollPositionMiddle
									  animated:NO];
		[self.tableView layoutIfNeeded];

		CGRect rowRect = [self.tableView rectForRowAtIndexPath:targetIndexPath];
		CGFloat rowTopInView = rowRect.origin.y - self.tableView.contentOffset.y;
		targetFrame = CGRectMake(0.0f,
								 rowTopInView + [[self masterTableView] fanShiftForRowTopInView:rowTopInView],
								 self.tableView.bounds.size.width,
								 [self noteCardHeight]);
	}

	ALUNoteCardView *cardView = self.activeCardView;
	UIControl *dimmingControl = self.dimmingControl;
	self.activeCardView = nil;
	_activeNoteTitle = nil;

	[[ALUExternalDisplayController sharedController] showNoteWithTitle:nil text:nil];

	[UIView animateWithDuration:0.5f
						  delay:0.0f
		 usingSpringWithDamping:0.85f
		  initialSpringVelocity:0.4f
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 dimmingControl.alpha = 0.0f;
						 // Slide the parted stack back in around the returning card.
						 [self masterTableView].partedRow = -1;
						 [self.tableView setNeedsLayout];
						 [self.tableView layoutIfNeeded];

						 if (hasTargetRow) {
							 cardView.frame = targetFrame;
							 [cardView layoutIfNeeded];
						 } else {
							 cardView.alpha = 0.0f;
						 }
					 }
					 completion:^(BOOL finished) {
						 [cardView removeFromSuperview];
						 [dimmingControl removeFromSuperview];
						 [self becomeFirstResponder];
					 }];
}

- (UIControl *)dimmingControl {
	if (!_dimmingControl) {
		_dimmingControl = [[UIControl alloc] initWithFrame:[self cardOverlayHostView].bounds];
		_dimmingControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
		[_dimmingControl addTarget:self action:@selector(collapseActiveCard) forControlEvents:UIControlEventTouchUpInside];
	}

	return _dimmingControl;
}

#pragma mark - Status Bar

- (UIView *)headerToolbar {
	if (!_headerToolbar) {
		_headerToolbar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScreenWidth, kStatusBarHeight * 1.05f)];
		[_headerToolbar addSubview:[[UIImageView alloc] initWithImage:self.backgroundView.blurredImageView.image]];

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0.0f,
                                         0.0f,
                                         LONGER_SIDE,
                                         _headerToolbar.frame.size.height);
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[[NKFColor black] CGColor], (id)[[NKFColor clearColor] CGColor], nil];
        gradientLayer.startPoint = CGPointMake(0.0f, 0.75f);
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

- (UIStatusBarStyle)preferredStatusBarStyle {
	if ([(NKFColor *)self.navigationController.navigationBar.barTintColor isDark]) {
		return UIStatusBarStyleLightContent;
	}

	return UIStatusBarStyleDarkContent;
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
		self.view.backgroundColor = [UIColor systemBackgroundColor];
	}

	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!USE_CARDS) {
		return defaultRowHeight;
	}

	CGFloat peek = [self cardStackPeekHeight];

	// The last card has nothing stacked on top of it, so give it whatever room is
	// left — with only a few notes its whole body shows, Wallet-style.
	if (indexPath.row + 1 == [self tableView:tableView numberOfRowsInSection:indexPath.section]) {
		CGFloat remaining = [self cardStackAvailableHeight] - (CGFloat)indexPath.row * peek;
		CGFloat lastRowHeight = MIN([self noteCardHeight], remaining);

		return (lastRowHeight > peek) ? lastRowHeight : peek;
	}

	return peek;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ALUMasterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	NSString *object = self.objects[indexPath.row];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE];
	cell.textLabel.attributedText = ALUAdaptiveAttributedString([NKFColor attributedStringForCompanyName:[object description]]);

	cell.backgroundColor = [UIColor clearColor];
	cell.opaque = NO;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	if (USE_CARDS) {
		// One call configures color, text, style and icon; every card gets an icon
		// (monogram fallback) unless the note's icon setting is off.
		[cell.cardView configureWithNoteTitle:object];
		cell.textLabel.hidden = YES;
		cell.accessoryView.hidden = YES;

		return cell;
	}

	cell.textLabel.hidden = NO;
	UIImage *companyLogoImage = [[ALUDataManager sharedDataManager] imageForCompanyName:cell.textLabel.text];

	if (companyLogoImage && [[ALUDataManager sharedDataManager] showImageForListTitle:cell.textLabel.text]) {
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
	} else {
		cell.accessoryView.hidden = YES;
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self usesCardStackInteraction] && !tableView.isEditing) {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		[self expandCardAtIndexPath:indexPath];
	}
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
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		    [self reloadAfterDeleting];
		});
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
	    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	[self reloadAfterDeleting];
}

- (void)reloadAfterDeleting {
    return;
}

- (void)delayedReload {
    if (!_lastReloadDate || [_lastReloadDate timeIntervalSinceNow] < -1) {
        self.objects = [[ALUDataManager sharedDataManager] lists];
        [self.tableView reloadData];
        _lastReloadDate = [NSDate date];
    }
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
			UIEdgeInsets indicatorInsets = scrollView.verticalScrollIndicatorInsets;
			self.tableView.verticalScrollIndicatorInsets = UIEdgeInsetsMake(indicatorInsets.top,
																			indicatorInsets.left,
																			0.0f,
																			indicatorInsets.right);
			[self resignFirstResponder];
		} else if (overScrolledDistance > 0.0f) {
			[self becomeFirstResponder];
		}

		_previousContentOffset = self.tableView.contentOffset;
	}
}

@end
