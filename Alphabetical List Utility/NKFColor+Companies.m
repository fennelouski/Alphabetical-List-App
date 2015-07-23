//
//  NKFColor+Companies.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/22/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "NKFColor+Companies.h"
#import "UIColor+AppColors.h"
#import "NKFColor+WikipediaColors.h"

@implementation NKFColor (Companies)


#pragma mark - Company Colors

+ (NSAttributedString *)attributedStringForCompanyName:(NSString *)companyName {
	NSMutableArray *colors = [NSMutableArray arrayWithArray:[NKFColor colorsForCompanyName:companyName]];
	
	NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] initWithString:companyName];
	
	NSArray *words = [companyName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSArray *copyOfColors = [NSArray arrayWithArray:colors];
	for (NKFColor *testColor in copyOfColors) {
		if ([testColor isLighterThan:0.665f] && colors.count > 1) {
			[colors removeObject:testColor];
		}
	}
	
	if (colors.count > 0 && words.count > 1) {
		finalString = [[NSMutableAttributedString alloc] init];
		NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" "];
		for (int i = 0; i < words.count; i++) {
			NSString *word = [words objectAtIndex:i];
			UIColor *currentColor = [colors objectAtIndex:i%colors.count];
			
			NSAttributedString *attributedWord;
			if ([currentColor isLighterThan:0.8f]) {
				attributedWord = [[NSAttributedString alloc] initWithString:word attributes:@{NSForegroundColorAttributeName : currentColor, NSBackgroundColorAttributeName : [NKFColor black]}];
			} else {
				attributedWord = [[NSAttributedString alloc] initWithString:word attributes:@{NSForegroundColorAttributeName : currentColor}];
			}
			
			if (finalString.length > 0) {
				[finalString appendAttributedString:spaceString];
			}
			
			[finalString appendAttributedString:attributedWord];
		}
	} else if (colors.count < companyName.length && colors.count > companyName.length / 2 && colors.count > 2) {
		for (int i = 0; i < companyName.length; i++) {
			UIColor *currentColor = [colors objectAtIndex:i%colors.count];
			[finalString addAttribute:NSForegroundColorAttributeName value:[currentColor colorWithAlphaComponent:1.0f] range:NSMakeRange(i, 1)];
		}
	} else if (colors.count > 0) {
		if ([colors.firstObject isLighterThan:0.8f]) {
			[finalString addAttribute:NSBackgroundColorAttributeName value:[NKFColor black] range:NSMakeRange(0, finalString.length)];
		}
		
		[finalString addAttribute:NSForegroundColorAttributeName value:[colors.firstObject colorWithAlphaComponent:1.0f] range:NSMakeRange(0, finalString.length)];
	} else {
		NKFColor *color = [[self colorForCompanyName:companyName] colorWithAlphaComponent:1.0];
		
		if ([colors.firstObject isLighterThan:0.8f]) {
			[finalString addAttribute:NSBackgroundColorAttributeName value:[NKFColor black] range:NSMakeRange(0, finalString.length)];
		}
		
		[finalString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, finalString.length)];
	}
	
	NSArray *bannedwords = [self bannedWords];
	for (NSString *bannedWord in bannedwords) {
		if ([[finalString.string lowercaseString] rangeOfString:bannedWord].location != NSNotFound) {
			NSString *modifiedCompanyName = companyName;
			for (NSString *innerBannedWord in bannedwords) {
				modifiedCompanyName = [modifiedCompanyName stringByReplacingOccurrencesOfString:innerBannedWord withString:@""];
			}
			UIColor *cleanColor = [NKFColor colorForCompanyName:modifiedCompanyName];
			[finalString setAttributedString:[[NSAttributedString alloc] initWithString:companyName attributes:@{NSForegroundColorAttributeName : cleanColor}]];
			return finalString;
		}
	}
	
	return finalString;
}

+ (NKFColor *)colorForCompanyName:(NSString *)companyName {
	NKFColor *color = [NKFColor strictColorForCompanyName:companyName];
	
	if (color) {
		return color;
	}
	
	return [NKFColor randomDarkColorFromString:companyName];
}

+ (NSArray *)bannedWords {
	return @[@"new", @"description", @"init", @"initialize", @"alloc", @"dealloc", @"copy", @"mutable", @"selector", @"invocation", @"method", @"reference", @"hash", @"class"];
}

+ (NKFColor *)strictColorForCompanyName:(NSString *)companyName {
	if (!companyName || companyName.length == 0) {
		NSLog(@"Company Name must exist to generate color.");
		return [NKFColor randomDarkColor];
	}
	
	NSString *lowerCaseCompanyName = [companyName lowercaseString];
	NSString *formattedCompanyName = [[lowerCaseCompanyName componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
	
	NSArray *bannedWords = [self bannedWords];
	for (NSString *bannedWord in bannedWords) {
		if ([formattedCompanyName rangeOfString:bannedWord].location != NSNotFound) {
			return [NKFColor black];
		}
	}
	
	if ([self respondsToSelector:NSSelectorFromString(formattedCompanyName)]) {
		return [NKFColor performSelector:NSSelectorFromString(formattedCompanyName) withObject:nil];
	} else if ([lowerCaseCompanyName firstAlphabeticalCharacterIndex]) {
		return [NKFColor colorForCompanyName:[lowerCaseCompanyName stringWithoutNumbersInTheBeginning]];
	} else {
		NSArray *words = [lowerCaseCompanyName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		for (NSString *word in words) {
			NSString *keyword = [[word componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
			NKFColor *keywordColor = [self colorForKeyword:keyword];
			if (keywordColor) {
				return keywordColor;
			}
		}
		
		for (NSInteger i = words.count - 1; i >= 0; i--) {
			NSString *word = [words objectAtIndex:i];
			
			for (NSString *bannedWord in bannedWords) {
				if ([word rangeOfString:bannedWord].location != NSNotFound) {
					return [NKFColor black];
				}
			}
			
			if ([self respondsToSelector:NSSelectorFromString(word)]) {
				return [NKFColor performSelector:NSSelectorFromString(word) withObject:nil];
			}
		}
		
		// try with a camel case
		// e.g. Cal Poly -> calPoly
		NSMutableString *camelCaseCompanyName = [[NSMutableString alloc] initWithString:words.firstObject];
		for (int i = 1; i < words.count; i++) {
			NSString *nextWord = [[words objectAtIndex:i] capitalizedString];
			[camelCaseCompanyName appendString:nextWord];
		}
		
		if ([self respondsToSelector:NSSelectorFromString(camelCaseCompanyName)]) {
			return [NKFColor performSelector:NSSelectorFromString(camelCaseCompanyName) withObject:nil];
		}
		
		if ([companyName rangeOfString:@"&"].location != NSNotFound) {
			return [NKFColor colorForCompanyName:[lowerCaseCompanyName stringByReplacingOccurrencesOfString:@"&" withString:@"and"]];
		}
		
		for (NSString *word in words) {
			if ([word hasSuffix:@"s"] && word.length > 1 && ![word hasSuffix:@"ss"]) {
				NSString *singularWord = [word substringToIndex:word.length - 1];
				NKFColor *singularWordColor = [NKFColor strictColorForCompanyName:singularWord];
				if (singularWordColor) {
					return singularWordColor;
				}
			}
		}
	}
	
	return nil;
}

+ (NSArray *)colorsForCompanyName:(NSString *)companyName {
	NSString *lowerCaseCompanyName = [companyName lowercaseString];
	NSString *initialFormattedCompanyName = [[lowerCaseCompanyName componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
	NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:companyName.length];
	NSString *formattedCompanyName = initialFormattedCompanyName;
	
	NSArray *bannedWords = [self bannedWords];
	for (NSString *bannedWord in bannedWords) {
		if ([formattedCompanyName rangeOfString:bannedWord].location != NSNotFound) {
			return @[[NKFColor black]];
		}
	}
	
	while ([self respondsToSelector:NSSelectorFromString(formattedCompanyName)]) {
		[colors addObject:[NKFColor performSelector:NSSelectorFromString(formattedCompanyName) withObject:nil]];
		
		formattedCompanyName = [NSString stringWithFormat:@"%@%zd", initialFormattedCompanyName, colors.count + 1];
	}
	
	if (colors.count > 0) {
		return colors;
	}
	
	NSArray *words = [companyName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (words.count > 1) {
		for (NSString *word in words) {
			if ([word rangeOfString:@"&"].location != NSNotFound) {
				[colors addObjectsFromArray:[NKFColor colorsForCompanyName:[word stringByReplacingOccurrencesOfString:@"&" withString:@"and"]]];
			} else {
				[colors addObjectsFromArray:[NKFColor colorsForCompanyName:word]];
			}
		}
	}
	
	if (colors.count > 0) {
		return colors;
	}
	
	for (NSString *word in words) {
		if ([word hasSuffix:@"s"] && word.length > 1 && ![word hasSuffix:@"ss"]) {
			NSString *singularWord = [word substringToIndex:word.length - 1];
			[colors addObjectsFromArray:[self colorsForCompanyName:singularWord]];
		}
	}
	
	if (colors.count > 0) {
		return colors;
	}
	
	return colors;
}

+ (NKFColor *)colorForKeyword:(NSString *)keyword {
	NSDictionary *keywordColors = @{@"tv" : [self hulu],
									@"movies" : [self netflix],
									@"auto" : [self autozone],
									@"autoparts" : [self autozone2],
									@"rx" : [self cvs],
									@"rxs" : [self cvs],
									@"prescription" : [self walgreens],
									@"prescriptions" : [self volcano],
									@"dr" : [self philips],
									@"doctor" : [self philips],
									@"welcome" : [NKFColor appColor]};
	if ([keywordColors objectForKey:keyword]) {
		return [keywordColors objectForKey:keyword];
	}
	
	return nil;
}

#pragma mark - Company names

+ (NKFColor *)fourormat{
	return [NKFColor colorWithHexString:@"#fb0a2a"];
}


+ (NKFColor *)fivehundredpix {
	return [NKFColor fivehundredpx];
}


+ (NKFColor *)fivehundredpx{
	return [NKFColor colorWithHexString:@"#0099e5"];
}

+ (NKFColor *)fivehundredpx2{
	return [NKFColor colorWithHexString:@"#ff4c4c"];
}

+ (NKFColor *)fivehundredpx3{
	return [NKFColor colorWithHexString:@"#34bf49"];
}


+ (NKFColor *)aboutme{
	return [NKFColor colorWithHexString:@"#00405d"];
}

+ (NKFColor *)aboutme2{
	return [NKFColor colorWithHexString:@"#062f3c"];
}

+ (NKFColor *)aboutme3{
	return [NKFColor colorWithHexString:@"#2b82ad"];
}

+ (NKFColor *)aboutme4{
	return [NKFColor colorWithHexString:@"#cc7a00"];
}

+ (NKFColor *)aboutme5{
	return [NKFColor colorWithHexString:@"#ffcc33"];
}


+ (NKFColor *)ace {
	return [NKFColor colorWithRed:230.0f/255.0f green:25.0f/255.0f blue:56.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)acehardware {
	return [NKFColor ace];
}

+ (NKFColor *)acehardwear {
	return [NKFColor ace];
}


+ (NKFColor *)acme {
	return [NKFColor colorWithRed:239.0f/255.0f green:59.0f/255.0f blue:57.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)acmoore {
	return [NKFColor colorWithRed:227.0f/255.0f green:25.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)acmooreartsandcrafts {
	return [NKFColor acmoore];
}

+ (NKFColor *)artsandcrafts {
	return [NKFColor acmoore];
}


+ (NKFColor *)addvocate{
	return [NKFColor colorWithHexString:@"#ff3322"];
}


+ (NKFColor *)advancedautoparts {
	return [NKFColor colorWithRed:235.0f/255.0f green:27.0f/255.0f blue:42.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)adobe{
	return [NKFColor colorWithHexString:@"#ff0000"];
}

+ (NKFColor *)adobe2{
	return [NKFColor colorWithHexString:@"#fbb034"];
}

+ (NKFColor *)adobe3{
	return [NKFColor colorWithHexString:@"#ffdd00"];
}

+ (NKFColor *)adobe4{
	return [NKFColor colorWithHexString:@"#c1d82f"];
}

+ (NKFColor *)adobe5{
	return [NKFColor colorWithHexString:@"#00a4e4"];
}

+ (NKFColor *)adobe6{
	return [NKFColor colorWithHexString:@"#8a7967"];
}

+ (NKFColor *)adobe7{
	return [NKFColor colorWithHexString:@"#6a737b"];
}


+ (NKFColor *)aetna{
	return [NKFColor colorWithHexString:@"#d20962"];
}

+ (NKFColor *)aetna2{
	return [NKFColor colorWithHexString:@"#f47721"];
}

+ (NKFColor *)aetna3{
	return [NKFColor colorWithHexString:@"#7ac143"];
}

+ (NKFColor *)aetna4{
	return [NKFColor colorWithHexString:@"#00a78e"];
}

+ (NKFColor *)aetna5{
	return [NKFColor colorWithHexString:@"#00bce4"];
}

+ (NKFColor *)aetna6{
	return [NKFColor colorWithHexString:@"#7d3f98"];
}


+ (NKFColor *)ahold {
	return [NKFColor colorWithRed:6.0f/255.0f green:98.0f/255.0f blue:168.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)aholdusa {
	return [NKFColor ahold];
}


+ (NKFColor *)aim{
	return [NKFColor colorWithHexString:@"#ffd900"];
}


+ (NKFColor *)airbnb{
	return [NKFColor colorWithHexString:@"#fd5c63"];
}


+ (NKFColor *)ajwright {
	return [NKFColor colorWithRed:235.0f/255.0f green:131.0f/255.0f blue:22.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)albertsons {
	return [NKFColor colorWithRed:20.0f/255.0f green:29.0f/255.0f blue:106.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)albertson {
	return [NKFColor albertsons];
}

+ (NKFColor *)albertsons2 {
	return [NKFColor colorWithRed:0.0f green:161.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)albertson2 {
	return [NKFColor albertsons2];
}


+ (NKFColor *)alcon{
	return [NKFColor colorWithHexString:@"#0079c1"];
}

+ (NKFColor *)alcon2{
	return [NKFColor colorWithHexString:@"#49176d"];
}

+ (NKFColor *)alcon3{
	return [NKFColor colorWithHexString:@"#00a0af"];
}

+ (NKFColor *)alcon4{
	return [NKFColor colorWithHexString:@"#49a942"];
}


+ (NKFColor *)aldi {
	return [NKFColor colorWithRed:0.0f/255.0f green:36.0f/255.0f blue:120.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)aldi2 {
	return [NKFColor colorWithRed:242.0f/255.0f green:54.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)aldi3 {
	return [NKFColor colorWithRed:250.0f/255.0f green:137.0f/255.0f blue:1.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)aldi4 {
	return [NKFColor colorWithRed:0.0f/255.0f green:148.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)alienware{
	return [NKFColor colorWithHexString:@"#020202"];
}

+ (NKFColor *)alienware2{
	return [NKFColor colorWithHexString:@"#2ad2c9"];
}

+ (NKFColor *)alienware3{
	return [NKFColor colorWithHexString:@"#d0e100"];
}

+ (NKFColor *)alienware4{
	return [NKFColor colorWithHexString:@"#00f0f0"];
}

+ (NKFColor *)alienware5{
	return [NKFColor colorWithHexString:@"#00f000"];
}

+ (NKFColor *)alienware6{
	return [NKFColor colorWithHexString:@"#f0e000"];
}

+ (NKFColor *)alienware7{
	return [NKFColor colorWithHexString:@"#00a0f0"];
}

+ (NKFColor *)alienware8{
	return [NKFColor colorWithHexString:@"#9000f0"];
}

+ (NKFColor *)alienware9{
	return [NKFColor colorWithHexString:@"#f00000"];
}


+ (NKFColor *)amazon{
	return [NKFColor colorWithHexString:@"#ff9900"];
}

+ (NKFColor *)amazon2{
	return [NKFColor colorWithHexString:@"#146eb4"];
}


+ (NKFColor *)americanredcross{
	return [NKFColor colorWithHexString:@"#ed1b2e"];
}

+ (NKFColor *)americanredcross2{
	return [NKFColor colorWithHexString:@"#6d6e70"];
}

+ (NKFColor *)americanredcross3{
	return [NKFColor colorWithHexString:@"#d7d7d8"];
}

+ (NKFColor *)americanredcross4{
	return [NKFColor colorWithHexString:@"#b4a996"];
}

+ (NKFColor *)americanredcross5{
	return [NKFColor colorWithHexString:@"#ecb731"];
}

+ (NKFColor *)americanredcross6{
	return [NKFColor colorWithHexString:@"#8ec06c"];
}

+ (NKFColor *)americanredcross7{
	return [NKFColor colorWithHexString:@"#537b35"];
}

+ (NKFColor *)americanredcross8{
	return [NKFColor colorWithHexString:@"#c4dff6"];
}

+ (NKFColor *)americanredcross9{
	return [NKFColor colorWithHexString:@"#56a0d3"];
}

+ (NKFColor *)americanredcross10{
	return [NKFColor colorWithHexString:@"#0091cd"];
}

+ (NKFColor *)americanredcross11{
	return [NKFColor colorWithHexString:@"#004b79"];
}

+ (NKFColor *)americanredcross12{
	return [NKFColor colorWithHexString:@"#7f181b"];
}

+ (NKFColor *)americanredcross13{
	return [NKFColor colorWithHexString:@"#d7d7d8"];
}

+ (NKFColor *)americanredcross14{
	return [NKFColor colorWithHexString:@"#9f9fa3"];
}

+ (NKFColor *)americanredcross15{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)recipe {
	return [NKFColor groceries];
}


+ (NKFColor *)redcross {
	return [NKFColor americanredcross];
}


+ (NKFColor *)riteaid {
	return [NKFColor colorWithRed:9.0f/255.0f green:17.0f/255.0f blue:144.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)riteaid2 {
	return [NKFColor colorWithRed:255.0f/255.0f green:1.0f/255.0f blue:3.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)android{
	return [NKFColor colorWithHexString:@"#a4c639"];
}


+ (NKFColor *)angieslist{
	return [NKFColor colorWithHexString:@"#7fbb00"];
}


+ (NKFColor *)answers{
	return [NKFColor colorWithHexString:@"#136ad5"];
}

+ (NKFColor *)answers2{
	return [NKFColor colorWithHexString:@"#fb8a2e"];
}


+ (NKFColor *)aol{
	return [NKFColor colorWithHexString:@"#ff0b00"];
}

+ (NKFColor *)aol2{
	return [NKFColor colorWithHexString:@"#00c4ff"];
}


+ (NKFColor *)apple {
	return [NKFColor colorWithRed:145.0f/255.0f green:156.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)archlinux{
	return [NKFColor colorWithHexString:@"#1793d1"];
}

+ (NKFColor *)archlinux2{
	return [NKFColor colorWithHexString:@"#333333"];
}


+ (NKFColor *)asana{
	return [NKFColor colorWithHexString:@"#1f8dd6"];
}

+ (NKFColor *)asana2{
	return [NKFColor colorWithHexString:@"#34ad00"];
}


+ (NKFColor *)associatedpress{
	return [NKFColor colorWithHexString:@"#ff322e"];
}


+ (NKFColor *)att{
	return [NKFColor colorWithHexString:@"#ff7200"];
}

+ (NKFColor *)att2{
	return [NKFColor colorWithHexString:@"#fcb314"];
}

+ (NKFColor *)att3{
	return [NKFColor colorWithHexString:@"#067ab4"];
}

+ (NKFColor *)att4{
	return [NKFColor colorWithHexString:@"#3aa5dc"];
}


+ (NKFColor *)atlanticcoast{
	return [NKFColor colorWithHexString:@"#013ca6"];
}

+ (NKFColor *)atlanticcoastconference{
	return [NKFColor colorWithHexString:@"#013ca6"];
}

+ (NKFColor *)atlanticcoastconferenceacc{
	return [NKFColor colorWithHexString:@"#013ca6"];
}

+ (NKFColor *)atlanticcoastconferenceacc2{
	return [NKFColor colorWithHexString:@"#a5a9ab"];
}


+ (NKFColor *)atlassian{
	return [NKFColor colorWithHexString:@"#003366"];
}


+ (NKFColor *)auth0{
	return [NKFColor colorWithHexString:@"#16214d"];
}

+ (NKFColor *)auth02{
	return [NKFColor colorWithHexString:@"#44c7f4"];
}

+ (NKFColor *)auth03{
	return [NKFColor colorWithHexString:@"#eb5424"];
}

+ (NKFColor *)auth04{
	return [NKFColor colorWithHexString:@"#d0d2d3"];
}


+ (NKFColor *)autozone {
	return [NKFColor colorWithRed:253.0f/255.0f green:2.0f/255.0f blue:27.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)autozone2 {
	return [NKFColor colorWithRed:255.0f/255.0f green:102.0f/255.0f blue:0.0f alpha:1.0f];
}


+ (NKFColor *)baidu{
	return [NKFColor colorWithHexString:@"#de0f17"];
}

+ (NKFColor *)baidu2{
	return [NKFColor colorWithHexString:@"#2529d8"];
}


+ (NKFColor *)bakers {
	return [NKFColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)bananarepublic {
	return [NKFColor colorWithRed:119.0f/255.0f green:79.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)bandcamp{
	return [NKFColor colorWithHexString:@"#629aa9"];
}


+ (NKFColor *)barnesnoble{
	return [NKFColor colorWithHexString:@"#2a5934"];
}


+ (NKFColor *)bebo{
	return [NKFColor colorWithHexString:@"#e04646"];
}


+ (NKFColor *)bedbathandbeyond {
	return [NKFColor colorWithRed:57.0f/255.0f green:75.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)bedbathbeyond {
	return [NKFColor bedbathandbeyond];
}


+ (NKFColor *)behance{
	return [NKFColor colorWithHexString:@"#1769ff"];
}


+ (NKFColor *)belk {
	return [NKFColor colorWithRed:0.0f green:143.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)belk2 {
	return [NKFColor colorWithRed:36.0f/255.0f green:64.0f/255.0f blue:143.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)bestbuy{
	return [NKFColor colorWithHexString:@"#003b64"];
}

+ (NKFColor *)bestbuy2{
	return [NKFColor colorWithHexString:@"#fff200"];
}


+ (NKFColor *)big5{
	return [NKFColor colorWithRed:51.0f/255.0f green:57.0f/255.0f blue:145.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)big5sportinggoods {
	return [NKFColor big5];
}

+ (NKFColor *)big5sports {
	return [NKFColor big5];
}


+ (NKFColor *)bigcartel{
	return [NKFColor colorWithHexString:@"#a0ac48"];
}

+ (NKFColor *)bigcartel2{
	return [NKFColor colorWithHexString:@"#70b29c"];
}


+ (NKFColor *)biglots {
	return [NKFColor colorWithRed:255.0f/255.0f green:121.0f/255.0f blue:0.0f alpha:1.0f];
}


+ (NKFColor *)bilo {
	return [NKFColor colorWithRed:254.0f/255.0f green:51.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)bilo2 {
	return [NKFColor colorWithRed:3.0f/255.0f green:151.0f/255.0f blue:63.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)bing2{
	return [NKFColor colorWithHexString:@"#ffb900"];
}

+ (NKFColor *)bing22{
	return [NKFColor colorWithHexString:@"#505050"];
}

+ (NKFColor *)bing23{
	return [NKFColor colorWithHexString:@"#a3a3a3"];
}


+ (NKFColor *)bitbucket{
	return [NKFColor colorWithHexString:@"#205081"];
}


+ (NKFColor *)bitly{
	return [NKFColor colorWithHexString:@"#ee6123"];
}

+ (NKFColor *)bitly2{
	return [NKFColor colorWithHexString:@"#61b3de"];
}


+ (NKFColor *)bjs {
	return [NKFColor colorWithRed:218.0f/255.0f green:38.0f/255.0f blue:29.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)blackberry{
	return [NKFColor colorWithHexString:@"#005387"];
}

+ (NKFColor *)blackberry2{
	return [NKFColor colorWithHexString:@"#8cb811"];
}

+ (NKFColor *)blackberry3{
	return [NKFColor colorWithHexString:@"#fdb813"];
}

+ (NKFColor *)blackberry4{
	return [NKFColor colorWithHexString:@"#88aca1"];
}

+ (NKFColor *)blackberry5{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)blackberry6{
	return [NKFColor colorWithHexString:@"#788cb6"];
}

+ (NKFColor *)blackberry7{
	return [NKFColor colorWithHexString:@"#a1a1a4"];
}

+ (NKFColor *)blackberry8{
	return [NKFColor colorWithHexString:@"#8f8f8c"];
}


+ (NKFColor *)blogger{
	return [NKFColor colorWithHexString:@"#f57d00"];
}


+ (NKFColor *)boeing{
	return [NKFColor colorWithHexString:@"#0039a6"];
}


+ (NKFColor *)bookingcom{
	return [NKFColor colorWithHexString:@"#003580"];
}


+ (NKFColor *)scouts{
	return [NKFColor colorWithHexString:@"#ce1126"];
}

+ (NKFColor *)boyscouts{
	return [NKFColor colorWithHexString:@"#ce1126"];
}

+ (NKFColor *)boyscoutsofamerica{
	return [NKFColor colorWithHexString:@"#ce1126"];
}

+ (NKFColor *)boyscoutsofamerica2{
	return [NKFColor colorWithHexString:@"#003f87"];
}

+ (NKFColor *)scouts2{
	return [NKFColor colorWithHexString:@"#003f87"];
}

+ (NKFColor *)boyscouts2{
	return [NKFColor colorWithHexString:@"#003f87"];
}


+ (NKFColor *)britishairways{
	return [NKFColor colorWithHexString:@"#075aaa"];
}

+ (NKFColor *)britishairways2{
	return [NKFColor colorWithHexString:@"#eb2226"];
}

+ (NKFColor *)britishairways3{
	return [NKFColor colorWithHexString:@"#01295c"];
}

+ (NKFColor *)britishairways4{
	return [NKFColor colorWithHexString:@"#efe9e5"];
}

+ (NKFColor *)britishairways5{
	return [NKFColor colorWithHexString:@"#aca095"];
}

+ (NKFColor *)britishairways6{
	return [NKFColor colorWithHexString:@"#b9cfed"];
}

+ (NKFColor *)britishairways7{
	return [NKFColor colorWithHexString:@"#a7a9ac"];
}


+ (NKFColor *)bt{
	return [NKFColor colorWithHexString:@"#d52685"];
}

+ (NKFColor *)bt2{
	return [NKFColor colorWithHexString:@"#553a99"];
}

+ (NKFColor *)bt3{
	return [NKFColor colorWithHexString:@"#6cbc35"];
}

+ (NKFColor *)bt4{
	return [NKFColor colorWithHexString:@"#fd9f3e"];
}

+ (NKFColor *)bt5{
	return [NKFColor colorWithHexString:@"#08538c"];
}


+ (NKFColor *)buffer{
	return [NKFColor colorWithHexString:@"#168eea"];
}

+ (NKFColor *)buffer2{
	return [NKFColor colorWithHexString:@"#ee4f4f"];
}

+ (NKFColor *)buffer3{
	return [NKFColor colorWithHexString:@"#fff9ea"];
}

+ (NKFColor *)buffer4{
	return [NKFColor colorWithHexString:@"#76b852"];
}

+ (NKFColor *)buffer5{
	return [NKFColor colorWithHexString:@"#323b43"];
}

+ (NKFColor *)buffer6{
	return [NKFColor colorWithHexString:@"#59626a"];
}

+ (NKFColor *)buffer7{
	return [NKFColor colorWithHexString:@"#ced7df"];
}

+ (NKFColor *)buffer8{
	return [NKFColor colorWithHexString:@"#eff3f6"];
}

+ (NKFColor *)buffer9{
	return [NKFColor colorWithHexString:@"#f4f7f9"];
}


+ (NKFColor *)burgerking{
	return [NKFColor colorWithHexString:@"#ec1c24"];
}

+ (NKFColor *)burgerking2{
	return [NKFColor colorWithHexString:@"#fdbd10"];
}

+ (NKFColor *)burgerking3{
	return [NKFColor colorWithHexString:@"#0066b2"];
}

+ (NKFColor *)burgerking4{
	return [NKFColor colorWithHexString:@"#ed7902"];
}


+ (NKFColor *)burlington {
	return [NKFColor burlingtoncoatfactory];
}

+ (NKFColor *)burlingtoncoatfactory {
	return [NKFColor colorWithRed:171.0f/255.0f green:29.0f/255.0f blue:56.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)bynder{
	return [NKFColor colorWithHexString:@"#1ca0de"];
}

+ (NKFColor *)bynder2{
	return [NKFColor colorWithHexString:@"#343a4e"];
}


+ (NKFColor *)cabot {
	return [NKFColor colorWithRed:236.0f/255.0f green:28.0f/255.0f blue:45.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)cabot2 {
	return [NKFColor colorWithRed:6.0f/255.0f green:151.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)canon{
	return [NKFColor colorWithHexString:@"#bc0024"];
}

+ (NKFColor *)canon2{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)carbonmade{
	return [NKFColor colorWithHexString:@"#613854"];
}


+ (NKFColor *)carrefour{
	return [NKFColor colorWithHexString:@"#00387b"];
}

+ (NKFColor *)carrefour2{
	return [NKFColor colorWithHexString:@"#bb1e10"];
}

+ (NKFColor *)carrefour3{
	return [NKFColor colorWithHexString:@"#f67828"];
}

+ (NKFColor *)carrefour4{
	return [NKFColor colorWithHexString:@"#237f52"];
}


+ (NKFColor *)casemate{
	return [NKFColor colorWithHexString:@"#84754e"];
}

+ (NKFColor *)casemate2{
	return [NKFColor colorWithHexString:@"#a6192e"];
}

+ (NKFColor *)casemate3{
	return [NKFColor colorWithHexString:@"#decba5"];
}

+ (NKFColor *)casemate4{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)champs {
	return [NKFColor colorWithRed:0.0f green:58.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)champssports {
	return [NKFColor champs];
}


+ (NKFColor *)charitywater{
	return [NKFColor colorWithHexString:@"#ffc907"];
}

+ (NKFColor *)charitywater2{
	return [NKFColor colorWithHexString:@"#2e9df7"];
}

+ (NKFColor *)charitywater3{
	return [NKFColor colorWithHexString:@"#231f20"];
}


+ (NKFColor *)chilis {
	return [NKFColor colorWithRed:14.0f/255.0f green:136.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)chilis2 {
	return [NKFColor colorWithRed:238.0f/255.0f green:54.0f/255.0f blue:37.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)cheddar{
	return [NKFColor colorWithHexString:@"#ff7243"];
}


+ (NKFColor *)citymarket {
	return [NKFColor colorWithRed:237.0f/255.0f green:28.0f/255.0f blue:36.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)cocacola{
	return [NKFColor colorWithHexString:@"#ed1c16"];
}


+ (NKFColor *)codeschool{
	return [NKFColor colorWithHexString:@"#616f67"];
}

+ (NKFColor *)codeschool2{
	return [NKFColor colorWithHexString:@"#c68143"];
}


+ (NKFColor *)codecademy{
	return [NKFColor colorWithHexString:@"#f65a5b"];
}

+ (NKFColor *)codecademy2{
	return [NKFColor colorWithHexString:@"#204056"];
}

+ (NKFColor *)costco {
	return [NKFColor colorWithRed:227.0f/255.0f green:24.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)costco2 {
	return [NKFColor colorWithRed:0.0f green:93.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)craftcms{
	return [NKFColor colorWithHexString:@"#da5a47"];
}


+ (NKFColor *)creativemarket{
	return [NKFColor colorWithHexString:@"#8ba753"];
}


+ (NKFColor *)crunchbase{
	return [NKFColor colorWithHexString:@"#2292a7"];
}


+ (NKFColor *)cub {
	return [NKFColor colorWithRed:255.0f/255.0f green:25.0f/255.0f blue:37.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)cunard{
	return [NKFColor colorWithHexString:@"#1d1d1b"];
}

+ (NKFColor *)cunard2{
	return [NKFColor colorWithHexString:@"#ae9a64"];
}

+ (NKFColor *)cunard3{
	return [NKFColor colorWithHexString:@"#e42313"];
}

+ (NKFColor *)cunard4{
	return [NKFColor colorWithHexString:@"#8b8c8d"];
}


+ (NKFColor *)cvs {
	return [NKFColor colorWithRed:222.0f/255.0f green:0.0f blue:0.0f alpha:1.0f];
}


+ (NKFColor *)daimler{
	return [NKFColor colorWithHexString:@"#263f6a"];
}

+ (NKFColor *)daimler2{
	return [NKFColor colorWithHexString:@"#182b45"];
}

+ (NKFColor *)daimler3{
	return [NKFColor colorWithHexString:@"#6b0f24"];
}

+ (NKFColor *)daimler4{
	return [NKFColor colorWithHexString:@"#193725"];
}

+ (NKFColor *)daimler5{
	return [NKFColor colorWithHexString:@"#606061"];
}


+ (NKFColor *)dairyqueen {
	return [NKFColor colorWithRed:222.0f/255.0f green:60.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)dannon {
	return [NKFColor colorWithRed:38.0f/255.0f green:58.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)dannon2 {
	return [NKFColor colorWithRed:202.0f/255.0f green:30.0f/255.0f blue:42.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)dannon3 {
	return [NKFColor colorWithRed:66.0f/255.0f green:183.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)delectable{
	return [NKFColor colorWithHexString:@"#334858"];
}

+ (NKFColor *)delectable2{
	return [NKFColor colorWithHexString:@"#cd595a"];
}

+ (NKFColor *)delectable3{
	return [NKFColor colorWithHexString:@"#94938f"];
}

+ (NKFColor *)delectable4{
	return [NKFColor colorWithHexString:@"#a3a7a6"];
}

+ (NKFColor *)delectable5{
	return [NKFColor colorWithHexString:@"#dbc5b0"];
}

+ (NKFColor *)delectable6{
	return [NKFColor colorWithHexString:@"#f8dfc2"];
}

+ (NKFColor *)delectable7{
	return [NKFColor colorWithHexString:@"#f9ebdf"];
}


+ (NKFColor *)delhaize {
	return [NKFColor colorWithRed:244.0f/255.0f green:7.0f/255.0f blue:9.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)delhaze {
	return [NKFColor delhaize];
}


+ (NKFColor *)delicious{
	return [NKFColor colorWithHexString:@"#3399ff"];
}

+ (NKFColor *)delicious2{
	return [NKFColor colorWithHexString:@"#222222"];
}

+ (NKFColor *)delicious3{
	return [NKFColor colorWithHexString:@"#eeeeee"];
}


+ (NKFColor *)dell{
	return [NKFColor colorWithHexString:@"#0085c3"];
}

+ (NKFColor *)dell2{
	return [NKFColor colorWithHexString:@"#7ab800"];
}

+ (NKFColor *)dell3{
	return [NKFColor colorWithHexString:@"#f2af00"];
}

+ (NKFColor *)dell4{
	return [NKFColor colorWithHexString:@"#dc5034"];
}

+ (NKFColor *)dell5{
	return [NKFColor colorWithHexString:@"#ce1126"];
}

+ (NKFColor *)dell6{
	return [NKFColor colorWithHexString:@"#b7295a"];
}

+ (NKFColor *)dell7{
	return [NKFColor colorWithHexString:@"#6e2585"];
}

+ (NKFColor *)dell8{
	return [NKFColor colorWithHexString:@"#71c6c1"];
}

+ (NKFColor *)dell9{
	return [NKFColor colorWithHexString:@"#5482ab"];
}

+ (NKFColor *)dell10{
	return [NKFColor colorWithHexString:@"#009bbb"];
}

+ (NKFColor *)dell11{
	return [NKFColor colorWithHexString:@"#444444"];
}

+ (NKFColor *)dell12{
	return [NKFColor colorWithHexString:@"#eeeeee"];
}


+ (NKFColor *)dentalplans{
	return [NKFColor colorWithHexString:@"#f99104"];
}

+ (NKFColor *)dentalplans2{
	return [NKFColor colorWithHexString:@"#00b7c9"];
}


+ (NKFColor *)designernews{
	return [NKFColor colorWithHexString:@"#2d72d9"];
}


+ (NKFColor *)designmoo{
	return [NKFColor colorWithHexString:@"#e64b50"];
}

+ (NKFColor *)designmoo2{
	return [NKFColor colorWithHexString:@"#dbc65d"];
}


+ (NKFColor *)deviantart{
	return [NKFColor colorWithHexString:@"#05cc47"];
}

+ (NKFColor *)deviantart2{
	return [NKFColor colorWithHexString:@"#4dc47d"];
}

+ (NKFColor *)deviantart3{
	return [NKFColor colorWithHexString:@"#181a1b"];
}


+ (NKFColor *)devour{
	return [NKFColor colorWithHexString:@"#ff0000"];
}


+ (NKFColor *)dewalt{
	return [NKFColor colorWithHexString:@"#febd17"];
}


+ (NKFColor *)dhl{
	return [NKFColor colorWithHexString:@"#ba0c2f"];
}

+ (NKFColor *)dhl2{
	return [NKFColor colorWithHexString:@"#ffcd00"];
}

+ (NKFColor *)dhl3{
	return [NKFColor colorWithHexString:@"#c9c9c9"];
}


+ (NKFColor *)dicks {
	return [NKFColor colorWithRed:37.0f/255.0f green:120.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)dickssportinggoods {
	return [NKFColor dicks];
}


+ (NKFColor *)dierbergs {
	return [NKFColor colorWithRed:251.0f/255.0f green:1.0f/255.0f blue:21.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)dierbergs2 {
	return [NKFColor colorWithRed:193.0f/255.0f green:148.0f/255.0f blue:47.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)dierbergs3 {
	return [NKFColor black];
}

+ (NKFColor *)dierbersmarket {
	return [NKFColor dierbergs];
}


+ (NKFColor *)digg{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)dillons {
	return [NKFColor colorWithRed:203.0f/255.0f green:22.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)directtv{
	return [NKFColor colorWithHexString:@"#00a6d6"];
}

+ (NKFColor *)directv{
	return [NKFColor colorWithHexString:@"#00a6d6"];
}

+ (NKFColor *)directv2{
	return [NKFColor colorWithHexString:@"#00629b"];
}

+ (NKFColor *)directv3{
	return [NKFColor colorWithHexString:@"#003865"];
}


+ (NKFColor *)disqus{
	return [NKFColor colorWithHexString:@"#2e9fff"];
}


+ (NKFColor *)django{
	return [NKFColor colorWithHexString:@"#092e20"];
}


+ (NKFColor *)dollartree {
	return [NKFColor colorWithHexString:@"41aa51"];
}

+ (NKFColor *)dollarstore {
	return [NKFColor dollartree];
}


+ (NKFColor *)dollargeneral {
	return [NKFColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:1.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)dominos{
	return [NKFColor colorWithHexString:@"#0b648f"];
}

+ (NKFColor *)dominos2{
	return [NKFColor colorWithHexString:@"#e21737"];
}


+ (NKFColor *)dow{
	return [NKFColor colorWithHexString:@"#e80033"];
}

+ (NKFColor *)dow2{
	return [NKFColor colorWithHexString:@"#fdbb30"];
}

+ (NKFColor *)dow3{
	return [NKFColor colorWithHexString:@"#ed8b00"];
}

+ (NKFColor *)dow4{
	return [NKFColor colorWithHexString:@"#f15d22"];
}

+ (NKFColor *)dow5{
	return [NKFColor colorWithHexString:@"#bf0d3e"];
}

+ (NKFColor *)dow6{
	return [NKFColor colorWithHexString:@"#910048"];
}

+ (NKFColor *)dow7{
	return [NKFColor colorWithHexString:@"#d0006f"];
}


+ (NKFColor *)dribbble{
	return [NKFColor colorWithHexString:@"#444444"];
}

+ (NKFColor *)dribbble2{
	return [NKFColor colorWithHexString:@"#ea4c89"];
}

+ (NKFColor *)dribbble3{
	return [NKFColor colorWithHexString:@"#8aba56"];
}

+ (NKFColor *)dribbble4{
	return [NKFColor colorWithHexString:@"#ff8833"];
}

+ (NKFColor *)dribbble5{
	return [NKFColor colorWithHexString:@"#00b6e3"];
}

+ (NKFColor *)dribbble6{
	return [NKFColor colorWithHexString:@"#9ba5a8"];
}


+ (NKFColor *)dropbox{
	return [NKFColor colorWithHexString:@"#007ee5"];
}

+ (NKFColor *)dropbox2{
	return [NKFColor colorWithHexString:@"#7b8994"];
}

+ (NKFColor *)dropbox3{
	return [NKFColor colorWithHexString:@"#47525d"];
}

+ (NKFColor *)dropbox4{
	return [NKFColor colorWithHexString:@"#3d464d"];
}


+ (NKFColor *)droplr{
	return [NKFColor colorWithHexString:@"#5654a4"];
}


+ (NKFColor *)drupal{
	return [NKFColor colorWithHexString:@"#0077c0"];
}

+ (NKFColor *)drupal2{
	return [NKFColor colorWithHexString:@"#81ceff"];
}

+ (NKFColor *)drupal3{
	return [NKFColor colorWithHexString:@"#00598e"];
}


+ (NKFColor *)dunked{
	return [NKFColor colorWithHexString:@"#2da9d7"];
}

+ (NKFColor *)dunked2{
	return [NKFColor colorWithHexString:@"#212a3e"];
}


+ (NKFColor *)dunkindonuts {
	return [NKFColor colorWithHexString:@"#D81860"];
}

+ (NKFColor *)dunkindonuts2 {
	return [NKFColor colorWithHexString:@"#FC772A"];
}

+ (NKFColor *)dunkindonuts3 {
	return [NKFColor colorWithHexString:@"#8D6E51"];
}

+ (NKFColor *)dunkindonuts4 {
	return [NKFColor colorWithHexString:@"#483030"];
}

+ (NKFColor *)dunkingdonuts {
	return [NKFColor dunkindonuts];
}

+ (NKFColor *)donuts {
	return [NKFColor dunkindonuts];
}


+ (NKFColor *)etrade{
	return [NKFColor colorWithHexString:@"#6633cc"];
}

+ (NKFColor *)etrade2{
	return [NKFColor colorWithHexString:@"#99cc00"];
}


+ (NKFColor *)easyjet{
	return [NKFColor colorWithHexString:@"#ff6600"];
}

+ (NKFColor *)easyjet2{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)easyjet3{
	return [NKFColor colorWithHexString:@"#58595b"];
}


+ (NKFColor *)ebay{
	return [NKFColor colorWithHexString:@"#e53238"];
}

+ (NKFColor *)ebay2{
	return [NKFColor colorWithHexString:@"#0064d2"];
}

+ (NKFColor *)ebay3{
	return [NKFColor colorWithHexString:@"#f5af02"];
}

+ (NKFColor *)ebay4{
	return [NKFColor colorWithHexString:@"#86b817"];
}


+ (NKFColor *)elance{
	return [NKFColor colorWithHexString:@"#0d69af"];
}


+ (NKFColor *)ello{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)ember{
	return [NKFColor colorWithHexString:@"#f23819"];
}


+ (NKFColor *)engadget{
	return [NKFColor colorWithHexString:@"#40b3ff"];
}


+ (NKFColor *)envato{
	return [NKFColor colorWithHexString:@"#82b541"];
}


+ (NKFColor *)ericsson{
	return [NKFColor colorWithHexString:@"#002561"];
}


+ (NKFColor *)esl{
	return [NKFColor colorWithHexString:@"#0d9ddb"];
}

+ (NKFColor *)esl2{
	return [NKFColor colorWithHexString:@"#48b8e7"];
}

+ (NKFColor *)esl3{
	return [NKFColor colorWithHexString:@"#efecea"];
}

+ (NKFColor *)esl4{
	return [NKFColor colorWithHexString:@"#2c2b2b"];
}


+ (NKFColor *)espn{
	return [NKFColor colorWithHexString:@"#ff0033"];
}


+ (NKFColor *)etsy{
	return [NKFColor colorWithHexString:@"#d5641c"];
}


+ (NKFColor *)evernote{
	return [NKFColor colorWithHexString:@"#7ac142"];
}

+ (NKFColor *)evernote2{
	return [NKFColor colorWithHexString:@"#808084"];
}


+ (NKFColor *)fabcom{
	return [NKFColor colorWithHexString:@"#dd0017"];
}

+ (NKFColor *)fabcom2{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)facebook{
	return [NKFColor colorWithHexString:@"#3b5998"];
}


+ (NKFColor *)familydollar {
	return [NKFColor colorWithRed:253.0f/255.0f green:72.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)familydollar2 {
	return [NKFColor colorWithRed:255.0f/255.0f green:173.0f/255.0f blue:63.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)familyfare {
	return [NKFColor colorWithRed:242.0f/255.0f green:45.0f/255.0f blue:8.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)famous{
	return [NKFColor colorWithHexString:@"#fa5c4f"];
}

+ (NKFColor *)famous2{
	return [NKFColor colorWithHexString:@"#333333"];
}


+ (NKFColor *)fancy{
	return [NKFColor colorWithHexString:@"#3098dc"];
}

+ (NKFColor *)fancy2{
	return [NKFColor colorWithHexString:@"#494e58"];
}


+ (NKFColor *)farmfresh {
	return [NKFColor colorWithRed:2.0f/255.0f green:100.0f/255.0f blue:47.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)farmfresh2 {
	return [NKFColor colorWithRed:26.0f/255.0f green:187.0f/255.0f blue:83.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)farmfresh3 {
	return [NKFColor colorWithRed:245.0f/255.0f green:237.0f/255.0f blue:14.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)farmfresh4 {
	return [NKFColor colorWithRed:241.0f/255.0f green:25.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)fedex{
	return [NKFColor colorWithHexString:@"#660099"];
}

+ (NKFColor *)fedex2{
	return [NKFColor colorWithHexString:@"#ff6600"];
}

+ (NKFColor *)fedex3{
	return [NKFColor colorWithHexString:@"#00cc00"];
}

+ (NKFColor *)fedex4{
	return [NKFColor colorWithHexString:@"#0099cc"];
}

+ (NKFColor *)fedex5{
	return [NKFColor colorWithHexString:@"#ff0033"];
}

+ (NKFColor *)fedex6{
	return [NKFColor colorWithHexString:@"#ffcc00"];
}

+ (NKFColor *)fedex7{
	return [NKFColor colorWithHexString:@"#999999"];
}

+ (NKFColor *)federalexpress {
	return [NKFColor fedex];
}


+ (NKFColor *)fiat{
	return [NKFColor colorWithHexString:@"#96172e"];
}

+ (NKFColor *)fiat2{
	return [NKFColor colorWithHexString:@"#6d2d41"];
}


+ (NKFColor *)firefox{
	return [NKFColor colorWithHexString:@"#e66000"];
}

+ (NKFColor *)firefox2{
	return [NKFColor colorWithHexString:@"#ff9500"];
}

+ (NKFColor *)firefox3{
	return [NKFColor colorWithHexString:@"#ffcb00"];
}

+ (NKFColor *)firefox4{
	return [NKFColor colorWithHexString:@"#00539f"];
}

+ (NKFColor *)firefox5{
	return [NKFColor colorWithHexString:@"#0095dd"];
}

+ (NKFColor *)firefox6{
	return [NKFColor colorWithHexString:@"#331e54"];
}

+ (NKFColor *)firefox7{
	return [NKFColor colorWithHexString:@"#002147"];
}


+ (NKFColor *)fitbit{
	return [NKFColor colorWithHexString:@"#4cc2c4"];
}

+ (NKFColor *)fitbit2{
	return [NKFColor colorWithHexString:@"#f54785"];
}

+ (NKFColor *)fitbit3{
	return [NKFColor colorWithHexString:@"#343434"];
}


+ (NKFColor *)fiveguys{
	return [NKFColor colorWithHexString:@"#ed174f"];
}

+ (NKFColor *)fiveguys2{
	return [NKFColor colorWithHexString:@"#fbb040"];
}

+ (NKFColor *)fiveguys3{
	return [NKFColor colorWithHexString:@"#efc402"];
}

+ (NKFColor *)fiveguys4{
	return [NKFColor colorWithHexString:@"#d4891c"];
}


+ (NKFColor *)flattr{
	return [NKFColor colorWithHexString:@"#f67c1a"];
}

+ (NKFColor *)flattr2{
	return [NKFColor colorWithHexString:@"#338d11"];
}


+ (NKFColor *)flavorsme{
	return [NKFColor colorWithHexString:@"#f10087"];
}

+ (NKFColor *)flavorsme2{
	return [NKFColor colorWithHexString:@"#009ae7"];
}


+ (NKFColor *)flickr{
	return [NKFColor colorWithHexString:@"#0063dc"];
}

+ (NKFColor *)flickr2{
	return [NKFColor colorWithHexString:@"#ff0084"];
}


+ (NKFColor *)flipboard{
	return [NKFColor colorWithHexString:@"#e12828"];
}


+ (NKFColor *)flixster{
	return [NKFColor colorWithHexString:@"#2971b2"];
}


+ (NKFColor *)follr{
	return [NKFColor colorWithHexString:@"#4dc9f6"];
}

+ (NKFColor *)follr2{
	return [NKFColor colorWithHexString:@"#f67019"];
}

+ (NKFColor *)follr3{
	return [NKFColor colorWithHexString:@"#f53794"];
}

+ (NKFColor *)follr4{
	return [NKFColor colorWithHexString:@"#537bc4"];
}

+ (NKFColor *)follr5{
	return [NKFColor colorWithHexString:@"#acc236"];
}


+ (NKFColor *)food4less {
	return [NKFColor black];
}

+ (NKFColor *)food4less2 {
	return [NKFColor colorWithRed:249.0f/255.0f green:232.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)foodsco {
	return [NKFColor colorWithRed:0.0f/255.0f green:160.0f/255.0f blue:62.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)foodlion {
	return [NKFColor colorWithRed:0.0f/255.0f green:75.0f/255.0f blue:130.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)foodlion2 {
	return [NKFColor black];
}


+ (NKFColor *)footlocker {
	return [NKFColor colorWithRed:204.0f/255.0f green:37.0f/255.0f blue:39.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)forever21 {
	return [NKFColor colorWithRed:255.0f/255.0f green:233.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)forrst{
	return [NKFColor colorWithHexString:@"#5b9a68"];
}


+ (NKFColor *)foursquare{
	return [NKFColor colorWithHexString:@"#f94877"];
}

+ (NKFColor *)foursquare2{
	return [NKFColor colorWithHexString:@"#0732a2"];
}

+ (NKFColor *)foursquare3{
	return [NKFColor colorWithHexString:@"#2d5be3"];
}


+ (NKFColor *)fredmeyers {
	return [NKFColor colorWithRed:237.0f/255.0f green:28.0f/255.0f blue:36.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)fredmeyer {
	return [NKFColor fredmeyers];
}


+ (NKFColor *)frys {
	return [NKFColor colorWithRed:236.0f/255.0f green:28.0f/255.0f blue:44.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)frys2 {
	return [NKFColor black];
}


+ (NKFColor *)gap {
	return [NKFColor colorWithRed:0.0f green:42.0f/255.0f blue:95.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)garmin{
	return [NKFColor colorWithHexString:@"#007cc3"];
}


+ (NKFColor *)geocaching{
	return [NKFColor colorWithHexString:@"#4a742c"];
}


+ (NKFColor *)gerbes {
	return [NKFColor dillons];
}


+ (NKFColor *)ghost{
	return [NKFColor colorWithHexString:@"#212425"];
}

+ (NKFColor *)ghost2{
	return [NKFColor colorWithHexString:@"#718087"];
}

+ (NKFColor *)ghost3{
	return [NKFColor colorWithHexString:@"#5ba4e5"];
}

+ (NKFColor *)ghost4{
	return [NKFColor colorWithHexString:@"#9fbb58"];
}

+ (NKFColor *)ghost5{
	return [NKFColor colorWithHexString:@"#e9e8dd"];
}


+ (NKFColor *)gibson{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)gibson2{
	return [NKFColor colorWithHexString:@"#436f8e"];
}

+ (NKFColor *)gibson3{
	return [NKFColor colorWithHexString:@"#887d59"];
}

+ (NKFColor *)gibson4{
	return [NKFColor colorWithHexString:@"#8f9696"];
}


+ (NKFColor *)gimmebar{
	return [NKFColor colorWithHexString:@"#d6156c"];
}


+ (NKFColor *)github{
	return [NKFColor colorWithHexString:@"#4183c4"];
}

+ (NKFColor *)github2{
	return [NKFColor colorWithHexString:@"#999999"];
}

+ (NKFColor *)github3{
	return [NKFColor colorWithHexString:@"#666666"];
}

+ (NKFColor *)github4{
	return [NKFColor colorWithHexString:@"#333333"];
}

+ (NKFColor *)github5{
	return [NKFColor colorWithHexString:@"#6cc644"];
}

+ (NKFColor *)github6{
	return [NKFColor colorWithHexString:@"#bd2c00"];
}

+ (NKFColor *)github7{
	return [NKFColor colorWithHexString:@"#ff9933"];
}


+ (NKFColor *)gittip{
	return [NKFColor colorWithHexString:@"#663300"];
}

+ (NKFColor *)gittip2{
	return [NKFColor colorWithHexString:@"#339966"];
}


+ (NKFColor *)godaddy{
	return [NKFColor colorWithHexString:@"#7db701"];
}

+ (NKFColor *)godaddy2{
	return [NKFColor colorWithHexString:@"#ff8a00"];
}


+ (NKFColor *)goodreads{
	return [NKFColor colorWithHexString:@"#553b08"];
}


+ (NKFColor *)google{
	return [NKFColor colorWithHexString:@"#4285f4"];
}

+ (NKFColor *)google2{
	return [NKFColor colorWithHexString:@"#db4437"];
}

+ (NKFColor *)google3{
	return [NKFColor colorWithHexString:@"#f4b400"];
}

+ (NKFColor *)google4{
	return [NKFColor colorWithHexString:@"#0f9d58"];
}

+ (NKFColor *)google5{
	return [NKFColor colorWithHexString:@"#e7e6dd"];
}


+ (NKFColor *)googleplus{
	return [NKFColor colorWithHexString:@"#dd4b39"];
}


+ (NKFColor *)guitarcenter {
	return [NKFColor colorWithRed:245.0f/255.0f green:33.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)gravatar{
	return [NKFColor colorWithHexString:@"#1e8cbe"];
}


+ (NKFColor *)grocery{
	return [NKFColor forestGreenTraditional];
}

+ (NKFColor *)groceries {
	return [NKFColor grocery];
}

+ (NKFColor *)grocerystore {
	return [NKFColor grocery];
}

+ (NKFColor *)store {
	return [NKFColor grocery];
}


+ (NKFColor *)groupon{
	return [NKFColor colorWithHexString:@"#82b548"];
}


+ (NKFColor *)hackernews{
	return [NKFColor colorWithHexString:@"#ff6600"];
}


+ (NKFColor *)handm {
	return [NKFColor colorWithRed:254.0f/255.0f green:0.0f blue:2.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)hannaford {
	return [NKFColor colorWithRed:236.0f/255.0f green:27.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)hannaford2 {
	return [NKFColor colorWithRed:47.0f/255.0f green:180.0f/255.0f blue:86.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)hannaford3 {
	return [NKFColor colorWithRed:145.0f/255.0f green:109.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)hannaford4 {
	return [NKFColor colorWithRed:254.0f/255.0f green:225.0f/255.0f blue:152.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)harristeeter {
	return [NKFColor colorWithRed:219.0f/255.0f green:2.0f/255.0f blue:5.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)harristeeter2 {
	return [NKFColor colorWithRed:1.0f/255.0f green:173.0f/255.0f blue:95.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)harristeeter3 {
	return [NKFColor colorWithRed:37.0f/255.0f green:109.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)harristeeter4 {
	return [NKFColor colorWithRed:248.0f/255.0f green:179.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)harristeeter5 {
	return [NKFColor colorWithRed:246.0f/255.0f green:67.0f/255.0f blue:78.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)harristeeter6 {
	return [NKFColor colorWithRed:1.0f/255.0f green:164.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)heb {
	return [NKFColor colorWithRed:254.0f/255.0f green:0.0f/255.0f blue:2.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)hebplus {
	return [NKFColor colorWithRed:2.0f/255.0f green:146.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)heineken{
	return [NKFColor colorWithHexString:@"#00a100"];
}

+ (NKFColor *)heineken2{
	return [NKFColor colorWithHexString:@"#ff2b00"];
}

+ (NKFColor *)heineken3{
	return [NKFColor colorWithHexString:@"#999999"];
}


+ (NKFColor *)hellowallet{
	return [NKFColor colorWithHexString:@"#0093d0"];
}


+ (NKFColor *)heroku{
	return [NKFColor colorWithHexString:@"#c9c3e6"];
}

+ (NKFColor *)heroku2{
	return [NKFColor colorWithHexString:@"#6762a6"];
}


+ (NKFColor *)hi5{
	return [NKFColor colorWithHexString:@"#fd9827"];
}


+ (NKFColor *)hilander {
	return [NKFColor colorWithRed:0.0f/255.0f green:128.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)hobbylobby {
	return [NKFColor colorWithRed:222.0f/255.0f green:104.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)homedepot{
	return [NKFColor colorWithHexString:@"#f96305"];
}

+ (NKFColor *)homeimprovement {
	return [NKFColor homedepot];
}


+ (NKFColor *)homegoods {
	return [NKFColor colorWithRed:211.0f/255.0f green:18.0f/255.0f blue:65.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)hootsuite{
	return [NKFColor colorWithHexString:@"#003265"];
}

+ (NKFColor *)hootsuite2{
	return [NKFColor colorWithHexString:@"#f7e8d5"];
}

+ (NKFColor *)hootsuite3{
	return [NKFColor colorWithHexString:@"#ffbd0a"];
}

+ (NKFColor *)hootsuite4{
	return [NKFColor colorWithHexString:@"#c6af92"];
}

+ (NKFColor *)hootsuite5{
	return [NKFColor colorWithHexString:@"#71685f"];
}

+ (NKFColor *)hootsuite6{
	return [NKFColor colorWithHexString:@"#54493f"];
}

+ (NKFColor *)hootsuite7{
	return [NKFColor colorWithHexString:@"#38322d"];
}


+ (NKFColor *)hornbachers {
	return [NKFColor colorWithRed:239.0f/255.0f green:60.0f/255.0f blue:70.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)houzz{
	return [NKFColor colorWithHexString:@"#7ac142"];
}

+ (NKFColor *)houzz2{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)hp{
	return [NKFColor colorWithHexString:@"#0096d6"];
}

+ (NKFColor *)hp2{
	return [NKFColor colorWithHexString:@"#d7410b"];
}

+ (NKFColor *)hewlettpackard {
	return [NKFColor hp];
}

+ (NKFColor *)hewlettpackard2 {
	return [NKFColor hp2];
}


+ (NKFColor *)hsbc{
	return [NKFColor colorWithHexString:@"#db0011"];
}


+ (NKFColor *)html5{
	return [NKFColor colorWithHexString:@"#e34f26"];
}


+ (NKFColor *)hulu{
	return [NKFColor colorWithHexString:@"#a5cd39"];
}

+ (NKFColor *)hulu2{
	return [NKFColor colorWithHexString:@"#6bb03e"];
}


+ (NKFColor *)ibm{
	return [NKFColor colorWithHexString:@"#006699"];
}


+ (NKFColor *)identica{
	return [NKFColor colorWithHexString:@"#789240"];
}

+ (NKFColor *)identica2{
	return [NKFColor colorWithHexString:@"#7d0100"];
}

+ (NKFColor *)identica3{
	return [NKFColor colorWithHexString:@"#8baaff"];
}


+ (NKFColor *)ifttt{
	return [NKFColor colorWithHexString:@"#33ccff"];
}

+ (NKFColor *)ifttt2{
	return [NKFColor colorWithHexString:@"#ff4400"];
}

+ (NKFColor *)ifttt3{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)iheartradio{
	return [NKFColor colorWithHexString:@"#c6002b"];
}


+ (NKFColor *)ikea{
	return [NKFColor colorWithHexString:@"#ffcc00"];
}

+ (NKFColor *)ikea2{
	return [NKFColor colorWithHexString:@"#003399"];
}


+ (NKFColor *)imdb{
	return [NKFColor colorWithHexString:@"#f5de50"];
}


+ (NKFColor *)imgur{
	return [NKFColor colorWithHexString:@"#85bf25"];
}


+ (NKFColor *)indiegogo{
	return [NKFColor colorWithHexString:@"#eb1478"];
}


+ (NKFColor *)instacart{
	return [NKFColor colorWithHexString:@"#60ab59"];
}


+ (NKFColor *)instagram{
	return [NKFColor colorWithHexString:@"#3f729b"];
}


+ (NKFColor *)instapaper{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)instapaper2{
	return [NKFColor colorWithHexString:@"#428bca"];
}


+ (NKFColor *)intel{
	return [NKFColor colorWithHexString:@"#0f7dc2"];
}


+ (NKFColor *)intuit{
	return [NKFColor colorWithHexString:@"#365ebf"];
}


+ (NKFColor *)ios{
	return [NKFColor colorWithHexString:@"#5fc9f8"];
}

+ (NKFColor *)ios2{
	return [NKFColor colorWithHexString:@"#fecb2e"];
}

+ (NKFColor *)ios3{
	return [NKFColor colorWithHexString:@"#fd9426"];
}

+ (NKFColor *)ios4{
	return [NKFColor colorWithHexString:@"#fc3158"];
}

+ (NKFColor *)ios5{
	return [NKFColor colorWithHexString:@"#147efb"];
}

+ (NKFColor *)ios6{
	return [NKFColor colorWithHexString:@"#53d769"];
}

+ (NKFColor *)ios7{
	return [NKFColor colorWithHexString:@"#fc3d39"];
}

+ (NKFColor *)ios8{
	return [NKFColor colorWithHexString:@"#8e8e93"];
}


+ (NKFColor *)jawbone{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)jayc {
	return [NKFColor colorWithRed:196.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)jcpenney {
	return [NKFColor colorWithRed:237.0f/255.0f green:29.0f/255.0f blue:37.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)jcpenny {
	return [NKFColor jcpenney];
}

+ (NKFColor *)jcpenneys {
	return [NKFColor colorWithRed:46.0f/255.0f green:48.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)joann {
	return [NKFColor colorWithRed:11.0f/255.0f green:59.0f/255.0f blue:49.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)joannfabric {
	return [NKFColor joann];
}

+ (NKFColor *)joannfabrics {
	return [NKFColor joann];
}


+ (NKFColor *)joyent{
	return [NKFColor colorWithHexString:@"#ff6600"];
}


+ (NKFColor *)keeeb{
	return [NKFColor colorWithHexString:@"#00a9c0"];
}

+ (NKFColor *)kohls {
	return [NKFColor colorWithRed:135.0f/255.0f green:35.0f/255.0f blue:61.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)khanacademy{
	return [NKFColor colorWithHexString:@"#9cb443"];
}

+ (NKFColor *)khanacademy2{
	return [NKFColor colorWithHexString:@"#242f3a"];
}


+ (NKFColor *)kia{
	return [NKFColor colorWithHexString:@"#c21a30"];
}


+ (NKFColor *)kickstarter{
	return [NKFColor colorWithHexString:@"#2bde73"];
}

+ (NKFColor *)kickstarter2{
	return [NKFColor colorWithHexString:@"#0f2105"];
}


+ (NKFColor *)kingsoopers {
	return [NKFColor colorWithRed:237.0f/255.0f green:28.0f/255.0f blue:36.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)kingsoopers2 {
	return [NKFColor colorWithRed:255.0f/255.0f green:242.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)kinkos {
	return [NKFColor darkBlue];
}

+ (NKFColor *)kinkos2 {
	return [NKFColor redPantone];
}


+ (NKFColor *)kippt{
	return [NKFColor colorWithHexString:@"#d51007"];
}


+ (NKFColor *)kitkat{
	return [NKFColor colorWithHexString:@"#d70021"];
}


+ (NKFColor *)kiwipay{
	return [NKFColor colorWithHexString:@"#00b0df"];
}


+ (NKFColor *)kmart {
	return [NKFColor colorWithRed:227.0f/255.0f green:25.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)kroger {
	return [NKFColor colorWithRed:36.0f/255.0f green:96.0f/255.0f blue:166.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)kroger2 {
	return [NKFColor colorWithRed:216.0f/255.0f green:34.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)laravel{
	return [NKFColor colorWithHexString:@"#f55247"];
}


+ (NKFColor *)lastfm{
	return [NKFColor colorWithHexString:@"#d51007"];
}


+ (NKFColor *)linkedin{
	return [NKFColor colorWithHexString:@"#0077b5"];
}

+ (NKFColor *)linkedin2{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)linkedin3{
	return [NKFColor colorWithHexString:@"#313335"];
}

+ (NKFColor *)linkedin4{
	return [NKFColor colorWithHexString:@"#86888a"];
}

+ (NKFColor *)linkedin5{
	return [NKFColor colorWithHexString:@"#caccce"];
}

+ (NKFColor *)linkedin6{
	return [NKFColor colorWithHexString:@"#00a0dc"];
}

+ (NKFColor *)linkedin7{
	return [NKFColor colorWithHexString:@"#8d6cab"];
}

+ (NKFColor *)linkedin8{
	return [NKFColor colorWithHexString:@"#dd5143"];
}

+ (NKFColor *)linkedin9{
	return [NKFColor colorWithHexString:@"#e68523"];
}


+ (NKFColor *)livestream{
	return [NKFColor colorWithHexString:@"#cf202e"];
}

+ (NKFColor *)livestream2{
	return [NKFColor colorWithHexString:@"#232121"];
}

+ (NKFColor *)livestream3{
	return [NKFColor colorWithHexString:@"#f78822"];
}

+ (NKFColor *)livestream4{
	return [NKFColor colorWithHexString:@"#f6db35"];
}

+ (NKFColor *)livestream5{
	return [NKFColor colorWithHexString:@"#6dc067"];
}

+ (NKFColor *)livestream6{
	return [NKFColor colorWithHexString:@"#4185be"];
}

+ (NKFColor *)livestream7{
	return [NKFColor colorWithHexString:@"#8f499c"];
}


+ (NKFColor *)lloyds{
	return [NKFColor colorWithHexString:@"#d81f2a"];
}

+ (NKFColor *)lloyds2{
	return [NKFColor colorWithHexString:@"#ff9900"];
}

+ (NKFColor *)lloyds3{
	return [NKFColor colorWithHexString:@"#e0d86e"];
}

+ (NKFColor *)lloyds4{
	return [NKFColor colorWithHexString:@"#9ea900"];
}

+ (NKFColor *)lloyds5{
	return [NKFColor colorWithHexString:@"#6ec9e0"];
}

+ (NKFColor *)lloyds6{
	return [NKFColor colorWithHexString:@"#007ea3"];
}

+ (NKFColor *)lloyds7{
	return [NKFColor colorWithHexString:@"#9e4770"];
}

+ (NKFColor *)lloyds8{
	return [NKFColor colorWithHexString:@"#631d76"];
}

+ (NKFColor *)lloyds9{
	return [NKFColor colorWithHexString:@"#1e1e1e"];
}


+ (NKFColor *)lomo{
	return [NKFColor colorWithHexString:@"#eb0028"];
}

+ (NKFColor *)lomo2{
	return [NKFColor colorWithHexString:@"#00a0df"];
}


+ (NKFColor *)lowes {
	return [NKFColor colorWithRed:0.0f green:72.0f/255.0f blue:144.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)lucky {
	return [NKFColor colorWithRed:18.0f/255.0f green:49.0f/255.0f blue:86.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)luckybrand {
	return [NKFColor lucky];
}


+ (NKFColor *)lumo{
	return [NKFColor colorWithHexString:@"#576396"];
}


+ (NKFColor *)lyft{
	return [NKFColor colorWithHexString:@"#d71472"];
}

+ (NKFColor *)lyft2{
	return [NKFColor colorWithHexString:@"#333e48"];
}

+ (NKFColor *)lyft3{
	return [NKFColor colorWithHexString:@"#c2bcb5"];
}

+ (NKFColor *)lyft4{
	return [NKFColor colorWithHexString:@"#fcdcf0"];
}

+ (NKFColor *)lyft5{
	return [NKFColor colorWithHexString:@"#85a6c7"];
}

+ (NKFColor *)lyft6{
	return [NKFColor colorWithHexString:@"#00b2a9"];
}

+ (NKFColor *)lyft7{
	return [NKFColor colorWithHexString:@"#9bd9d9"];
}


+ (NKFColor *)macys {
	return [NKFColor colorWithRed:232.0f/255.0f green:1.0f/255.0f blue:1.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)mailchimp{
	return [NKFColor colorWithHexString:@"#2c9ab7"];
}

+ (NKFColor *)mailchimp2{
	return [NKFColor colorWithHexString:@"#449a88"];
}

+ (NKFColor *)mailchimp3{
	return [NKFColor colorWithHexString:@"#febe12"];
}

+ (NKFColor *)mailchimp4{
	return [NKFColor colorWithHexString:@"#db3a1b"];
}

+ (NKFColor *)mailchimp5{
	return [NKFColor colorWithHexString:@"#373737"];
}


+ (NKFColor *)marketbasket {
	return [NKFColor colorWithRed:204.0f/255.0f green:0.0f blue:27.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)marketbasket2 {
	return [NKFColor colorWithRed:4.0f/255.0f green:115.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)marshalls {
	return [NKFColor colorWithRed:0.0f green:48.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)massygroup{
	return [NKFColor colorWithHexString:@"#004a77"];
}

+ (NKFColor *)massygroup2{
	return [NKFColor colorWithHexString:@"#00adee"];
}

+ (NKFColor *)massygroup3{
	return [NKFColor colorWithHexString:@"#ff8100"];
}

+ (NKFColor *)massygroup4{
	return [NKFColor colorWithHexString:@"#ffd200"];
}


+ (NKFColor *)mastercard{
	return [NKFColor colorWithHexString:@"#cc0000"];
}

+ (NKFColor *)mastercard2{
	return [NKFColor colorWithHexString:@"#ff9900"];
}

+ (NKFColor *)mastercard3{
	return [NKFColor colorWithHexString:@"#000066"];
}


+ (NKFColor *)mcdonalds {
	return [NKFColor colorWithHexString:@"#FCC910"];
}


+ (NKFColor *)meetup{
	return [NKFColor colorWithHexString:@"#e0393e"];
}


+ (NKFColor *)meh {
	return [NKFColor colorWithRed:255.0f/255.0f green:106.0f/255.0f blue:0.0f alpha:1.0f];
}

+ (NKFColor *)mehcom {
	return [NKFColor meh];
}


+ (NKFColor *)microsoft{
	return [NKFColor colorWithHexString:@"#f65314"];
}

+ (NKFColor *)microsoft2{
	return [NKFColor colorWithHexString:@"#7cbb00"];
}

+ (NKFColor *)microsoft3{
	return [NKFColor colorWithHexString:@"#00a1f1"];
}

+ (NKFColor *)microsoft4{
	return [NKFColor colorWithHexString:@"#ffbb00"];
}


+ (NKFColor *)microsoftoffice{
	return [NKFColor colorWithHexString:@"#ea3e23"];
}


+ (NKFColor *)mixpanel{
	return [NKFColor colorWithHexString:@"#a086d3"];
}


+ (NKFColor *)motorola{
	return [NKFColor colorWithHexString:@"#5c92fa"];
}


+ (NKFColor *)muut{
	return [NKFColor colorWithHexString:@"#1fadc5"];
}

+ (NKFColor *)muut2{
	return [NKFColor colorWithHexString:@"#ff8000"];
}


+ (NKFColor *)myspace{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)nbc{
	return [NKFColor colorWithHexString:@"#e1ac26"];
}

+ (NKFColor *)nbc2{
	return [NKFColor colorWithHexString:@"#dc380f"];
}

+ (NKFColor *)nbc3{
	return [NKFColor colorWithHexString:@"#9f0812"];
}

+ (NKFColor *)nbc4{
	return [NKFColor colorWithHexString:@"#6347b2"];
}

+ (NKFColor *)nbc5{
	return [NKFColor colorWithHexString:@"#368dd5"];
}

+ (NKFColor *)nbc6{
	return [NKFColor colorWithHexString:@"#70af1e"];
}

+ (NKFColor *)nbc7{
	return [NKFColor colorWithHexString:@"#7e887a"];
}


+ (NKFColor *)nest{
	return [NKFColor colorWithHexString:@"#00afd8"];
}

+ (NKFColor *)nest2{
	return [NKFColor colorWithHexString:@"#7b858e"];
}


+ (NKFColor *)netflix{
	return [NKFColor colorWithHexString:@"#e50914"];
}

+ (NKFColor *)netflix2{
	return [NKFColor colorWithHexString:@"#221f1f"];
}

+ (NKFColor *)netflix3{
	return [NKFColor colorWithHexString:@"#f5f5f1"];
}


+ (NKFColor *)netvibes{
	return [NKFColor colorWithHexString:@"#39bd00"];
}


+ (NKFColor *)newbalance{
	return [NKFColor colorWithHexString:@"#ce2724"];
}

+ (NKFColor *)newbalance2{
	return [NKFColor colorWithHexString:@"#f3ec19"];
}

+ (NKFColor *)newbalance3{
	return [NKFColor colorWithHexString:@"#207c88"];
}

+ (NKFColor *)newbalance4{
	return [NKFColor colorWithHexString:@"#aac1bf"];
}

+ (NKFColor *)newbalance5{
	return [NKFColor colorWithHexString:@"#e8e9d7"];
}

+ (NKFColor *)newbalance6{
	return [NKFColor colorWithHexString:@"#4c4d4f"];
}

+ (NKFColor *)newbalance7{
	return [NKFColor colorWithHexString:@"#231f20"];
}


+ (NKFColor *)nextdoor{
	return [NKFColor colorWithHexString:@"#19975d"];
}


+ (NKFColor *)nike {
	return [NKFColor nikefootball];
}


+ (NKFColor *)nikefootball{
	return [NKFColor colorWithHexString:@"#504847"];
}

+ (NKFColor *)nikefootball2{
	return [NKFColor colorWithHexString:@"#27a770"];
}


+ (NKFColor *)nikefuel{
	return [NKFColor colorWithHexString:@"#4bad31"];
}

+ (NKFColor *)nikefuel2{
	return [NKFColor colorWithHexString:@"#f5dc00"];
}

+ (NKFColor *)nikefuel3{
	return [NKFColor colorWithHexString:@"#e95814"];
}

+ (NKFColor *)nikefuel4{
	return [NKFColor colorWithHexString:@"#e2142d"];
}


+ (NKFColor *)nokia{
	return [NKFColor colorWithHexString:@"#124191"];
}


+ (NKFColor *)novartis{
	return [NKFColor colorWithHexString:@"#765438"];
}

+ (NKFColor *)novartis2{
	return [NKFColor colorWithHexString:@"#a13323"];
}

+ (NKFColor *)novartis3{
	return [NKFColor colorWithHexString:@"#e65124"];
}

+ (NKFColor *)novartis4{
	return [NKFColor colorWithHexString:@"#ec7f22"];
}

+ (NKFColor *)novartis5{
	return [NKFColor colorWithHexString:@"#f8b22a"];
}

+ (NKFColor *)novartis6{
	return [NKFColor colorWithHexString:@"#ffd430"];
}


+ (NKFColor *)npm{
	return [NKFColor colorWithHexString:@"#cb3837"];
}


+ (NKFColor *)nvidia{
	return [NKFColor colorWithHexString:@"#76b900"];
}


+ (NKFColor *)office {
	return [NKFColor officedepot];
}

+ (NKFColor *)officedepot{
	return [NKFColor colorWithRed:243.0f/255.0f green:21.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)oldnavy {
	return [NKFColor colorWithRed:12.0f/255.0f green:68.0f/255.0f blue:116.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)olympus{
	return [NKFColor colorWithHexString:@"#08107b"];
}

+ (NKFColor *)olympus2{
	return [NKFColor colorWithHexString:@"#dfb226"];
}

+ (NKFColor *)olympus3{
	return [NKFColor colorWithHexString:@"#777777"];
}


+ (NKFColor *)opera{
	return [NKFColor colorWithHexString:@"#cc0f16"];
}

+ (NKFColor *)opera2{
	return [NKFColor colorWithHexString:@"#9c9e9f"];
}


+ (NKFColor *)oracle{
	return [NKFColor colorWithHexString:@"#ff0000"];
}

+ (NKFColor *)oracle2{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)oracle3{
	return [NKFColor colorWithHexString:@"#7f7f7f"];
}


+ (NKFColor *)oreilly {
	return [NKFColor colorWithRed:1.0f/255.0f green:173.0f/255.0f blue:107.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)owens {
	return [NKFColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)oxford {
	return [NKFColor oxforduniversitypress];
}


+ (NKFColor *)oxforduniversity {
	return [NKFColor oxford];
}


+ (NKFColor *)oxforduniversitypress{
	return [NKFColor colorWithHexString:@"#002147"];
}

+ (NKFColor *)oxforduniversitypress2{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)oxforduniversitypress3{
	return [NKFColor colorWithHexString:@"#666666"];
}


+ (NKFColor *)panasonic{
	return [NKFColor colorWithHexString:@"#0f58a8"];
}

+ (NKFColor *)panasonic2{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)pandora{
	return [NKFColor colorWithHexString:@"#005483"];
}


+ (NKFColor *)partycity {
	return [NKFColor colorWithHexString:@"6c76be"];
}

+ (NKFColor *)path{
	return [NKFColor colorWithHexString:@"#ee3423"];
}


+ (NKFColor *)paylesssupermarket {
	return [NKFColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)paylesssupermarket2 {
	return [NKFColor colorWithRed:0.0f/255.0f green:136.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)paylesssupermarkets {
	return [NKFColor paylesssupermarket];
}

+ (NKFColor *)paylesssupermarkets2 {
	return [NKFColor paylesssupermarket2];
}


+ (NKFColor *)payless {
	return [NKFColor colorWithRed:223.0f/255.0f green:140.0f/255.0f blue:66.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)payless2 {
	return [NKFColor colorWithRed:137.0f/255.0f green:197.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)paylessshoesource {
	return [NKFColor payless];
}

+ (NKFColor *)paylessshoesource2 {
	return [NKFColor payless2];
}


+ (NKFColor *)paymill{
	return [NKFColor colorWithHexString:@"#f05000"];
}


+ (NKFColor *)paypal{
	return [NKFColor colorWithHexString:@"#003087"];
}

+ (NKFColor *)paypal2{
	return [NKFColor colorWithHexString:@"#009cde"];
}

+ (NKFColor *)paypal3{
	return [NKFColor colorWithHexString:@"#012169"];
}


+ (NKFColor *)pearson{
	return [NKFColor colorWithHexString:@"#ed6b06"];
}

+ (NKFColor *)pearson2{
	return [NKFColor colorWithHexString:@"#9d1348"];
}

+ (NKFColor *)pearson3{
	return [NKFColor colorWithHexString:@"#008b5d"];
}

+ (NKFColor *)pearson4{
	return [NKFColor colorWithHexString:@"#364395"];
}


+ (NKFColor *)penguinbooks{
	return [NKFColor colorWithHexString:@"#ff6900"];
}


+ (NKFColor *)pepboys {
	return [NKFColor colorWithRed:203.0f/255.0f green:13.0f/255.0f blue:39.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)pepsi{
	return [NKFColor colorWithHexString:@"#e32934"];
}

+ (NKFColor *)pepsi2{
	return [NKFColor colorWithHexString:@"#004883"];
}


+ (NKFColor *)pfizer{
	return [NKFColor colorWithHexString:@"#0093d0"];
}

+ (NKFColor *)pfizer2{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)pfizer3{
	return [NKFColor colorWithHexString:@"#616365"];
}

+ (NKFColor *)pfizer4{
	return [NKFColor colorWithHexString:@"#00aeef"];
}

+ (NKFColor *)pfizer5{
	return [NKFColor colorWithHexString:@"#d6006e"];
}

+ (NKFColor *)pfizer6{
	return [NKFColor colorWithHexString:@"#75d1e0"];
}

+ (NKFColor *)pfizer7{
	return [NKFColor colorWithHexString:@"#7dba00"];
}

+ (NKFColor *)pfizer8{
	return [NKFColor colorWithHexString:@"#cc292b"];
}

+ (NKFColor *)pfizer9{
	return [NKFColor colorWithHexString:@"#00a950"];
}

+ (NKFColor *)pfizer10{
	return [NKFColor colorWithHexString:@"#f8971d"];
}

+ (NKFColor *)pfizer11{
	return [NKFColor colorWithHexString:@"#f7d417"];
}

+ (NKFColor *)pfizer12{
	return [NKFColor colorWithHexString:@"#4a245e"];
}

+ (NKFColor *)pfizer13{
	return [NKFColor colorWithHexString:@"#f26649"];
}


+ (NKFColor *)philips{
	return [NKFColor colorWithHexString:@"#0e5fd8"];
}


+ (NKFColor *)photobucket{
	return [NKFColor colorWithHexString:@"#0ea0db"];
}

+ (NKFColor *)photobucket2{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)pier1 {
	return [NKFColor colorWithRed:0.0f green:114.0f/255.0f blue:188.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)pierone {
	return [NKFColor pier1];
}

+ (NKFColor *)pier1imports {
	return [NKFColor pier1];
}

+ (NKFColor *)pieroneimports {
	return [NKFColor pier1];
}


+ (NKFColor *)pinboard{
	return [NKFColor colorWithHexString:@"#0000e6"];
}


+ (NKFColor *)pinterest{
	return [NKFColor colorWithHexString:@"#cc2127"];
}


+ (NKFColor *)pizzahut{
	return [NKFColor colorWithHexString:@"#ee3124"];
}

+ (NKFColor *)pizzahut2{
	return [NKFColor colorWithHexString:@"#00a160"];
}

+ (NKFColor *)pizzahut3{
	return [NKFColor colorWithHexString:@"#ffc425"];
}


+ (NKFColor *)plasso{
	return [NKFColor colorWithHexString:@"#6585ed"];
}

+ (NKFColor *)plasso2{
	return [NKFColor colorWithHexString:@"#f5756c"];
}

+ (NKFColor *)plasso3{
	return [NKFColor colorWithHexString:@"#98afc0"];
}

+ (NKFColor *)plasso4{
	return [NKFColor colorWithHexString:@"#2f3148"];
}


+ (NKFColor *)plaxo{
	return [NKFColor colorWithHexString:@"#414f5a"];
}


+ (NKFColor *)playstation{
	return [NKFColor colorWithHexString:@"#003087"];
}


+ (NKFColor *)pocket{
	return [NKFColor colorWithHexString:@"#d3505a"];
}

+ (NKFColor *)pocket2{
	return [NKFColor colorWithHexString:@"#478f8f"];
}


+ (NKFColor *)portfolium{
	return [NKFColor colorWithHexString:@"#0099ff"];
}

+ (NKFColor *)portfolium2{
	return [NKFColor colorWithHexString:@"#fb0a2a"];
}

+ (NKFColor *)portfolium3{
	return [NKFColor colorWithHexString:@"#17ad49"];
}

+ (NKFColor *)portfolium4{
	return [NKFColor colorWithHexString:@"#333333"];
}


+ (NKFColor *)postmates{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)postmates2{
	return [NKFColor colorWithHexString:@"#36454f"];
}


+ (NKFColor *)prezi{
	return [NKFColor colorWithHexString:@"#318bff"];
}


+ (NKFColor *)priceline{
	return [NKFColor colorWithHexString:@"#1885bf"];
}


+ (NKFColor *)pricerite {
	return [NKFColor colorWithRed:36.0f/255.0f green:91.0f/255.0f blue:173.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)priceright {
	return [NKFColor pricerite];
}

+ (NKFColor *)pricerite2 {
	return [NKFColor colorWithRed:246.0f/255.0f green:35.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)priceright2 {
	return [NKFColor pricerite2];
}


+ (NKFColor *)producthunt{
	return [NKFColor colorWithHexString:@"#da552f"];
}

+ (NKFColor *)producthunt2{
	return [NKFColor colorWithHexString:@"#534540"];
}

+ (NKFColor *)producthunt3{
	return [NKFColor colorWithHexString:@"#988f8c"];
}

+ (NKFColor *)producthunt4{
	return [NKFColor colorWithHexString:@"#00b27f"];
}


+ (NKFColor *)publix {
	return [NKFColor colorWithRed:62.0f/255.0f green:144.0f/255.0f blue:45.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)publics {
	return [NKFColor publix];
}


+ (NKFColor *)qfc {
	return [NKFColor colorWithRed:0.0f/255.0f green:112.0f/255.0f blue:192.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)qfc2 {
	return [NKFColor colorWithRed:255.0f/255.0f green:238.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)quora{
	return [NKFColor colorWithHexString:@"#a82400"];
}


+ (NKFColor *)quotefm{
	return [NKFColor colorWithHexString:@"#66ceff"];
}


+ (NKFColor *)raiz {
	return [NKFColor raizlabs];
}

+ (NKFColor *)raizlabs {
	return [NKFColor colorWithRed:0.927f green:0.352f blue:0.303f alpha:1.0f];
}


+ (NKFColor *)ralphlauren {
	return [NKFColor colorWithRed:28.0f/255.0f green:28.0f/255.0f blue:28.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)ralphs {
	return [NKFColor colorWithRed:246.0f/255.0f green:27.0f/255.0f blue:49.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)razer{
	return [NKFColor colorWithHexString:@"#00ff00"];
}


+ (NKFColor *)rdio{
	return [NKFColor colorWithHexString:@"#007dc3"];
}


+ (NKFColor *)readability{
	return [NKFColor colorWithHexString:@"#990000"];
}


+ (NKFColor *)redhat{
	return [NKFColor colorWithHexString:@"#cc0000"];
}


+ (NKFColor *)reddit{
	return [NKFColor colorWithHexString:@"#ff4500"];
}

+ (NKFColor *)reddit2{
	return [NKFColor colorWithHexString:@"#5f99cf"];
}

+ (NKFColor *)reddit3{
	return [NKFColor colorWithHexString:@"#cee3f8"];
}


+ (NKFColor *)redfin{
	return [NKFColor colorWithHexString:@"#a02021"];
}


+ (NKFColor *)rei {
	return [NKFColor colorWithRed:78.0f/255.0f green:92.0f/255.0f blue:56.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)rei2 {
	return [NKFColor colorWithRed:197.0f/255.0f green:193.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)rentler{
	return [NKFColor colorWithHexString:@"#ed1c27"];
}


+ (NKFColor *)reverbnation{
	return [NKFColor colorWithHexString:@"#e43526"];
}


+ (NKFColor *)rockpack{
	return [NKFColor colorWithHexString:@"#0ba6ab"];
}


+ (NKFColor *)roku{
	return [NKFColor colorWithHexString:@"#6f1ab1"];
}


+ (NKFColor *)rollsroyce{
	return [NKFColor colorWithHexString:@"#680021"];
}

+ (NKFColor *)rollsroyce2{
	return [NKFColor colorWithHexString:@"#fffaec"];
}

+ (NKFColor *)rollsroyce3{
	return [NKFColor colorWithHexString:@"#939598"];
}

+ (NKFColor *)rollsroyce4{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)ross {
	return [NKFColor colorWithRed:0.0f green:102.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)rookids{
	return [NKFColor colorWithHexString:@"#e22027"];
}

+ (NKFColor *)rookids2{
	return [NKFColor colorWithHexString:@"#a1cd3d"];
}

+ (NKFColor *)rookids3{
	return [NKFColor colorWithHexString:@"#003e70"];
}


+ (NKFColor *)roon{
	return [NKFColor colorWithHexString:@"#62b0d9"];
}


+ (NKFColor *)rounds{
	return [NKFColor colorWithHexString:@"#fdd800"];
}


+ (NKFColor *)royalahold {
	return [NKFColor ahold];
}


+ (NKFColor *)rss{
	return [NKFColor colorWithHexString:@"#f26522"];
}

+ (NKFColor *)rss2{
	return [NKFColor colorWithHexString:@"#f26522"];
}


+ (NKFColor *)safari {
	return [NKFColor colorWithRed:50.0f/255.0f green:156.0f/255.0f blue:203.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)safari2 {
	return [NKFColor colorWithRed:229.0f/255.0f green:45.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)safari3 {
	return [NKFColor colorWithRed:174.0f/255.0f green:173.0f/255.0f blue:173.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)safeway{
	return [NKFColor colorWithRed:226.0f/255.0f green:55.0f/255.0f blue:63.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)sainsburys{
	return [NKFColor colorWithHexString:@"#ec8a00"];
}


+ (NKFColor *)salesforce{
	return [NKFColor colorWithHexString:@"#1798c1"];
}

+ (NKFColor *)salesforce2{
	return [NKFColor colorWithHexString:@"#ff1100"];
}


+ (NKFColor *)samsclub {
	return [NKFColor colorWithRed:0.0f green:75.0f/255.0f blue:141.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)samsclub2 {
	return [NKFColor colorWithRed:93.0f/255.0f green:151.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)samsung{
	return [NKFColor colorWithHexString:@"#1428a0"];
}

+ (NKFColor *)samsung2{
	return [NKFColor colorWithHexString:@"#75787b"];
}

+ (NKFColor *)samsung3{
	return [NKFColor colorWithHexString:@"#0689d8"];
}

+ (NKFColor *)samsung4{
	return [NKFColor colorWithHexString:@"#ffc600"];
}

+ (NKFColor *)samsung5{
	return [NKFColor colorWithHexString:@"#ff6900"];
}

+ (NKFColor *)samsung6{
	return [NKFColor colorWithHexString:@"#e4002b"];
}

+ (NKFColor *)samsung7{
	return [NKFColor colorWithHexString:@"#c800a1"];
}

+ (NKFColor *)samsung8{
	return [NKFColor colorWithHexString:@"#685bc7"];
}

+ (NKFColor *)samsung9{
	return [NKFColor colorWithHexString:@"#0057b8"];
}

+ (NKFColor *)samsung10{
	return [NKFColor colorWithHexString:@"#00a9e0"];
}

+ (NKFColor *)samsung11{
	return [NKFColor colorWithHexString:@"#009ca6"];
}

+ (NKFColor *)samsung12{
	return [NKFColor colorWithHexString:@"#00b140"];
}


+ (NKFColor *)sap{
	return [NKFColor colorWithHexString:@"#003366"];
}

+ (NKFColor *)sap2{
	return [NKFColor colorWithHexString:@"#999999"];
}


+ (NKFColor *)savealot {
	return [NKFColor colorWithRed:236.0f/255.0f green:21.0f/255.0f blue:27.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)savealot2 {
	return [NKFColor colorWithRed:0.0f/255.0f green:79.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)scotts {
	return [NKFColor colorWithRed:235.0f/255.0f green:15.0f/255.0f blue:29.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)scribd{
	return [NKFColor colorWithHexString:@"#1a7bba"];
}


+ (NKFColor *)sears {
	return [NKFColor colorWithRed:20.0f/255.0f green:37.0f/255.0f blue:145.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)sears2 {
	return [NKFColor colorWithRed:242.0f/255.0f green:35.0f/255.0f blue:39.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)shaws {
	return [NKFColor colorWithRed:236.0f/255.0f green:141.0f/255.0f blue:61.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)shaws2 {
	return [NKFColor colorWithRed:121.0f/255.0f green:185.0f/255.0f blue:89.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)shell {
	return [NKFColor colorWithRed:251.0f/255.0f green:217.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)sherwinwilliams{
	return [NKFColor colorWithHexString:@"#0168b3"];
}

+ (NKFColor *)sherwinwilliams2{
	return [NKFColor colorWithHexString:@"#ee3e34"];
}


+ (NKFColor *)schnucks {
	return [NKFColor colorWithRed:237.0f/255.0f green:28.0f/255.0f blue:36.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)schnuks {
	return [NKFColor schnucks];
}


+ (NKFColor *)shopify{
	return [NKFColor colorWithHexString:@"#96bf48"];
}

+ (NKFColor *)shopify2{
	return [NKFColor colorWithHexString:@"#479ccf"];
}

+ (NKFColor *)shopify3{
	return [NKFColor colorWithHexString:@"#2d3538"];
}

+ (NKFColor *)shopify4{
	return [NKFColor colorWithHexString:@"#f5f5f5"];
}

+ (NKFColor *)shopify5{
	return [NKFColor colorWithHexString:@"#f2f7fa"];
}

+ (NKFColor *)shopify6{
	return [NKFColor colorWithHexString:@"#666666"];
}


+ (NKFColor *)shoppers {
	return [NKFColor colorWithRed:227.0f/255.0f green:24.0f/255.0f blue:54.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)shoppers2 {
	return [NKFColor colorWithRed:255.0f/255.0f green:228.0f/255.0f blue:15.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)shoppers3 {
	return [NKFColor black];
}


+ (NKFColor *)shopnsave {
	return [NKFColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
}


+ (NKFColor *)shoprite {
	return [NKFColor colorWithRed:239.0f/255.0f green:45.0f/255.0f blue:36.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)shoprite2 {
	return [NKFColor colorWithRed:252.0f/255.0f green:183.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)skype{
	return [NKFColor colorWithHexString:@"#00aff0"];
}


+ (NKFColor *)slack{
	return [NKFColor colorWithHexString:@"#6ecadc"];
}

+ (NKFColor *)slack2{
	return [NKFColor colorWithHexString:@"#e9a820"];
}

+ (NKFColor *)slack3{
	return [NKFColor colorWithHexString:@"#e01563"];
}

+ (NKFColor *)slack4{
	return [NKFColor colorWithHexString:@"#3eb991"];
}


+ (NKFColor *)smashingmagazine{
	return [NKFColor colorWithHexString:@"#e53b2c"];
}

+ (NKFColor *)smashingmagazine2{
	return [NKFColor colorWithHexString:@"#41b7d8"];
}


+ (NKFColor *)smiths {
	return [NKFColor colorWithRed:227.0f/255.0f green:48.0f/255.0f blue:61.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)snagajob{
	return [NKFColor colorWithHexString:@"#f47a20"];
}


+ (NKFColor *)socialbro{
	return [NKFColor colorWithHexString:@"#29c4d0"];
}

+ (NKFColor *)socialbro2{
	return [NKFColor colorWithHexString:@"#f29556"];
}

+ (NKFColor *)socialbro3{
	return [NKFColor colorWithHexString:@"#84afa2"];
}

+ (NKFColor *)socialbro4{
	return [NKFColor colorWithHexString:@"#72c427"];
}

+ (NKFColor *)socialbro5{
	return [NKFColor colorWithHexString:@"#f24c7c"];
}

+ (NKFColor *)socialbro6{
	return [NKFColor colorWithHexString:@"#00aaf2"];
}


+ (NKFColor *)softonic{
	return [NKFColor colorWithHexString:@"#008ace"];
}


+ (NKFColor *)songkick{
	return [NKFColor colorWithHexString:@"#f80046"];
}


+ (NKFColor *)sonicbids{
	return [NKFColor colorWithHexString:@"#ff6600"];
}

+ (NKFColor *)sonicbids2{
	return [NKFColor colorWithHexString:@"#0c88b1"];
}


+ (NKFColor *)soundcloud{
	return [NKFColor colorWithHexString:@"#ff8800"];
}

+ (NKFColor *)soundcloud2{
	return [NKFColor colorWithHexString:@"#ff3300"];
}


+ (NKFColor *)spoken{
	return [NKFColor colorWithHexString:@"#fc00c1"];
}

+ (NKFColor *)spoken2{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)spotify{
	return [NKFColor colorWithHexString:@"#2ebd59"];
}


+ (NKFColor *)sprint{
	return [NKFColor colorWithHexString:@"#ffe100"];
}


+ (NKFColor *)squarecash{
	return [NKFColor colorWithHexString:@"#28c101"];
}


+ (NKFColor *)squarespace{
	return [NKFColor colorWithHexString:@"#222222"];
}


+ (NKFColor *)stackoverflow{
	return [NKFColor colorWithHexString:@"#fe7a15"];
}


+ (NKFColor *)staples{
	return [NKFColor colorWithHexString:@"#cc0000"];
}

+ (NKFColor *)staples2{
	return [NKFColor colorWithHexString:@"#2c8aec"];
}

+ (NKFColor *)staples3{
	return [NKFColor colorWithHexString:@"#ffcc00"];
}


+ (NKFColor *)starbucks{
	return [NKFColor colorWithHexString:@"#00704a"];
}

+ (NKFColor *)starbucks2{
	return [NKFColor colorWithHexString:@"#000000"];
}


+ (NKFColor *)starmarket {
	return [NKFColor colorWithRed:0.0f/255.0f green:132.0f/255.0f blue:202.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)starmarket2 {
	return [NKFColor colorWithRed:121.0f/255.0f green:185.0f/255.0f blue:89.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)staterbrothers {
	return [NKFColor colorWithHexString:@"1644b3"];
}

+ (NKFColor *)staterbros {
	return [NKFColor staterbrothers];
}


+ (NKFColor *)statuschart{
	return [NKFColor colorWithHexString:@"#d7584f"];
}


+ (NKFColor *)sterlinghotels{
	return [NKFColor colorWithHexString:@"#3b5a6f"];
}

+ (NKFColor *)sterlinghotels2{
	return [NKFColor colorWithHexString:@"#828a87"];
}

+ (NKFColor *)sterlinghotels3{
	return [NKFColor colorWithHexString:@"#000000"];
}

+ (NKFColor *)sterlinghotels4{
	return [NKFColor colorWithHexString:@"#9db7c4"];
}

+ (NKFColor *)sterlinghotels5{
	return [NKFColor colorWithHexString:@"#ccd7dd"];
}

+ (NKFColor *)sterlinghotels6{
	return [NKFColor colorWithHexString:@"#838f97"];
}

+ (NKFColor *)sterlinghotels7{
	return [NKFColor colorWithHexString:@"#002054"];
}


+ (NKFColor *)stopandshop {
	return [NKFColor colorWithRed:121.0f/255.0f green:31.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)stopandshop2 {
	return [NKFColor colorWithRed:252.0f/255.0f green:182.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)stopandshop3 {
	return [NKFColor colorWithRed:237.0f/255.0f green:50.0f/255.0f blue:33.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)stopandshop4 {
	return [NKFColor colorWithRed:139.0f/255.0f green:195.0f/255.0f blue:68.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)storyful{
	return [NKFColor colorWithHexString:@"#f97200"];
}

+ (NKFColor *)storyful2{
	return [NKFColor colorWithHexString:@"#010101"];
}

+ (NKFColor *)storyful3{
	return [NKFColor colorWithHexString:@"#8b8b64"];
}

+ (NKFColor *)storyful4{
	return [NKFColor colorWithHexString:@"#bbbdc0"];
}


+ (NKFColor *)strava{
	return [NKFColor colorWithHexString:@"#fc4c02"];
}


+ (NKFColor *)stripe{
	return [NKFColor colorWithHexString:@"#00afe1"];
}


+ (NKFColor *)studyblue{
	return [NKFColor colorWithHexString:@"#00afe1"];
}


+ (NKFColor *)stumbleupon{
	return [NKFColor colorWithHexString:@"#eb4924"];
}


+ (NKFColor *)subway2{
	return [NKFColor colorWithHexString:@"#00543d"];
}

+ (NKFColor *)subway3{
	return [NKFColor colorWithHexString:@"#fef035"];
}

+ (NKFColor *)subway{
	return [NKFColor colorWithHexString:@"#489e3b"];
}

+ (NKFColor *)subway4{
	return [NKFColor colorWithHexString:@"#fabd42"];
}

+ (NKFColor *)subway5{
	return [NKFColor colorWithHexString:@"#cd0a20"];
}


+ (NKFColor *)sugarcrm{
	return [NKFColor colorWithHexString:@"#e61718"];
}

+ (NKFColor *)sugarcrm2{
	return [NKFColor colorWithHexString:@"#e8e9ea"];
}

+ (NKFColor *)sugarcrm3{
	return [NKFColor colorWithHexString:@"#595a5c"];
}

+ (NKFColor *)sugarcrm4{
	return [NKFColor colorWithHexString:@"#282828"];
}


+ (NKFColor *)supervalu {
	return [NKFColor colorWithRed:219.0f/255.0f green:37.0f/255.0f blue:28.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)supervalue {
	return [NKFColor supervalu];
}


+ (NKFColor *)surlatable {
	return [NKFColor colorWithRed:90.0f/255.0f green:40.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)swarm{
	return [NKFColor colorWithHexString:@"#f06d1f"];
}

+ (NKFColor *)swarm2{
	return [NKFColor colorWithHexString:@"#ffa633"];
}


+ (NKFColor *)tjmaxx {
	return [NKFColor colorWithRed:171.0f/255.0f green:25.0f/255.0f blue:44.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)tjmax {
	return [NKFColor tjmaxx];
}


+ (NKFColor *)tmobile{
	return [NKFColor colorWithHexString:@"#e20074"];
}


+ (NKFColor *)toysrus {
	return [NKFColor colorWithRed:0.0f green:84.0f/255.0f blue:166.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)taco {
	return [NKFColor tacobell];
}

+ (NKFColor *)taco2 {
	return [NKFColor tacobell2];
}

+ (NKFColor *)taco3 {
	return [NKFColor tacobell3];
}

+ (NKFColor *)tacobell {
	return [NKFColor colorWithRed:58.0f/255.0f green:22.0f/255.0f blue:126.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)tacobell2 {
	return [NKFColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:126.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)tacobell3 {
	return [NKFColor colorWithRed:1.0f green:1.0f blue:1.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)tagstr{
	return [NKFColor colorWithHexString:@"#e74635"];
}


+ (NKFColor *)tagstr2{
	return [NKFColor colorWithHexString:@"#e74635"];
}

+ (NKFColor *)target {
	return [NKFColor colorWithHexString:@"#e90022"];
}


+ (NKFColor *)technorati{
	return [NKFColor colorWithHexString:@"#339900"];
}


+ (NKFColor *)tesla{
	return [NKFColor colorWithHexString:@"#cc0000"];
}


+ (NKFColor *)theaudienceawards{
	return [NKFColor colorWithHexString:@"#ee8421"];
}

+ (NKFColor *)theaudienceawards2{
	return [NKFColor colorWithHexString:@"#8c8a8a"];
}

+ (NKFColor *)theaudienceawards3{
	return [NKFColor colorWithHexString:@"#222222"];
}


+ (NKFColor *)thenextweb{
	return [NKFColor colorWithHexString:@"#ff3c1f"];
}

+ (NKFColor *)thenextweb2{
	return [NKFColor colorWithHexString:@"#26313b"];
}

+ (NKFColor *)thenextweb3{
	return [NKFColor colorWithHexString:@"#4e5860"];
}

+ (NKFColor *)thenextweb4{
	return [NKFColor colorWithHexString:@"#a6abaf"];
}

+ (NKFColor *)thenextweb5{
	return [NKFColor colorWithHexString:@"#d9e0e2"];
}

+ (NKFColor *)thenextweb6{
	return [NKFColor colorWithHexString:@"#fafbfc"];
}


+ (NKFColor *)thomsonreuters{
	return [NKFColor colorWithHexString:@"#ff8000"];
}

+ (NKFColor *)thomsonreuters2{
	return [NKFColor colorWithHexString:@"#555555"];
}

+ (NKFColor *)thomsonreuters3{
	return [NKFColor colorWithHexString:@"#444444"];
}

+ (NKFColor *)thomsonreuters4{
	return [NKFColor colorWithHexString:@"#666666"];
}

+ (NKFColor *)thomsonreuters5{
	return [NKFColor colorWithHexString:@"#cccccc"];
}

+ (NKFColor *)thomsonreuters6{
	return [NKFColor colorWithHexString:@"#e9e9e9"];
}

+ (NKFColor *)thomsonreuters7{
	return [NKFColor colorWithHexString:@"#f7f7f7"];
}


+ (NKFColor *)tiffany {
	return [NKFColor colorWithRed:136.0f/255.0f green:204.0f/255.0f blue:207.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)tiffanys {
	return [NKFColor tiffany];
}

+ (NKFColor *)tiffanies {
	return [NKFColor tiffany];
}

+ (NKFColor *)tiffanyandco {
	return [NKFColor tiffany];
}

+ (NKFColor *)tiffanyandcompany {
	return [NKFColor tiffany];
}


+ (NKFColor *)tivo{
	return [NKFColor colorWithHexString:@"#da3d34"];
}

+ (NKFColor *)tivo2{
	return [NKFColor colorWithHexString:@"#00a480"];
}

+ (NKFColor *)tivo3{
	return [NKFColor colorWithHexString:@"#ed9f40"];
}

+ (NKFColor *)tivo4{
	return [NKFColor colorWithHexString:@"#6a76ac"];
}

+ (NKFColor *)tivo5{
	return [NKFColor colorWithHexString:@"#17170e"];
}

+ (NKFColor *)tivo6{
	return [NKFColor colorWithHexString:@"#534b38"];
}

+ (NKFColor *)tivo7{
	return [NKFColor colorWithHexString:@"#a6a480"];
}


+ (NKFColor *)traderjoes {
	return [NKFColor colorWithRed:227.0f/255.0f green:25.0f/255.0f blue:54.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)traderjoe {
	return [NKFColor traderjoes];
}


+ (NKFColor *)treehouse{
	return [NKFColor colorWithHexString:@"#6fbc6d"];
}

+ (NKFColor *)treehouse2{
	return [NKFColor colorWithHexString:@"#47535b"];
}


+ (NKFColor *)trello{
	return [NKFColor colorWithHexString:@"#0079bf"];
}

+ (NKFColor *)trello2{
	return [NKFColor colorWithHexString:@"#70b500"];
}

+ (NKFColor *)trello3{
	return [NKFColor colorWithHexString:@"#ff9f1a"];
}

+ (NKFColor *)trello4{
	return [NKFColor colorWithHexString:@"#eb5a46"];
}

+ (NKFColor *)trello5{
	return [NKFColor colorWithHexString:@"#f2d600"];
}

+ (NKFColor *)trello6{
	return [NKFColor colorWithHexString:@"#c377e0"];
}

+ (NKFColor *)trello7{
	return [NKFColor colorWithHexString:@"#ff78cb"];
}

+ (NKFColor *)trello8{
	return [NKFColor colorWithHexString:@"#00c2e0"];
}

+ (NKFColor *)trello9{
	return [NKFColor colorWithHexString:@"#51e898"];
}

+ (NKFColor *)trello10{
	return [NKFColor colorWithHexString:@"#c4c9cc"];
}


+ (NKFColor *)tripadvisor{
	return [NKFColor colorWithHexString:@"#589442"];
}


+ (NKFColor *)trulia{
	return [NKFColor colorWithHexString:@"#5eab1f"];
}


+ (NKFColor *)tsc {
	return [NKFColor colorWithRed:252.0f/255.0f green:25.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)tractorsupplyco {
	return [NKFColor tsc];
}

+ (NKFColor *)tractorsupplycompany {
	return [NKFColor tsc];
}


+ (NKFColor *)tumblr{
	return [NKFColor colorWithHexString:@"#35465c"];
}


+ (NKFColor *)tunngle{
	return [NKFColor colorWithHexString:@"#c30f24"];
}


+ (NKFColor *)tvtag{
	return [NKFColor colorWithHexString:@"#f24e4e"];
}


+ (NKFColor *)twitchtv{
	return [NKFColor colorWithHexString:@"#6441a5"];
}


+ (NKFColor *)twitter{
	return [NKFColor colorWithHexString:@"#55acee"];
}


+ (NKFColor *)typekit{
	return [NKFColor colorWithHexString:@"#98ce1e"];
}


+ (NKFColor *)typepad{
	return [NKFColor colorWithHexString:@"#d2de61"];
}


+ (NKFColor *)typo3{
	return [NKFColor colorWithHexString:@"#ff8600"];
}


+ (NKFColor *)ubuntu{
	return [NKFColor colorWithHexString:@"#dd4814"];
}

+ (NKFColor *)ubuntu2{
	return [NKFColor colorWithHexString:@"#77216f"];
}

+ (NKFColor *)ubuntu3{
	return [NKFColor colorWithHexString:@"#5e2750"];
}

+ (NKFColor *)ubuntu4{
	return [NKFColor colorWithHexString:@"#2c001e"];
}

+ (NKFColor *)ubuntu5{
	return [NKFColor colorWithHexString:@"#aea79f"];
}

+ (NKFColor *)ubuntu6{
	return [NKFColor colorWithHexString:@"#333333"];
}


+ (NKFColor *)unitedsupermarkets {
	return [NKFColor colorWithRed:7.0f/255.0f green:69.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)unitedsupermarket {
	return [NKFColor unitedsupermarkets];
}

+ (NKFColor *)unitedsupermarkets2 {
	return [NKFColor colorWithRed:214.0f/255.0f green:3.0f/255.0f blue:4.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)unitedsupermarket2 {
	return [NKFColor unitedsupermarkets2];
}


+ (NKFColor *)unitedway{
	return [NKFColor colorWithHexString:@"#10167f"];
}

+ (NKFColor *)unitedway2{
	return [NKFColor colorWithHexString:@"#fe230a"];
}

+ (NKFColor *)unitedway3{
	return [NKFColor colorWithHexString:@"#ff9600"];
}

+ (NKFColor *)unitedway4{
	return [NKFColor colorWithHexString:@"#000064"];
}

+ (NKFColor *)unitedway5{
	return [NKFColor colorWithHexString:@"#b41428"];
}

+ (NKFColor *)unitedway6{
	return [NKFColor colorWithHexString:@"#f57814"];
}

+ (NKFColor *)unitedway7{
	return [NKFColor colorWithHexString:@"#e6d7aa"];
}

+ (NKFColor *)unitedway8{
	return [NKFColor colorWithHexString:@"#505050"];
}

+ (NKFColor *)unitedway9{
	return [NKFColor colorWithHexString:@"#f0e6c8"];
}

+ (NKFColor *)unitedway10{
	return [NKFColor colorWithHexString:@"#969696"];
}

+ (NKFColor *)unitedway11{
	return [NKFColor colorWithHexString:@"#7c81b8"];
}

+ (NKFColor *)unitedway12{
	return [NKFColor colorWithHexString:@"#ff967d"];
}

+ (NKFColor *)unitedway13{
	return [NKFColor colorWithHexString:@"#ffc87d"];
}


+ (NKFColor *)unity{
	return [NKFColor colorWithHexString:@"#222c37"];
}

+ (NKFColor *)unity2{
	return [NKFColor colorWithHexString:@"#00cccc"];
}

+ (NKFColor *)unity3{
	return [NKFColor colorWithHexString:@"#fff600"];
}

+ (NKFColor *)unity4{
	return [NKFColor colorWithHexString:@"#ff0066"];
}

+ (NKFColor *)unity5{
	return [NKFColor colorWithHexString:@"#19e3b1"];
}

+ (NKFColor *)unity6{
	return [NKFColor colorWithHexString:@"#ff7f33"];
}

+ (NKFColor *)unity7{
	return [NKFColor colorWithHexString:@"#b83c82"];
}


+ (NKFColor *)universityoforegon{
	return [NKFColor colorWithHexString:@"#fce122"];
}

+ (NKFColor *)universityoforegon2{
	return [NKFColor colorWithHexString:@"#18453b"];
}


+ (NKFColor *)univision{
	return [NKFColor colorWithHexString:@"#c822b0"];
}


+ (NKFColor *)ups {
	return [NKFColor pullmanBrownUPSBrown];
}


+ (NKFColor *)ustream{
	return [NKFColor colorWithHexString:@"#3388ff"];
}


+ (NKFColor *)valero{
	return [NKFColor colorWithRed:1.0f/255.0f green:107.0f/255.0f blue:138.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)valero2{
	return [NKFColor colorWithRed:255.0f/255.0f green:177.0f/255.0f blue:41.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)vons {
	return [NKFColor safeway];
}


+ (NKFColor *)verizon{
	return [NKFColor colorWithHexString:@"#ff0000"];
}

+ (NKFColor *)verizon2{
	return [NKFColor colorWithHexString:@"#f2f2f2"];
}

+ (NKFColor *)verizon3{
	return [NKFColor colorWithHexString:@"#070000"];
}


+ (NKFColor *)viadeo{
	return [NKFColor colorWithHexString:@"#f07355"];
}


+ (NKFColor *)victoriassecret {
	return [NKFColor colorWithRed:208.0f/255.0f green:17.0f/255.0f blue:112.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)viki{
	return [NKFColor colorWithHexString:@"#3c9cd7"];
}

+ (NKFColor *)viki2{
	return [NKFColor colorWithHexString:@"#d24663"];
}


+ (NKFColor *)vimeo{
	return [NKFColor colorWithHexString:@"#162221"];
}

+ (NKFColor *)vimeo2{
	return [NKFColor colorWithHexString:@"#1ab7ea"];
}


+ (NKFColor *)vine{
	return [NKFColor colorWithHexString:@"#00b488"];
}


+ (NKFColor *)virb{
	return [NKFColor colorWithHexString:@"#1e91d0"];
}


+ (NKFColor *)virginmedia{
	return [NKFColor colorWithHexString:@"#c3092d"];
}

+ (NKFColor *)virginmedia2{
	return [NKFColor colorWithHexString:@"#222221"];
}


+ (NKFColor *)vkontakte{
	return [NKFColor colorWithHexString:@"#45668e"];
}

+ (NKFColor *)volcano {
	return [NKFColor colorWithRed:27.0f/255.0f green:58.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)volcanocorp {
	return [NKFColor volcano];
}


+ (NKFColor *)volvo{
	return [NKFColor colorWithHexString:@"#003057"];
}

+ (NKFColor *)volvo2{
	return [NKFColor colorWithHexString:@"#115740"];
}

+ (NKFColor *)volvo3{
	return [NKFColor colorWithHexString:@"#65665c"];
}

+ (NKFColor *)volvo4{
	return [NKFColor colorWithHexString:@"#425563"];
}

+ (NKFColor *)volvo5{
	return [NKFColor colorWithHexString:@"#517891"];
}

+ (NKFColor *)volvo6{
	return [NKFColor colorWithHexString:@"#212721"];
}


+ (NKFColor *)wakefern {
	return [NKFColor colorWithRed:249.0f/255.0f green:60.0f/255.0f blue:48.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)wakefern2 {
	return [NKFColor colorWithRed:34.0f/255.0f green:32.0f/255.0f blue:33.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)walgreens{
	return [NKFColor colorWithHexString:@"#e31837"];
}

+ (NKFColor *)walgreens2{
	return [NKFColor colorWithHexString:@"#f37520"];
}

+ (NKFColor *)walgreens3{
	return [NKFColor colorWithHexString:@"#489cd4"];
}

+ (NKFColor *)walgreens4{
	return [NKFColor colorWithHexString:@"#2774a6"];
}

+ (NKFColor *)walgreens5{
	return [NKFColor colorWithHexString:@"#35393d"];
}


+ (NKFColor *)walmart{
	return [NKFColor colorWithHexString:@"#0e7bc3"];
}

+ (NKFColor *)walmart2{
	return [NKFColor colorWithHexString:@"#05509b"];
}

+ (NKFColor *)walmart3{
	return [NKFColor colorWithHexString:@"#6eaddf"];
}

+ (NKFColor *)walmart4{
	return [NKFColor colorWithHexString:@"#f27922"];
}

+ (NKFColor *)walmart5{
	return [NKFColor colorWithHexString:@"#fcbc32"];
}

+ (NKFColor *)walmart6{
	return [NKFColor colorWithHexString:@"#3b7f2c"];
}

+ (NKFColor *)walmart7{
	return [NKFColor colorWithHexString:@"#7ec544"];
}


+ (NKFColor *)wechat{
	return [NKFColor colorWithHexString:@"#7bb32e"];
}


+ (NKFColor *)wegmans {
	return [NKFColor colorWithRed:62.0f/255.0f green:150.0f/255.0f blue:63.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)wendys{
	return [NKFColor colorWithHexString:@"#e2203d"];
}

+ (NKFColor *)wendys2{
	return [NKFColor colorWithHexString:@"#199fda"];
}


+ (NKFColor *)westerndigital{
	return [NKFColor colorWithHexString:@"#005195"];
}

+ (NKFColor *)westerndigital2{
	return [NKFColor colorWithHexString:@"#028948"];
}

+ (NKFColor *)westerndigital3{
	return [NKFColor colorWithHexString:@"#ffd400"];
}

+ (NKFColor *)westerndigital4{
	return [NKFColor colorWithHexString:@"#0067b3"];
}

+ (NKFColor *)westerndigital5{
	return [NKFColor colorWithHexString:@"#9d0a0e"];
}

+ (NKFColor *)westerndigital6{
	return [NKFColor colorWithHexString:@"#003369"];
}


+ (NKFColor *)whatsapp{
	return [NKFColor colorWithHexString:@"#4dc247"];
}


+ (NKFColor *)wholefoods {
	return [NKFColor colorWithRed:2.0f/255.0f green:145.0f/255.0f blue:45.0f/255.0f alpha:1.0f];
}


+ (NKFColor *)whoosnapdesigner{
	return [NKFColor colorWithHexString:@"#2fa5d6"];
}

+ (NKFColor *)whoosnapdesigner2{
	return [NKFColor colorWithHexString:@"#b52f2c"];
}


+ (NKFColor *)williamssonoma {
	return [NKFColor colorWithRed:0.0f green:72.0f/255.0f blue:17.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)williamsonoma {
	return [NKFColor williamssonoma];
}


+ (NKFColor *)windows{
	return [NKFColor colorWithHexString:@"#00bcf2"];
}


+ (NKFColor *)windowsphone{
	return [NKFColor colorWithHexString:@"#68217a"];
}


+ (NKFColor *)wired {
	return [NKFColor black];
}

+ (NKFColor *)wired2 {
	return [NKFColor white];
}


+ (NKFColor *)wooga{
	return [NKFColor colorWithHexString:@"#5b009c"];
}


+ (NKFColor *)woot {
	return [NKFColor colorWithRed:97.0f/255.0f green:134.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)wootcom {
	return [NKFColor woot];
}


+ (NKFColor *)wordpress{
	return [NKFColor colorWithHexString:@"#21759b"];
}

+ (NKFColor *)wordpress2{
	return [NKFColor colorWithHexString:@"#d54e21"];
}

+ (NKFColor *)wordpress3{
	return [NKFColor colorWithHexString:@"#464646"];
}


+ (NKFColor *)wordpresscom{
	return [NKFColor colorWithHexString:@"#0087be"];
}

+ (NKFColor *)wordpresscom2{
	return [NKFColor colorWithHexString:@"#78dcfa"];
}

+ (NKFColor *)wordpresscom3{
	return [NKFColor colorWithHexString:@"#00aadc"];
}

+ (NKFColor *)wordpresscom4{
	return [NKFColor colorWithHexString:@"#005082"];
}

+ (NKFColor *)wordpresscom5{
	return [NKFColor colorWithHexString:@"#87a6bc"];
}

+ (NKFColor *)wordpresscom6{
	return [NKFColor colorWithHexString:@"#f3f6f8"];
}

+ (NKFColor *)wordpresscom7{
	return [NKFColor colorWithHexString:@"#e9eff3"];
}

+ (NKFColor *)wordpresscom8{
	return [NKFColor colorWithHexString:@"#e9eff3"];
}

+ (NKFColor *)wordpresscom9{
	return [NKFColor colorWithHexString:@"#a8bece"];
}

+ (NKFColor *)wordpresscom10{
	return [NKFColor colorWithHexString:@"#668eaa"];
}

+ (NKFColor *)wordpresscom11{
	return [NKFColor colorWithHexString:@"#4f748e"];
}

+ (NKFColor *)wordpresscom12{
	return [NKFColor colorWithHexString:@"#3d596d"];
}

+ (NKFColor *)wordpresscom13{
	return [NKFColor colorWithHexString:@"#2e4453"];
}

+ (NKFColor *)wordpresscom14{
	return [NKFColor colorWithHexString:@"#d54e21"];
}

+ (NKFColor *)wordpresscom15{
	return [NKFColor colorWithHexString:@"#f0821e"];
}

+ (NKFColor *)wordpresscom16{
	return [NKFColor colorWithHexString:@"#4ab866"];
}

+ (NKFColor *)wordpresscom17{
	return [NKFColor colorWithHexString:@"#f0b849"];
}

+ (NKFColor *)wordpresscom18{
	return [NKFColor colorWithHexString:@"#d94f4f"];
}


+ (NKFColor *)worldline{
	return [NKFColor colorWithHexString:@"#0066a1"];
}


+ (NKFColor *)wunderlist{
	return [NKFColor colorWithHexString:@"#2b96f1"];
}


+ (NKFColor *)xbox{
	return [NKFColor colorWithHexString:@"#52b043"];
}


+ (NKFColor *)xing{
	return [NKFColor colorWithHexString:@"#026466"];
}

+ (NKFColor *)xing2{
	return [NKFColor colorWithHexString:@"#cfdc00"];
}


+ (NKFColor *)yahoo{
	return [NKFColor colorWithHexString:@"#400191"];
}


+ (NKFColor *)yandex{
	return [NKFColor colorWithHexString:@"#ffcc00"];
}


+ (NKFColor *)yelp{
	return [NKFColor colorWithHexString:@"#af0606"];
}


+ (NKFColor *)yo{
	return [NKFColor colorWithHexString:@"#9b59b6"];
}

+ (NKFColor *)yo2{
	return [NKFColor colorWithHexString:@"#e74c3c"];
}

+ (NKFColor *)yo3{
	return [NKFColor colorWithHexString:@"#8e44ad"];
}

+ (NKFColor *)yo4{
	return [NKFColor colorWithHexString:@"#2980b9"];
}

+ (NKFColor *)yo5{
	return [NKFColor colorWithHexString:@"#f1c40f"];
}

+ (NKFColor *)yo6{
	return [NKFColor colorWithHexString:@"#16a085"];
}

+ (NKFColor *)yo7{
	return [NKFColor colorWithHexString:@"#34495e"];
}

+ (NKFColor *)yo8{
	return [NKFColor colorWithHexString:@"#3498db"];
}

+ (NKFColor *)yo9{
	return [NKFColor colorWithHexString:@"#2ecc71"];
}

+ (NKFColor *)yo10{
	return [NKFColor colorWithHexString:@"#1abc9c"];
}


+ (NKFColor *)youtube{
	return [NKFColor colorWithHexString:@"#cd201f"];
}


+ (NKFColor *)zendesk{
	return [NKFColor colorWithHexString:@"#78a300"];
}

+ (NKFColor *)zendesk2{
	return [NKFColor colorWithHexString:@"#f1f1f1"];
}

+ (NKFColor *)zendesk3{
	return [NKFColor colorWithHexString:@"#444444"];
}


+ (NKFColor *)zerply{
	return [NKFColor colorWithHexString:@"#9dbc7a"];
}


+ (NKFColor *)zillow{
	return [NKFColor colorWithHexString:@"#1277e1"];
}


+ (NKFColor *)zootool {
	return [NKFColor colorWithHexString:@"5e8b1d"];
}


+ (NKFColor *)zopim{
	return [NKFColor colorWithHexString:@"#ff9d3b"];
}

#pragma mark - State colors

+ (NKFColor *)alabama {
	return [NKFColor colorWithRed:247.0f/255.0f green:0.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)alabama2 {
	return [NKFColor white];
}

+ (NKFColor *)arizona {
	return [NKFColor federalBlue];
}

+ (NKFColor *)arizona2 {
	return [NKFColor oldGold];
}

+ (NKFColor *)californiaBlue {
	return [NKFColor colorWithRed:18.0f/255.0f green:0.0f/255.0f blue:127.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)californiaGold {
	return [NKFColor colorWithRed:250.0f/255.0f green:218.0f/255.0f blue:31.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)california {
	return [NKFColor californiaBlue];
}

+ (NKFColor *)california2 {
	return [NKFColor californiaGold];
}

+ (NKFColor *)colonialBlue {
	return [NKFColor colorWithRed:38.0f/255.0f green:122.0f/255.0f blue:166.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)delaware {
	return [NKFColor colonialBlue];
}

+ (NKFColor *)delaware2 {
	return [NKFColor buff];
}

+ (NKFColor *)floridaOrange {
	return [NKFColor colorWithRed:248.0f/255.0f green:126.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)florida {
	return [NKFColor floridaOrange];
}

+ (NKFColor *)florida2 {
	return [NKFColor alabama];
}

+ (NKFColor *)florida3 {
	return [NKFColor alabama2];
}

+ (NKFColor *)idaho {
	return [NKFColor alabama];
}

+ (NKFColor *)idaho2 {
	return [NKFColor colorWithRed:23.0f/255.0f green:131.0f/255.0f blue:3.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)idaho3 {
	return [NKFColor californiaGold];
}

+ (NKFColor *)indiana {
	return [NKFColor colorWithRed:48.0f/255.0f green:0.0f/255.0f blue:253.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)indiana2 {
	return [NKFColor californiaGold];
}

+ (NKFColor *)louisiana {
	return [NKFColor indiana];
}

+ (NKFColor *)louisiana2 {
	return [NKFColor white];
}

+ (NKFColor *)louisiana3 {
	return [NKFColor californiaGold];
}

+ (NKFColor *)maryland {
	return [NKFColor alabama];
}

+ (NKFColor *)maryland2 {
	return [NKFColor white];
}

+ (NKFColor *)maryland3 {
	return [NKFColor black];
}

+ (NKFColor *)maryland4 {
	return [NKFColor californiaGold];
}

+ (NKFColor *)massachusetts {
	return [NKFColor indiana];
}

+ (NKFColor *)massachusetts2 {
	return [NKFColor colorWithRed:25.0f/255.0f green:139.0f/255.0f blue:3.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)massachusetts3 {
	return [NKFColor cranberry];
}

+ (NKFColor *)nevada {
	return [NKFColor colorWithWhite:192.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)nevada2 {
	return [NKFColor indiana];
}

+ (NKFColor *)newjersey {
	return [NKFColor colorWithRed:237.0f/255.0f green:222.0f/255.0f blue:132.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)newjersey2 {
	return [NKFColor indiana];
}

+ (NKFColor *)newmexico {
	return [NKFColor alabama];
}

+ (NKFColor *)newmexico2 {
	return [NKFColor colorWithRed:252.0f/255.0f green:255.0f/255.0f blue:33.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)newyork {
	return [NKFColor colorWithRed:18.0f/255.0f green:0.0f/255.0f blue:127.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)newyork2 {
	return [NKFColor colorWithRed:250.0f/255.0f green:218.0f/255.0f blue:31.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)northcarolina {
	return [NKFColor alabama];
}

+ (NKFColor *)northcarolina2 {
	return [NKFColor indiana];
}

+ (NKFColor *)ohio {
	return [NKFColor alabama];
}

+ (NKFColor *)ohio2 {
	return [NKFColor white];
}

+ (NKFColor *)ohio3 {
	return [NKFColor indiana];
}

+ (NKFColor *)oklahoma {
	return [NKFColor colorWithRed:23.0f/255.0f green:131.0f/255.0f blue:1.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)oklahoma2 {
	return [NKFColor white];
}

+ (NKFColor *)oregon {
	return [NKFColor newyork];
}

+ (NKFColor *)oregon2 {
	return [NKFColor newyork2];
}

+ (NKFColor *)pennsylvania {
	return [NKFColor colorWithRed:62.0f/255.0f green:55.0f/255.0f blue:109.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)pennsylvania2 {
	return [NKFColor newyork2];
}

+ (NKFColor *)southcarolina {
	return [NKFColor colorWithRed:18.0f/255.0f green:63.0f/255.0f blue:105.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)tennessee {
	return [NKFColor colorWithRed:248.0f/255.0f green:126.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)texas {
	return [NKFColor alabama];
}

+ (NKFColor *)texas2 {
	return [NKFColor white];
}

+ (NKFColor *)texas3 {
	return [NKFColor indiana];
}

+ (NKFColor *)utah {
	return [NKFColor black];
}

+ (NKFColor *)utah2 {
	return [NKFColor newmexico2];
}

+ (NKFColor *)westvirginia {
	return [NKFColor colorWithRed:203.0f/255.0f green:183.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
}

+ (NKFColor *)westvirginia2 {
	return [NKFColor indiana];
}


@end
