#import <Foundation/Foundation.h>

// Public content requests do not need account cookies, saved credentials or a disk cache.
static inline NSURLSessionConfiguration *ALUContentSessionConfiguration(void) {
    NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
    configuration.HTTPCookieStorage = nil;
    configuration.HTTPShouldSetCookies = NO;
    configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
    configuration.URLCredentialStorage = nil;
    configuration.URLCache = nil;
    configuration.timeoutIntervalForRequest = 20;
    configuration.timeoutIntervalForResource = 30;
    return configuration;
}

static inline NSURLSession *ALUContentSession(void) {
    static NSURLSession *session;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ session = [NSURLSession sessionWithConfiguration:ALUContentSessionConfiguration()]; });
    return session;
}

static inline NSURL *ALUDailyBiblePassageURL(void) {
    return [NSURL URLWithString:@"https://www.bible.com/verse-of-the-day"];
}

static inline BOOL ALUIsDailyBibleNoteTitle(NSString *title) {
    NSString *key = [[[title lowercaseString] componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] componentsJoinedByString:@""];
    for (NSString *alias in @[@"bibleverseoftheday", @"bibleversedaily", @"dailybibleverse", @"dailyscripture", @"scriptureeveryday", @"scripturedaily", @"verseoftheday", @"versedaily"]) {
        if ([key containsString:alias]) return YES;
    }
    return NO;
}

static inline BOOL ALUShouldAddDailyBibleLink(NSString *existing) {
    return ![existing containsString:ALUDailyBiblePassageURL().absoluteString];
}

// This is the complete outbound allowlist. Never derive an outbound domain from a title.
static inline NSDictionary<NSString *, NSString *> *ALULegacyForwardingDomains(void) {
    return @{@"volcano"			: @"volcanocorp.com",
                                      @"welcome"			: @"nathanfennel.com",
                                      @"massachusetts"		: @"mass.gov",
                                      @"arizona"			: @"az.gov",
                                      @"jets"				: @"newyorkjets.com",
                                      @"astonvilla"			: @"avfc.co.uk/",
                                      @"atlantahawks"		: @"hawks.com",
                                      @"vikings"			: @"vikings",
                                      @"bostonceltics"		: @"celtics.com",
                                      @"sacramentokings"	: @"kings.com",
                                      @"kings"				: @"lakings.com",
                                      @"seattleseahawks"	: @"seahawks.com",
                                      @"ravens"				: @"baltimoreravens.com",
                                      @"carolinapanthers"	: @"panthers.com",
                                      @"houstontexans"		: @"texans.com",
                                      @"indianapoliscolts"	: @"colts.com",
                                      @"greenbaypackers"	: @"packers.com",
                                      @"newenglandpatriots"	: @"patriots.com",
                                      @"minnesotavikings"	: @"vikings.com",
                                      @"saints"				: @"neworleanssaints.com",
                                      @"oaklandraiders"		: @"raiders.com",
                                      @"pittsburgsteelers"	: @"steelers.com",
                                      @"sandiegochargers"	: @"chargers.com",
                                      @"sdchargers"			: @"chargers.com",
                                      @"mexico"				: @"presidencia.gob.mx/",
                                      @"california"			: @"ca.gov",
                                      @"sanfrancisco49ers"	: @"49ers.com",
                                      @"49ers"				: @"49ers.com",
                                      @"rams"				: @"stlouisrams.com",
                                      @"tampabaybuccaneers"	: @"buccaneers.com",
                                      @"anaheimducks"		: @"ducks.nhl.com",
                                      @"bruins"				: @"bostonbruins.com",
                                      @"oilers"				: @"edmontonoilers.com",
                                      @"minnesotawild"		: @"wild.com",
                                      @"mapleleafs"			: @"torontomapleleafs.com",
                                      @"neworleanspelicans"	: @"pelicans.com",
                                      @"goldenstatewarriors": @"warriors.com",
                                      @"laclippers"			: @"clippers.com",
                                      @"losangelesclippers"	: @"clippers.com",
                                      @"mets"				: @"newyork.mets.mlb.com",
                                      @"padres"				: @"padres.com",
                                      @"sandiegopadres"		: @"padres.com",
                                      @"oaklandas"			: @"oaklandathletics.com",
                                      @"anaheimangels"		: @"angels.com",
                                      @"miamimarlins"		: @"marlins.com",
                                      @"chicagocubs"		: @"cubs.com",
                                      @"coloradorockies"	: @"coloradorockies.com",
                                      @"baltimoreorioles"	: @"orioles.com",
                                      @"hotspur"			: @"tottenhamhotspur.com",
                                      @"meh"				: @"meh.com",
                                      @"amazon"				: @"amazon.com",
                                      @"amazonbook"			: @"amazon.com",
                                      @"windows"            : @"microsoft.com",
                                      @"ace"                : @"acehardware.com",
                                      @"luckys"             : @"luckysmarket.com",
                                      @"harvard"            : @"harvard.edu",
                                      @"apu"                : @"apu.edu",
                                      @"calpoly"            : @"calpoly.edu",
                                      @"ucla"               : @"ucla.edu",
                                      @"usc"                : @"usc.edu",
									  @"bible"              : @"bible.com",
									  @"bibleverseoftheday" : @"bible.com",
									  @"bibleversedaily"	: @"bible.com",
									  @"dailybibleverse"    : @"bible.com",
									  @"dailyscripture"		: @"bible.com",
									  @"scriptureeveryday"  : @"bible.com",
									  @"versedaily"			: @"bible.com",
									  @"verseoftheday"      : @"bible.com",
									  @"scripturedaily"     : @"bible.com",
									  @"mit"                : @"mit.edu",
                                      @"darntoughsocks"		: @"darntough.com",
                                      @"ohiostate"          : @"osu.edu",
                                      @"ohiostateuniversity": @"osu.edu",
                                      @"michiganstateuniversity":@"msu.edu",
                                      @"michiganstate"      : @"msu.edu",
                                      @"mississippistate"   : @"mssstate.edu",
									  @"pier1imports"		: @"pier1.com",
									  @"worldmark"			: @"worldmarkbywyndham.com",
                                      @"peetscoffeeandtea"  : @"peets.com",
                                      @"peetscoffee"        : @"peets.com",
                                      @"innout"             : @"in-n-out.com",
                                      @"northeastern"       : @"northeastern.edu",
                                      @"northwestern"       : @"northwestern.edu",
                                      @"northeasternuniversity": @"northeastern.edu",
                                      @"northwesternuniversity": @"northwestern.edu",
									  @"americanairlines"	: @"aa.com",
									  @"wholefoods"			: @"wholefoodsmarket.com",
									  @"unity"				: @"unity3d.com",
									  @"aandw"				: @"awrestaurants.com",
									  @"aw"					: @"awrestaurants.com",
									  @"oculusrift"			: @"oculus.com",
									  @"benandjerrys"		: @"benjerry.com",
									  @"benjerrys"			: @"benjerry.com",
									  @"californiapizzakitchen":@"cpk.com"};
}

static inline NSDictionary<NSString *, NSString *> *ALUBundledWebIconDomains(void) {
    static NSDictionary *domains;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSMutableDictionary *known = [ALULegacyForwardingDomains() mutableCopy];
        [known addEntriesFromDictionary:@{@"apple": @"apple.com", @"google": @"google.com", @"microsoft": @"microsoft.com", @"spotify": @"spotify.com", @"netflix": @"netflix.com", @"github": @"github.com", @"youtube": @"youtube.com", @"facebook": @"facebook.com", @"instagram": @"instagram.com"}];
        domains = [known copy];
    });
    return domains;
}

static inline NSString *ALUWebIconDomain(NSString *title) {
    if (title.length == 0) return nil;
    NSDictionary *domains = ALUBundledWebIconDomains();
    NSString *key = [[[title lowercaseString] componentsSeparatedByCharactersInSet:
        [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789"] invertedSet]] componentsJoinedByString:@""];
    NSString *candidate = domains[key];
    // An exact known domain is also allowed. URL paths, credentials, and private
    // subdomains are not inferred, matched by suffix, or copied into the request.
    if (!candidate) {
        NSString *literal = [[title stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] lowercaseString];
        for (NSString *known in domains.allValues) {
            NSString *host = [NSURLComponents componentsWithString:[@"https://" stringByAppendingString:known]].host;
            if ([host isEqualToString:literal]) { candidate = known; break; }
        }
    }
    if (!candidate) return nil;
    NSString *host = [NSURLComponents componentsWithString:[@"https://" stringByAppendingString:candidate]].host;
    return [host containsString:@"."] ? host : nil;
}

static inline NSURLRequest *ALUWebIconRequest(NSString *title) {
    NSString *domain = ALUWebIconDomain(title);
    if (!domain) return nil;
    return [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/favicon.ico", domain]]];
}
