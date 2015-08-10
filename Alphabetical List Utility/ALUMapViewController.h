//
//  ALUMapViewController.h
//  Alphabetical List Utility
//
//  Created by Developer Nathan on 7/27/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUNavigationController.h"
#import <MapKit/MapKit.h>
#import "ALUGeolocationReminder.h"

@interface ALUMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) UIToolbar *footerToolbar;

@property (nonatomic, strong) UISlider *radiusSlider;

@property (nonatomic, strong) UILabel *crossHairs;

@property (nonatomic, strong) ALUGeolocationReminder *reminder;

@end
