//
//  ALUMasterTableView.m
//  Alphabetical List Utility
//
//  Created by HAI on 8/6/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUMasterTableView.h"
#import "ALUDataManager.h"

@implementation ALUMasterTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (USE_CARDS) {
		NSArray *sortedIndexPaths = [[self indexPathsForVisibleRows] sortedArrayUsingSelector:@selector(compare:)];
		for (NSIndexPath *path in sortedIndexPaths) {
			UITableViewCell *cell = [self cellForRowAtIndexPath:path];
			[self bringSubviewToFront:cell];
			[cell.layer setZPosition:path.row];
		}
	}
}

@end
