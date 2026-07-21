//
//  ALUDataManager.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "ALUDataManager.h"
#import "ALUVerse.h"
#import "ALUPassage.h"
#import "NKFColor+Universities.h"
#import "NKFColor+Companies.h"
#import <UserNotifications/UserNotifications.h>

static NSString * const separator = @"%&&^AB)*971";
static NSString * const masterListKey = @"M@$teR I1$7 K3yY";
static NSString * const userLocationLatitudeKey = @"userLocationLatitudeK£y";
static NSString * const userLocationLongitudeKey = @"userLocationLongitudeK£y";
static NSString * const previousErrorsKey = @"PreviousErros K£y";
static NSString * const lastVerseOfTheDayDateKey = @"Last Verse of The Day Date K£y";
static NSString * const useCardViewKey = @"Use Card Vi£w K3Y";
static NSString * const fontSizeKey = @"This is my font size Key and don't forget that I like Tacos";
static NSString * const adjustedFontSizeKey = @"This is my font size Key for changing the font size of the card view";

static CGFloat const screenSizeLimit = 668.0f;

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
	BOOL _containsBibleVerseOfTheDay;
	NSString *_verseOfTheDayListTitle;
	NSString *_verseOfTheDay;
    BOOL _iCloudIsAvailable;
    ALUDocument *_document;
    NSMetadataQuery *_query;
	BOOL _useCardView;
	BOOL _shouldShowStatusBar;
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
		// Load the user's saved choice. The old expression tested majorVersion >= 9, which is
		// always true now, so the stored preference was discarded on every launch.
		_useCardView = [[NSUserDefaults standardUserDefaults] boolForKey:useCardViewKey];
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
		
		[self checkForBibleVerseOfTheDay];
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
		NSString *listTitle = @"Welcome!";
		
		NSString *deviceType = [UIDevice currentDevice].model;
		DLog(@"deviceType: %@", deviceType);
		
		if ([deviceType rangeOfString:@"iPhone"].location != NSNotFound) {
			if (kScreenHeight < screenSizeLimit && kScreenWidth < screenSizeLimit) {
				NSString *list = @"Welcome to A2Z Notes!\n\nThis is your first note.\n\nTap the + to create a new note.\n\nTap a note title to open that note.\n\nWith a note open, tap on the note title to see settings for that note or tap < to return to a list of all your notes.\n\nPinch this text to adjust the font size.";
				[_lists addObject:listTitle];
				[_dictionaryOfLists setObject:list forKey:listTitle];
			} else {
				NSString *list = @"Welcome to A2Z Notes!\n\nThis is your first note.\n\nTap < to see a list of all your notes. Tap the + to create a new note.\n\nTap the note title to view settings for that note.\n\nPinch this text to adjust the font size.";
				[_lists addObject:listTitle];
				[_dictionaryOfLists setObject:list forKey:listTitle];
			}
		} else /*if ([deviceType rangeOfString:@"iPad"].location != NSNotFound)*/ {
			NSString *list = @"Welcome to A2Z Notes!\n\nThis is your first note.\n\nTap \"My Notes\" to see a list of all your notes. Tap the \"+\" to create a new note.\n\nPinch this text to adjust the font size.";
			[_lists addObject:listTitle];
			[_dictionaryOfLists setObject:list forKey:listTitle];
		}
	}
}

- (BOOL)addList:(NSString *)listTitle {
    NSString *cleanedTitle = [listTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
	if (![_lists containsObject:cleanedTitle]) {
		[_lists addObject:cleanedTitle];
		[self saveList:@"" withTitle:cleanedTitle];
		[self updateListsInStorage];
		[self checkForBibleVerseOfTheDay];
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
	NSData *richTextData = [attributedList dataFromRange:NSMakeRange(0, attributedList.length)
									  documentAttributes:@{NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType}
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
		NSAttributedString *attributedList = [[NSAttributedString alloc] initWithData:richTextData
																			 options:@{NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType}
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
    
    NSDictionary *forwardingWords = @{@"volcano"			: @"volcanocorp.com",
                                      @"welcome"			: @"nathanfennel.com",
                                      @"massachusetts"		: @"mass.gov",
                                      @"arizona"			: @"az.gov",
                                      @"jets"				: @"newyorkjets.com",
                                      @"astonvilla"			: @"avfc.co.uk/",
                                      @"atlantahawks"		: @"hawks.com",
                                      @"vikings"			: @"vikings",
                                      @"bostonceltics"		: @"celtics.com",
                                      @"sacramentokings"	: @"kings.com",
                                      @"kings"				: @"lakings.com",
                                      @"seattleseahawks"	: @"seahawks.com",
                                      @"ravens"				: @"baltimoreravens.com",
                                      @"carolinapanthers"	: @"panthers.com",
                                      @"houstontexans"		: @"texans.com",
                                      @"indianapoliscolts"	: @"colts.com",
                                      @"greenbaypackers"	: @"packers.com",
                                      @"newenglandpatriots"	: @"patriots.com",
                                      @"minnesotavikings"	: @"vikings.com",
                                      @"saints"				: @"neworleanssaints.com",
                                      @"oaklandraiders"		: @"raiders.com",
                                      @"pittsburgsteelers"	: @"steelers.com",
                                      @"sandiegochargers"	: @"chargers.com",
                                      @"sdchargers"			: @"chargers.com",
                                      @"mexico"				: @"presidencia.gob.mx/",
                                      @"california"			: @"ca.gov",
                                      @"sanfrancisco49ers"	: @"49ers.com",
                                      @"49ers"				: @"49ers.com",
                                      @"rams"				: @"stlouisrams.com",
                                      @"tampabaybuccaneers"	: @"buccaneers.com",
                                      @"anaheimducks"		: @"ducks.nhl.com",
                                      @"bruins"				: @"bostonbruins.com",
                                      @"oilers"				: @"edmontonoilers.com",
                                      @"minnesotawild"		: @"wild.com",
                                      @"mapleleafs"			: @"torontomapleleafs.com",
                                      @"neworleanspelicans"	: @"pelicans.com",
                                      @"goldenstatewarriors": @"warriors.com",
                                      @"laclippers"			: @"clippers.com",
                                      @"losangelesclippers"	: @"clippers.com",
                                      @"mets"				: @"newyork.mets.mlb.com",
                                      @"padres"				: @"padres.com",
                                      @"sandiegopadres"		: @"padres.com",
                                      @"oaklandas"			: @"oaklandathletics.com",
                                      @"anaheimangels"		: @"angels.com",
                                      @"miamimarlins"		: @"marlins.com",
                                      @"chicagocubs"		: @"cubs.com",
                                      @"coloradorockies"	: @"coloradorockies.com",
                                      @"baltimoreorioles"	: @"orioles.com",
                                      @"hotspur"			: @"tottenhamhotspur.com",
                                      @"meh"				: @"meh.com",
                                      @"amazon"				: @"amazon.com",
                                      @"amazonbook"			: @"amazon.com",
                                      @"windows"            : @"microsoft.com",
                                      @"ace"                : @"acehardware.com",
                                      @"luckys"             : @"luckysmarket.com",
                                      @"harvard"            : @"harvard.edu",
                                      @"apu"                : @"apu.edu",
                                      @"calpoly"            : @"calpoly.edu",
                                      @"ucla"               : @"ucla.edu",
                                      @"usc"                : @"usc.edu",
									  @"bible"              : @"bible.com",
									  @"bibleverseoftheday" : @"bible.com",
									  @"bibleversedaily"	: @"bible.com",
									  @"dailybibleverse"    : @"bible.com",
									  @"dailyscripture"		: @"bible.com",
									  @"scriptureeveryday"  : @"bible.com",
									  @"versedaily"			: @"bible.com",
									  @"verseoftheday"      : @"bible.com",
									  @"scripturedaily"     : @"bible.com",
									  @"mit"                : @"mit.edu",
                                      @"darntoughsocks"		: @"darntough.com",
                                      @"ohiostate"          : @"osu.edu",
                                      @"ohiostateuniversity": @"osu.edu",
                                      @"michiganstateuniversity":@"msu.edu",
                                      @"michiganstate"      : @"msu.edu",
                                      @"mississippistate"   : @"mssstate.edu",
									  @"pier1imports"		: @"pier1.com",
									  @"worldmark"			: @"worldmarkbywyndham.com",
                                      @"peetscoffeeandtea"  : @"peets.com",
                                      @"peetscoffee"        : @"peets.com",
                                      @"innout"             : @"in-n-out.com",
                                      @"northeastern"       : @"northeastern.edu",
                                      @"northwestern"       : @"northwestern.edu",
                                      @"northeasternuniversity": @"northeastern.edu",
                                      @"northwesternuniversity": @"northwestern.edu",
									  @"americanairlines"	: @"aa.com",
									  @"wholefoods"			: @"wholefoodsmarket.com",
									  @"unity"				: @"unity3d.com",
									  @"aandw"				: @"awrestaurants.com",
									  @"aw"					: @"awrestaurants.com",
									  @"oculusrift"			: @"oculus.com",
									  @"benandjerrys"		: @"benjerry.com",
									  @"benjerrys"			: @"benjerry.com",
									  @"californiapizzakitchen":@"cpk.com"};
	
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


#pragma mark - Bible Verse of the Day

- (void)checkForBibleVerseOfTheDay {
	NSArray *possibleTitles = @[@"bibleverseoftheday", @"bibleversedaily", @"dailybibleverse", @"dailyscripture", @"scriptureeveryday", @"scripturedaily", @"verseoftheday", @"versedaily"];
	for (int i = 0; i < _lists.count && !_containsBibleVerseOfTheDay; i++) {
		NSString *title = [_lists objectAtIndex:i];
		NSString *formattedTitle = [self formattedListTitle:title];
		
		for (int j = 0; j < possibleTitles.count && !_containsBibleVerseOfTheDay; j++) {
			NSString *possibleTitle = [possibleTitles objectAtIndex:j];
			if ([formattedTitle containsString:possibleTitle]) {
				_containsBibleVerseOfTheDay = YES;
				_verseOfTheDayListTitle = title;
			} else {
				_containsBibleVerseOfTheDay = NO;
				_verseOfTheDayListTitle = nil;
			}
		}
	}
	
	if (_containsBibleVerseOfTheDay) {
		[self retrieveBibleVerseOfTheDay];
	} else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults removeObjectForKey:lastVerseOfTheDayDateKey];
	}
}

- (void)retrieveBibleVerseOfTheDay {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *lastVerseOfTheDayDate = [defaults objectForKey:lastVerseOfTheDayDateKey];
	
	if (!lastVerseOfTheDayDate) {
		lastVerseOfTheDayDate = [NSDate dateWithTimeIntervalSince1970:0];
	}
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
	NSDate *today = [cal dateFromComponents:components];
	components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:lastVerseOfTheDayDate];
	lastVerseOfTheDayDate = [cal dateFromComponents:components];
	
	if (![today isEqualToDate:lastVerseOfTheDayDate] ||
		[self listWithTitle:_verseOfTheDayListTitle].length == 0) {
		NSURL *URL = [NSURL URLWithString:@"https://labs.bible.org/api/?passage=votd&type=json"];
		NSURLRequest *request = [NSURLRequest requestWithURL:URL];
		NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
																			 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if (error || !data) {
				DLog(@"Error retrieving verse of the day: %@", error);
				return;
			}
			NSError *jsonError = nil;
			id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
			if (jsonError || !responseObject) {
				DLog(@"Error parsing verse of the day: %@", jsonError);
				return;
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				[self analyzeBibleVerseResponseObject:responseObject];
			});
		}];
		[task resume];
	} else {
		DLog(@"Verse does not need to be updated %@", lastVerseOfTheDayDate);
	}
}

- (void)analyzeBibleVerseResponseObject:(id)responseObject {
	if ([responseObject isKindOfClass:[NSArray class]]) {
		ALUPassage *passage = [[ALUPassage alloc] init];
		for (id object in responseObject) {
			if ([object isKindOfClass:[NSDictionary class]]) {
				ALUVerse *verse = [self verseFromJSONDictionary:object];
				[passage addVerse:verse];
				
				if (!passage.title) {
					passage.title = verse.title;
				}
				
				if (!passage.book) {
					passage.book = verse.book;
				}
			}
		}
		
		NSMutableString *updatedListText = [[NSMutableString alloc] initWithString:passage.formattedVerse.string];
		
		NSString *oldListText = [self listWithTitle:_verseOfTheDayListTitle];
		
		if (oldListText) {
			// check if the verse is already entered in the note in the right format
			if ([oldListText containsString:[updatedListText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]] ||
				[updatedListText containsString:[oldListText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]) {
				return;
			} else {
				// if the verse is not found, then add the date to the beginning of the verse and prepend the whole thing to the top of the note
				[updatedListText deleteCharactersInRange:NSMakeRange(0, updatedListText.length)];
				[updatedListText appendString:passage.formattedVersePrependedByDate.string];
				
				[updatedListText appendFormat:@"\n\n%@", oldListText];
				
				// the verse of the day can actually be added so update the date of the last verse of the day
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setObject:[NSDate date] forKey:lastVerseOfTheDayDateKey];
			}
		}
		
		[self saveList:[updatedListText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
			 withTitle:_verseOfTheDayListTitle];

	} else if ([responseObject isKindOfClass:[NSDictionary class]]) {
		DLog(@"Received dictionary instead of array as expected");
	} else {
		DLog(@"responseObject class: %@!", [responseObject class]);
	}
}

- (ALUVerse *)verseFromJSONDictionary:(NSDictionary *)responseDictionary {
	ALUVerse *verse = [ALUVerse new];
	
	for (NSString *key in responseDictionary) {
		if ([key containsString:@"bookname"]) {
			verse.book = [responseDictionary objectForKey:key];
		} else if ([key containsString:@"chapter"]) {
			verse.chapter = [[responseDictionary objectForKey:key] integerValue];
		} else if ([key containsString:@"verse"]) {
			verse.verse = [[responseDictionary objectForKey:key] integerValue];
		} else if ([key containsString:@"title"]) {
			verse.title = [responseDictionary objectForKey:key];
		} else if ([key containsString:@"text"]) {
			verse.text = [responseDictionary objectForKey:key];
		}
	}

	return verse;
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
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    self.query = query;
    [self.query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey, noteTitle];
    [query setPredicate:pred];
    
    
    [query startQuery];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:query];
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
        NSURL *ubiq = [[NSFileManager defaultManager]
                       URLForUbiquityContainerIdentifier:nil];
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
