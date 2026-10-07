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

#import "ALUSettingsViewController.h"
#import "ALUNoteCardView.h"
#import "ALUExternalDisplayController.h"

// Generated interface for ALUNotePolisher.swift and ALUIconEditorViewController.swift.
#import "Alphabetical_List_Utility-Swift.h"

// kScreenWidth / kScreenHeight / kStatusBarHeight come from PrefixHeader.pch. They used to be
// redefined here, which shadowed the shared versions and kept this screen on the deprecated
// -statusBarFrame math that evaluates to 0 on every notched / Dynamic Island device.

#define kViewControllerWidth self.view.frame.size.width
#define kViewControllerHeight self.view.frame.size.height

static CGFloat const ALUDetailViewControllerMaxFontSize = 60.0f;

static CGFloat const ALUDetailViewControllerMinFontSize = 6.0f;

static NSString * const numericDelimeter = @".) ";

@interface DetailViewController () <ALUSettingsViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *actionButton;

@property (nonatomic, strong) UIBarButtonItem *polishButton;

@property (nonatomic, strong) UIBarButtonItem *overflowButton;

@property (nonatomic, strong) UIButton *titleViewButton;

@end

@implementation DetailViewController {
	CGFloat _tempFontSize, _currentFontSize;
	BOOL _isKeyboardShowing;
	BOOL _pickingPhotoForNoteBody;
	UITextField *_alertTextField;
	BOOL _noteWasDeleted;
	BOOL _isPolishingNote;
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
	
	self.navigationItem.rightBarButtonItems = @[self.overflowButton];

	[self.navigationItem setTitleView:self.titleViewButton];
	[self.titleViewButton setTitleColor:[[NKFColor colorForCompanyName:_detailItem] oppositeBlackOrWhite] forState:UIControlStateNormal];
	[self.titleViewButton setTitle:_detailItem forState:UIControlStateNormal];
	self.navigationController.title = @"";

	// Fires on every detailItem change — including iPad split view and the card
	// stack, where the controller stays on screen and viewWillAppear never runs.
	[[ALUExternalDisplayController sharedController] showNoteWithTitle:_detailItem
																	text:nil
														  scrollFraction:[self currentScrollFraction]];
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
	[self applyCardStyleToEditor];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[ALUExternalDisplayController sharedController] showNoteWithTitle:_detailItem
																	text:nil
														  scrollFraction:[self currentScrollFraction]];

	[self setNeedsStatusBarAppearanceUpdate];
	
	[self.splitViewController setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.navigationController.navigationBar.barTintColor) {
        ALUApplyNavigationBarColor(self.navigationController.navigationBar,
                                   [NKFColor appColor],
                                   [(NKFColor *)[NKFColor appColor] oppositeBlackOrWhite]);
    }

    [self.listItemTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self saveList];

	// Back to the list: the external screen falls back to the idle view. Presenting
	// something over the note (settings, share sheet) is not leaving it.
	if (self.isMovingFromParentViewController || self.isBeingDismissed) {
		[[ALUExternalDisplayController sharedController] showNoteWithTitle:nil text:nil scrollFraction:0.0f];
	}
}

// Bottom edge of the navigation bar in this controller's coordinate space. Pushed
// normally, the bar sits below the status bar; embedded in the card UI it sits at the
// card's top edge — measuring the bar's actual frame handles both, where the old
// "bar height + status bar height" formula assumed the pushed layout.
- (CGFloat)topBarBottom {
	return CGRectGetMaxY(self.navigationController.navigationBar.frame);
}

- (void)findTextView {
	for (UIView *subview in self.view.subviews) {
		if ([subview isEqual:self.listItemTextView]) {
			[self updateViewConstraints];
		}
	}
}

- (void)saveList {
	// Saving after the note was deleted from the overflow menu would recreate it.
	if (_noteWasDeleted) {
		return;
	}

	// While Writing Tools is mid-rewrite the text view's contents are a transient preview that
	// the user has not accepted yet. Persisting it here would commit a suggestion they may
	// reject; -textViewWritingToolsDidEnd: saves once they've decided.
	if (@available(iOS 18.0, *)) {
		if (self.listItemTextView.isWritingToolsActive) {
			return;
		}
	}

	// Saves rich text, and mirrors the plain string so sharing, email, reminder bodies and the
	// master list keep working exactly as before.
	[[ALUDataManager sharedDataManager] saveAttributedList:self.listItemTextView.attributedText
												 withTitle:_detailItem];
}

// On iPad the notes list is presented as a sidebar floating over the note. The note text view
// spans the full width underneath it, so short lines were rendered behind the sidebar and the
// note looked blank. Inset the text so it always begins clear of the sidebar.
- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	UISplitViewController *splitViewController = self.splitViewController;
	CGFloat sidebarClearance = 0.0f;

	if (splitViewController &&
		!splitViewController.isCollapsed &&
		splitViewController.displayMode != UISplitViewControllerDisplayModeSecondaryOnly) {
		// Only inset where the sidebar actually overlaps this view.
		CGRect sidebarFrame = [self.view convertRect:self.view.bounds toView:nil];
		sidebarClearance = MAX(0.0f, splitViewController.primaryColumnWidth - sidebarFrame.origin.x);
	}

	UIEdgeInsets textInsets = self.listItemTextView.textContainerInset;
	if (fabs(textInsets.left - sidebarClearance) > 0.5f) {
		textInsets.left = sidebarClearance;
		self.listItemTextView.textContainerInset = textInsets;
	}
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
											 [self topBarBottom] + borderWidth,
											 kViewControllerWidth - borderWidth * 2.0f,
											 kViewControllerHeight - ([self topBarBottom] + borderWidth));
	
	for (UITextView *subview in self.view.subviews) {
		if ([subview isKindOfClass:[UITextView class]]) {
			if (![subview isEqual:self.listItemTextView] && [subview respondsToSelector:@selector(text)]) {
				subview.frame = CGRectMake(borderWidth,
										   [self topBarBottom] + borderWidth,
										   kViewControllerWidth - borderWidth * 2.0f,
										   kViewControllerHeight - ([self topBarBottom] + borderWidth));
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
    ALUApplyNavigationBarColor(self.navigationController.navigationBar, [NKFColor appColor], [NKFColor whiteColor]);
    ALUApplyNavigationBarColor(self.navigationController.navigationController.navigationBar, [NKFColor appColor], [NKFColor whiteColor]);
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
	
    [self updateViewConstraints];
}


#pragma mark - Subviews

// Load the note as rich text. Notes written before rich text existed come back with no attributes
// at all, so those get the editor's base font rather than rendering at RTF defaults.
- (void)loadNoteTextWithBaseFont:(UIFont *)baseFont {
	NSAttributedString *storedText = [[ALUDataManager sharedDataManager] attributedListWithTitle:_detailItem];

	if (storedText.length == 0) {
		_listItemTextView.text = @"";
		return;
	}

	NSMutableAttributedString *noteText = [storedText mutableCopy];
	NSRange fullRange = NSMakeRange(0, noteText.length);

	[noteText enumerateAttribute:NSFontAttributeName
						 inRange:fullRange
						 options:0
					  usingBlock:^(UIFont *font, NSRange range, BOOL *stop) {
						  if (!font) {
							  [noteText addAttribute:NSFontAttributeName value:baseFont range:range];
						  }
					  }];

	// Force the semantic label colour: RTF carries an explicit (usually black) colour, which
	// would be unreadable in dark mode.
	[noteText addAttribute:NSForegroundColorAttributeName value:[UIColor labelColor] range:fullRange];

	_listItemTextView.attributedText = noteText;
}

// Resize without flattening formatting. Assigning -font would collapse every bold/italic run to
// one uniform font, so scale each run instead and keep its traits.
- (void)applyNoteFontSize:(CGFloat)fontSize {
	UITextView *textView = self.listItemTextView;
	UIFont *baseFont = [UIFont systemFontOfSize:fontSize];

	if (textView.attributedText.length == 0) {
		textView.font = baseFont;
	} else {
		NSMutableAttributedString *scaledText = [textView.attributedText mutableCopy];
		NSRange fullRange = NSMakeRange(0, scaledText.length);

		[scaledText enumerateAttribute:NSFontAttributeName
							   inRange:fullRange
							   options:0
							usingBlock:^(UIFont *font, NSRange range, BOOL *stop) {
								UIFont *runFont = font ?: baseFont;
								[scaledText addAttribute:NSFontAttributeName
												   value:[runFont fontWithSize:fontSize]
												   range:range];
							}];

		NSRange selectedRange = textView.selectedRange;
		textView.attributedText = scaledText;
		textView.selectedRange = selectedRange;
	}

	NSMutableDictionary *typingAttributes = [textView.typingAttributes mutableCopy];
	typingAttributes[NSFontAttributeName] = baseFont;
	textView.typingAttributes = typingAttributes;
}

- (UITextView *)listItemTextView {
	if (!_listItemTextView) {
		_listItemTextView = [[UITextView alloc] initWithFrame:CGRectInset(self.view.bounds, borderWidth, 0.0f)];
		_listItemTextView.tag = 17;
		_listItemTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
		_listItemTextView.keyboardType = UIKeyboardTypeAlphabet;
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
		
		UIFont *baseFont = [UIFont boldSystemFontOfSize:_tempFontSize];
		[_listItemTextView setFont:baseFont];

		// Rich text: users get Bold/Italic/Underline from the selection menu, and Writing Tools
		// can hand back formatted results (such as lists).
		_listItemTextView.allowsEditingTextAttributes = YES;
		_listItemTextView.typingAttributes = @{NSFontAttributeName : baseFont,
											   NSForegroundColorAttributeName : [UIColor labelColor]};

		[self loadNoteTextWithBaseFont:baseFont];

		UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
		[_listItemTextView addGestureRecognizer:pinch];
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

- (UIBarButtonItem *)polishButton {
	if (!_polishButton) {
		UIImage *icon = [UIImage systemImageNamed:@"wand.and.sparkles"];
		_polishButton = [[UIBarButtonItem alloc] initWithImage:icon
														 style:UIBarButtonItemStylePlain
														target:self
														action:@selector(polishButtonTouched:)];
		_polishButton.accessibilityLabel = NSLocalizedString(@"Polish Note", nil);
		_polishButton.accessibilityHint = NSLocalizedString(@"Proofreads and rewrites this note, or tidies its formatting", nil);
	}

	return _polishButton;
}

// The single "…" menu in the top-right corner: Share, Polish, Note Settings, and Delete. Built
// uncached so the Share row's enabled state always reflects the current note text.
- (UIBarButtonItem *)overflowButton {
	if (!_overflowButton) {
		__weak typeof(self) weakSelf = self;
		UIDeferredMenuElement *items = [UIDeferredMenuElement elementWithUncachedProvider:^(void (^completion)(NSArray<UIMenuElement *> *)) {
			__strong typeof(weakSelf) strongSelf = weakSelf;
			if (!strongSelf) {
				completion(@[]);
				return;
			}

			UIAction *shareAction = [UIAction actionWithTitle:NSLocalizedString(@"Share", nil)
														image:[UIImage systemImageNamed:@"square.and.arrow.up"]
												   identifier:nil
													  handler:^(UIAction *action) {
				[strongSelf actionButtonTouched:strongSelf.overflowButton];
			}];
			shareAction.attributes = strongSelf.actionButton.enabled ? 0 : UIMenuElementAttributesDisabled;

			UIAction *polishAction = [UIAction actionWithTitle:NSLocalizedString(@"Polish Note", nil)
														 image:[UIImage systemImageNamed:@"wand.and.sparkles"]
													identifier:nil
													   handler:^(UIAction *action) {
				[strongSelf polishButtonTouched:strongSelf.overflowButton];
			}];
			if (![strongSelf canPolishNote]) {
				polishAction.attributes = UIMenuElementAttributesDisabled;
				polishAction.subtitle = strongSelf->_isPolishingNote ? NSLocalizedString(@"Polishing…", nil) : NSLocalizedString(@"Text-only notes", nil);
			}

			// The classic settings panel (list mode, icons, card style, location
			// reminders, …) — same one that opens when tapping the note title.
			UIAction *settingsAction = [UIAction actionWithTitle:NSLocalizedString(@"Note Settings", nil)
														   image:[UIImage systemImageNamed:@"gearshape"]
													  identifier:nil
														 handler:^(UIAction *action) {
				[strongSelf titleTapped:strongSelf.overflowButton];
			}];

			// Note actions — renaming, inserting a photo, and the numbered-list line
			// operations. One-shot actions on the note, so they live here rather than in
			// the settings sheet, which is for configuration.
			NSMutableArray<UIMenuElement *> *noteActions = [NSMutableArray array];

			UIAction *renameAction = [UIAction actionWithTitle:NSLocalizedString(@"Rename Note", nil)
														 image:[UIImage systemImageNamed:@"character.cursor.ibeam"]
													identifier:nil
													   handler:^(UIAction *action) {
				[strongSelf renameList];
			}];
			[noteActions addObject:renameAction];

			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
				UIAction *insertPhotoAction = [UIAction actionWithTitle:NSLocalizedString(@"Insert Photo", nil)
																  image:[UIImage systemImageNamed:@"photo.badge.plus"]
															 identifier:nil
																handler:^(UIAction *action) {
					[strongSelf insertPhotoInNote];
				}];
				[noteActions addObject:insertPhotoAction];
			}

			if ([[ALUDataManager sharedDataManager] listModeForListTitle:strongSelf->_detailItem]) {
				UIAction *sortAction = [UIAction actionWithTitle:NSLocalizedString(@"Sort Lines A–Z", nil)
														   image:[UIImage systemImageNamed:@"arrow.up.arrow.down"]
													  identifier:nil
														 handler:^(UIAction *action) {
					[strongSelf alphabetize];
				}];
				[noteActions addObject:sortAction];
			} else {
				UIAction *stripAction = [UIAction actionWithTitle:NSLocalizedString(@"Strip Line Numbers", nil)
															image:[UIImage systemImageNamed:@"eraser"]
													   identifier:nil
														  handler:^(UIAction *action) {
					[strongSelf removeListModeNumbersCurrentSelectedTextRange:NSMakeRange(0, 0) replacementText:@""];
				}];
				[noteActions addObject:stripAction];
			}

			UIMenu *noteActionsMenu = [UIMenu menuWithTitle:@""
													  image:nil
												 identifier:nil
													options:UIMenuOptionsDisplayInline
												   children:noteActions];

			UIAction *deleteAction = [UIAction actionWithTitle:NSLocalizedString(@"Delete Note", nil)
														 image:[UIImage systemImageNamed:@"trash"]
													identifier:nil
													   handler:^(UIAction *action) {
				[strongSelf confirmDeleteNote];
			}];
			deleteAction.attributes = UIMenuElementAttributesDestructive;

			completion(@[shareAction, polishAction, noteActionsMenu, settingsAction, deleteAction]);
		}];

		_overflowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"ellipsis.circle"]
															menu:[UIMenu menuWithChildren:@[items]]];
		_overflowButton.accessibilityLabel = NSLocalizedString(@"More", nil);
	}

	return _overflowButton;
}

#pragma mark - Delete Note

- (void)confirmDeleteNote {
	UIAlertController *confirmController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete “%@”?", nil), _detailItem]
																			   message:NSLocalizedString(@"This note will be deleted. This cannot be undone.", nil)
																		preferredStyle:UIAlertControllerStyleAlert];

	[confirmController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
														  style:UIAlertActionStyleCancel
														handler:nil]];
	[confirmController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil)
														  style:UIAlertActionStyleDestructive
														handler:^(UIAlertAction *action) {
		[self deleteNote];
	}]];

	[self presentViewController:confirmController animated:YES completion:nil];
}

- (void)deleteNote {
	[[ALUDataManager sharedDataManager] removeList:_detailItem];
	[[ALUDataManager sharedDataManager] removeReminderForListTitle:_detailItem];
	// From here on the lifecycle saves (viewWillDisappear etc.) must not resurrect
	// the note; -saveList checks this flag.
	_noteWasDeleted = YES;

	if ([self.delegate respondsToSelector:@selector(reloadList)]) {
		[self.delegate reloadList];
	}
	if ([self.delegate respondsToSelector:@selector(noteWasDeleted)]) {
		[self.delegate noteWasDeleted];
	}

	// Pushed normally this returns to the list; embedded in the card UI this is the
	// navigation root, so it's a harmless no-op and the delegate handled teardown.
	[self.navigationController popViewControllerAnimated:YES];
	self.listItemTextView.text = @"";
}

#pragma mark - Polish

// Hand the note to Apple's Writing Tools (proofread / rewrite / summarise). Where Writing Tools
// isn't available — an older device, or Apple Intelligence switched off — fall back to a
// deterministic tidy so the button always does something useful.
- (void)polishButtonTouched:(id)sender {
	UITextView *textView = self.listItemTextView;
	if (![self canPolishNote]) {
		return;
	}

	if ([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
		return;
	}

	// Prefer the on-device foundation model: unlike Writing Tools, which can route to Private
	// Cloud Compute, it never sends the note off the device.
	if ([ALUNotePolisher isAvailable]) {
		[self polishNoteOnDevice];
		return;
	}

	if (@available(iOS 18.2, *)) {
		// Writing Tools works on the selection; with an empty selection, offer the whole note.
		if (textView.selectedRange.length == 0) {
			textView.selectedRange = NSMakeRange(0, textView.text.length);
		}

		if (![textView isFirstResponder]) {
			[textView becomeFirstResponder];
		}

		// Ask the system rather than guessing at device eligibility: this returns NO when
		// Apple Intelligence is unavailable or switched off.
		if ([textView canPerformAction:@selector(showWritingTools:) withSender:sender]) {
			[textView showWritingTools:sender];
			return;
		}
	}

	[self tidyNoteFormatting];
}

// Run the note through Apple's on-device foundation model. The text never leaves the device.
- (BOOL)canPolishNote {
	if (_noteWasDeleted || _isPolishingNote) {
		return NO;
	}
	// Whole-note text replacement cannot preserve embedded photos.
	NSAttributedString *note = self.listItemTextView.attributedText;
	__block BOOL hasAttachment = NO;
	[note enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, note.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
		if (value) { hasAttachment = YES; *stop = YES; }
	}];
	return !hasAttachment;
}

- (void)polishNoteOnDevice {
	if (![self canPolishNote]) {
		return;
	}
	UITextView *textView = self.listItemTextView;
	NSAttributedString *originalText = [textView.attributedText copy];
	NSString *originalTitle = [_detailItem copy];

	// The model takes a moment; make it obvious the button is working and can't be re-triggered.
	self.polishButton.enabled = NO;
	_isPolishingNote = YES;

	__weak typeof(self) weakSelf = self;
	[ALUNotePolisher polishNote:textView.text
					 completion:^(NSString * _Nullable polishedNote, NSError * _Nullable error) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		if (!strongSelf) {
			return;
		}

		strongSelf.polishButton.enabled = YES;
		strongSelf->_isPolishingNote = NO;
		if (strongSelf->_noteWasDeleted || ![strongSelf->_detailItem isEqual:originalTitle] ||
			![strongSelf.listItemTextView.attributedText isEqualToAttributedString:originalText]) {
			return;
		}

		if (!polishedNote) {
			DLog(@"On-device polish failed: %@", error);
			// Rather than dead-end, fall back to the tidy so the tap still achieves something.
			[strongSelf tidyNoteFormatting];
			return;
		}

		if ([polishedNote isEqualToString:originalText.string]) {
			return;
		}

		[strongSelf replaceNoteTextWithPolishedText:polishedNote originalText:originalText];
	}];
}

// Swap in the polished text while keeping the note's formatting attributes, and register an undo
// so a polish the user dislikes is one shake (or Cmd-Z) away from being reverted.
- (void)replaceNoteTextWithPolishedText:(NSString *)polishedNote
						   originalText:(NSAttributedString *)originalText {
	UITextView *textView = self.listItemTextView;
	if (![self canPolishNote] || ![textView.attributedText isEqualToAttributedString:originalText]) {
		return;
	}

	// Carry the note's existing typing attributes across so the polished text matches the rest of
	// the note rather than reverting to system defaults.
	NSDictionary *attributes = textView.typingAttributes;
	if (originalText.length > 0) {
		attributes = [originalText attributesAtIndex:0 effectiveRange:NULL];
	}

	NSAttributedString *polishedText = [[NSAttributedString alloc] initWithString:polishedNote
																	  attributes:attributes];

	[[textView.undoManager prepareWithInvocationTarget:textView] setAttributedText:originalText];
	[textView.undoManager setActionName:NSLocalizedString(@"Polish", nil)];

	textView.attributedText = polishedText;
	[self saveList];
}

// Structural clean-up that needs no model at all, so it works on every device: normalise bullet
// glyphs, drop trailing whitespace, collapse runs of blank lines, and capitalise each line.
- (void)tidyNoteFormatting {
	if (![self canPolishNote]) {
		return;
	}
	UITextView *textView = self.listItemTextView;
	NSArray<NSString *> *lines = [textView.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSMutableArray<NSString *> *tidiedLines = [[NSMutableArray alloc] initWithCapacity:lines.count];
	NSCharacterSet *bulletCharacters = [NSCharacterSet characterSetWithCharactersInString:@"*-–—•"];
	NSInteger consecutiveBlankLines = 0;

	for (NSString *line in lines) {
		NSString *tidiedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

		if (tidiedLine.length == 0) {
			// Keep paragraph breaks, but collapse longer runs of blank lines down to one.
			consecutiveBlankLines++;
			if (consecutiveBlankLines == 1 && tidiedLines.count > 0) {
				[tidiedLines addObject:@""];
			}
			continue;
		}
		consecutiveBlankLines = 0;

		// Normalise whatever bullet character was used to a single consistent one.
		if (tidiedLine.length > 1 && [bulletCharacters characterIsMember:[tidiedLine characterAtIndex:0]]) {
			NSString *body = [[tidiedLine substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if (body.length > 0) {
				tidiedLine = [NSString stringWithFormat:@"• %@", body];
			}
		}

		// Capitalise the first letter without touching the rest (which may be an acronym).
		NSUInteger firstLetterIndex = [tidiedLine rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location;
		if (firstLetterIndex != NSNotFound) {
			NSString *firstLetter = [tidiedLine substringWithRange:NSMakeRange(firstLetterIndex, 1)];
			tidiedLine = [tidiedLine stringByReplacingCharactersInRange:NSMakeRange(firstLetterIndex, 1)
															withString:[firstLetter uppercaseString]];
		}

		[tidiedLines addObject:tidiedLine];
	}

	// Drop any trailing blank line the collapse may have left behind.
	while (tidiedLines.count > 0 && [[tidiedLines lastObject] length] == 0) {
		[tidiedLines removeLastObject];
	}

	NSString *tidiedText = [tidiedLines componentsJoinedByString:@"\n"];
	if ([tidiedText isEqualToString:textView.text]) {
		return;
	}

	textView.text = tidiedText;
	[self saveList];
}

#pragma mark - Writing Tools

- (void)textViewWritingToolsDidEnd:(UITextView *)textView {
	// The user has accepted or rejected the suggestion, so the text is settled — persist it.
	[self saveList];

	if ([[ALUDataManager sharedDataManager] listModeForListTitle:_detailItem]) {
		[self updateTextWithLineNumbersRange:NSMakeRange(0, 0) replacementText:@""];
	}
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
	[self.listItemTextView resignFirstResponder];

	BOOL hasNoteText = [self.listItemTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;

	[ALUSettingsViewController presentForListName:_detailItem
	                                        color:self.navigationController.navigationBar.barTintColor
	                                  hasNoteText:hasNoteText
	                                     delegate:self
	                                         from:self];
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
	self.listItemTextView.frame = CGRectMake(borderWidth, 0.0f, kViewControllerWidth - borderWidth * 2.0f, kViewControllerHeight - ([self topBarBottom] + borderWidth));
	NSDictionary *info = [aNotification userInfo];
	CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	UIEdgeInsets contentInsets = UIEdgeInsetsMake([self topBarBottom] + borderWidth, 0.0, kbSize.height, 0.0);
	self.listItemTextView.contentInset = contentInsets;
	self.listItemTextView.scrollIndicatorInsets = UIEdgeInsetsMake([self topBarBottom], -borderWidth * 2.0f, -borderWidth, -borderWidth);
	
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
	self.listItemTextView.contentInset = UIEdgeInsetsMake([self topBarBottom] + borderWidth, 0.0f, borderWidth, 0.0f);
	self.listItemTextView.scrollIndicatorInsets = UIEdgeInsetsMake([self topBarBottom], -borderWidth * 2.0f, -borderWidth, -borderWidth);
	
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
    
    [self applyNoteFontSize:_tempFontSize];
	
	if (sender.state == UIGestureRecognizerStateEnded) {
		_currentFontSize = _tempFontSize;
        [[ALUDataManager sharedDataManager] saveAdjustedFontSize:_currentFontSize];
    }
}

#pragma mark - Action Button

- (void)actionButtonTouched:(id)sender {
	if (self.listItemTextView.text.length > 0) {
		UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.listItemTextView.text] applicationActivities:nil];
		activityVC.popoverPresentationController.barButtonItem = self.overflowButton;
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

	[self checkForActionButtonAbility];

	// Live typing mirrors to the external screen before the note is saved.
	[[ALUExternalDisplayController sharedController] showNoteWithTitle:_detailItem
																	text:textView.text
														  scrollFraction:[self currentScrollFraction]];
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

// How far the phone has scrolled through the note (0 = top, 1 = bottom), so the
// external screen can show the same portion of text.
- (CGFloat)currentScrollFraction {
	UITextView *textView = self.listItemTextView;
	CGFloat scrollableHeight = textView.contentSize.height - textView.bounds.size.height;
	if (scrollableHeight <= 0.0f) {
		return 0.0f;
	}
	return (CGFloat)fmax(0.0, fmin(1.0, textView.contentOffset.y / scrollableHeight));
}

// UIScrollViewDelegate: UITextView forwards scroll events to its own delegate,
// which is already self via listItemTextView.delegate.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView != self.listItemTextView) {
		return;
	}

	[[ALUExternalDisplayController sharedController] showNoteWithTitle:_detailItem
																	text:nil
														  scrollFraction:[self currentScrollFraction]];
}


#pragma mark - Line Numbers

- (void)rewriteListRange:(NSRange)range replacementText:(NSString *)text numbered:(BOOL)numbered {
    UITextView *textView = self.listItemTextView;
    NSMutableAttributedString *note = [textView.attributedText mutableCopy];
    if (!note || range.location > note.length || range.length > note.length - range.location) {
        return;
    }

    NSRange selection = textView.selectedRange;
    // Empty replacement means reformat existing content; only the Return delegate inserts text.
    if (text.length > 0) {
        NSMutableDictionary *attributes = [textView.typingAttributes mutableCopy] ?: [NSMutableDictionary new];
        [attributes removeObjectForKey:NSAttachmentAttributeName];
        [note replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:text attributes:attributes]];
        selection = NSMakeRange(range.location + text.length, 0);
    }
    NSUInteger selectionStart = MIN(selection.location, note.length);
    NSUInteger selectionEnd = selectionStart + MIN(selection.length, note.length - selectionStart);
    NSString *plain = note.string;
    NSMutableArray<NSValue *> *lines = [NSMutableArray new];
    NSUInteger start = 0;
    while (start < plain.length) {
        NSUInteger end, contentsEnd;
        [plain getLineStart:NULL end:&end contentsEnd:&contentsEnd forRange:NSMakeRange(start, 0)];
        [lines addObject:[NSValue valueWithRange:NSMakeRange(start, contentsEnd - start)]];
        start = end;
    }
    if (plain.length == 0 || [[NSCharacterSet newlineCharacterSet] characterIsMember:[plain characterAtIndex:plain.length - 1]]) {
        [lines addObject:[NSValue valueWithRange:NSMakeRange(plain.length, 0)]];
    }

    // Change only prefixes, backwards, so photos, styling, line breaks and source ranges survive.
    for (NSInteger index = (NSInteger)lines.count - 1; index >= 0; index--) {
        NSRange line = lines[index].rangeValue;
        NSString *body = [plain substringWithRange:line];
        NSUInteger delimiter = [body rangeOfString:numericDelimeter].location;
        NSUInteger oldLength = 0;
        if (delimiter != NSNotFound && delimiter > 0 &&
            [body rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet options:0 range:NSMakeRange(0, delimiter)].location == NSNotFound) {
            oldLength = delimiter + numericDelimeter.length;
        }
        NSString *prefix = numbered ? [NSString stringWithFormat:@"%zd%@", index + 1, numericDelimeter] : @"";
        NSRange prefixRange = NSMakeRange(line.location, oldLength);
        NSMutableDictionary *attributes = [textView.typingAttributes mutableCopy] ?: [NSMutableDictionary new];
        [attributes removeObjectForKey:NSAttachmentAttributeName];
        if (line.length > oldLength) {
            NSMutableDictionary *bodyAttributes = [[note attributesAtIndex:line.location + oldLength effectiveRange:NULL] mutableCopy];
            [bodyAttributes removeObjectForKey:NSAttachmentAttributeName];
            attributes = bodyAttributes;
        }
        [note replaceCharactersInRange:prefixRange withAttributedString:[[NSAttributedString alloc] initWithString:prefix attributes:attributes]];
        if (selectionStart >= NSMaxRange(prefixRange)) selectionStart = selectionStart - oldLength + prefix.length;
        else if (selectionStart >= line.location) selectionStart = line.location + prefix.length;
        if (selectionEnd >= NSMaxRange(prefixRange)) selectionEnd = selectionEnd - oldLength + prefix.length;
        else if (selectionEnd >= line.location) selectionEnd = line.location + prefix.length;
    }
    textView.attributedText = note;
    textView.selectedRange = NSMakeRange(selectionStart, selectionEnd - selectionStart);
}

- (void)updateTextWithLineNumbersRange:(NSRange)range replacementText:(NSString *)text {
    [self rewriteListRange:range replacementText:text numbered:YES];
    dispatch_async(dispatch_get_main_queue(), ^{ [self delayedScroll:@(NO)]; });
}

- (void)delayedScroll:(NSNumber *)animated {
	CGRect rect = [self.listItemTextView caretRectForPosition:self.listItemTextView.selectedTextRange.end];
	[self.listItemTextView scrollRectToVisible:rect
									  animated:animated.boolValue];
	DLog(@"Scroll to %f", rect.origin.y);
}

- (void)removeListModeNumbersCurrentSelectedTextRange:(NSRange)range replacementText:(NSString *)text {
    [self rewriteListRange:range replacementText:text numbered:NO];
}

- (void)alphabetizeList {
    [self removeListModeNumbersCurrentSelectedTextRange:NSMakeRange(0, 0) replacementText:@""];

    // Sort whole attributed lines rather than plain substrings, so each line keeps whatever
    // formatting it carries instead of the sort flattening the note.
    NSAttributedString *noteText = self.listItemTextView.attributedText;
    NSMutableArray<NSAttributedString *> *lines = [[NSMutableArray alloc] init];
    NSUInteger lineStart = 0;
    NSString *plainText = noteText.string;
    while (lineStart < plainText.length) {
        NSUInteger end, contentsEnd;
        [plainText getLineStart:NULL end:&end contentsEnd:&contentsEnd forRange:NSMakeRange(lineStart, 0)];
        [lines addObject:[noteText attributedSubstringFromRange:NSMakeRange(lineStart, contentsEnd - lineStart)]];
        lineStart = end;
    }
    if (plainText.length == 0 || [[NSCharacterSet newlineCharacterSet] characterIsMember:[plainText characterAtIndex:plainText.length - 1]]) {
        [lines addObject:[[NSAttributedString alloc] initWithString:@""]];
    }

    [lines sortUsingComparator:^NSComparisonResult(NSAttributedString *first, NSAttributedString *second) {
        return [first.string localizedCaseInsensitiveCompare:second.string];
    }];

    NSMutableAttributedString *sortedText = [[NSMutableAttributedString alloc] init];
    NSAttributedString *newline = [[NSAttributedString alloc] initWithString:@"\n"];
    BOOL firstLine = YES;
    for (NSAttributedString *line in lines) {
        if (!firstLine) {
            [sortedText appendAttributedString:newline];
        }
        [sortedText appendAttributedString:line];
        firstLine = NO;
    }

    self.listItemTextView.attributedText = sortedText;
    self.listItemTextView.selectedRange = NSMakeRange(0, 0);
    [self updateTextWithLineNumbersRange:NSMakeRange(0, 0) replacementText:@""];
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

// When the settings sheet is open, icon and location UI layers onto its own navigation
// stack so configuring a setting never dismisses settings. Otherwise fall back to ours.
- (UINavigationController *)presentedSettingsNavigationController {
	UIViewController *presented = self.presentedViewController;
	if ([presented isKindOfClass:[UINavigationController class]] &&
	    [[(UINavigationController *)presented viewControllers].firstObject isKindOfClass:[ALUSettingsViewController class]]) {
		return (UINavigationController *)presented;
	}
	return nil;
}

- (UINavigationController *)settingActionNavigationController {
	return [self presentedSettingsNavigationController] ?: self.navigationController;
}

- (UIViewController *)settingActionPresenter {
	return [self presentedSettingsNavigationController] ?: self;
}

- (void)pickPhoto {
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		return;
	}
	
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = YES;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

	[[self settingActionPresenter] presentViewController:picker animated:YES completion:NULL];
}

- (void)useWebIcon {
    [[ALUDataManager sharedDataManager] setUseWebIcon:YES forListTitle:_detailItem];
    [[ALUDataManager sharedDataManager] removeImageForCompanyName:_detailItem];
    if ([self.delegate respondsToSelector:@selector(reloadList)]) {
        [self.delegate reloadList];
    }
}

#pragma mark - Card Style

- (void)cardStyleChanged {
	[self applyCardStyleToEditor];
	if ([self.delegate respondsToSelector:@selector(reloadList)]) {
		[self.delegate reloadList];
	}
}

// Washes the editor background toward the note's card style, as strongly as the
// user's editor-intensity slider says.
- (void)applyCardStyleToEditor {
	UIColor *background = [UIColor systemBackgroundColor];

	NSString *style = [[ALUDataManager sharedDataManager] cardStyleForListTitle:_detailItem];
	UIColor *styleColor = [ALUNoteCardView backgroundColorForStyle:style];
	CGFloat intensity = [[ALUDataManager sharedDataManager] cardStyleEditorIntensityForListTitle:_detailItem];

	if (styleColor && intensity > 0.02f) {
		CGFloat baseRed = 0.0f, baseGreen = 0.0f, baseBlue = 0.0f, baseAlpha = 0.0f;
		CGFloat styleRed = 0.0f, styleGreen = 0.0f, styleBlue = 0.0f, styleAlpha = 0.0f;
		[[background resolvedColorWithTraitCollection:self.traitCollection] getRed:&baseRed green:&baseGreen blue:&baseBlue alpha:&baseAlpha];
		[styleColor getRed:&styleRed green:&styleGreen blue:&styleBlue alpha:&styleAlpha];
		CGFloat blend = intensity * styleAlpha;
		background = [UIColor colorWithRed:baseRed + (styleRed - baseRed) * blend
									 green:baseGreen + (styleGreen - baseGreen) * blend
									  blue:baseBlue + (styleBlue - baseBlue) * blend
									 alpha:1.0f];
	}

	self.view.backgroundColor = background;
	self.listItemTextView.backgroundColor = [UIColor clearColor];
}

- (void)insertPhotoInNote {
	_pickingPhotoForNoteBody = YES;
	[self pickPhoto];
}

#pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];

	if (_pickingPhotoForNoteBody) {
		_pickingPhotoForNoteBody = NO;
		UIImage *photo = info[UIImagePickerControllerOriginalImage] ?: chosenImage;

		if (photo) {
			NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
			attachment.image = photo;
			CGFloat maximumWidth = self.listItemTextView.textContainer.size.width - 10.0f;
			if (maximumWidth > 0.0f && photo.size.width > maximumWidth) {
				attachment.bounds = CGRectMake(0.0f, 0.0f, maximumWidth, photo.size.height * maximumWidth / photo.size.width);
			}

			NSMutableAttributedString *noteText = [self.listItemTextView.attributedText mutableCopy];
			NSUInteger insertLocation = MIN(self.listItemTextView.selectedRange.location, noteText.length);
			[noteText insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment] atIndex:insertLocation];
			self.listItemTextView.attributedText = noteText;
			[self saveList];
		}

		[picker dismissViewControllerAnimated:YES completion:NULL];
		return;
	}

    [[ALUDataManager sharedDataManager] saveImage:chosenImage forCompanyName:_detailItem];

    [picker dismissViewControllerAnimated:YES completion:NULL];

    [[ALUDataManager sharedDataManager] setUseWebIcon:NO forListTitle:_detailItem];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	_pickingPhotoForNoteBody = NO;
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
    // Use the instance property (the class method is deprecated) and escalate correctly:
    // iOS only offers When-In-Use from NotDetermined, with Always as a later escalation.
    CLLocationManager *locationManager = [[ALUDataManager sharedDataManager] locationManager];

    switch (locationManager.authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
            [locationManager requestWhenInUseAuthorization];
            break;

        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            DLog(@"Location access denied — cannot attach a location reminder.");
            return;

        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [locationManager requestAlwaysAuthorization];
            break;

        default:
            break;
    }
    
    DLog(@"Select Location");
    
    ALUMapViewController *mapViewController = [[ALUMapViewController alloc] init];
    mapViewController.title = _detailItem;
    [[self settingActionNavigationController] pushViewController:mapViewController animated:YES];
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

- (void)editIcon {
	NSString *title = _detailItem;
	if (title.length == 0) {
		return;
	}

	ALUDataManager *dataManager = [ALUDataManager sharedDataManager];
	UIColor *tint = [ALUNoteCardView mutedColor:[NKFColor colorForCompanyName:title]];
	UIImage *current = [dataManager showImageForListTitle:title] ? [dataManager imageForCompanyName:title] : nil;

	ALUIconEditorViewController *editor = [[ALUIconEditorViewController alloc] initWithNoteTitle:title
																					   tintColor:tint
																						   image:current];
	__weak typeof(self) weakSelf = self;
	editor.onSave = ^(UIImage *image) {
		if (!image) {
			return;
		}
		// A chosen icon wins over the web favicon, matching the card's icon editor.
		[dataManager saveImage:image forCompanyName:title];
		[dataManager setUseWebIcon:NO forListTitle:title];
		if ([weakSelf.delegate respondsToSelector:@selector(reloadList)]) {
			[weakSelf.delegate reloadList];
		}
	};

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editor];
	[[weakSelf settingActionPresenter] presentViewController:navigationController animated:YES completion:nil];
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

@end
