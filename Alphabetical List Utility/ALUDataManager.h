//
//  ALUDataManager.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALUDataManager : NSObject

+ (instancetype)sharedDataManager;

- (BOOL)addList:(NSString *)listTitle;

- (void)removeList:(NSString *)listTitle;

- (NSArray *)lists;

- (NSString *)listWithTitle:(NSString *)listTitle;

- (void)saveList:(NSString *)list withTitle:(NSString *)title;

- (UIImage *)imageForCompanyName:(NSString *)companyName;


- (void)setListMode:(BOOL)listMode forListTitle:(NSString *)title;

- (BOOL)listModeForListTitle:(NSString *)title;

- (void)setAlphabetize:(BOOL)listMode forListTitle:(NSString *)title;

- (BOOL)alphabetizeForListTitle:(NSString *)title;



- (void)setShowImage:(BOOL)showImage forListTitle:(NSString *)title;

- (BOOL)showImageForListTitle:(NSString *)title;


- (void)setUseWebIcon:(BOOL)useWebIcon forListTitle:(NSString *)title;

- (BOOL)useWebIconForListTitle:(NSString *)title;


- (void)saveImage:(UIImage *)image forCompanyName:(NSString *)companyName;

- (void)removeImageForCompanyName:(NSString *)companyName;

- (BOOL)imageSavedLocallyForCompanyName:(NSString *)companyName;

@property (nonatomic) BOOL currentColorIsDark;

@end
