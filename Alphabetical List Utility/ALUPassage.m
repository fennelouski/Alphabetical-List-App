//
//  ALUPassage.m
//  Alphabetical List Utility
//
//  Created by HAI on 8/10/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUPassage.h"

@implementation ALUPassage

- (instancetype)init {
	self = [super init];
	
	if (self) {
		self.verses = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)addVerse:(ALUVerse *)verse {
	if (![self.verses containsObject:verse]) {
		[self.verses addObject:verse];
	}
}

- (NSAttributedString *)formattedVersePrependedByDate {
	NSMutableAttributedString *formattedVerse = [[NSMutableAttributedString alloc] init];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterShortStyle;
	[formattedVerse appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[NSDate date]]]
																		   attributes:@{}]];
	[formattedVerse appendAttributedString:self.formattedVerse];
	
	return formattedVerse;
}

- (NSAttributedString *)formattedVerse {
	NSMutableAttributedString *formattedVerse = [[NSMutableAttributedString alloc] init];
	
	if (self.title) {
		[formattedVerse appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" - %@", self.title]
																			   attributes:@{}]];
	}
	
	[formattedVerse appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{}]];
	
	NSMutableString *formattedLocationString = [[NSMutableString alloc] init];
	
	if (self.book) {
		[formattedLocationString appendFormat:@"%@ ", self.book];
	}
	
	NSInteger startingChapter = 1000;
	NSInteger endingChapter = 0;
	NSInteger startingVerse = 1000;
	NSInteger endingVerse = 0;
	for (ALUVerse *verse in self.verses) {
		if (verse.chapter && verse.chapter < startingChapter) {
			startingChapter = verse.chapter;
		} else if (verse.chapter && verse.chapter > endingChapter) {
			endingChapter = verse.chapter;
		}
	}
	
	for (ALUVerse *verse in self.verses) {
		if (verse.verse < startingVerse) {
			startingVerse = verse.verse;
		} else if (verse.verse > endingVerse) {
			endingVerse = verse.verse;
		}
	}
	
	if (startingChapter) {
		[formattedLocationString appendFormat:@"%zd", startingChapter];
	}
	
	if (startingChapter && startingVerse) {
		[formattedLocationString appendString:@":"];
	}
	
	if (startingVerse) {
		[formattedLocationString appendFormat:@"%zd", startingVerse];
	}
	
	if (endingChapter > startingChapter) {
		[formattedLocationString appendFormat:@" - %zd", endingChapter];
		
		if (endingVerse) {
			[formattedLocationString appendFormat:@":%zd", endingVerse];
		}
	} else if (endingVerse > startingVerse) {
		[formattedLocationString appendFormat:@"-%zd", endingVerse];
	}
	
	if (formattedLocationString.length > 0) {
		NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
		[attributes setObject:[UIFont systemFontOfSize:12.0f] forKey:NSFontAttributeName];
		[formattedVerse appendAttributedString:[[NSAttributedString alloc] initWithString:formattedLocationString
																			   attributes:attributes]];
		[formattedVerse appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"
																			   attributes:attributes]];
	}
	
	[self.verses sortUsingDescriptors:
	 [NSArray arrayWithObjects:
	  [NSSortDescriptor sortDescriptorWithKey:@"chapter" ascending:YES],
	  [NSSortDescriptor sortDescriptorWithKey:@"verse" ascending:YES], nil]];
	
	NSMutableString *conjoinedString = [[NSMutableString alloc] init];
	
	for (ALUVerse *verse in self.verses) {
		NSString *verseText = [verse.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",;:/\\+=@#%^&* \n\t_<>"]];
		[conjoinedString appendFormat:@"%@ ", verseText];
	}
	
	NSString *text = [conjoinedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",;:/\\+=@#%^&* \n\t_<>"]]; // cleanup
	
	
	if (text) {
		[formattedVerse appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\"%@\"", text]
																			   attributes:@{}]];
	}
	
	return formattedVerse;
}


@end
