//
//  ALUPointAnnotation.m
//  Alphabetical List Utility
//
//  Created by Developer Nathan on 7/27/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUPointAnnotation.h"
#import <AddressBook/AddressBook.h>

static NSString * const latitudeCoordinateKey   = @"latitudeCoordinateK£y";
static NSString * const longitudeCoordinateKey  = @"longitudeCoordinateK£y";
static NSString * const radiusInMetersKey       = @"radiusInMetersK£y";
static NSString * const notifyOnEntryKey        = @"notifyOnEntryK£y";
static NSString * const notificationEnabledKey  = @"notificationEnabledK£y";
static NSString * const addressStringKey        = @"addressStringK£y";

@implementation ALUPointAnnotation

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)save {
    if (self.radius == 0) {
        NSLog(@"Radius is 0. Not saving geotification for \"%@\"", self.title);
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults doubleForKey:[self latitudeKey]] != self.coordinate.latitude ||
        [defaults doubleForKey:[self longitudeKey]] != self.coordinate.longitude) {
        [self getAddressForCoordinate];
    }
    
    [defaults setDouble:self.coordinate.latitude forKey:[self latitudeKey]];
    [defaults setDouble:self.coordinate.longitude forKey:[self longitudeKey]];
    [defaults setDouble:self.radius forKey:[self radiusKey]];
    [defaults setBool:self.notifyOnEntry forKey:[self entryKey]];
    [defaults setBool:self.notificationEnabled forKey:[self notificationKey]];
	
	if (self.coordinate.latitude != 0.0 &&
		self.coordinate.longitude != 0.0) {
		self.addressString = [NSString stringWithFormat:@"%f, %f", self.coordinate.latitude, self.coordinate.longitude];
	} else {
		self.addressString = @"Add location";
	}
}

- (void)getAddressForCoordinate {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude
                                                      longitude:self.coordinate.longitude];
    
    if (self.coordinate.latitude == 0.0 &&
        self.coordinate.longitude == 0.0) {
        return;
    }
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks) {
            NSLog(@"placemark.addressDictionary: %@", placemark.addressDictionary);
			NSString *streetAddress = [[placemark addressDictionary] objectForKey:(NSString *)kABPersonAddressStreetKey];
			NSString *cityAddress = [[placemark addressDictionary] objectForKey:(NSString *)kABPersonAddressCityKey];
			NSString *stateAddress = [[placemark addressDictionary] objectForKey:(NSString *)kABPersonAddressStateKey];
			
			if (!streetAddress || !cityAddress || !stateAddress) {
				self.addressString = @"Add location";
			} else {
				NSString *addressString = [NSString stringWithFormat:@"%@, %@, %@",
										   streetAddress,
										   cityAddress,
										   stateAddress];
				self.addressString = addressString;
				
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setObject:self.addressString forKey:[self addressStringKey]];
			}
        }
    }];
}

- (void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees latitude = [defaults doubleForKey:[self latitudeKey]];
    CLLocationDegrees longitude = [defaults doubleForKey:[self longitudeKey]];
    self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    self.radius = [defaults doubleForKey:[self radiusKey]];
    self.notifyOnEntry = [defaults boolForKey:[self entryKey]];
    self.notificationEnabled = [defaults boolForKey:[self notificationKey]];
    self.addressString = [defaults objectForKey:[self addressStringKey]];
    if (!self.addressString) {
		if (self.coordinate.latitude != 0.0 &&
			self.coordinate.longitude != 0.0) {
			self.addressString = [NSString stringWithFormat:@"%f, %f", self.coordinate.latitude, self.coordinate.longitude];
		} else {
			self.addressString = @"Add location";
		}
		
        [self getAddressForCoordinate];
    }
    
    NSLog(@"Loaded %@", self.title);
}

- (NSString *)latitudeKey {
    return [self.title stringByAppendingString:latitudeCoordinateKey];
}

- (NSString *)longitudeKey {
    return [self.title stringByAppendingString:longitudeCoordinateKey];
}

- (NSString *)radiusKey {
    return [self.title stringByAppendingString:radiusInMetersKey];
}

- (NSString *)entryKey {
    return [self.title stringByAppendingString:notifyOnEntryKey];
}

- (NSString *)notificationKey {
    return [self.title stringByAppendingString:notificationEnabledKey];
}

- (NSString *)addressStringKey {
    return [self.title stringByAppendingString:addressStringKey];
}


- (void)remove {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:[self latitudeKey]];
	[defaults removeObjectForKey:[self longitudeKey]];
	[defaults removeObjectForKey:[self radiusKey]];
	[defaults removeObjectForKey:[self entryKey]];
	[defaults removeObjectForKey:[self notificationKey]];
	[defaults removeObjectForKey:[self addressStringKey]];
}


@end
