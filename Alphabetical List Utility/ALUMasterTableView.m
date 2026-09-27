//
//  ALUMasterTableView.m
//  Alphabetical List Utility
//
//  Created by HAI on 8/6/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ALUMasterTableView.h"
#import "ALUDataManager.h"
#import "ALUMasterTableViewCell.h"

static CGFloat const maximumFanShift = 200.0f;

// Extra distance past the edge so card shadows fully clear the screen when parted.
static CGFloat const partedOverscan = 80.0f;

@implementation ALUMasterTableView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		_partedRow = -1;
	}

	return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	self = [super initWithFrame:frame style:style];

	if (self) {
		_partedRow = -1;
	}

	return self;
}

- (CGFloat)fanShiftForRowTopInView:(CGFloat)rowTopInView {
	CGFloat height = self.bounds.size.height;
	if (height <= 0.0f) {
		return 0.0f;
	}

	// t: 0 at the bottom edge … 1 at the top edge.
	CGFloat t = 1.0f - rowTopInView / height;
	t = MAX(0.0f, MIN(1.0f, t));

	// Cards travel slower near the bottom, fastest around 50–75% of the way up,
	// then slower again near the top. The shift is an S-curve of position, so its
	// derivative (the apparent scroll-speed change) is a smooth bump; the t^1.47
	// bias moves the fastest point from mid-screen up to ~62% of the way up.
	CGFloat biased = powf(t, 1.47f);
	CGFloat eased = biased * biased * (3.0f - 2.0f * biased); // smoothstep

	return (1.0f - 2.0f * eased) * maximumFanShift;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	if (USE_CARDS) {
		NSArray *sortedIndexPaths = [[self indexPathsForVisibleRows] sortedArrayUsingSelector:@selector(compare:)];
		for (NSIndexPath *path in sortedIndexPaths) {
			UITableViewCell *cell = [self cellForRowAtIndexPath:path];
			[self bringSubviewToFront:cell];
			[cell.layer setZPosition:path.row];

			if (![cell isKindOfClass:[ALUMasterTableViewCell class]]) {
				continue;
			}

			ALUMasterTableViewCell *cardCell = (ALUMasterTableViewCell *)cell;
			CGFloat rowTopInView = CGRectGetMinY(cell.frame) - self.contentOffset.y;
			CGFloat shift;

			if (self.partedRow >= 0 && !(self.partsFrontRowsOnly && path.row <= self.partedRow)) {
				// A card is expanded: part the stack around it. Cards behind (above)
				// leave through the top edge, the lifted card's row and the cards in
				// front of it leave through the bottom.
				if (path.row < self.partedRow) {
					shift = -(rowTopInView + cardCell.cardView.bounds.size.height + partedOverscan);
				} else {
					shift = self.bounds.size.height - rowTopInView + partedOverscan;
				}
			} else {
				// Rolodex effect: cards fan slightly apart around the vertical
				// middle, so the card under the thumb reveals a bit more of itself
				// than the cards squeezed at the top and bottom.
				shift = [self fanShiftForRowTopInView:rowTopInView];
			}

			[cardCell setCardShift:shift];
		}
	}
}

// Cards are translated by the fan effect (up to ±maximumFanShift), so a card's
// visible position no longer matches the row geometry UITableView selects by — a
// tap on the card you see would otherwise open whatever row happens to sit at that
// screen spot. Walk the visible cards frontmost (top card) first and return the
// first whose translated card body actually contains the point.
- (NSIndexPath *)indexPathForFrontmostCardAtPoint:(CGPoint)point {
	NSArray *sortedIndexPaths = [[self indexPathsForVisibleRows] sortedArrayUsingSelector:@selector(compare:)];
	for (NSIndexPath *path in [sortedIndexPaths reverseObjectEnumerator]) {
		UITableViewCell *cell = [self cellForRowAtIndexPath:path];
		if (![cell isKindOfClass:[ALUMasterTableViewCell class]]) {
			continue;
		}

		UIView *card = ((ALUMasterTableViewCell *)cell).cardView;
		if ([card pointInside:[self convertPoint:point toView:card] withEvent:nil]) {
			return path;
		}
	}

	return nil;
}

@end
