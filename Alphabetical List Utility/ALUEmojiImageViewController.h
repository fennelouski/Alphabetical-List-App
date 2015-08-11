//
//  ALUEmojiImageViewController.h
//  Alphabetical List Utility
//
//  Created by Nathan Fennel on 8/10/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALUEmojiImageViewControllerDelegate <NSObject>

@required
- (void)emojiImage:(UIImage *)image;

@end

@interface ALUEmojiImageViewController : UIViewController

- (UIImage *)image;

@property (assign) id <ALUEmojiImageViewControllerDelegate> delegate;

@end
