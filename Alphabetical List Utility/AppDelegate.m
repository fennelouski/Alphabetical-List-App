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
#import "ALUExternalDisplayController.h"
#import "UIColor+AppColors.h"
#import "NKFColor+Companies.h"
#import "ALUNoteCardView.h"
#import "Alphabetical_List_Utility-Swift.h"

@interface AppDelegate () <UISplitViewControllerDelegate, DetailViewControllerDelegate>

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

	// Become the notification delegate so we can present/handle reminders, but defer the
	// authorization prompt until the user actually creates a location-based reminder
	// (requesting permissions at launch, out of context, is an anti-pattern).
	[UNUserNotificationCenter currentNotificationCenter].delegate = self;

	// AirPlay / HDMI: show a non-interactive reading view instead of mirroring.
	[[ALUExternalDisplayController sharedController] start];

    __weak AppDelegate *weakSelf = self;
    self.window.rootViewController = [ALULibraryBuilder makeControllerWithNotes:^NSArray<NSDictionary<NSString *, id> *> * {
        ALUDataManager *data = [ALUDataManager sharedDataManager];
        NSMutableArray *notes = [NSMutableArray array];
        for (NSString *title in [data lists]) {
            NSMutableDictionary *item = [@{@"title": title, @"text": [data listWithTitle:title] ?: @"",
                @"id": [[ALUNoteDetailsStore shared] identifierForTitle:title],
                @"summary": [[ALUNoteDetailsStore shared] summaryForTitle:title],
                @"color": ALUAdaptiveColor([NKFColor colorForCompanyName:title]),
                @"styledTitle": ALUAdaptiveAttributedString([NKFColor attributedStringForCompanyName:title])} mutableCopy];
            if ([data showImageForListTitle:title]) {
                UIImage *icon = [data imageForCompanyName:title];
                if (icon) item[@"icon"] = icon;
            }
            UIColor *styleColor = [ALUNoteCardView backgroundColorForStyle:[data cardStyleForListTitle:title]];
            if (styleColor) { item[@"styleColor"] = styleColor; item[@"styleIntensity"] = @([data cardStyleListIntensityForListTitle:title]); }
            [notes addObject:item];
        }
        return notes;
    } create:^BOOL(NSString *title) {
        return ![[ALUDataManager sharedDataManager] addList:title];
    } delete:^(NSString *title) {
        [[ALUDataManager sharedDataManager] removeList:title];
    } editor:^UIViewController *(NSString *title) {
        DetailViewController *detail = [[DetailViewController alloc] init];
        detail.detailItem = title;
        detail.delegate = weakSelf;
        detail.view.backgroundColor = UIColor.systemBackgroundColor;
        return [[UINavigationController alloc] initWithRootViewController:detail];
    } save:^(UIViewController *controller) {
        if ([controller isKindOfClass:UINavigationController.class]) {
            UIViewController *detail = [(UINavigationController *)controller topViewController];
            if ([detail isKindOfClass:DetailViewController.class]) { [(DetailViewController *)detail saveList]; }
        }
    } cards:^UIViewController * {
        return splitViewController;
    }];

    [[ALUPlaceReminders shared] startWithNotes:^NSArray<NSDictionary<NSString *, NSString *> *> * {
        ALUDataManager *data = [ALUDataManager sharedDataManager];
        NSMutableArray *notes = [NSMutableArray array];
        for (NSString *title in data.lists) [notes addObject:@{@"title": title, @"text": [data listWithTitle:title] ?: @""}];
        return notes;
    }];


	return YES;
}

- (void)reloadList {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ALULibraryChanged" object:nil];
}

- (void)noteWasDeleted {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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
    [[ALUPlaceReminders shared] resume];
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

#pragma mark - User Notifications

// Without this, notifications delivered while the app is foregrounded are silently
// suppressed — which is exactly when a geofence reminder tends to fire.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
	   willPresentNotification:(UNNotification *)notification
		 withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
	completionHandler(UNNotificationPresentationOptionBanner |
					  UNNotificationPresentationOptionList |
					  UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
		 withCompletionHandler:(void (^)(void))completionHandler {
    NSString *noteID = response.notification.request.content.userInfo[@"noteID"];
    NSString *title = response.notification.request.content.userInfo[@"noteTitle"] ?: response.notification.request.content.title;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ALUOpenNote" object:nil userInfo:@{@"title": title ?: @"", @"id": noteID ?: @""}];
    });
	completionHandler();
}

#pragma mark - Location Notifications

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
	if ([region isKindOfClass:[CLCircularRegion class]]) {
		[self handleRegionEvent:region];
	}
}

- (void)handleRegionEvent:(CLRegion *)region {
    [[ALUPlaceReminders shared] handleRegionWithIdentifier:region.identifier];
}

@end
