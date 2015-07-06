//
//  ALUDataManager.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALUDataManager : NSObject

+ (instancetype)sharedDataManager;

- (void)addList:(NSString *)listTitle;

- (void)removeList:(NSString *)listTitle;

- (NSArray *)lists;

- (NSString *)listWithTitle:(NSString *)listTitle;

- (void)saveList:(NSString *)list withTitle:(NSString *)title;

@end
