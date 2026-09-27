//
//  ALUNavigationController.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/20/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALUNavigationController : UINavigationController

@end

// Navigation bar for the nav controller embedded in the full-screen note card. There,
// iOS 26 lays its circular glass bar-button platters flush against the bar's (and so
// the screen's) edges; this bar nudges them back inside after each layout pass.
@interface ALUCardNavigationBar : UINavigationBar

@end
