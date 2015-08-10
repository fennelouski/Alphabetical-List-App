//
//  ALUVerse.h
//  Alphabetical List Utility
//
//  Created by HAI on 8/3/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALUVerse : NSObject

@property (nonatomic, strong) NSString *book;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *text;

@property NSInteger chapter;

@property NSInteger verse;

- (NSAttributedString *)formattedVerse;
- (NSAttributedString *)formattedVersePrependedByDate;

@end
