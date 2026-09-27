//
//  MasterViewController.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALUBackgroundView.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (nonatomic, strong) UIView *inputAccessoryView;

@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) UIView *headerToolbar;

@property (nonatomic, strong) ALUBackgroundView *backgroundView;

@end

