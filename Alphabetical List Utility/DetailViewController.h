//
//  DetailViewController.h
//  Alphabetical List Utility
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailViewControllerDelegate <NSObject>

- (void)reloadList;

@end

@interface DetailViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UITextView *detailDescriptionLabel;

@property (nonatomic, strong) UITextView *listItemTextView;

@property (weak) id <DetailViewControllerDelegate> delegate;

@end

