//
//  ALUVerse.m
//  Alphabetical List Utility
//
//  Created by HAI on 8/3/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUVerse.h"

@implementation ALUVerse

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
	
	if (self.chapter) {
		[formattedLocationString appendFormat:@"%zd", self.chapter];
	}
	
	if (self.chapter && self.verse) {
		[formattedLocationString appendString:@":"];
	}
	
	if (self.verse) {
		[formattedLocationString appendFormat:@"%zd", self.verse];
	}
	
	if (formattedLocationString.length > 0) {
		NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
		[attributes setObject:[UIFont systemFontOfSize:12.0f] forKey:NSFontAttributeName];
		[formattedVerse appendAttributedString:[[NSAttributedString alloc] initWithString:formattedLocationString
																			   attributes:attributes]];
		[formattedVerse appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"
																			   attributes:attributes]];
	}
	
	self.text = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",;:/\\+=@#%^&* \n\t_<>"]]; // cleanup
	
	
	if (self.text) {
		[formattedVerse appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\"%@\"", self.text]
																			   attributes:@{}]];
	}
	
	return formattedVerse;
}

@end
