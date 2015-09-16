//
//  UIFont+AppFonts.m
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "UIFont+AppFonts.h"
#import "UIFont+Custom.h"

#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))

@implementation UIFont (AppFonts)

+ (UIFont *)appFont {
	return [self appFontOfSize:(kScreenHeight + kScreenWidth)*0.009];
}

+ (UIFont *)appFontOfSize:(float)fontSize {
	return [UIFont systemFontOfSize:fontSize];
}

@end
