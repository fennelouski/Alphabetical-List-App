//
//  Alphabetical_List_UtilityTests.m
//  Alphabetical List UtilityTests
//
//  Created by HAI on 7/6/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>

#import "../Alphabetical List Utility/ALUDataManager.h"
#import "../Alphabetical List Utility/NKFColor+AppColors.h"
#import "../Alphabetical List Utility/NKFColor+Companies.h"

// Titles are prefixed so a failed run can never be mistaken for (or clobber) a real note.
static NSString * const kTestListTitle = @"XCTest Scratch List";
static NSString * const kTestRichTitle = @"XCTest Rich Text List";
static NSString * const kTestColorName = @"XCTest Saved Color";

@interface Alphabetical_List_UtilityTests : XCTestCase

@end

@implementation Alphabetical_List_UtilityTests

- (void)setUp {
    [super setUp];
    [self removeTestArtifacts];
}

- (void)tearDown {
    [self removeTestArtifacts];
    [super tearDown];
}

- (void)removeTestArtifacts {
    ALUDataManager *manager = [ALUDataManager sharedDataManager];
    [manager removeList:kTestListTitle];
    [manager removeRichTextForListTitle:kTestRichTitle];
    [manager removeList:kTestRichTitle];
    [NKFColor deleteColorWithName:kTestColorName];
}

#pragma mark - List storage

- (void)testListSaveLoadAndRemoveRoundTrip {
    ALUDataManager *manager = [ALUDataManager sharedDataManager];
    NSString *contents = @"Bananas\nApples\nCarrots";

    [manager addList:kTestListTitle];
    [manager saveList:contents withTitle:kTestListTitle];

    XCTAssertEqualObjects([manager listWithTitle:kTestListTitle], contents,
                          @"A saved list should read back exactly as written");
    XCTAssertTrue([[manager lists] containsObject:kTestListTitle],
                  @"A saved list should appear in the lists index");

    [manager removeList:kTestListTitle];
    XCTAssertFalse([[manager lists] containsObject:kTestListTitle],
                   @"A removed list should leave the lists index");
}

- (void)testPerListSettingsPersist {
    ALUDataManager *manager = [ALUDataManager sharedDataManager];
    [manager addList:kTestListTitle];
    [manager saveList:@"one\ntwo" withTitle:kTestListTitle];

    [manager setListMode:YES forListTitle:kTestListTitle];
    [manager setAlphabetize:YES forListTitle:kTestListTitle];
    XCTAssertTrue([manager listModeForListTitle:kTestListTitle]);
    XCTAssertTrue([manager alphabetizeForListTitle:kTestListTitle]);

    [manager setListMode:NO forListTitle:kTestListTitle];
    XCTAssertFalse([manager listModeForListTitle:kTestListTitle]);
}

#pragma mark - Rich text

- (void)testAttributedListRoundTripPreservesFormatting {
    ALUDataManager *manager = [ALUDataManager sharedDataManager];

    UIFont *boldFont = [UIFont boldSystemFontOfSize:17.0f];
    NSMutableAttributedString *note =
        [[NSMutableAttributedString alloc] initWithString:@"Pack the tent"
                                               attributes:@{NSFontAttributeName : boldFont}];
    [manager saveList:note.string withTitle:kTestRichTitle];
    [manager saveAttributedList:note withTitle:kTestRichTitle];

    NSAttributedString *restored = [manager attributedListWithTitle:kTestRichTitle];
    XCTAssertNotNil(restored, @"Rich text should read back after saving");
    XCTAssertEqualObjects(restored.string, note.string);

    UIFont *restoredFont = [restored attribute:NSFontAttributeName
                                       atIndex:0
                                effectiveRange:NULL];
    XCTAssertNotNil(restoredFont, @"The font attribute should survive the round trip");
    XCTAssertTrue(restoredFont.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold,
                  @"Bold formatting should survive the round trip");
}

#pragma mark - Monogram note icons

- (void)testMonogramIsGeneratedOnDevice {
    UIImage *icon = [[ALUDataManager sharedDataManager] imageForCompanyName:@"Groceries"];

    XCTAssertNotNil(icon, @"Every non-empty title should get a generated monogram icon");
    XCTAssertEqual(icon.size.width, 120.0f);
    XCTAssertEqual(icon.size.height, 120.0f);
}

- (void)testMonogramIsCachedPerTitle {
    ALUDataManager *manager = [ALUDataManager sharedDataManager];
    UIImage *first = [manager imageForCompanyName:@"Camping Trip"];
    UIImage *second = [manager imageForCompanyName:@"Camping Trip"];

    XCTAssertNotNil(first);
    XCTAssertTrue(first == second, @"Repeated lookups should return the cached image, not re-render");
}

- (void)testMonogramTileIsFilledWithTheBrandColor {
    NSString *title = @"Workout Plan";
    UIImage *icon = [[ALUDataManager sharedDataManager] imageForCompanyName:title];
    UIColor *expected = [NKFColor colorForCompanyName:title];
    XCTAssertNotNil(icon);
    XCTAssertNotNil(expected);

    CGFloat expectedRed = 0.0f, expectedGreen = 0.0f, expectedBlue = 0.0f, expectedAlpha = 0.0f;
    if (![expected getRed:&expectedRed green:&expectedGreen blue:&expectedBlue alpha:&expectedAlpha]) {
        return; // Non-RGB color space; nothing meaningful to compare against.
    }

    // Sample a point on the left edge at mid-height: inside the rounded tile, clear of the glyphs.
    unsigned char pixel[4] = {0, 0, 0, 0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, -8.0f, -60.0f);
    CGContextScaleCTM(context, icon.size.width / (icon.size.width * icon.scale),
                      icon.size.height / (icon.size.height * icon.scale));
    CGContextDrawImage(context,
                       CGRectMake(0, 0, icon.size.width * icon.scale, icon.size.height * icon.scale),
                       icon.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    XCTAssertGreaterThan(pixel[3], 0, @"The sampled point should be inside the opaque tile");
    XCTAssertEqualWithAccuracy(pixel[0] / 255.0, expectedRed, 0.04);
    XCTAssertEqualWithAccuracy(pixel[1] / 255.0, expectedGreen, 0.04);
    XCTAssertEqualWithAccuracy(pixel[2] / 255.0, expectedBlue, 0.04);
}

#pragma mark - Color engine

- (void)testBrandColorIsDeterministic {
    UIColor *first = [NKFColor colorForCompanyName:@"Apple"];
    UIColor *second = [NKFColor colorForCompanyName:@"Apple"];

    XCTAssertNotNil(first, @"Known brands should resolve to a color");
    XCTAssertEqualObjects(first, second, @"The same title must always produce the same color");
}

- (void)testAppColorsAreAvailable {
    NSArray *colors = [NKFColor appColors];
    XCTAssertGreaterThan(colors.count, 0);
    for (id color in colors) {
        XCTAssertTrue([color isKindOfClass:[UIColor class]]);
    }
}

- (void)testUserColorSaveAndDelete {
    NKFColor *color = [NKFColor colorWithRed:0.25f green:0.5f blue:0.75f alpha:1.0f];

    [NKFColor saveColor:color named:kTestColorName];
    XCTAssertNotNil([NKFColor userColors][kTestColorName],
                    @"A saved user color should appear in userColors");

    [NKFColor deleteColorWithName:kTestColorName];
    XCTAssertNil([NKFColor userColors][kTestColorName],
                 @"A deleted user color should leave userColors");
}

@end
