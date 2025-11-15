//
//  ALUColorPickerView.h
//  Alphabetical List Utility
//
//  Created by HAI on 8/11/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALUColorPickerViewDelegate <NSObject>

@required
- (void)colorPicked:(UIColor *)color;

@end

@interface ALUColorPickerView : UIImageView

@property (weak, nonatomic) id <ALUColorPickerViewDelegate> delegate;

@end
