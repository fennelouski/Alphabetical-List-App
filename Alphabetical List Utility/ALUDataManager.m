//
//  ALUDataManager.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "ALUDataManager.h"

static NSString * const separator = @"%&&^AB)*971";
static NSString * const masterListKey = @"M@$teR I1$7 K3yY";

@implementation ALUDataManager {
	NSMutableArray *_lists;
	NSMutableDictionary *_dictionaryOfLists;
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
		
	}
	
	return self;
}

- (void)addList:(NSString *)listTitle {
	if (![_lists containsObject:listTitle]) {
		[_lists addObject:listTitle];
		[self saveList:@"" withTitle:listTitle];
	} else {
		NSLog(@"%@", _lists);
	}
}

- (void)removeList:(NSString *)listTitle {
	if (![_lists containsObject:listTitle]) {
		NSLog(@"List does NOT exist...cannot remove");
	}
	[_lists removeObject:listTitle];
	[_dictionaryOfLists removeObjectForKey:listTitle];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:listTitle];
}

- (void)saveList:(NSString *)list withTitle:(NSString *)title {
	if (!list || list.length == 0) {
		NSLog(@"List must exist");
		return;
	} else if (!title || title.length == 0) {
		NSLog(@"Title must exist");
		return;
	}
	
	[_dictionaryOfLists setObject:list forKey:title];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableString *stringOfListTitles = [[NSMutableString alloc] initWithString:@""];
	NSArray *sortedList = [_lists sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	for (NSString *listTitle in sortedList) {
		[stringOfListTitles appendFormat:@"%@%@", listTitle, separator];
	}
	
	[defaults setObject:stringOfListTitles forKey:masterListKey];
	
	[defaults setObject:list forKey:title];
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
	
	// return an empty string
	return @"";
}


@end
