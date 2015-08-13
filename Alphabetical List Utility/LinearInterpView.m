

#import "LinearInterpView.h"
#import "NKFColor.h"

static CGFloat const LinearInterpViewLineWidth = 15.0f;

@interface LinearInterpView ()

@end



@implementation LinearInterpView {
	NSMutableArray *paths, *colors, *lineThicknesses;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
		paths = [[NSMutableArray alloc] init];
		colors = [[NSMutableArray alloc] init];
		lineThicknesses = [[NSMutableArray alloc] init];
    }
	
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setMultipleTouchEnabled:NO];
		[self setBackgroundColor:[UIColor whiteColor]];
		paths = [[NSMutableArray alloc] init];
		colors = [[NSMutableArray alloc] init];
		lineThicknesses = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect {
	for (int i = 0; i < paths.count && colors.count; i++) {
		UIBezierPath *path = [paths objectAtIndex:i];
		UIColor *color = [colors objectAtIndex:i];
		NSNumber *lineWidth = [lineThicknesses objectAtIndex:i];
		[color setStroke];
		[path stroke];
		[path setLineWidth:lineWidth.floatValue];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path setLineWidth:self.lineThickness.floatValue];
    [path moveToPoint:p];
	[paths addObject:path];
	[colors addObject:self.currentColor];
	[lineThicknesses addObject:self.lineThickness];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
	UIBezierPath *path = [paths lastObject];
    [path addLineToPoint:p];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}


- (void)undoLastLine {
	if (paths.count > 0 && colors.count > 0) {
		[paths removeLastObject];
		[colors removeLastObject];
		[lineThicknesses removeLastObject];
		[self setNeedsDisplay];
	}
}


@end
