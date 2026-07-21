//
//  UIFont+AppFonts.m
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "UIFont+AppFonts.h"
#import "UIFont+Custom.h"

// kStatusBarHeight comes from PrefixHeader.pch (safe-area based); the local redefinition here
// shadowed it with deprecated -statusBarFrame math that returns 0 on modern devices.

@implementation UIFont (AppFonts)

+ (UIFont *)appFont {
	return [self appFontOfSize:(kScreenHeight + kScreenWidth)*0.009];
}

+ (UIFont *)appFontOfSize:(float)fontSize {
	return [UIFont systemFontOfSize:fontSize];
}

@end
