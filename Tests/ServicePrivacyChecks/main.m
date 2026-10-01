#import <Foundation/Foundation.h>
#import "ALUServicePrivacy.h"
int main(void) {
    @autoreleasepool {
        NSURLSessionConfiguration *config = ALUContentSessionConfiguration();
        NSCAssert(!config.HTTPShouldSetCookies && config.HTTPCookieAcceptPolicy == NSHTTPCookieAcceptPolicyNever, @"Cookies must stay off");
        NSCAssert(config.HTTPCookieStorage == nil && config.URLCredentialStorage == nil && config.URLCache == nil, @"No shared cookie, credential or response store");
        for (NSString *title in @[@"Bible Verse of the Day", @"Bible Verse Daily", @"Daily Bible Verse", @"Daily Scripture", @"Scripture Every Day", @"Scripture Daily", @"Verse of the Day", @"Verse Daily"]) {
            NSCAssert(ALUIsDailyBibleNoteTitle(title), @"Keep the existing daily Bible title aliases");
        }
        NSCAssert(!ALUIsDailyBibleNoteTitle(nil) && !ALUIsDailyBibleNoteTitle(@"Bible study notes"), @"Other notes must stay untouched");
        NSCAssert(ALUShouldAddDailyBibleLink(nil) && ALUShouldAddDailyBibleLink(@""), @"New and empty notes get a passage link");
        NSCAssert(ALUShouldAddDailyBibleLink(@"Old verse (NET)\nUser notes"), @"Historical notes can keep their content and get a link");
        NSCAssert(!ALUShouldAddDailyBibleLink([@"User notes\n" stringByAppendingString:ALUDailyBiblePassageURL().absoluteString]), @"Do not insert duplicate links");
        NSCAssert([ALUDailyBiblePassageURL().absoluteString isEqualToString:@"https://www.bible.com/verse-of-the-day"], @"Use the fixed external daily passage page");
        NSCAssert([ALUWebIconDomain(@"Apple") isEqualToString:@"apple.com"], @"Known brand maps to a bundled domain");
        NSCAssert([ALUWebIconDomain(@"Aston Villa") isEqualToString:@"avfc.co.uk"], @"Bundled paths are reduced to the host");
        NSCAssert([ALUWebIconDomain(@"apple.com") isEqualToString:@"apple.com"], @"Exact known domain works");
        for (NSString *privateTitle in @[@"My medical appointment", @"Private University", @"secret.example.com", @"apple.com/private-note", @"secret@apple.com", @"https://apple.com/?secret=1", @"Apple appointment 4pm"]) {
            NSCAssert(ALUWebIconRequest(privateTitle) == nil, @"Private titles and arbitrary URLs must never become outbound requests");
        }
        for (NSString *title in ALUBundledWebIconDomains()) {
            NSURLRequest *request = ALUWebIconRequest(title);
            if (!ALUWebIconDomain(title)) continue;
            NSCAssert([request.URL.scheme isEqualToString:@"https"] && [request.URL.host isEqualToString:ALUWebIconDomain(title)], @"Request the known originating website");
            NSCAssert([request.URL.path isEqualToString:@"/favicon.ico"] && request.URL.query == nil, @"No note content or lookup query is sent");
        }
        NSCAssert([ALUWebIconRequest(@"Apple").URL.absoluteString isEqualToString:@"https://apple.com/favicon.ico"], @"Use the originating website, not an icon service");
        puts("AtoZ checks passed: isolated favicon session, Bible title aliases and duplicate links, and direct-origin domain allowlist.");
    }
    return 0;
}
