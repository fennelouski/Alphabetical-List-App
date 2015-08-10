//
//  ALUDataManager.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "ALUDataManager.h"
#import "AFNetworking.h"
#import "ALUVerse.h"
#import "ALUPassage.h"
#import "NKFColor+Universities.h"

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
	NSMutableArray *_failedDomains;
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
		_failedDomains = [[NSMutableArray alloc] init];
		_listModes = [[NSMutableDictionary alloc] init];
		_showListImages = [[NSMutableDictionary alloc] init];
		_apiURLDictionary = [NSMutableDictionary dictionaryWithDictionary:[self urlDictionary]];
		_apiResponseDictionary = [[NSMutableDictionary alloc] init];
        _geolocationReminders = [[NSMutableDictionary alloc] init];
        _geolocationExists = [[NSMutableDictionary alloc] init];
		_useCardView = kScreenHeight < screenSizeLimit && kScreenWidth < screenSizeLimit;
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
        [_locationManager startUpdatingLocation];
		
		NSSet *monitoredRegions = [NSSet setWithSet:_locationManager.monitoredRegions];
		for (CLRegion *region in monitoredRegions) {
			if (![self listWithTitle:region.identifier]) {
				[_locationManager stopMonitoringForRegion:region];
				NSLog(@"List is no longer recognized");
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
		NSLog(@"deviceType: %@", deviceType);
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
		NSLog(@"All List titles: %@", _lists);
	}
	
	return YES;
}

- (void)removeList:(NSString *)listTitle {
	if (![_lists containsObject:listTitle]) {
		NSLog(@"List does NOT exist...cannot remove");
	}
	
	[_lists removeObject:listTitle];
	[_dictionaryOfLists removeObjectForKey:listTitle];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:listTitle];
	[self updateListsInStorage];
	NSLog(@"All List titles:\t%@", _lists);
	[self performSelector:@selector(addDefaultList) withObject:self afterDelay:0.0f];
}

- (void)saveList:(NSString *)list withTitle:(NSString *)title {
	if (!list) {
		NSLog(@"List must exist");
		return;
	} else if (!title || title.length == 0) {
		NSLog(@"Title must exist");
		return;
	}
    
    NSString *cleanedTitle = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	[_dictionaryOfLists setObject:list forKey:cleanedTitle];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:list forKey:cleanedTitle];
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
	
	if ([_companyLogos objectForKey:companyName]) {
		return [_companyLogos objectForKey:companyName];
	}
	
	NSString *companyNameURLString = [self companyNameURLStringForCompanyName:companyName];
    
    if (!companyNameURLString && ![self imageSavedLocallyForCompanyName:companyName]) {
        return nil;
    } else if (!companyNameURLString) {
        companyNameURLString = [self formattedListTitle:companyName];
    }
	
    if ([_companyLogos objectForKey:companyNameURLString]) {
        return [_companyLogos objectForKey:companyNameURLString];
    }
    
    if (companyNameURLString.length < 7) {
        return nil;
    }

	// Use the default session configuration for the manager (background downloads must use the delegate APIs)
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	// Use AFNetworking's NSURLSessionManager to manage a NSURLSession.
	AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
	
	NSString *baseURLString = @"https://logo.clearbit.com/";
	NSString *urlString = [NSString stringWithFormat:@"%@%@", baseURLString, companyNameURLString];
	// Create the image URL from some known string.
	NSURL *imageURL = [NSURL URLWithString:urlString];
	// Create a request object for the given URL.
	NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
	// Create a pointer for a NSProgress object to be used to determining download progress.
	NSProgress *progress = nil;
	
    NSURL *saveLocation = [self saveLocationForCompanyNameURLString:companyNameURLString];
    
    
    
	if (saveLocation) {
		// Get the data for the image we just saved.
		NSData *imageData = [NSData dataWithContentsOfURL:saveLocation];
		
		if (!imageData) {
//			NSLog(@"No image data!");
		} else {
			// Get a UIImage object from the image data.
			UIImage *image = [UIImage imageWithData:imageData];
			if (image) {
				if (companyNameURLString) {
					[_companyLogos setObject:image forKey:companyNameURLString];
                    [_companyLogos setObject:image forKey:companyName];
					return image;
				} else {
					NSLog(@"So, I have the filepath, imageData, and image but the companyURLString is null!");
				}
			} else {
				NSLog(@"I'm missing the image for %@", companyNameURLString);
			}
		}
	}
	
	// Create the callback block responsible for determining the location to save the downloaded file to.
	NSURL *(^destinationBlock)(NSURL *targetPath, NSURLResponse *response) = ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
		// Get the path of the application's documents directory.
		NSURL *documentsDirectoryURL = [self documentsDirectoryURL];
		NSURL *saveLocation = nil;
		
		// Check if the response contains a suggested file name
		if (response.suggestedFilename) {
			// Append the suggested file name to the documents directory path.
			saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:response.suggestedFilename];
		} else {
			// Append the desired file name to the documents directory path.
			saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", companyNameURLString]];
		}
        
        saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", companyNameURLString]];
		
		return saveLocation;
	};
	
	
	// Create the completion block that will be called when the image is done downloading/saving.
	void (^completionBlock)(NSURLResponse *response, NSURL *filePath, NSError *error) = ^void (NSURLResponse *response, NSURL *filePath, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			// There is no longer any reason to observe progress, the download has finished or cancelled.
			[progress removeObserver:self
						  forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
			
			if (error) {
//				DLog(@"Error in downloading image: %@",error.localizedDescription);
				// Something went wrong downloading or saving the file. Figure out what went wrong and handle the error.
				[_failedDomains addObject:companyNameURLString];
			} else {
				// Get the data for the image we just saved.
				NSData *imageData = [NSData dataWithContentsOfURL:filePath];
				
				if (!filePath) {
					NSLog(@"No filepath");
				}
				
				if (!imageData) {
					NSLog(@"No image data!");
				}
				
				// Get a UIImage object from the image data.
				UIImage *image = [UIImage imageWithData:imageData];
				if (image) {
					if (companyNameURLString) {
						[_companyLogos setObject:image forKey:companyNameURLString];
                        [_companyLogos setObject:image forKey:companyName];
					} else {
						NSLog(@"So, I have the filepath, imageData, and image but the companyURLString is null!");
					}
				} else {
					NSLog(@"I'm missing the image for %@", companyNameURLString);
				}
			}
		});
	};
	
	// Create the download task for the image.
	NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request
															 progress:&progress
														  destination:destinationBlock
													completionHandler:completionBlock];
	// Start the download task.
	[task resume];
	
	// Begin observing changes to the download task's progress to display to the user.
	[progress addObserver:self
			   forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
				  options:NSKeyValueObservingOptionNew
				  context:NULL];
	
	return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	// We only care about updates to fractionCompleted
	if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))]) {
//		NSProgress *progress = (NSProgress *)object;
		// localizedDescription gives a string appropriate for display to the user, i.e. "42% completed"
//		self.progressLabel.text = progress.localizedDescription;
//		NSLog(@"%@", progress.localizedDescription);
	} else {
		[super observeValueForKeyPath:keyPath
							 ofObject:object
							   change:change
							  context:context];
	}
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
                                      @"pavilions"          : @"pavilions.com",
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
                                      @"mit"                : @"mit.edu",
									  @"bible"              : @"bible.com",
									  @"bibleverseoftheday" : @"bible.com",
									  @"verseoftheday"      : @"bible.com",
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
                                      @"mississippistate"   : @"mssstate.edu"};
	
    BOOL replacementFound = NO;
    for (NSString *forwardingWord in forwardingWords.allKeys) {
        if ([companyNameURLString rangeOfString:forwardingWord].location != NSNotFound && !replacementFound && forwardingWord.length * 2 > companyName.length && !replacementFound) {
            companyNameURLString = [forwardingWords objectForKey:forwardingWord];
            replacementFound = YES;
            break;
        }
    }
    
    if ([_failedDomains containsObject:companyNameURLString]) {
        return nil;
    }
    
    NSArray *invalidWords = @[@"tacos", @"buff", @"cardinals", @"bills", @"eagles", @"chargers", @"buffalo", @"as", @"dodgers", @"brewers", @"twins", @"rockies", @"city", @"chores", @"officesupplies", @"samsonite", @"packing", @"aaa"];
    for (NSString *invalidWord in invalidWords) {
        if ([companyNameURLString rangeOfString:invalidWord].location != NSNotFound && invalidWord.length * 2 >= companyNameURLString.length && !replacementFound) {
            return nil;
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
                if (word.length > 1) {
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
}

- (void)removeImageForCompanyName:(NSString *)companyName {
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
		NSLog(@"%s", __PRETTY_FUNCTION__);
        NSLog(@"removeImageForCompanyName Error: %@", error.localizedDescription);
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
		NSLog(@"setListMode: List is not recognized and cannot be set: \"%@\"\n\nAll Lists: %@", title, _lists);
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
		NSLog(@"listModeForListTitle: List is not recognized: \"%@\"\n\nAll Lists: %@", title, _lists);
	}
	
	return NO;
}

- (void)setAlphabetize:(BOOL)listMode forListTitle:(NSString *)title {
    if ([_lists containsObject:title]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:listMode forKey:[NSString stringWithFormat:@"%@alphabetizeEnabled", title]];
        [_listModes setObject:@(listMode) forKey:title];
    } else {
        NSLog(@"setAlphabetize: List is not recognized and cannot be set: \"%@\"\n\nAll Lists: %@", title, _lists);
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
        NSLog(@"alphabetizeForListTitle: List is not recognized: \"%@\"\n\nAll Lists: %@", title, _lists);
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
		NSLog(@"setShowImage: List is not recognized and cannot set show image: \"%@\"\n\nAll Lists: %@", title, _lists);
	}
}

- (BOOL)showImageForListTitle:(NSString *)title {
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
		NSLog(@"showImageForListTitle: List is not recognized: \"%@\"\n\nAll Lists: %@", title, _lists);
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
        NSLog(@"setUseWebIcon: List is not recognized and cannot set show image: \"%@\"\n\nAll Lists: %@", title, _lists);
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
        NSLog(@"useWebIconForListTitle: List is not recognized: \"%@\"\n\nAll Lists: %@", title, _lists);
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
		NSLog(@"I should try calling %@", urlString);
		
		return YES;
	}
	
	return NO;
}

- (void)makeCallForListTitle:(NSString *)listTitle {
	NSString *urlString = [_apiURLDictionary objectForKey:[self formattedListTitle:listTitle]];
	
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"I'm ready to call \"%@\"", url);
}

- (NSDictionary *)dictionaryForTitle:(NSString *)listTitle {
	NSDictionary *apiResponseDictionary = [_apiResponseDictionary objectForKey:[self formattedListTitle:listTitle]];
	
	if (apiResponseDictionary) {
		if (![apiResponseDictionary isKindOfClass:[NSDictionary class]]) {
			NSLog(@"Response for %@ is kindOfClass: %@", [self formattedListTitle:listTitle], [apiResponseDictionary class]);
		}
		
		return apiResponseDictionary;
	}
	
	NSLog(@"No response found %@", [self formattedListTitle:listTitle]);
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
	
	
	UIUserNotificationType notificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
	UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
	
	UIMutableUserNotificationAction *showNoteAction = [[UIMutableUserNotificationAction alloc] init];
	showNoteAction.identifier = @"showNote";
	showNoteAction.title = @"Show Note";
	showNoteAction.activationMode = UIUserNotificationActivationModeBackground;
	showNoteAction.destructive = false;
	showNoteAction.authenticationRequired = false;
	
	UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
	notificationCategory.identifier = @"showNoteNotificationCategory";
	[notificationCategory setActions:@[showNoteAction] forContext:UIUserNotificationActionContextDefault];
	[notificationCategory setActions:@[showNoteAction] forContext:UIUserNotificationActionContextMinimal];
	
	[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	
	CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:radiusInMeters identifier:listTitle];
	region.notifyOnEntry = YES;
	region.notifyOnExit = NO;
	[[self locationManager] startMonitoringForRegion:region];
	
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
		
		NSSet *regions = [self.locationManager monitoredRegions];
		for (CLRegion *region in regions) {
			[self.locationManager stopMonitoringForRegion:region];
			break;
		}
	} else {
		NSLog(@"The annotation doesn't exist for the listTitle %@", listTitle);
	}
    
    [_geolocationReminders removeObjectForKey:formattedListTitle];
    [_geolocationExists setObject:@(NO) forKey:formattedListTitle];
}


#pragma mark - Location Manager Delegate

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
	
	NSLog(@"currentErrorString: %@", currentErrorString);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"Location manager failed with the following error: %@", error);
	
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
	
	NSLog(@"currentErrorString: %@", currentErrorString);
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
	NSDate *lastVerseOfTheDayDate;// = [defaults objectForKey:lastVerseOfTheDayDateKey];
	
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
		NSURL *URL = [NSURL URLWithString:@"http://labs.bible.org/api/?passage=votd&type=json"];
		NSURLRequest *request = [NSURLRequest requestWithURL:URL];
		AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
		op.responseSerializer = [AFJSONResponseSerializer serializer];
		NSMutableSet *acceptableContentTypes = [NSMutableSet setWithObject:op.responseSerializer.acceptableContentTypes];
		[acceptableContentTypes addObject:@"application/x-javascript"];
		[acceptableContentTypes addObject:@"text/html"];
		op.responseSerializer.acceptableContentTypes = acceptableContentTypes;
		[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
			[self analyzeBibleVerseResponseObject:responseObject];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Error: %@", error);
		}];
		[[NSOperationQueue mainQueue] addOperation:op];
	} else {
		NSLog(@"Verse does not need to be updated %@", lastVerseOfTheDayDate);
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
		NSLog(@"Received dictionary instead of array as expected");
	} else {
		NSLog(@"responseObject class: %@!", [responseObject class]);
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
        NSLog(@"iCloud access at %@", ubiq);
        // TODO: Load document...
        [self loadIcloudDocument:[_lists firstObject]];
        _iCloudIsAvailable = YES;
    } else {
        NSLog(@"No iCloud access");
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
                NSLog(@"iCloud document opened");
            } else {
                NSLog(@"failed opening document from iCloud");
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
                      NSLog(@"new document opened from iCloud");
                  }];
              }
          }];
    }
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker {
	NSLog(@"\n- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker\n\t\tDOES NOTHING\n");
}


@end
