#!/usr/bin/env python3
"""Compile actual editor line methods with a Foundation-only text-view adapter."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
source = (root / "Alphabetical List Utility/DetailViewController.m").read_text()

def method(name):
    start = source.index("- (void)" + name)
    opening = source.index("{", start)
    depth = 1
    end = opening + 1
    while depth:
        depth += (source[end] == "{") - (source[end] == "}")
        end += 1
    return source[start:end]

names = ["updateTextWithLineNumbersRange:", "removeListModeNumbersCurrentSelectedTextRange:", "alphabetizeList"]
if "- (void)rewriteListRange:" in source:
    names.insert(0, "rewriteListRange:")
methods = "\n".join(method(name) for name in names)
harness = r'''
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#define DLog(...) ((void)0)
#define UITextView TestTextView
static NSString * const numericDelimeter = @".) ";
static NSString * const NSAttachmentAttributeName = @"NSAttachment";
@interface TestTextView : NSObject
@property NSAttributedString *attributedText;
@property NSRange selectedRange;
@property NSDictionary *typingAttributes;
@property NSString *text;
@end
@implementation TestTextView
- (NSString *)text { return self.attributedText.string; }
- (void)setText:(NSString *)text { self.attributedText = [[NSAttributedString alloc] initWithString:text]; }
@end
@interface DetailViewController : NSObject
@property TestTextView *listItemTextView;
- (void)delayedScroll:(NSNumber *)value;
@end
@implementation DetailViewController
- (void)delayedScroll:(NSNumber *)value {}
// METHODS
@end
int main(void) { @autoreleasepool {
    DetailViewController *c = [DetailViewController new];
    c.listItemTextView = [TestTextView new];
    c.listItemTextView.typingAttributes = @{};
    NSObject *photo = [NSObject new];
    NSMutableAttributedString *note = [[NSMutableAttributedString alloc] initWithString:@"2.) Zebra \uFFFC\n1.) Apple"];
    [note addAttribute:NSAttachmentAttributeName value:photo range:[note.string rangeOfString:@"\uFFFC"]];
    [note addAttribute:@"UserStyle" value:@"bold" range:[note.string rangeOfString:@"Apple"]];
    c.listItemTextView.attributedText = note;
    c.listItemTextView.selectedRange = [note.string rangeOfString:@"Zebra"];
    [c alphabetizeList];
    NSAttributedString *sorted = c.listItemTextView.attributedText;
    NSCAssert([sorted attribute:NSAttachmentAttributeName atIndex:[sorted.string rangeOfString:@"\uFFFC"].location effectiveRange:nil] == photo, @"Sorting must preserve photo attachments");
    NSCAssert([[sorted attribute:@"UserStyle" atIndex:[sorted.string rangeOfString:@"Apple"].location effectiveRange:nil] isEqual:@"bold"], @"Sorting must preserve body formatting");
    NSCAssert([sorted.string isEqualToString:@"1.) Apple\n2.) Zebra \uFFFC"], @"Sorting must retain selected text and number complete lines");

    c.listItemTextView.attributedText = note; c.listItemTextView.selectedRange = NSMakeRange(0,0);
    [c updateTextWithLineNumbersRange:NSMakeRange(0,0) replacementText:@""];
    NSCAssert([c.listItemTextView.attributedText attribute:NSAttachmentAttributeName atIndex:[c.listItemTextView.text rangeOfString:@"\uFFFC"].location effectiveRange:nil] == photo, @"Renumbering must retain photos");
    NSRange apple = [c.listItemTextView.text rangeOfString:@"Apple"];
    c.listItemTextView.selectedRange = apple;
    [c updateTextWithLineNumbersRange:apple replacementText:@""];
    NSCAssert([c.listItemTextView.text containsString:@"Apple"], @"Reformatting must not delete the selected text");
    [c updateTextWithLineNumbersRange:NSMakeRange(c.listItemTextView.text.length,0) replacementText:@"\n"];
    NSCAssert([c.listItemTextView.text hasSuffix:@"\n3.) "], @"Return must create the next item");

    c.listItemTextView.text = @"abc.) keep\r\n9999.) Long\r\n\r\nPhoto";
    c.listItemTextView.selectedRange = NSMakeRange(0,0);
    [c removeListModeNumbersCurrentSelectedTextRange:NSMakeRange(0,0) replacementText:@""];
    NSCAssert([c.listItemTextView.text isEqualToString:@"abc.) keep\r\nLong\r\n\r\nPhoto"], @"Strip only numeric prefixes, preserving blank lines and CRLF");
    c.listItemTextView.text = @"2.) Zebra\r\n1.) Apple";
    [c alphabetizeList];
    NSCAssert([c.listItemTextView.text isEqualToString:@"1.) Apple\n2.) Zebra"], @"CRLF sorting must not invent blank items");
    NSAttributedString *before = c.listItemTextView.attributedText;
    [c updateTextWithLineNumbersRange:NSMakeRange(NSUIntegerMax,1) replacementText:@"\n"];
    NSCAssert([before isEqualToAttributedString:c.listItemTextView.attributedText], @"Invalid edit must leave content unchanged");
    c.listItemTextView.text = @"";
    [c updateTextWithLineNumbersRange:NSMakeRange(0,0) replacementText:@""];
    NSCAssert([c.listItemTextView.text isEqualToString:@"1.) "], @"Empty numbered note must have a safe first item");
    puts("PASS: actual line methods preserve photos, formatting, selections, literal text, blank lines and newlines; Return and range bounds checked.");
} return 0; }
'''.replace("// METHODS", methods)
with tempfile.TemporaryDirectory(prefix="atoz-line-check-") as directory:
    directory = Path(directory)
    path = directory / "main.m"
    path.write_text(harness)
    subprocess.run(["xcrun", "clang", "-fobjc-arc", "-fblocks", "-framework", "Foundation", str(path), "-o", str(directory / "check")], check=True)
    subprocess.run([str(directory / "check")], check=True)
