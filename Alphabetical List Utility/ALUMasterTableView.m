//
//  ALUMasterTableView.m
//  Alphabetical List Utility
//
//  Created by HAI on 8/6/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUMasterTableView.h"
#import "ALUDataManager.h"

static CGFloat const tableViewInset = 0.0f;

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

- (CGRect)frame {
    if (self.superview) {
        return CGRectOffset(CGRectMake(0.0f, -tableViewInset, self.superview.frame.size.width, self.superview.frame.size.height + tableViewInset + 14.0f), 0.0f, -13.0f);
    }
    
    return CGRectMake(0.0f, 0.0f, 200.0f, 300.0f);
}

@end
