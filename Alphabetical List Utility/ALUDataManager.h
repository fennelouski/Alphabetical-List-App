//
//  ALUDataManager.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ALUPointAnnotation.h"
#import "ALUDocument.h"

@interface ALUDataManager : NSObject <CLLocationManagerDelegate, UIDocumentMenuDelegate>

- (CLLocationManager *)locationManager;

- (CLLocationCoordinate2D)userLocation;

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


- (NSString *)companyNameURLStringForCompanyName:(NSString *)companyName;


// API Calls
- (BOOL)apiAvailableForTitle:(NSString *)listTitle;

- (void)makeCallForListTitle:(NSString *)listTitle;

- (NSDictionary *)dictionaryForTitle:(NSString *)listTitle;



// Geolocation
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radiusInMeters forListTitle:(NSString *)listTitle;

- (void)setRadius:(double)radiusInMeters forListTitle:(NSString *)listTitle;

- (BOOL)geolocationReminderExistsForTitle:(NSString *)listTitle;

- (ALUPointAnnotation *)annotationForTitle:(NSString *)listTitle;

- (NSString *)geolocationNameForTitle:(NSString *)listTitle;

- (void)removeReminderForListTitle:(NSString *)listTitle;


// App State

- (void)setNoteHasBeenSelectedOnce:(BOOL)noteHasBeenSelectedOnce;

- (BOOL)noteHasBeenSelectedOnce;

- (void)setMenuShowing:(BOOL)menuShowing;

- (BOOL)menuShowing;

- (void)setShouldShowStatusBar:(BOOL)shouldShowStatusBar;

- (BOOL)shouldShowStatusBar;

// font size

- (void)saveAdjustedFontSize:(CGFloat)adjustedFontSize;

- (CGFloat)currentFontSize;

// cards

- (void)setUseCardView:(BOOL)useCardView;

- (BOOL)useCardView;


// iCloud

- (BOOL)iCloudIsAvailable;

@property (nonatomic) BOOL currentColorIsDark;



- (void)setDocument:(ALUDocument *)document;
- (ALUDocument *)document;
- (void)setQuery:(NSMetadataQuery *)query;
- (NSMetadataQuery *)query;
- (void)loadIcloudDocument:(NSString *)noteTitle;


@end
