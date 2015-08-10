//
//  ALUGeolocationReminder.h
//  Alphabetical List Utility
//
//  Created by Developer Nathan on 7/27/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ALUGeolocationReminder : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description;


@property (nonatomic) double radiusInMeters;

@property (nonatomic) BOOL notifyOnEntry;

@property (nonatomic) BOOL notificationEnabled;

- (void)deleteWithTitle:(NSString *)title;

+ (ALUGeolocationReminder *)reminderWithTitle:(NSString *)title;

@end
