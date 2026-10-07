#!/usr/bin/env python3
"""Compile the production polish methods with Foundation-only editor/model adapters."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
source = (root / "Alphabetical List Utility/DetailViewController.m").read_text()
start = source.index("// Run the note through Apple's on-device foundation model.")
end = source.index("#pragma mark - Writing Tools", start)
methods = source[start:end]
harness = r'''
#import <Foundation/Foundation.h>
#define UITextView TestTextView
#define DLog(...) ((void)0)
static NSString * const NSAttachmentAttributeName = @"NSAttachment";
static NSMutableArray *pending;
@interface TestTextView : NSObject
@property NSAttributedString *attributedText;
@property NSDictionary *typingAttributes;
@property NSUndoManager *undoManager;
@property NSString *text;
@property NSRange selectedRange;
@end
@implementation TestTextView
- (instancetype)init { if ((self = [super init])) { _typingAttributes = @{}; _undoManager = [NSUndoManager new]; } return self; }
- (NSString *)text { return self.attributedText.string; }
- (void)setText:(NSString *)text { self.attributedText = [[NSAttributedString alloc] initWithString:text]; }
@end
@interface TestButton : NSObject
@property BOOL enabled;
@end
@implementation TestButton
@end
@interface ALUNotePolisher : NSObject
+ (void)polishNote:(NSString *)text completion:(void (^)(NSString *, NSError *))completion;
@end
@implementation ALUNotePolisher
+ (void)polishNote:(NSString *)text completion:(void (^)(NSString *, NSError *))completion { [pending addObject:[completion copy]]; }
@end
@interface DetailViewController : NSObject {
    NSString *_detailItem;
    BOOL _noteWasDeleted, _isPolishingNote;
}
@property TestTextView *listItemTextView;
@property TestButton *polishButton;
@property NSUInteger writes;
- (BOOL)canPolishNote;
- (void)polishNoteOnDevice;
- (void)tidyNoteFormatting;
- (void)replaceNoteTextWithPolishedText:(NSString *)text originalText:(NSAttributedString *)original;
- (void)saveList;
- (void)switchNote;
- (void)deleteNote;
@end
@implementation DetailViewController
- (instancetype)init { if ((self = [super init])) { _detailItem = @"First"; _listItemTextView = [TestTextView new]; _listItemTextView.text = @"  buy bread  "; _polishButton = [TestButton new]; _polishButton.enabled = YES; } return self; }
- (void)saveList { self.writes++; }
- (void)switchNote { _detailItem = @"Second"; }
- (void)deleteNote { _noteWasDeleted = YES; }
// PRODUCTION_METHODS
@end
static void complete(NSString *result) { void (^callback)(NSString *, NSError *) = pending.firstObject; NSCAssert(callback, @"Expected provider callback"); [pending removeObjectAtIndex:0]; callback(result, nil); }
static DetailViewController *fresh(void) { pending = [NSMutableArray new]; return [DetailViewController new]; }
int main(void) { @autoreleasepool {
    DetailViewController *c = fresh();
    NSMutableAttributedString *photoNote = [[NSMutableAttributedString alloc] initWithString:@"  picnic \uFFFC  "];
    [photoNote addAttribute:NSAttachmentAttributeName value:[NSObject new] range:NSMakeRange(9, 1)];
    c.listItemTextView.attributedText = photoNote;
    [c tidyNoteFormatting];
    NSCAssert([c.listItemTextView.attributedText isEqualToAttributedString:photoNote] && c.writes == 0, @"Formatting must retain embedded photo attributes");
    [c polishNoteOnDevice];
    NSCAssert(pending.count == 0, @"Text-only provider must not receive a photo note");

    c = fresh(); [c polishNoteOnDevice]; [c polishNoteOnDevice];
    NSCAssert(pending.count == 1, @"Repeated polish must not queue overlapping rewrites");
    complete(@"Buy bread");
    NSCAssert([c.listItemTextView.text isEqualToString:@"Buy bread"] && c.writes == 1 && c.polishButton.enabled, @"Unchanged text note must still polish and save");

    for (NSUInteger scenario = 0; scenario < 5; scenario++) {
        c = fresh(); [c polishNoteOnDevice];
        if (scenario == 0) c.listItemTextView.text = @"New edits";
        if (scenario == 1) [c switchNote];
        if (scenario == 2) [c deleteNote];
        if (scenario == 3) c.listItemTextView.attributedText = photoNote;
        if (scenario == 4) c.listItemTextView.attributedText = [[NSAttributedString alloc] initWithString:c.listItemTextView.text attributes:@{@"UserFormat": @"new"}];
        NSAttributedString *current = [c.listItemTextView.attributedText copy];
        complete(@"Old model result");
        NSCAssert([c.listItemTextView.attributedText isEqualToAttributedString:current] && c.writes == 0, @"Delayed result must not overwrite edits, another note, deletion, photo or formatting");
    }
    c = fresh(); [c polishNoteOnDevice]; c.listItemTextView.text = @"  keep new edits  "; complete(nil);
    NSCAssert([c.listItemTextView.text isEqualToString:@"  keep new edits  "] && c.writes == 0, @"Failed stale request must not tidy new edits");
    c = fresh(); [c polishNoteOnDevice]; complete(nil);
    NSCAssert([c.listItemTextView.text isEqualToString:@"Buy bread"] && c.writes == 1, @"Unchanged failure must retain deterministic fallback");
    c = fresh();
    NSMutableAttributedString *styled = [[NSMutableAttributedString alloc] initWithString:@"  * buy NASA tickets  \r\n\r\n\r\n  call zoë  "];
    [styled addAttribute:@"UserStyle" value:@"bold" range:[styled.string rangeOfString:@"NASA"]];
    [styled addAttribute:@"UserStyle" value:@"italic" range:[styled.string rangeOfString:@"zoë"]];
    c.listItemTextView.attributedText = styled;
    [c.listItemTextView.undoManager beginUndoGrouping];
    [c tidyNoteFormatting];
    [c.listItemTextView.undoManager endUndoGrouping];
    NSAttributedString *tidy = c.listItemTextView.attributedText;
    NSCAssert([tidy.string isEqualToString:@"• Buy NASA tickets\n\nCall zoë"], @"Fallback must trim, normalize bullets, capitalize and retain one paragraph break with CRLF");
    NSCAssert([[tidy attribute:@"UserStyle" atIndex:[tidy.string rangeOfString:@"NASA"].location effectiveRange:nil] isEqual:@"bold"], @"Fallback must preserve bold body text");
    NSCAssert([[tidy attribute:@"UserStyle" atIndex:[tidy.string rangeOfString:@"zoë"].location effectiveRange:nil] isEqual:@"italic"], @"Fallback must preserve italic body text");
    NSCAssert(c.listItemTextView.undoManager.canUndo, @"Fallback must offer Undo");
    [c.listItemTextView.undoManager undo];
    NSCAssert([c.listItemTextView.attributedText isEqualToAttributedString:styled], @"Undo must restore exact styled content");
    puts("PASS: production polishing preserves attachments, edits, note identity, deletion and formatting; reentry, success and fallback checked.");
} return 0; }
'''.replace("// PRODUCTION_METHODS", methods)
with tempfile.TemporaryDirectory(prefix="atoz-polish-check-") as directory:
    directory = Path(directory)
    path = directory / "main.m"
    path.write_text(harness)
    subprocess.run(["xcrun", "clang", "-fobjc-arc", "-fblocks", "-framework", "Foundation", str(path), "-o", str(directory / "check")], check=True)
    subprocess.run([str(directory / "check")], check=True)
