//
//  AppDelegate.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "ALUDataManager.h"
#import "UIColor+AppColors.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
//												animated:YES];
	UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
	UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
	navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
	splitViewController.delegate = self;
	
	if (!self.locationManager) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
	}
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController showViewController:(UIViewController *)vc sender:(id)sender {
	NSLog(@"- (BOOL)splitViewController:(UISplitViewController *)splitViewController showViewController:(UIViewController *)vc sender:(id)sender");
	if ([splitViewController.navigationController.navigationBar.tintColor isLight]) {
		if ([splitViewController.navigationController.navigationBar.barTintColor isLight]) {
			splitViewController.navigationController.navigationBar.tintColor = [UIColor black];
		}
	} else {
		if (![splitViewController.navigationController.navigationBar.barTintColor isLight]) {
			splitViewController.navigationController.navigationBar.tintColor = [UIColor white];
		}
	}
	
	return YES;
}

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
	if ([svc.navigationController.navigationBar.tintColor isLight]) {
		if ([svc.navigationController.navigationBar.barTintColor isLight]) {
			svc.navigationController.navigationBar.tintColor = [UIColor black];
		}
	} else {
		if (![svc.navigationController.navigationBar.barTintColor isLight]) {
			svc.navigationController.navigationBar.tintColor = [UIColor white];
		}
	}
}

#pragma mark - Location Notifications

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
	if ([region isKindOfClass:[CLCircularRegion class]]) {
		[self handleRegionEvent:region];
	}
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	if ([region isKindOfClass:[CLCircularRegion class]]) {
		[self handleRegionEvent:region];
	}
}

- (void)handleRegionEvent:(CLRegion *)region {
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[region identifier] message:@"" preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
														   style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction *action) {
															 
														 }];
		[alertController addAction:okAction];
	} else {
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		NSMutableString *alertBody = [[NSMutableString alloc] init];
		
		NSString *noteInfo = [[ALUDataManager sharedDataManager] listWithTitle:[region identifier]];
		if (noteInfo) {
			// remove extra white space between lines and limits the number of lines to 5
			NSArray *lines = [noteInfo componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
			
			if (lines.count > 1) {
				int maxNumberOfLines = 5;
				int blankLines = 0;
				NSMutableString *formattedNoteInfo = [[NSMutableString alloc] initWithString:[lines firstObject]];
				
				for (int i = 1; i < lines.count && i < maxNumberOfLines + blankLines; i++) {
					NSString *line = [[lines objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					
					if (line.length > 0) {
						[formattedNoteInfo appendFormat:@"\n%@", line];
					} else {
						blankLines++;
					}
				}
			}
			
			[alertBody appendString:noteInfo];
		} else {
			[self.locationManager stopMonitoringForRegion:region];
			return;
		}
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *lastNotificationDateKey = [NSString stringWithFormat:@"Last Notification Date K£Y%@", [region identifier]];
        NSDate *lastNotificationDate = [defaults objectForKey:lastNotificationDateKey];
        NSTimeInterval minimumWaitTime = -600.0f;
        if (lastNotificationDate && [lastNotificationDate timeIntervalSinceNow] > minimumWaitTime) {
            return;
        }
        
        [defaults setObject:[NSDate date] forKey:lastNotificationDateKey];
		
        localNotification.alertAction = @"show note";
        localNotification.alertTitle = [region identifier];
        localNotification.alertBody = alertBody;
		localNotification.soundName = @"Default";
		localNotification.category = @"showNoteNotificationCategory";
		
		
        NSLog(@"scheduledLocalNotifications: %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
        
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
}

@end
