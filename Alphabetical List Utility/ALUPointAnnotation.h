//
//  ALUPointAnnotation.h
//  Alphabetical List Utility
//
//  Created by Developer Nathan on 7/27/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ALUPointAnnotation : MKPointAnnotation

@property (nonatomic) double radius;

@property (nonatomic) BOOL notifyOnEntry;

@property (nonatomic) BOOL notificationEnabled;

@property (nonatomic, strong) NSString *addressString;

- (void)getAddressForCoordinate;

- (void)save;
- (void)load;
- (void)remove;

@end
