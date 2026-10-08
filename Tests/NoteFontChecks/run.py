#!/usr/bin/env python3
"""Exercise the production font transform with native macOS attributed strings."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
source = (root / "Alphabetical List Utility/DetailViewController.m").read_text()
start = source.index("static NSAttributedString *ALUScaleNoteFonts(")
opening = source.index("{", start)
depth, end = 1, opening + 1
while depth:
    depth += (source[end] == "{") - (source[end] == "}")
    end += 1
transform = source[start:end]
harness = r'''
#import <AppKit/AppKit.h>
#import <math.h>
#define UIFont NSFont
// TRANSFORM
int main(void) { @autoreleasepool {
    NSMutableAttributedString *original = [[NSMutableAttributedString alloc] initWithString:@"Bold italic link \uFFFC"];
    NSFont *bold = [NSFont boldSystemFontOfSize:16];
    NSFont *italic = [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:21] toHaveTrait:NSItalicFontMask];
    [original addAttribute:NSFontAttributeName value:bold range:NSMakeRange(0, 4)];
    [original addAttribute:NSFontAttributeName value:italic range:NSMakeRange(5, 6)];
    [original addAttribute:NSLinkAttributeName value:@"https://example.com" range:NSMakeRange(12, 4)];
    [original addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(5, 6)];
    NSTextAttachment *attachment = [NSTextAttachment new];
    [original addAttribute:NSAttachmentAttributeName value:attachment range:NSMakeRange(17, 1)];
    NSAttributedString *large = ALUScaleNoteFonts(original, 2.4);
    NSFont *scaledBold = [large attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
    NSFont *scaledItalic = [large attribute:NSFontAttributeName atIndex:5 effectiveRange:nil];
    NSCAssert(fabs(scaledBold.pointSize - 38.4) < 0.01, @"Scale a user's chosen size");
    NSCAssert(fabs(scaledItalic.pointSize - 50.4) < 0.01, @"Preserve distinct run sizes");
    NSCAssert(scaledBold.fontDescriptor.symbolicTraits & NSFontDescriptorTraitBold, @"Preserve bold");
    NSCAssert(scaledItalic.fontDescriptor.symbolicTraits & NSFontDescriptorTraitItalic, @"Preserve italic");
    NSCAssert([large attribute:NSAttachmentAttributeName atIndex:17 effectiveRange:nil] == attachment, @"Preserve inline media");
    NSCAssert([[large attribute:NSLinkAttributeName atIndex:12 effectiveRange:nil] isEqual:@"https://example.com"], @"Preserve links");
    NSCAssert([[large attribute:NSUnderlineStyleAttributeName atIndex:5 effectiveRange:nil] isEqual:@1], @"Preserve underline");
    NSAttributedString *canonical = ALUScaleNoteFonts(large, 1.0 / 2.4);
    NSCAssert([canonical isEqualToAttributedString:original], @"Reading preferences must not alter stored formatting");
    for (int i = 0; i < 20; i++) canonical = ALUScaleNoteFonts(ALUScaleNoteFonts(canonical, 1.352941176), 1.0 / 1.352941176);
    NSFont *roundTrip = [canonical attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
    NSCAssert(fabs(roundTrip.pointSize - 16) < 0.01, @"Repeated saves must not accumulate reading-size changes");
    NSCAssert(ALUScaleNoteFonts(original, NAN) == original, @"Invalid scale keeps original data");
    NSCAssert(ALUScaleNoteFonts(original, 0) == original, @"Zero scale keeps original data");
    NSCAssert(ALUScaleNoteFonts(nil, 2) == nil, @"Nil stays nil");
    NSCAssert(original.length == 18 && fabs(bold.pointSize - 16) < 0.01, @"Original stays unchanged");
    puts("PASS: production font scaling preserves mixed sizes, bold, italic, underline, links and attachments; canonical saves do not accumulate reading preferences.");
} return 0; }
'''.replace("// TRANSFORM", transform)
with tempfile.TemporaryDirectory(prefix="atoz-font-check-") as directory:
    directory = Path(directory)
    path = directory / "main.m"
    path.write_text(harness)
    subprocess.run(["xcrun", "clang", "-fobjc-arc", "-fblocks", "-framework", "AppKit", str(path), "-o", str(directory / "check")], check=True)
    subprocess.run([str(directory / "check")], check=True)
