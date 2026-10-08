//
//  ALUDataManager.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "ALUDataManager.h"
#import "ALUServicePrivacy.h"
#import "NKFColor+Universities.h"
#import "NKFColor+Companies.h"
#import <UserNotifications/UserNotifications.h>
// Generated interface for ALUImageGenerator.swift (Image Playground is Swift-only).
#import "Alphabetical_List_Utility-Swift.h"

static NSString * const separator = @"%&&^AB)*971";
static NSString * const masterListKey = @"M@$teR I1$7 K3yY";
static NSString * const userLocationLatitudeKey = @"userLocationLatitudeK£y";
static NSString * const userLocationLongitudeKey = @"userLocationLongitudeK£y";
static NSString * const previousErrorsKey = @"PreviousErros K£y";
static NSString * const useCardViewKey = @"Use Card Vi£w K3Y";
static NSString * const fontSizeKey = @"This is my font size Key and don't forget that I like Tacos";
static NSString * const adjustedFontSizeKey = @"This is my font size Key for changing the font size of the card view";

@interface ALUDataManager ()

- (void)fetchWebIconIfNeededForCompanyName:(NSString *)companyName;

@end

@implementation ALUDataManager {
	NSMutableArray *_lists;
	NSMutableDictionary *_dictionaryOfLists;
	NSMutableDictionary *_companyLogos;
	NSMutableDictionary *_listModes;
	NSMutableDictionary *_showListImages;
    NSMutableDictionary *_useWebIcon;
	NSMutableDictionary *_apiURLDictionary;
	NSMutableDictionary *_apiResponseDictionary;
    NSMutableDictionary *_geolocationReminders;
    NSMutableDictionary *_geolocationExists;
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _userLocationCoordinate;
	BOOL _noteHasBeenSelectedOnce;
	BOOL _menuShowing;
    BOOL _iCloudIsAvailable;
    ALUDocument *_document;
    NSMetadataQuery *_query;
	BOOL _useCardView;
	BOOL _shouldShowStatusBar;
	NSMutableArray *_playgroundQueue;
	NSMutableSet *_playgroundAttempted;
	BOOL _playgroundGenerating;
}

+ (instancetype)sharedDataManager {
	static ALUDataManager *sharedDataManager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedDataManager = [[ALUDataManager alloc] init];
	});
	
	return sharedDataManager;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *stringOfListTitles = [defaults objectForKey:masterListKey];
		NSArray *listTitles = [stringOfListTitles componentsSeparatedByString:separator];
		_companyLogos = [[NSMutableDictionary alloc] init];
		_listModes = [[NSMutableDictionary alloc] init];
		_showListImages = [[NSMutableDictionary alloc] init];
		_apiURLDictionary = [NSMutableDictionary dictionaryWithDictionary:[self urlDictionary]];
		_apiResponseDictionary = [[NSMutableDictionary alloc] init];
        _geolocationReminders = [[NSMutableDictionary alloc] init];
        _geolocationExists = [[NSMutableDictionary alloc] init];
		// Load the user's saved choice; the Wallet-style card list is the default until
		// they explicitly switch to the plain list.
		if ([[NSUserDefaults standardUserDefaults] objectForKey:useCardViewKey] == nil) {
			_useCardView = YES;
		} else {
			_useCardView = [[NSUserDefaults standardUserDefaults] boolForKey:useCardViewKey];
		}
		_shouldShowStatusBar = YES;
        
		_lists = [[NSMutableArray alloc] initWithArray:listTitles];
//		[_lists addObjectsFromArray:@[@"Gold Ideas", @"Groceries", @"Home Improvement", @"Office Supplies", @"Operas", @"Questions for my Dr.", @"Recipe - Coconut Shrimp", @"Recipe - Lemon Bars", @"Target Practice", @"Things to pack for Cambridge", @"Things to talk to Indigo about", @"Chocolates", @"Welcome!", @"Chores", @"Errands", @"Happy Hours", @"Meeting Notes - 7/11"]];

		for (int i = 0; i < _lists.count; ) {
			NSString *listTitle = [_lists objectAtIndex:i];
			if (listTitle.length == 0) {
				[self removeList:listTitle];
			} else {
				i++;
			}
		}
		
		_dictionaryOfLists = [[NSMutableDictionary alloc] init];
		
		for (NSString *listTitle in _lists) {
			NSString *list = [defaults objectForKey:listTitle];
			if (list) {
				[_dictionaryOfLists setObject:list forKey:listTitle];
			}
		}
		
		[self addDefaultList];
		
		[self addDailyBibleLinksIfNeeded];
        [self checkIfIcloudIsAvailable];
	}
	
	return self;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;

        // Authorization was never requested, so the manager stayed at "notDetermined" and
        // region-entry events were never delivered — the reminder feature was inert.
        // Geofencing needs Always, which iOS only grants as an escalation from When-In-Use.
        if (_locationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestWhenInUseAuthorization];
        } else if (_locationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [_locationManager requestAlwaysAuthorization];
        }

        [_locationManager startUpdatingLocation];
		
		NSSet *monitoredRegions = [NSSet setWithSet:_locationManager.monitoredRegions];
		for (CLRegion *region in monitoredRegions) {
			if (![self listWithTitle:region.identifier]) {
				[_locationManager stopMonitoringForRegion:region];
				DLog(@"List is no longer recognized");
			}
		}
    }
    
    return _locationManager;
}

- (CLLocationCoordinate2D)userLocation {
    if (_userLocationCoordinate.latitude == 0.0 &&
        _userLocationCoordinate.longitude == 0.0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        CLLocationDegrees latitude = [defaults doubleForKey:userLocationLatitudeKey];
        CLLocationDegrees longitude = [defaults doubleForKey:userLocationLongitudeKey];
        _userLocationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    
    return _userLocationCoordinate;
}


- (void)addDefaultList {
	if (_lists.count == 0 && _dictionaryOfLists.count == 0) {
		NSString *deviceType = [UIDevice currentDevice].model;
		DLog(@"deviceType: %@", deviceType);

		BOOL isiPhone = [deviceType rangeOfString:@"iPhone"].location != NSNotFound;

		// Numeric prefixes keep these three notes sorted first, ahead of the user's own
		// notes, since -lists sorts alphabetically.
		NSString *useTitle = @"1. How to Use A2Z Notes";
		NSString *useNote;
		if (isiPhone) {
			useNote = @"Welcome to A2Z Notes!\n\nThis is your first note.\n\nTap ⌄ to return to your stack of notes. Tap + to create a new note.\n\nTap the note title to view settings for that note.\n\nPinch this text to adjust the font size.";
		} else {
			useNote = @"Welcome to A2Z Notes!\n\nThis is your first note.\n\nTap \"My Notes\" to see a list of all your notes. Tap the \"+\" to create a new note.\n\nPinch this text to adjust the font size.";
		}

		NSString *settingsTitle = @"2. How to Modify a Note's Settings";
		NSString *settingsNote = @"Open a note, then tap on its title at the top of the screen.\n\nThis opens that note's settings, where you can:\n\n• Rename the note\n• Turn on numbered list mode\n• Alphabetize the note's lines\n• Add a photo or use a web icon\n• Choose a color for the note\n• Attach a location-based reminder\n• Attach a contact\n• Insert an emoji or a drawing\n• Email the note\n\nTap outside the settings to close them.";

		NSString *wandTitle = @"3. Polish Your Notes";
		NSString *wandNote = @"Choose Polish Note to tidy formatting or improve the note you're reading.\n\nRewriting requires Apple Intelligence. When it isn't available, Polish tidies formatting.\n\nThe built-in polisher uses Apple’s on-device model. If system Writing Tools are offered instead, their processing follows your Apple settings.\n\nPolished notes are saved automatically. Use Undo, or Cmd-Z with a keyboard, to restore the previous text.";

		NSString *deleteTitle = @"4. How to Delete a Note";
		NSString *goToListInstruction = isiPhone ? @"Tap ⌄ to return to your stack of notes." : @"Tap \"My Notes\" to see a list of all your notes.";
		NSString *deleteNote = [NSString stringWithFormat:@"%@\n\nSwipe left on any note, then tap Delete.\n\nIf you delete every note, these instructional notes will reappear to help you get started again.", goToListInstruction];

		for (NSArray *pair in @[@[useTitle, useNote], @[settingsTitle, settingsNote], @[wandTitle, wandNote], @[deleteTitle, deleteNote]]) {
			NSString *title = pair[0];
			NSString *note = pair[1];
			[_lists addObject:title];
			[self saveList:note withTitle:title];
		}

		[self updateListsInStorage];
	}
}

- (BOOL)addList:(NSString *)listTitle {
    NSString *cleanedTitle = [listTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
	if (![_lists containsObject:cleanedTitle]) {
		[_lists addObject:cleanedTitle];
		[self saveList:@"" withTitle:cleanedTitle];
		[self updateListsInStorage];
		[self addDailyBibleLinksIfNeeded];
		return NO;
	} else {
		DLog(@"All List titles: %@", _lists);
	}
	
	return YES;
}

- (void)removeList:(NSString *)listTitle {
	if (![_lists containsObject:listTitle]) {
		DLog(@"List does NOT exist...cannot remove");
	}
	
	[_lists removeObject:listTitle];
	[_dictionaryOfLists removeObjectForKey:listTitle];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:listTitle];
	[self removeRichTextForListTitle:listTitle];
	[self updateListsInStorage];
	DLog(@"All List titles:\t%@", _lists);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	    [self addDefaultList];
	});
}

- (void)saveList:(NSString *)list withTitle:(NSString *)title {
	if (!list) {
		DLog(@"List must exist");
		return;
	} else if (!title || title.length == 0) {
		DLog(@"Title must exist");
		return;
	}
    
    NSString *cleanedTitle = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	[_dictionaryOfLists setObject:list forKey:cleanedTitle];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:list forKey:cleanedTitle];
}

#pragma mark - Rich Text

// Rich text is stored as RTF under a namespaced key, deliberately separate from the plain-text
// value. Two reasons: the plain text stays the source of truth for everything that needs a
// string (sharing, email, reminder bodies, the master list), and a note written by an older
// build — or one whose RTF fails to decode — still opens correctly.
static NSString *ALURichTextKeyForTitle(NSString *title) {
	return [NSString stringWithFormat:@"ALURichText::%@", title];
}

- (void)saveAttributedList:(NSAttributedString *)attributedList withTitle:(NSString *)title {
	if (!attributedList || title.length == 0) {
		return;
	}

	NSString *cleanedTitle = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	// Always mirror the plain text first, so a failure below can never lose the note's content.
	[self saveList:attributedList.string withTitle:cleanedTitle];

	NSError *error = nil;
	// RTFD rather than RTF so inline image attachments survive the round trip.
	NSData *richTextData = [attributedList dataFromRange:NSMakeRange(0, attributedList.length)
									  documentAttributes:@{NSDocumentTypeDocumentAttribute : NSRTFDTextDocumentType}
												   error:&error];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (richTextData && !error) {
		[defaults setObject:richTextData forKey:ALURichTextKeyForTitle(cleanedTitle)];
	} else {
		// Don't leave stale formatting behind that no longer matches the text.
		DLog(@"Could not encode rich text for \"%@\": %@", cleanedTitle, error);
		[defaults removeObjectForKey:ALURichTextKeyForTitle(cleanedTitle)];
	}
}

- (NSAttributedString *)attributedListWithTitle:(NSString *)title {
	if (title.length == 0) {
		return nil;
	}

	NSString *cleanedTitle = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSData *richTextData = [[NSUserDefaults standardUserDefaults] dataForKey:ALURichTextKeyForTitle(cleanedTitle)];

	if (richTextData) {
		NSError *error = nil;
		// No explicit document type: the importer sniffs the format, so both new RTFD
		// notes and notes saved as RTF by earlier builds decode.
		NSAttributedString *attributedList = [[NSAttributedString alloc] initWithData:richTextData
																			 options:@{}
																  documentAttributes:nil
																			   error:&error];
		NSString *plainText = [self listWithTitle:cleanedTitle];

		// Only trust the RTF if it still matches the plain text. If another code path wrote the
		// plain value without updating the formatting, the plain text wins.
		if (attributedList && !error &&
			(!plainText || [attributedList.string isEqualToString:plainText])) {
			return attributedList;
		}
	}

	// No rich text yet (or it was stale): fall back to plain text. Saving will upgrade it.
	NSString *plainText = [self listWithTitle:cleanedTitle];
	if (!plainText) {
		return nil;
	}

	return [[NSAttributedString alloc] initWithString:plainText];
}

- (void)removeRichTextForListTitle:(NSString *)title {
	if (title.length == 0) {
		return;
	}
	NSString *cleanedTitle = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:ALURichTextKeyForTitle(cleanedTitle)];
}

- (void)updateListsInStorage {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableString *stringOfListTitles = [[NSMutableString alloc] initWithString:@""];
	NSArray *sortedList = [_lists sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	for (NSString *listTitle in sortedList) {
		[stringOfListTitles appendFormat:@"%@%@", listTitle, separator];
	}
	
	[defaults setObject:stringOfListTitles forKey:masterListKey];
}

- (NSArray *)lists {
	return [_lists sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSString *)listWithTitle:(NSString *)listTitle {
	NSString *list = [_dictionaryOfLists objectForKey:listTitle];
	if (list) {
//		NSArray *listByComponents = [list componentsSeparatedByString:separator];
		return list;
	}
	
	return nil;
}

#pragma mark - Images

- (UIImage *)imageForCompanyName:(NSString *)companyName {
	if (companyName.length == 0) {
		return nil;
	}

	if ([_companyLogos objectForKey:companyName]) {
		return [_companyLogos objectForKey:companyName];
	}

	NSString *companyNameURLString = [self companyNameURLStringForCompanyName:companyName];
	if (!companyNameURLString) {
		companyNameURLString = [self formattedListTitle:companyName];
	}

	if (companyNameURLString && [_companyLogos objectForKey:companyNameURLString]) {
		return [_companyLogos objectForKey:companyNameURLString];
	}

	// An icon the user chose themselves (camera, photo library, drawing or emoji) always wins.
	NSURL *saveLocation = [self saveLocationForCompanyNameURLString:companyNameURLString];
	if (saveLocation) {
		NSData *savedData = [NSData dataWithContentsOfURL:saveLocation];
		UIImage *savedImage = savedData ? [UIImage imageWithData:savedData] : nil;
		if (savedImage) {
			[_companyLogos setObject:savedImage forKey:companyNameURLString];
			[_companyLogos setObject:savedImage forKey:companyName];
			return savedImage;
		}
	}

	// The monogram below shows immediately as a placeholder. In the background we try to
	// do better: a real favicon when we're confident the note names a brand, or — when we
	// aren't — an on-device generated icon. fetchWebIconIfNeeded makes that call and hands
	// off to the (one-at-a-time) generator whenever no confident brand icon turns up.
	[self fetchWebIconIfNeededForCompanyName:companyName];

	// Otherwise draw a monogram in the note's own brand colour, on device.
	//
	// This replaces a logo.clearbit.com lookup. That API has been discontinued, so it fetched
	// nothing, and it sent the note's title — user content — to a third party, which meant the
	// App Store privacy label could not honestly say "Data Not Collected". The brand colours
	// themselves are bundled with the app, so the branding survives with no network at all.
	UIImage *monogram = [self monogramImageForCompanyName:companyName];
	if (monogram) {
		[_companyLogos setObject:monogram forKey:companyName];
		if (companyNameURLString) {
			[_companyLogos setObject:monogram forKey:companyNameURLString];
		}
	}

	return monogram;
}

// A rounded tile carrying the note's initials, filled with the colour the app already derives
// from the note's title. Rendered once and cached in _companyLogos.
- (UIImage *)monogramImageForCompanyName:(NSString *)companyName {
	NSString *initials = [self initialsForCompanyName:companyName];
	if (initials.length == 0) {
		return nil;
	}

	UIColor *backgroundColor = [NKFColor colorForCompanyName:companyName];
	if (!backgroundColor) {
		return nil;
	}

	// Pick a legible foreground from the fill's luminance rather than trusting a fixed colour.
	UIColor *foregroundColor = [UIColor whiteColor];
	CGFloat red = 0.0f, green = 0.0f, blue = 0.0f, alpha = 0.0f;
	if ([backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha]) {
		CGFloat luminance = 0.299f * red + 0.587f * green + 0.114f * blue;
		foregroundColor = (luminance > 0.6f) ? [UIColor blackColor] : [UIColor whiteColor];
	}

	CGFloat side = 120.0f;
	UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(side, side)];

	return [renderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
		UIBezierPath *tile = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0f, 0.0f, side, side)
													   cornerRadius:side * 0.2237f];
		[backgroundColor setFill];
		[tile fill];

		UIFont *font = [UIFont systemFontOfSize:side * 0.42f weight:UIFontWeightSemibold];
		NSDictionary *attributes = @{NSFontAttributeName : font,
									 NSForegroundColorAttributeName : foregroundColor};
		CGSize textSize = [initials sizeWithAttributes:attributes];
		CGPoint textOrigin = CGPointMake((side - textSize.width) * 0.5f,
										 (side - textSize.height) * 0.5f);
		[initials drawAtPoint:textOrigin withAttributes:attributes];
	}];
}

// "Home Improvement" -> "HI", "Groceries" -> "G". At most two letters.
- (NSString *)initialsForCompanyName:(NSString *)companyName {
	NSMutableString *initials = [[NSMutableString alloc] init];
	NSCharacterSet *nonAlphanumeric = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

	for (NSString *word in [companyName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]) {
		NSString *trimmedWord = [word stringByTrimmingCharactersInSet:nonAlphanumeric];
		if (trimmedWord.length == 0) {
			continue;
		}

		[initials appendString:[[trimmedWord substringToIndex:1] uppercaseString]];
		if (initials.length == 2) {
			break;
		}
	}

	return initials;
}

- (NSURL *)documentsDirectoryURL {
	NSError *error = nil;
	NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
														inDomain:NSUserDomainMask
											   appropriateForURL:nil
														  create:NO
														   error:&error];
	if (error) {
		// Figure out what went wrong and handle the error.
	}
	
	return url;
}

- (NSString *)companyNameURLStringForCompanyName:(NSString *)companyName {
    NSString *companyNameURLString;
    
    NSArray *validTLDs = @[@".com", @".org", @".net", @".edu"];
    
    for (NSString *validTLD in validTLDs) {
        if ([companyName hasSuffix:validTLD]) {
            companyNameURLString = [[[companyName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""] lowercaseString];
            break;
        }
    }
    
    if (!companyNameURLString) {
        companyNameURLString = [NSString stringWithFormat:@"%@.com",[[[companyName lowercaseString] componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789"] invertedSet]] componentsJoinedByString:@""]];
    }
    
    NSDictionary *forwardingWords = ALULegacyForwardingDomains();
	
    BOOL replacementFound = NO;
    for (NSString *forwardingWord in forwardingWords.allKeys) {
        if ([companyNameURLString rangeOfString:forwardingWord].location != NSNotFound && !replacementFound && forwardingWord.length * 2 > companyName.length && !replacementFound) {
            companyNameURLString = [forwardingWords objectForKey:forwardingWord];
            replacementFound = YES;
            break;
        }
    }
    
    NSArray *invalidWords = @[@"tacos", @"buff", @"cardinals", @"bills", @"eagles", @"chargers", @"buffalo", @"as", @"dodgers", @"brewers", @"twins", @"rockies", @"city", @"chores", @"officesupplies", @"samsonite", @"packing", @"aaa", @"promise", @"university", @"josh", @"sand"];
	
	if (!replacementFound) {
		for (NSString *invalidWord in invalidWords) {
			if ([companyNameURLString rangeOfString:invalidWord].location != NSNotFound && invalidWord.length * 2 >= companyNameURLString.length) {
				return nil;
			}
		}
	}
	
    NSArray *universityWords = @[@"university", @"college"];
    
    for (NSString *universityWord in universityWords) {
        if ([[companyName lowercaseString] containsString:universityWord]) {
            NSArray *words = [companyName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSMutableString *abbreviatedString = [[NSMutableString alloc] init];
            
            if ([[companyName lowercaseString] containsString:@"state"]) {
                NSString *smushedURLString = [[[companyName lowercaseString] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
                return [NSString stringWithFormat:@"%@.edu", smushedURLString];
            }
            
            for (NSString *word in words) {
                if (word.length > 1 && !(word.length == 2 && [[word lowercaseString] containsString:@"of"])) {
                    [abbreviatedString appendString:[[word substringToIndex:1] lowercaseString]];
                }
            }
            
            if (abbreviatedString.length > 2) {
                [abbreviatedString appendString:@".edu"];
                return abbreviatedString;
            }
        }
    }
    
    return companyNameURLString;
}

- (NSURL *)saveLocationForCompanyNameURLString:(NSString *)companyNameURLString {
    NSURL *documentsDirectoryURL = [self documentsDirectoryURL];
    return [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", companyNameURLString]];
}

- (void)saveImage:(UIImage *)image forCompanyName:(NSString *)companyName {
    DLog(@"Saving image for %@", companyName);
    NSString *companyNameURLString = [self companyNameURLStringForCompanyName:companyName];
    if (!companyNameURLString) {
        companyNameURLString = [self formattedListTitle:companyName];
    }
	
    NSURL *filePath = [self saveLocationForCompanyNameURLString:companyNameURLString];
	NSData *imageData = UIImagePNGRepresentation(image);
	
    [imageData writeToURL:filePath atomically:YES];
    [_companyLogos setObject:image forKey:companyName];
    [_companyLogos setObject:image forKey:companyNameURLString];
	
	imageData = [NSData dataWithContentsOfURL:filePath];

    if (!imageData) {
        DLog(@"Image data is not saved for %@", companyName);
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkForDataAtFilePath:filePath];
        });
    }
}

- (void)checkForDataAtFilePath:(NSURL *)filePath {
    NSData *imageData = [NSData dataWithContentsOfURL:filePath];
    if (!imageData) {
        DLog(@"Now the data is is missing for %@", filePath);
    }
}

- (void)removeImageForCompanyName:(NSString *)companyName {
    DLog(@"Removing image for %@", companyName);
    [_companyLogos removeObjectForKey:companyName];
    
    NSString *companyNameURLString = [self companyNameURLStringForCompanyName:companyName];
	if (!companyNameURLString) {
        companyNameURLString = [self formattedListTitle:companyName];
    }
    
    NSURL *filePath = [self saveLocationForCompanyNameURLString:companyNameURLString];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    
    [manager removeItemAtURL:filePath error:&error];
    
    if (error) {
		DLog(@"%s", __PRETTY_FUNCTION__);
        DLog(@"removeImageForCompanyName Error: %@", error.localizedDescription);
    }
}

- (BOOL)imageSavedLocallyForCompanyName:(NSString *)companyName {
    NSString *companyNameURLString = [self companyNameURLStringForCompanyName:companyName];
    if (!companyNameURLString) {
        companyNameURLString = [self formattedListTitle:companyName];
	}
    
    NSURL *filePath = [self saveLocationForCompanyNameURLString:companyNameURLString];
    NSData *imageData = [NSData dataWithContentsOfURL:filePath];
    
    if (imageData) {
        return YES;
    }
	
    return NO;
}


#pragma mark - Card Style

// Same per-title NSUserDefaults pattern as list mode / show image below.

- (void)setCardStyle:(NSString *)style forListTitle:(NSString *)title {
	if (title.length == 0) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:style forKey:[NSString stringWithFormat:@"%@cardStyle", title]];
}

- (NSString *)cardStyleForListTitle:(NSString *)title {
	if (title.length == 0) {
		return nil;
	}
	return [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@cardStyle", title]];
}

- (void)setCardStyleListIntensity:(CGFloat)intensity forListTitle:(NSString *)title {
	if (title.length == 0) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:@(intensity) forKey:[NSString stringWithFormat:@"%@cardStyleListIntensity", title]];
}

- (CGFloat)cardStyleListIntensityForListTitle:(NSString *)title {
	NSNumber *stored = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@cardStyleListIntensity", title]];
	return stored ? stored.doubleValue : 1.0f;
}

- (void)setCardStyleEditorIntensity:(CGFloat)intensity forListTitle:(NSString *)title {
	if (title.length == 0) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:@(intensity) forKey:[NSString stringWithFormat:@"%@cardStyleEditorIntensity", title]];
}

- (CGFloat)cardStyleEditorIntensityForListTitle:(NSString *)title {
	NSNumber *stored = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@cardStyleEditorIntensity", title]];
	return stored ? stored.doubleValue : 0.35f;
}

#pragma mark - List Mode

- (void)setListMode:(BOOL)listMode forListTitle:(NSString *)title {
	if ([_lists containsObject:title]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:listMode forKey:[NSString stringWithFormat:@"%@listModeEnabled", title]];
		[_listModes setObject:@(listMode) forKey:title];
	} else {
		DLog(@"setListMode: List is not recognized and cannot be set: \"%@\"\n\nAll Lists: %@", title, _lists);
	}
}

- (BOOL)listModeForListTitle:(NSString *)title {
	if ([_lists containsObject:title]) {
		if ([_listModes objectForKey:title]) {
			return [[_listModes objectForKey:title] boolValue];
		} else {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			BOOL listModeEnabled = [defaults boolForKey:[NSString stringWithFormat:@"%@listModeEnabled", title]];
			[_listModes setObject:@(listModeEnabled) forKey:title];
			return listModeEnabled;
		}
	} else {
		DLog(@"listModeForListTitle: List is not recognized: \"%@\"\n\nAll Lists: %@", title, _lists);
	}
	
	return NO;
}

- (void)setAlphabetize:(BOOL)listMode forListTitle:(NSString *)title {
    if ([_lists containsObject:title]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:listMode forKey:[NSString stringWithFormat:@"%@alphabetizeEnabled", title]];
        [_listModes setObject:@(listMode) forKey:title];
    } else {
        DLog(@"setAlphabetize: List is not recognized and cannot be set: \"%@\"\n\nAll Lists: %@", title, _lists);
    }
}

- (BOOL)alphabetizeForListTitle:(NSString *)title {
    if ([_lists containsObject:title]) {
        if ([_listModes objectForKey:title]) {
            return [[_listModes objectForKey:title] boolValue];
        } else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL listModeEnabled = [defaults boolForKey:[NSString stringWithFormat:@"%@alphabetizeEnabled", title]];
            [_listModes setObject:@(listModeEnabled) forKey:title];
            return listModeEnabled;
        }
    } else {
        DLog(@"alphabetizeForListTitle: List is not recognized: \"%@\"\n\nAll Lists: %@", title, _lists);
    }
    
    return NO;
}

#pragma mark - Image in List

// This is actually backwards in storage. A NO in storage results in a YES when pulled out so the default value is interpreted as YES

- (void)setShowImage:(BOOL)showImage forListTitle:(NSString *)title {
	if ([_lists containsObject:title]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:!showImage forKey:[NSString stringWithFormat:@"%@showImageInList", title]];
		[_showListImages setObject:@(showImage) forKey:title];
	} else {
		DLog(@"setShowImage: List is not recognized and cannot set show image: \"%@\"\n\nAll Lists: %@", title, _lists);
	}
}

- (BOOL)showImageForListTitle:(NSString *)title {
    if (!title) {
        return NO;
    }
    
	if ([_lists containsObject:title]) {
		if ([_showListImages objectForKey:title]) {
			return [[_showListImages objectForKey:title] boolValue];
		} else {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			BOOL listModeEnabled = ![defaults boolForKey:[NSString stringWithFormat:@"%@showImageInList", title]];
			[_showListImages setObject:@(listModeEnabled) forKey:title];
			return listModeEnabled;
		}
	} else {
		DLog(@"showImageForListTitle: List is not recognized: \"%@\"\n\nAll Lists: %@", title, _lists);
	}
	
	return NO;
}

- (void)setUseWebIcon:(BOOL)useWebIcon forListTitle:(NSString *)title {
    if ([_lists containsObject:title]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:!useWebIcon forKey:[NSString stringWithFormat:@"%@useWebIcon", title]];
        [_useWebIcon setObject:@(useWebIcon) forKey:title];
		
		if (useWebIcon) {
			[self removeImageForCompanyName:title];
			[_companyLogos removeAllObjects];
			[_useWebIcon removeAllObjects];
			[self imageForCompanyName:title];
		}
    } else {
        DLog(@"setUseWebIcon: List is not recognized and cannot set show image: \"%@\"\n\nAll Lists: %@", title, _lists);
    }
}

NSString * const ALUNoteIconDidLoadNotification = @"ALUNoteIconDidLoadNotification";

// Downloads a favicon for notes whose title maps to a domain in the bundled brand
// table. Only the bundled domain string leaves the device — never the note title —
// and only when the note's "Use Web Icon" setting is on. One attempt per launch.
- (void)fetchWebIconIfNeededForCompanyName:(NSString *)companyName {
	static NSMutableSet *attempted;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{ attempted = [[NSMutableSet alloc] init]; });

	// Already have a chosen / favicon / previously-generated icon on disk — leave it be.
	if ([self imageSavedLocallyForCompanyName:companyName]) {
		return;
	}

	NSString *domain = ALUWebIconDomain(companyName);
	if (!domain || ![self useWebIconForListTitle:companyName]) {
		// No favicon will be tried for this note — go straight to on-device generation.
		[self generatePlaygroundIconIfNeededForCompanyName:companyName];
		return;
	}
	if ([attempted containsObject:companyName]) {
		// A favicon is already in flight or done for this note this launch; its completion
		// routes to generation on failure, so don't double up here.
		return;
	}
	[attempted addObject:companyName];

	NSURLRequest *iconRequest = ALUWebIconRequest(companyName);
	[[ALUContentSession() dataTaskWithRequest:iconRequest
								 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		// Network failure (offline / unreachable): decide nothing. Keep the monogram and
		// let a later launch retry the favicon, so we never shadow a real brand icon with
		// a generated one just because the lookup happened to fail.
		if (error || !data || ![response isKindOfClass:NSHTTPURLResponse.class] ||
            ((NSHTTPURLResponse *)response).statusCode != 200) {
			return;
		}

		UIImage *icon = [UIImage imageWithData:data];
		// Origin websites can supply valid 16-pixel favicons. Only undecodable data fails.
		if (!icon) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self generatePlaygroundIconIfNeededForCompanyName:companyName];
			});
			return;
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			if (![self useWebIconForListTitle:companyName] || [self imageSavedLocallyForCompanyName:companyName]) return;
			[self saveImage:icon forCompanyName:companyName];
			[[NSNotificationCenter defaultCenter] postNotificationName:ALUNoteIconDidLoadNotification object:companyName];
		});
	}] resume];
}

// Fully on-device: nothing leaves the phone. Reached only after fetchWebIconIfNeeded
// decides no confident brand icon exists, so brand notes are never generated over.
// Icons are queued and generated one at a time — the model is happier not being asked
// for several at once — and results persist via saveImage. One attempt per title/launch.
- (void)generatePlaygroundIconIfNeededForCompanyName:(NSString *)companyName {
	if (!_playgroundQueue) {
		_playgroundQueue = [[NSMutableArray alloc] init];
		_playgroundAttempted = [[NSMutableSet alloc] init];
	}

	if (companyName.length == 0 ||
		![ALUImageGenerator isSupported] ||
		[self imageSavedLocallyForCompanyName:companyName] ||
		![self showImageForListTitle:companyName] ||
		[_playgroundAttempted containsObject:companyName] ||
		[_playgroundQueue containsObject:companyName]) {
		return;
	}

	[_playgroundQueue addObject:companyName];
	[self processPlaygroundQueue];
}

// Drains the queue one icon at a time. Everything here runs on the main thread — icon
// requests come from cell rendering and the generator's completion returns on the main
// queue — so the queue needs no locking.
- (void)processPlaygroundQueue {
	if (_playgroundGenerating) {
		return;
	}

	while (_playgroundQueue.count > 0) {
		NSString *companyName = _playgroundQueue.firstObject;
		[_playgroundQueue removeObjectAtIndex:0];

		// A favicon may have landed (or icons been switched off) while this note waited
		// its turn — if so it's handled, so skip it and move on.
		if ([self imageSavedLocallyForCompanyName:companyName] ||
			![self showImageForListTitle:companyName]) {
			continue;
		}

		[_playgroundAttempted addObject:companyName];
		_playgroundGenerating = YES;
		[ALUImageGenerator generateIconForNoteTitle:companyName completion:^(UIImage *icon) {
			if (icon && [_lists containsObject:companyName] &&
				[self showImageForListTitle:companyName] &&
				![self imageSavedLocallyForCompanyName:companyName]) {
			[self saveImage:icon forCompanyName:companyName];
				[[NSNotificationCenter defaultCenter] postNotificationName:ALUNoteIconDidLoadNotification object:companyName];
			}
			_playgroundGenerating = NO;
			[self processPlaygroundQueue];
		}];
		return;  // one generation in flight at a time
	}
}

- (BOOL)useWebIconForListTitle:(NSString *)title {
    if ([_lists containsObject:title]) {
        if ([_useWebIcon objectForKey:title]) {
            return [[_useWebIcon objectForKey:title] boolValue];
        } else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL useWebIcon = ![defaults boolForKey:[NSString stringWithFormat:@"%@useWebIcon", title]];
            [_useWebIcon setObject:@(useWebIcon) forKey:title];
            return useWebIcon;
        }
    } else {
        DLog(@"useWebIconForListTitle: List is not recognized: \"%@\"\n\nAll Lists: %@", title, _lists);
    }
    
    return NO;
}



#pragma mark - API Calls


- (NSString *)formattedListTitle:(NSString *)listTitle {
	NSString *formattedListTitle = [[[listTitle lowercaseString] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
	return formattedListTitle;
}

- (NSDictionary *)urlDictionary {
	return @{@"xkcd" : @"xkcd.com/info.0.com"};
}

- (BOOL)apiAvailableForTitle:(NSString *)listTitle {
	NSString *formattedListTitle = [self formattedListTitle:listTitle];
	NSString *urlString = [[self urlDictionary] objectForKey:formattedListTitle];
	if (urlString) {
		DLog(@"I should try calling %@", urlString);
		
		return YES;
	}
	
	return NO;
}

- (void)makeCallForListTitle:(NSString *)listTitle {
	// Not implemented — ALUDataManager+APICalls is an empty category. Kept as the entry point.
	// No locals here: DLog compiles out in Release, which would leave them unused.
	DLog(@"I'm ready to call \"%@\"", [_apiURLDictionary objectForKey:[self formattedListTitle:listTitle]]);
}

- (NSDictionary *)dictionaryForTitle:(NSString *)listTitle {
	NSDictionary *apiResponseDictionary = [_apiResponseDictionary objectForKey:[self formattedListTitle:listTitle]];
	
	if (apiResponseDictionary) {
		if (![apiResponseDictionary isKindOfClass:[NSDictionary class]]) {
			DLog(@"Response for %@ is kindOfClass: %@", [self formattedListTitle:listTitle], [apiResponseDictionary class]);
		}
		
		return apiResponseDictionary;
	}
	
	DLog(@"No response found %@", [self formattedListTitle:listTitle]);
	return @{};
}



#pragma mark - Geolocation Reminders

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radiusInMeters forListTitle:(NSString *)listTitle {
    NSString *formattedListTitle = [self formattedListTitle:listTitle];
    
    ALUPointAnnotation *annotation = [_geolocationReminders objectForKey:formattedListTitle];
    
    if (!annotation) {
        annotation = [[ALUPointAnnotation alloc] init];
    }
    
    annotation.coordinate = coordinate;
    annotation.radius = radiusInMeters;
    annotation.title = listTitle;
    
    [annotation save];
	
	
	// Register the reminder category and ask for notification permission here — this is the
	// moment the user actually opts in to a location reminder. (The old UIUserNotification
	// stack was removed in iOS 10 and did nothing; it also cancelled every pending
	// notification and re-prompted on each save.)
	UNNotificationAction *showNoteAction = [UNNotificationAction actionWithIdentifier:@"showNote"
																			   title:@"Show Note"
																			 options:UNNotificationActionOptionForeground];
	UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:@"showNoteNotificationCategory"
																						  actions:@[showNoteAction]
																				intentIdentifiers:@[]
																						  options:UNNotificationCategoryOptionNone];
	UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
	[center setNotificationCategories:[NSSet setWithObject:notificationCategory]];
	[center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
						  completionHandler:^(BOOL granted, NSError * _Nullable error) {
							  if (!granted) {
								  DLog(@"Notification permission not granted: %@", error);
							  }
						  }];

	// iOS monitors at most 20 regions per app; past that startMonitoringForRegion: fails
	// silently, so surface it rather than pretending the reminder was set.
	if ([self locationManager].monitoredRegions.count >= 20 &&
		![self geolocationReminderExistsForTitle:listTitle]) {
		DLog(@"Region monitoring limit (20) reached — not monitoring \"%@\"", listTitle);
	} else {
		CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:radiusInMeters identifier:listTitle];
		region.notifyOnEntry = YES;
		region.notifyOnExit = NO;
		[[self locationManager] startMonitoringForRegion:region];
	}
	
    [_geolocationReminders setObject:annotation forKey:formattedListTitle];
    [_geolocationExists setObject:@(YES) forKey:formattedListTitle];
}

- (void)setRadius:(double)radiusInMeters forListTitle:(NSString *)listTitle {
    NSString *formattedListTitle = [self formattedListTitle:listTitle];
    
    ALUPointAnnotation *annotation = [_geolocationReminders objectForKey:formattedListTitle];
    
    if (!annotation) {
        annotation = [[ALUPointAnnotation alloc] init];
    }
    
    annotation.radius = radiusInMeters;
	
	for (CLRegion *region in [self locationManager].monitoredRegions) {
		if ([region.identifier isEqualToString:listTitle]) {
			[[self locationManager] stopMonitoringForRegion:region];
			CLCircularRegion *circularRegion = [[CLCircularRegion alloc] initWithCenter:annotation.coordinate radius:radiusInMeters identifier:listTitle];
			[[self locationManager] startMonitoringForRegion:circularRegion];
		}
	}
}

- (BOOL)geolocationReminderExistsForTitle:(NSString *)listTitle {
    NSString *formattedListTitle = [self formattedListTitle:listTitle];
    
    if ([_geolocationExists objectForKey:formattedListTitle]) {
        return [[_geolocationExists objectForKey:formattedListTitle] boolValue];
    }
    
    [self annotationForTitle:listTitle];
    if ([_geolocationReminders objectForKey:[self formattedListTitle:listTitle]]) {
        return YES;
    }
	
    return NO;
}

- (MKPointAnnotation *)annotationForTitle:(NSString *)listTitle {
    if (![_geolocationReminders objectForKey:listTitle]) {
        ALUPointAnnotation *annotation = [[ALUPointAnnotation alloc] init];
        annotation.title = listTitle;
        [annotation load];
        [_geolocationReminders setObject:annotation forKey:[self formattedListTitle:listTitle]];
    }
    
    return [_geolocationReminders objectForKey:[self formattedListTitle:listTitle]];
}

- (NSString *)geolocationNameForTitle:(NSString *)listTitle {
    ALUPointAnnotation *annotation = [self annotationForTitle:listTitle];
    return annotation.addressString;
}

- (void)removeReminderForListTitle:(NSString *)listTitle {
    NSString *formattedListTitle = [self formattedListTitle:listTitle];
	
	ALUPointAnnotation *annotation = [_geolocationReminders objectForKey:[self formattedListTitle:listTitle]];
	
	if (annotation) {
		[annotation remove];
		
		// Match the region by identifier. This used to stop whichever region happened to be
		// first in the set, so deleting one note's reminder could cancel a different note's.
		NSSet *regions = [self.locationManager monitoredRegions];
		for (CLRegion *region in regions) {
			if ([region.identifier isEqualToString:listTitle]) {
				[self.locationManager stopMonitoringForRegion:region];
			}
		}
	} else {
		DLog(@"The annotation doesn't exist for the listTitle %@", listTitle);
	}
    
    [_geolocationReminders removeObjectForKey:formattedListTitle];
    [_geolocationExists setObject:@(NO) forKey:formattedListTitle];
}


#pragma mark - Location Manager Delegate

// React to the user's authorization decision. Region monitoring requires Always, which iOS
// only offers as an escalation once When-In-Use has been granted.
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
	switch (manager.authorizationStatus) {
		case kCLAuthorizationStatusAuthorizedWhenInUse:
			[manager requestAlwaysAuthorization];
			[manager startUpdatingLocation];
			break;

		case kCLAuthorizationStatusAuthorizedAlways:
			[manager startUpdatingLocation];
			break;

		default:
			DLog(@"Location access not granted; location reminders are unavailable.");
			break;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *userLocation = [locations lastObject];
    
    if (_userLocationCoordinate.longitude == 0.0 ||
        _userLocationCoordinate.latitude  == 0.0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        CLLocationDegrees latitude  = userLocation.coordinate.latitude;
        CLLocationDegrees longitude = userLocation.coordinate.longitude;
        [defaults setDouble:latitude    forKey:userLocationLatitudeKey];
        [defaults setDouble:longitude   forKey:userLocationLongitudeKey];
    }
    
    _userLocationCoordinate = userLocation.coordinate;
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *pastErrors = [defaults objectForKey:previousErrorsKey];
	
	if (!pastErrors) {
		pastErrors = @"";
	}
	
	NSMutableString *errorsString = [[NSMutableString alloc] initWithString:pastErrors];
	[errorsString appendString:@"\n\n"];
	[errorsString appendString:[[NSDate date] description]];
	NSString *currentErrorString = [NSString stringWithFormat:@"Monitoring failed for region with identifier: \"%@\"", region.identifier];
	[errorsString appendString:currentErrorString];
	[defaults setObject:currentErrorString forKey:previousErrorsKey];
	
	DLog(@"currentErrorString: %@", currentErrorString);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	DLog(@"Location manager failed with the following error: %@", error);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *pastErrors = [defaults objectForKey:previousErrorsKey];
	
	if (!pastErrors) {
		pastErrors = @"";
	}
	
	NSMutableString *errorsString = [[NSMutableString alloc] initWithString:pastErrors];
	[errorsString appendString:@"\n\n"];
	[errorsString appendString:[[NSDate date] description]];
	NSString *currentErrorString = [NSString stringWithFormat:@"Location manager failed with the following error: %@", error];
	[errorsString appendString:currentErrorString];
	[defaults setObject:currentErrorString forKey:previousErrorsKey];
	
	DLog(@"currentErrorString: %@", currentErrorString);
}


#pragma mark - App State

- (void)setNoteHasBeenSelectedOnce:(BOOL)noteHasBeenSelectedOnce {
	_noteHasBeenSelectedOnce = noteHasBeenSelectedOnce;
}

- (BOOL)noteHasBeenSelectedOnce {
	return _noteHasBeenSelectedOnce;
}

- (void)setMenuShowing:(BOOL)menuShowing {
	_menuShowing = menuShowing;
}

- (BOOL)menuShowing {
	return _menuShowing;
}

- (void)setShouldShowStatusBar:(BOOL)shouldShowStatusBar {
	_shouldShowStatusBar = shouldShowStatusBar;
}

- (BOOL)shouldShowStatusBar {
	return _shouldShowStatusBar;
}


#pragma mark - Save Font Size

- (void)saveAdjustedFontSize:(CGFloat)adjustedFontSize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:adjustedFontSize forKey:fontSizeKey];
}

- (CGFloat)currentFontSize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults floatForKey:fontSizeKey];
}

- (void)saveAdjustedFontSizeForCardViews:(CGFloat)adjustedFontSize {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:adjustedFontSize forKey:adjustedFontSizeKey];
}

- (CGFloat)currentFontSizeForCardViews {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults floatForKey:adjustedFontSizeKey];
}

#pragma mark - Card view

- (void)setUseCardView:(BOOL)useCardView {
	_useCardView = useCardView;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:useCardView forKey:useCardViewKey];
}

- (BOOL)useCardView {
	return _useCardView;
}


#pragma mark - Daily Bible passage link

- (void)addDailyBibleLinksIfNeeded {
    for (NSString *title in _lists) {
        if (!ALUIsDailyBibleNoteTitle(title)) continue;
        NSAttributedString *oldNote = [self attributedListWithTitle:title];
        if (!ALUShouldAddDailyBibleLink(oldNote.string)) continue;
        NSURL *url = ALUDailyBiblePassageURL();
        NSMutableAttributedString *updated = [[NSMutableAttributedString alloc] initWithString:@"Read today's Bible passage\n"];
        [updated appendAttributedString:[[NSAttributedString alloc] initWithString:url.absoluteString
            attributes:@{NSLinkAttributeName: url}]];
        if (oldNote.length) {
            [updated appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
            [updated appendAttributedString:oldNote];
        }
        [self saveAttributedList:updated withTitle:title];
    }
}


#pragma mark - iCloud

- (void)checkIfIcloudIsAvailable {
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        DLog(@"iCloud access at %@", ubiq);
        // TODO: Load document...
        [self loadIcloudDocument:[_lists firstObject]];
        _iCloudIsAvailable = YES;
    } else {
        DLog(@"No iCloud access");
        _iCloudIsAvailable = NO;
    }
}

- (BOOL)iCloudIsAvailable {
    return _iCloudIsAvailable;
}

- (void)setDocument:(ALUDocument *)document {
    _document = document;
}

- (ALUDocument *)document {
    return _document;
}

- (void)setQuery:(NSMetadataQuery *)query {
    _query = query;
}

- (NSMetadataQuery *)query {
    return _query;
}

- (void)loadIcloudDocument:(NSString *)noteTitle {
    if (noteTitle.length == 0) return;
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    self.query = query;
    [self.query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey, noteTitle];
    [query setPredicate:pred];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:query];
    [query startQuery];
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
    
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    
    _query = nil;
    
    [self loadData:query];
}

- (void)loadData:(NSMetadataQuery *)query {
    if ([query resultCount] == 1) {
        NSMetadataItem *item = [query resultAtIndex:0];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        ALUDocument *document = [[ALUDocument alloc] initWithFileURL:url];
        self.document = document;
        
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                DLog(@"iCloud document opened");
            } else {
                DLog(@"failed opening document from iCloud");
            }
        }];
    } else {
        if ([_lists firstObject] == nil) return;
        NSURL *ubiq = [[NSFileManager defaultManager]
                       URLForUbiquityContainerIdentifier:nil];
        if (!ubiq) return;
        NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[_lists firstObject]];
        
        ALUDocument *document = [[ALUDocument alloc] initWithFileURL:ubiquitousPackage];
        self.document = document;
        
        [document saveToURL:[document fileURL]
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  [document openWithCompletionHandler:^(BOOL success) {
                      DLog(@"new document opened from iCloud");
                  }];
              }
          }];
    }
}



@end
