//
//  ALUGeolocationReminder.m
//  Alphabetical List Utility
//
//  Created by Developer Nathan on 7/27/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUGeolocationReminder.h"

static NSString * const latitudeCoordinateKey   = @"latitudeCoordinateK£y";
static NSString * const longitudeCoordinateKey  = @"longitudeCoordinateK£y";
static NSString * const radiusInMetersKey       = @"radiusInMetersK£y";
static NSString * const notifyOnEntryKey        = @"notifyOnEntryK£y";
static NSString * const notificationEnabledKey  = @"notificationEnabledK£y";

@implementation ALUGeolocationReminder {
    NSString *_title;
}

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description {
    self = [super init];
    
    if (self) {
        _title = placeName;
        _coordinate = location;
    }
    
    return self;
}

+ (NSString *)formattedString:(NSString *)input {
    NSString *formattedString = [[[input lowercaseString] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
    return formattedString;
}

- (void)deleteWithTitle:(NSString *)title {
    _title = [ALUGeolocationReminder formattedString:title];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:[self latitudeKey]];
    [defaults removeObjectForKey:[self longitudeKey]];
    [defaults removeObjectForKey:[self radiusKey]];
    [defaults removeObjectForKey:[self entryKey]];
    [defaults removeObjectForKey:[self notificationKey]];
}

- (void)saveWithTitle {
    if (self.radiusInMeters == 0) {
        NSLog(@"Radius is 0. Not saving geotification for \"%@\"", _title);
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setDouble:self.coordinate.latitude forKey:[self latitudeKey]];
    [defaults setDouble:self.coordinate.longitude forKey:[self longitudeKey]];
    [defaults setDouble:self.radiusInMeters forKey:[self radiusKey]];
    [defaults setBool:self.notifyOnEntry forKey:[self entryKey]];
    [defaults setBool:self.notificationEnabled forKey:[self notificationKey]];
}

- (NSString *)latitudeKey {
    return [_title stringByAppendingString:latitudeCoordinateKey];
}

- (NSString *)longitudeKey {
    return [_title stringByAppendingString:longitudeCoordinateKey];
}

- (NSString *)radiusKey {
    return [_title stringByAppendingString:radiusInMetersKey];
}

- (NSString *)entryKey {
    return [_title stringByAppendingString:notifyOnEntryKey];
}

- (NSString *)notificationKey {
    return [_title stringByAppendingString:notificationEnabledKey];
}

+ (ALUGeolocationReminder *)reminderWithTitle:(NSString *)title {
    NSString *latitudeKey = [[ALUGeolocationReminder formattedString:title] stringByAppendingString:latitudeCoordinateKey];
    NSString *longitudeKey = [[ALUGeolocationReminder formattedString:title] stringByAppendingString:longitudeCoordinateKey];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees latitude = [defaults doubleForKey:latitudeKey];
    CLLocationDegrees longitude = [defaults doubleForKey:longitudeKey];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    ALUGeolocationReminder *reminder = [[ALUGeolocationReminder alloc] initWithCoordinates:coordinate placeName:title description:@""];
    
    [reminder readReminderFromDefaults];
    
    if (reminder.coordinate.latitude != 0.0 &&
        reminder.coordinate.longitude != 0.0 &&
        reminder.radiusInMeters != 0.0) {
        return reminder;
    }
    
    return nil;
}

- (void)readReminderFromDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CLLocationDegrees latitude = [defaults doubleForKey:[self latitudeKey]];
    CLLocationDegrees longitude = [defaults doubleForKey:[self longitudeKey]];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    self.radiusInMeters = [defaults doubleForKey:[self radiusKey]];
    
    self.notifyOnEntry = [defaults boolForKey:[self entryKey]];
    
    self.notificationEnabled = [defaults boolForKey:[self notificationKey]];
}

@end
