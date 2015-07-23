//
//  ALUDataManager.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "ALUDataManager.h"
#import "AFNetworking.h"

static NSString * const separator = @"%&&^AB)*971";
static NSString * const masterListKey = @"M@$teR I1$7 K3yY";

@implementation ALUDataManager {
	NSMutableArray *_lists;
	NSMutableDictionary *_dictionaryOfLists;
	NSMutableDictionary *_companyLogos;
	NSMutableArray *_failedDomains;
	NSMutableDictionary *_listModes;
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
		
		_lists = [[NSMutableArray alloc] initWithArray:listTitles];
//		[_lists addObjectsFromArray:@[@"Belk", @"Sears", @"Tiffany", @"JC Penney", @"Victorias Secret", @"Macys", @"Engadget", @"T-Mobile", @"Facebook", @"Aetna", @"Volcano", @"Kohl's"]];

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
	}
	
	return self;
}


- (void)addDefaultList {
	if (_lists.count == 0 && _dictionaryOfLists.count == 0) {
		NSString *listTitle = @"Welcome!";
		
		NSString *deviceType = [UIDevice currentDevice].model;
		NSLog(@"%@", deviceType);
		if ([deviceType rangeOfString:@"iPhone"].location != NSNotFound) {
			NSString *list = @"Welcome to A2Z Notes!\n\nThis is your first note.\n\nTap < to see a list of all your notes. Tap the + to create a new note.\n\nPinch this text to adjust the font size.";
			[_lists addObject:listTitle];
			[_dictionaryOfLists setObject:list forKey:listTitle];
		} else if ([deviceType rangeOfString:@"iPad"].location != NSNotFound) {
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

	NSArray *validTLDs = @[@".com", @".org", @".net", @".edu"];
	NSString *companyNameURLString;
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
									  @"darntoughsocks"		: @"darntough.com"};
	
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
	
	NSArray *invalidWords = @[@"tacos", @"buff", @"cardinals", @"bills", @"eagles", @"chargers", @"buffalo", @"as", @"dodgers", @"brewers", @"twins", @"rockies", @"city"];
	for (NSString *invalidWord in invalidWords) {
		if ([companyNameURLString rangeOfString:invalidWord].location != NSNotFound && invalidWord.length * 2 >= companyNameURLString.length && !replacementFound) {
			return nil;
		}
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
	
    NSURL *documentsDirectoryURL = [self documentsDirectoryURL];
    NSURL *saveLocation = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", companyNameURLString]];
    
    
    
	if (saveLocation) {
		// Get the data for the image we just saved.
		NSData *imageData = [NSData dataWithContentsOfURL:saveLocation];
		
		if (!imageData) {
			NSLog(@"No image data!");
		} else {
			// Get a UIImage object from the image data.
			UIImage *image = [UIImage imageWithData:imageData];
			if (image) {
				if (companyNameURLString) {
					[_companyLogos setObject:image forKey:companyNameURLString];
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
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[saveLocation description] forKey:companyNameURLString];
		
		return saveLocation;
	};
	
	
	// Create the completion block that will be called when the image is done downloading/saving.
	void (^completionBlock)(NSURLResponse *response, NSURL *filePath, NSError *error) = ^void (NSURLResponse *response, NSURL *filePath, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			// There is no longer any reason to observe progress, the download has finished or cancelled.
			[progress removeObserver:self
						  forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
			
			if (error) {
				NSLog(@"%@",error.localizedDescription);
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


#pragma mark - List Mode

- (void)setListMode:(BOOL)listMode forListTitle:(NSString *)title {
	if ([_lists containsObject:title]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:listMode forKey:[NSString stringWithFormat:@"%@listModeEnabled", title]];
		[_listModes setObject:@(listMode) forKey:title];
	} else {
		NSLog(@"List is not recognized and cannot be set: \"%@\"\n\nAll Lists: %@", title, _lists);
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
		NSLog(@"List is not recognized: \"%@\"\n\nAll Lists: %@", title, _lists);
	}
	
	return NO;
}


@end
