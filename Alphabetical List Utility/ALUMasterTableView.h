//
//  ALUMasterTableView.h
//  Alphabetical List Utility
//
//  Created by HAI on 8/6/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALUMasterTableView : UITableView

// Row an expanded card was lifted from. While >= 0, the cards above that row slide
// up out of view and that row plus the cards below slide down out of view
// (Wallet-style parting); -1 restores the normal fanned stack. Applied in
// layoutSubviews, so it survives reloads — change it inside an animation block
// (followed by layoutIfNeeded) to animate the parting.
@property (nonatomic) NSInteger partedRow;

// While YES, only the rows in front of partedRow stay parted; partedRow and the
// rows behind it sit in their normal fanned positions. Lets a returning card dock
// into an already-settled stack before the cards in front slide up over it.
@property (nonatomic) BOOL partsFrontRowsOnly;

// The rolodex fan offset a card sitting at this y position gets, so a returning
// card can be aimed at exactly where the stack will place it.
- (CGFloat)fanShiftForRowTopInView:(CGFloat)rowTopInView;

// Row whose card is drawn frontmost under the given point (table coords), or nil.
// Cards are translated by the fan effect, so this — not UITableView's row geometry —
// is what a tap on a visible card should act on.
- (NSIndexPath *)indexPathForFrontmostCardAtPoint:(CGPoint)point;

@end
