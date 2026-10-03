#import <Foundation/Foundation.h>
#define UIImage NSObject
NSString * const ALUNoteIconDidLoadNotification = @"ALUNoteIconDidLoadNotification";
static NSMutableArray *pending;
@interface ALUImageGenerator : NSObject
+ (BOOL)isSupported;
+ (void)generateIconForNoteTitle:(NSString *)title completion:(void (^)(UIImage *))completion;
@end
@implementation ALUImageGenerator
+ (BOOL)isSupported { return YES; }
+ (void)generateIconForNoteTitle:(NSString *)title completion:(void (^)(UIImage *))completion { [pending addObject:[completion copy]]; }
@end
static void complete(BOOL withImage) { void (^callback)(UIImage *) = pending.firstObject; NSCAssert(callback != nil, @"Expected a real queued provider callback"); [pending removeObjectAtIndex:0]; callback(withImage ? [NSObject new] : nil); }
@interface ALUDataManager : NSObject {
    NSMutableArray *_lists, *_playgroundQueue;
    NSMutableSet *_playgroundAttempted;
    BOOL _playgroundGenerating;
}
@property NSMutableDictionary *images;
@property NSMutableSet *hidden;
@property BOOL webEnabled;
@property NSUInteger writes;
- (void)generatePlaygroundIconIfNeededForCompanyName:(NSString *)name;
- (void)processPlaygroundQueue;
- (BOOL)imageSavedLocallyForCompanyName:(NSString *)name;
- (BOOL)showImageForListTitle:(NSString *)name;
- (BOOL)useWebIconForListTitle:(NSString *)name;
- (void)saveImage:(UIImage *)image forCompanyName:(NSString *)name;
- (void)removeNote:(NSString *)name;
- (BOOL)isIdle;
@end
@implementation ALUDataManager
- (instancetype)init { if ((self = [super init])) { _lists = [@[@"First", @"Second"] mutableCopy]; _images = [NSMutableDictionary new]; _hidden = [NSMutableSet new]; } return self; }
- (BOOL)imageSavedLocallyForCompanyName:(NSString *)name { return self.images[name] != nil; }
- (BOOL)showImageForListTitle:(NSString *)name { return ![self.hidden containsObject:name]; }
- (BOOL)useWebIconForListTitle:(NSString *)name { return self.webEnabled; }
- (void)saveImage:(UIImage *)image forCompanyName:(NSString *)name { self.images[name] = image; self.writes += 1; }
- (void)removeNote:(NSString *)name { [_lists removeObject:name]; }
- (BOOL)isIdle { return !_playgroundGenerating && _playgroundQueue.count == 0; }
// PRODUCTION_METHODS
@end
static ALUDataManager *startTwo(void) { pending = [NSMutableArray new]; ALUDataManager *m = [ALUDataManager new]; [m generatePlaygroundIconIfNeededForCompanyName:@"First"]; [m generatePlaygroundIconIfNeededForCompanyName:@"Second"]; NSCAssert(pending.count == 1, @"Only one provider request may be in flight"); return m; }
int main(void) { @autoreleasepool {
    ALUDataManager *m = startTwo(); complete(YES); NSCAssert(m.writes == 1 && pending.count == 1, @"Web icons off must not reject on-device images or strand the next note"); complete(YES); NSCAssert(m.writes == 2 && m.isIdle, @"Successful generation must drain both notes");
    m = startTwo(); NSObject *chosen = [NSObject new]; m.images[@"First"] = chosen; complete(YES); NSCAssert(m.images[@"First"] == chosen && m.writes == 0 && pending.count == 1, @"An in-flight generated image must not replace a chosen icon; queue must continue"); complete(NO); NSCAssert(m.isIdle, @"Nil response must release the queue");
    m = startTwo(); [m.hidden addObject:@"First"]; complete(YES); NSCAssert(m.writes == 0 && pending.count == 1, @"Turning icons off must suppress stale output without stranding the queue"); complete(NO); NSCAssert(m.isIdle, @"Hidden-note completion must release the queue");
    m = startTwo(); [m removeNote:@"First"]; complete(YES); NSCAssert(m.writes == 0 && pending.count == 1, @"Deleted note must not acquire a new orphan icon; queue must continue"); complete(NO); NSCAssert(m.isIdle, @"Deleted-note completion must release the queue");
    puts("PASS: actual production generation methods handle web-off, chosen icons, hidden/deleted notes, nil responses and queue continuation.");
} return 0; }
