//
//  ALUMapViewController.m
//  Alphabetical List Utility
//
//  Created by Developer Nathan on 7/27/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUMapViewController.h"
#import "ALUDataManager.h"
#import "NKFColor.h"
#import "NKFColor+AppColors.h"

@implementation ALUMapViewController {
    BOOL _foundUserLocation;
    double _radius;
    MKCircle *_circle;
    NSDate *_lastCircleChangeDate;
    ALUPointAnnotation *_annotation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.mapView];
    [self addAnnotations];
    _radius = _annotation.radius;
    [self.view addSubview:self.footerToolbar];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createGeofence)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.radiusSlider setValue:_annotation.radius animated:YES];
    
    if (_annotation && _annotation.coordinate.latitude && _annotation.coordinate.longitude) {
        self.mapView.centerCoordinate = _annotation.coordinate;
    }
	
	UIView *blankView = [[UIView alloc] init];
	self.navigationItem.titleView = blankView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.radiusSlider setValue:_annotation.radius animated:YES];
    [self sliderTouched:self.radiusSlider];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[ALUDataManager sharedDataManager] setRadius:_radius forListTitle:self.title];
    [_annotation save];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    self.mapView.frame = self.view.bounds;
    self.crossHairs.frame = [self crossHairsFrame];
	self.footerToolbar.frame = [self footerToolbarFrame];
    self.radiusSlider.frame = CGRectInset(self.footerToolbar.bounds, 20.0f, 5.0f);
}

- (void)addAnnotations {
    ALUPointAnnotation *annotation;
    
    if ([[ALUDataManager sharedDataManager] geolocationReminderExistsForTitle:self.title]) {
        annotation = [[ALUDataManager sharedDataManager] annotationForTitle:self.title];
        _annotation = annotation;
        [self.mapView addAnnotation:annotation];
    }
    
    if (!annotation) {
        DLog(@"No annotation for %@", self.title);
        return;
    }
    
    [self.mapView addAnnotation:annotation];
    
    if (!_circle) {
        _circle = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:annotation.radius];
    } else {
        [self.mapView removeOverlay:_circle];
        _circle = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:annotation.radius];
    }
    
    [self.mapView addOverlay:_circle];
	
	[self showSlider];
}


- (void)createGeofence {
    DLog(@"Create geofence");
    
    if (_radius == 0.0) {
        DLog(@"Radius is 0 so changing it to a default of 100");
        _radius = 10.0;
    }
    
    [[ALUDataManager sharedDataManager] setCoordinate:self.mapView.centerCoordinate
                                               radius:_radius
                                         forListTitle:self.title];
    
    [self addAnnotations];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    DLog(@"Overlay: %@", [overlay title]);

    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
        renderer.fillColor = [[NKFColor appColor] colorWithAlphaComponent:0.5f];
        renderer.strokeColor = [[NKFColor appColor] colorWithAlphaComponent:0.7f];
        renderer.lineWidth = 2.0f;
        return renderer;
    }

    return nil;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    NSString *identifier = @"mapViewAnnotationIdentifier";
    MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.canShowCallout = YES;
        annotationView.backgroundColor = [NKFColor purpleColor];
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.fillColor = [[NKFColor appColor] colorWithAlphaComponent:0.5f];
        circleRenderer.strokeColor = [NKFColor appColor1];
        circleRenderer.lineWidth = 1.0f;
        return circleRenderer;
    }
    
    return nil;
}

- (void)showSlider {
	[UIView animateWithDuration:0.35f
					 animations:^{
						 self.footerToolbar.frame = [self footerToolbarFrame];
					 }];
}

- (CGRect)footerToolbarFrame {
	if ([[ALUDataManager sharedDataManager] geolocationReminderExistsForTitle:self.title]) {
		return CGRectMake(0.0f, self.view.frame.size.height - 44.0f, self.view.frame.size.width, 44.0f);
	}
	
	return CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 44.0f);
}

#pragma mark - Subviews

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.showsUserLocation = YES;
        _mapView.delegate = self;
        [_mapView addSubview:self.crossHairs];
        
        CLLocationCoordinate2D coordinate = [[ALUDataManager sharedDataManager] userLocation];
        if (coordinate.latitude != 0.0 &&
            coordinate.longitude != 0.0) {
            [self.mapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.05, 0.05))];
            _foundUserLocation = YES;
        } else {
            [self performSelector:@selector(findUserLocation) withObject:self afterDelay:0.05f];
            _foundUserLocation = NO;
        }
    }
    
    return _mapView;
}

- (void)findUserLocation {
    if (self.mapView.userLocation.coordinate.longitude != 0.0 &&
        self.mapView.userLocation.coordinate.latitude  != 0.0 &&
        !_foundUserLocation) {
        self.mapView.centerCoordinate = self.mapView.userLocation.coordinate;
        [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.userLocation.coordinate, MKCoordinateSpanMake(0.1, 0.1))];
        _foundUserLocation = YES;
    } else {
        [self performSelector:@selector(findUserLocation) withObject:self afterDelay:0.05f];
    }
}

- (UIToolbar *)footerToolbar {
    if (!_footerToolbar) {
        _footerToolbar = [[UIToolbar alloc] initWithFrame:[self footerToolbarFrame]];
        [_footerToolbar addSubview:self.radiusSlider];
        [self performSelector:@selector(sliderTouched:) withObject:self.radiusSlider afterDelay:0.1f];
    }
    
    return _footerToolbar;
}

- (UISlider *)radiusSlider {
    if (!_radiusSlider) {
        _radiusSlider = [[UISlider alloc] initWithFrame:CGRectInset(self.footerToolbar.bounds, 20.0f, 5.0f)];
        [_radiusSlider setValue:(int)_annotation.radius
                       animated:YES];
        _radiusSlider.minimumValue = 50.0f;
        _radiusSlider.maximumValue = 1609.34f * 2.0f;
        _radiusSlider.tintColor = self.navigationController.navigationBar.barTintColor;
        [_radiusSlider addTarget:self
                          action:@selector(sliderTouched:)
                forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragInside];
    }
    
    return _radiusSlider;
}

- (UILabel *)crossHairs {
    if (!_crossHairs) {
        _crossHairs = [[UILabel alloc] initWithFrame:[self crossHairsFrame]];
        _crossHairs.text = @"+";
        _crossHairs.textAlignment = NSTextAlignmentCenter;
    }
    
    return _crossHairs;
}

- (CGRect)crossHairsFrame {
    CGRect frame = CGRectOffset(self.mapView.bounds, 0.0f, self.navigationController.navigationBar.frame.size.height*0.5f + kStatusBarHeight * 0.5f);
    frame.origin.y -= 1.0f;
    return frame;
}

#pragma mark - Button Actions

- (void)sliderTouched:(UISlider *)slider {
    if ([slider isEqual:self.radiusSlider]) {
        float value = self.radiusSlider.value;
//        if (slider.value > 240.0f) {
//            value *= ((int)slider.value - 240.0f);
//            
//            if (value < slider.value) {
//                value = slider.value;
//            }
//        }
        
        
        if ((!_lastCircleChangeDate || [_lastCircleChangeDate timeIntervalSinceNow] < -0.1f) && _radius != value) {
            [self.mapView removeOverlay:_circle];
            
            _circle = [MKCircle circleWithCenterCoordinate:_circle.coordinate radius:_radius];
            [self.mapView addOverlay:_circle];
            
            _lastCircleChangeDate = [NSDate date];
        }
        
        _radius = value;
    }
}

@end
