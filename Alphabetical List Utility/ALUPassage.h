//
//  ALUPassage.h
//  Alphabetical List Utility
//
//  Created by HAI on 8/10/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALUVerse.h"

@interface ALUPassage : NSObject

@property (nonatomic, strong) NSString *book;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSMutableArray *verses;

- (void)addVerse:(ALUVerse *)verse;

- (NSAttributedString *)formattedVerse;
- (NSAttributedString *)formattedVersePrependedByDate;


@end
