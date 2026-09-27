#import <Foundation/Foundation.h>
#import "ALUServicePrivacy.h"
int main(void) {
    @autoreleasepool {
        NSURLSessionConfiguration *config = ALUContentSessionConfiguration();
        NSCAssert(!config.HTTPShouldSetCookies && config.HTTPCookieAcceptPolicy == NSHTTPCookieAcceptPolicyNever, @"Cookies must stay off");
        NSCAssert(config.HTTPCookieStorage == nil && config.URLCredentialStorage == nil && config.URLCache == nil, @"No shared cookie, credential or response store");
        NSCAssert(ALUShouldPrependVerse(nil, @"Verse (NET)"), @"New notes must receive the first verse");
        NSCAssert(ALUShouldPrependVerse(@"", @"Verse (NET)"), @"Empty notes must receive the first verse");
        NSCAssert(ALUShouldPrependVerse(@"Existing note", @"Verse (NET)"), @"Keep existing text and add the verse");
        NSCAssert(!ALUShouldPrependVerse(@"Date\nVerse (NET)\nOlder notes", @"Verse (NET)"), @"Do not repeat an existing verse");
        NSCAssert(!ALUShouldPrependVerse(@"Existing", @" \n "), @"No empty payloads");
        NSCAssert(ALUValidVersePayload(@{@"bookname":@"Psalms", @"chapter":@"94", @"verse":@14, @"text":@"Example"}), @"Provider's string numbers are valid");
        NSCAssert(!ALUValidVersePayload(@{@"bookname":@"Psalms", @"chapter":NSNull.null, @"verse":@14, @"text":@"Example"}), @"Null chapter must not crash");
        NSCAssert(!ALUValidVersePayload(@{@"bookname":@"Psalms", @"chapter":@94, @"verse":@14, @"text":@[]}), @"Invalid text must not crash");
        NSCAssert(!ALUValidVersePayload(@{}), @"Reject empty results");
        NSCAssert([ALUWebIconDomain(@"Apple") isEqualToString:@"apple.com"], @"Known brand maps to a bundled domain");
        NSCAssert([ALUWebIconDomain(@"Aston Villa") isEqualToString:@"avfc.co.uk"], @"Bundled paths are reduced to the host");
        NSCAssert([ALUWebIconDomain(@"apple.com") isEqualToString:@"apple.com"], @"Exact known domain works");
        for (NSString *privateTitle in @[@"My medical appointment", @"Private University", @"secret.example.com", @"apple.com/private-note", @"secret@apple.com", @"https://apple.com/?secret=1", @"Apple appointment 4pm"]) {
            NSCAssert(ALUWebIconRequest(privateTitle) == nil, @"Private titles and arbitrary URLs must never become outbound requests");
        }
        NSCAssert([ALUWebIconRequest(@"Apple").URL.absoluteString containsString:@"domain=apple.com"], @"Request sends only the matched domain");
        puts("AtoZ checks passed: isolated public-content session, first/empty note, duplicate verse, invalid provider payload and outbound domain allowlist.");
    }
    return 0;
}
