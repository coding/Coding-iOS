//
//  iVersion.m
//
//  Version 1.11.4
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/iVersion
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "iVersion.h"


#pragma clang diagnostic ignored "-Wreceiver-is-weak"
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
#pragma clang diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
#pragma clang diagnostic ignored "-Wunused-macros"
#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wselector"
#pragma clang diagnostic ignored "-Wshadow"
#pragma clang diagnostic ignored "-Wgnu"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


NSString *const iVersionErrorDomain = @"iVersionErrorDomain";

NSString *const iVersionInThisVersionTitleKey = @"iVersionInThisVersionTitle";
NSString *const iVersionUpdateAvailableTitleKey = @"iVersionUpdateAvailableTitle";
NSString *const iVersionVersionLabelFormatKey = @"iVersionVersionLabelFormat";
NSString *const iVersionOKButtonKey = @"iVersionOKButton";
NSString *const iVersionIgnoreButtonKey = @"iVersionIgnoreButton";
NSString *const iVersionRemindButtonKey = @"iVersionRemindButton";
NSString *const iVersionDownloadButtonKey = @"iVersionDownloadButton";

static NSString *const iVersionAppStoreIDKey = @"iVersionAppStoreID";
static NSString *const iVersionLastVersionKey = @"iVersionLastVersionChecked";
static NSString *const iVersionIgnoreVersionKey = @"iVersionIgnoreVersion";
static NSString *const iVersionLastCheckedKey = @"iVersionLastChecked";
static NSString *const iVersionLastRemindedKey = @"iVersionLastReminded";

static NSString *const iVersionMacAppStoreBundleID = @"com.apple.appstore";
static NSString *const iVersionAppLookupURLFormat = @"http://itunes.apple.com/%@/lookup";

static NSString *const iVersioniOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@";
static NSString *const iVersionMacAppStoreURLFormat = @"macappstore://itunes.apple.com/app/id%@";


#define SECONDS_IN_A_DAY 86400.0
#define MAC_APP_STORE_REFRESH_DELAY 5.0
#define REQUEST_TIMEOUT 60.0


@implementation NSString(iVersion)

- (NSComparisonResult)compareVersion:(NSString *)version
{
    return [self compare:version options:NSNumericSearch];
}

- (NSComparisonResult)compareVersionDescending:(NSString *)version
{
    return (NSComparisonResult)(0 - [self compareVersion:version]);
}

@end


@interface iVersion ()

@property (nonatomic, copy) NSDictionary *remoteVersionsDict;
@property (nonatomic, strong) NSError *downloadError;
@property (nonatomic, copy) NSString *versionDetails;
@property (nonatomic, strong) id visibleLocalAlert;
@property (nonatomic, strong) id visibleRemoteAlert;
@property (nonatomic, assign) BOOL checkingForNewVersion;

@end


@implementation iVersion

+ (void)load
{
    [self performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:NO];
}

+ (iVersion *)sharedInstance
{
    static iVersion *sharedInstance = nil;
    if (sharedInstance == nil)
    {
        sharedInstance = [[iVersion alloc] init];
    }
    return sharedInstance;
}

- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"iVersion" ofType:@"bundle"];
        if (self.useAllAvailableLanguages)
        {
            bundle = [NSBundle bundleWithPath:bundlePath];
            NSString *language = [[NSLocale preferredLanguages] count]? [NSLocale preferredLanguages][0]: @"en";
            if (![[bundle localizations] containsObject:language])
            {
                language = [language componentsSeparatedByString:@"-"][0];
            }
            if ([[bundle localizations] containsObject:language])
            {
                bundlePath = [bundle pathForResource:language ofType:@"lproj"];
            }
        }
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

- (iVersion *)init
{
    if ((self = [super init]))
    {
        
#if TARGET_OS_IPHONE
        
        //register for iphone application events
        if (&UIApplicationWillEnterForegroundNotification)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationWillEnterForeground)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
#endif
        
        //get country
        self.appStoreCountry = [(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        if ([self.appStoreCountry isEqualToString:@"150"])
        {
            self.appStoreCountry = @"eu";
        }
        else if ([[self.appStoreCountry stringByReplacingOccurrencesOfString:@"[A-Za-z]{2}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, 2)] length])
        {
            self.appStoreCountry = @"us";
        }
        
        //application version (use short version preferentially)
        self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if ([self.applicationVersion length] == 0)
        {
            self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        }
        
        //bundle id
        self.applicationBundleID = [[NSBundle mainBundle] bundleIdentifier];
        
        //default settings
        self.updatePriority = iVersionUpdatePriorityDefault;
        self.useAllAvailableLanguages = YES;
        self.onlyPromptIfMainWindowIsAvailable = YES;
        self.checkAtLaunch = YES;
        self.checkPeriod = 0.0f;
        self.remindPeriod = 1.0f;
        
#ifdef DEBUG
        
        //enable verbose logging in debug mode
        self.verboseLogging = YES;
        
#endif
        
        //app launched
        [self performSelectorOnMainThread:@selector(applicationLaunched) withObject:nil waitUntilDone:NO];
    }
    return self;
}

- (id<iVersionDelegate>)delegate
{
    if (_delegate == nil)
    {
        
#if TARGET_OS_IPHONE
#define APP_CLASS UIApplication
#else
#define APP_CLASS NSApplication
#endif
        
        _delegate = (id<iVersionDelegate>)[[APP_CLASS sharedApplication] delegate];
    }
    return _delegate;
}

- (NSString *)inThisVersionTitle
{
    return _inThisVersionTitle ?: [self localizedStringForKey:iVersionInThisVersionTitleKey withDefault:@"New in this version"];
}

- (NSString *)updateAvailableTitle
{
    return _updateAvailableTitle ?: [self localizedStringForKey:iVersionUpdateAvailableTitleKey withDefault:@"New version available"];
}

- (NSString *)versionLabelFormat
{
    return _versionLabelFormat ?: [self localizedStringForKey:iVersionVersionLabelFormatKey withDefault:@"Version %@"];
}

- (NSString *)okButtonLabel
{
    return _okButtonLabel ?: [self localizedStringForKey:iVersionOKButtonKey withDefault:@"OK"];
}

- (NSString *)ignoreButtonLabel
{
    return _ignoreButtonLabel ?: [self localizedStringForKey:iVersionIgnoreButtonKey withDefault:@"Ignore"];
}

- (NSString *)downloadButtonLabel
{
    return _downloadButtonLabel ?: [self localizedStringForKey:iVersionDownloadButtonKey withDefault:@"Download"];
}

- (NSString *)remindButtonLabel
{
    return _remindButtonLabel ?: [self localizedStringForKey:iVersionRemindButtonKey withDefault:@"Remind Me Later"];
}

- (NSURL *)updateURL
{
    if (_updateURL)
    {
        return _updateURL;
    }
    
    if (!self.appStoreID)
    {
        NSLog(@"iVersion error: No App Store ID was found for this application. If the application is not intended for App Store release then you must specify a custom updateURL.");
    }
    
#if TARGET_OS_IPHONE
    
    return [NSURL URLWithString:[NSString stringWithFormat:iVersioniOSAppStoreURLFormat, @(self.appStoreID)]];
    
#else
    
    return [NSURL URLWithString:[NSString stringWithFormat:iVersionMacAppStoreURLFormat, @(self.appStoreID)]];
    
#endif
    
}

- (NSUInteger)appStoreID
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:iVersionAppStoreIDKey] unsignedIntegerValue];
}

- (void)setAppStoreID:(NSUInteger)appStoreID
{
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)appStoreID forKey:iVersionAppStoreIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)lastChecked
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastCheckedKey];
}

- (void)setLastChecked:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:iVersionLastCheckedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)lastReminded
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastRemindedKey];
}

- (void)setLastReminded:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:iVersionLastRemindedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)ignoredVersion
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:iVersionIgnoreVersionKey];
}

- (void)setIgnoredVersion:(NSString *)version
{
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:iVersionIgnoreVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)viewedVersionDetails
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastVersionKey] isEqualToString:self.applicationVersion];
}

- (void)setViewedVersionDetails:(BOOL)viewed
{
    [[NSUserDefaults standardUserDefaults] setObject:(viewed? self.applicationVersion: nil) forKey:iVersionLastVersionKey];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)lastVersion
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:iVersionLastVersionKey];
}

- (void)setLastVersion:(NSString *)version
{
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:iVersionLastVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)localVersionsDict
{
    static NSDictionary *versionsDict = nil;
    if (versionsDict == nil)
    {
        if (self.localVersionsPlistPath == nil)
        {
            versionsDict = [[NSDictionary alloc] init]; //empty dictionary
        }
        else
        {
            NSString *versionsFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.localVersionsPlistPath];
            versionsDict = [[NSDictionary alloc] initWithContentsOfFile:versionsFile];
            if (!versionsDict)
            {
                // Get the path to versions plist in localized directory
                NSArray *pathComponents = [self.localVersionsPlistPath componentsSeparatedByString:@"."];
                versionsFile = ([pathComponents count] == 2) ? [[NSBundle mainBundle] pathForResource:pathComponents[0] ofType:pathComponents[1]] : nil;
                versionsDict = [[NSDictionary alloc] initWithContentsOfFile:versionsFile];
            }
        }
    }
    return versionsDict;
}

- (NSString *)mostRecentVersionInDict:(NSDictionary *)dict
{
    return [[[dict allKeys] sortedArrayUsingSelector:@selector(compareVersion:)] lastObject];
}

- (NSString *)versionDetails:(NSString *)version inDict:(NSDictionary *)dict
{
    id versionData = dict[version];
    if ([versionData isKindOfClass:[NSString class]])
    {
        return versionData;
    }
    else if ([versionData isKindOfClass:[NSArray class]])
    {
        return [versionData componentsJoinedByString:@"\n"];
    }
    return nil;
}

- (NSString *)versionDetailsSince:(NSString *)lastVersion inDict:(NSDictionary *)dict
{
    if (self.previewMode)
    {
        lastVersion = @"0";
    }
    BOOL newVersionFound = NO;
    NSMutableString *details = [NSMutableString string];
    NSArray *versions = [[dict allKeys] sortedArrayUsingSelector:@selector(compareVersionDescending:)];
    for (NSString *version in versions)
    {
        if ([version compareVersion:lastVersion] == NSOrderedDescending)
        {
            newVersionFound = YES;
            if (self.groupNotesByVersion)
            {
                [details appendString:[self.versionLabelFormat stringByReplacingOccurrencesOfString:@"%@" withString:version]];
                [details appendString:@"\n\n"];
            }
            [details appendString:[self versionDetails:version inDict:dict] ?: @""];
            [details appendString:@"\n"];
            if (self.groupNotesByVersion)
            {
                [details appendString:@"\n"];
            }
        }
    }
    return newVersionFound? [details stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]: nil;
}

- (NSString *)versionDetails
{
    if (!_versionDetails)
    {
        if (self.viewedVersionDetails)
        {
            self.versionDetails = [self versionDetails:self.applicationVersion inDict:[self localVersionsDict]];
        }
        else
        {
            self.versionDetails = [self versionDetailsSince:self.lastVersion inDict:[self localVersionsDict]];
        }
    }
    return _versionDetails;
}

- (NSString *)URLEncodedString:(NSString *)string
{
    CFStringRef stringRef = CFBridgingRetain(string);
    CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  stringRef,
                                                                  NULL,
                                                                  CFSTR("!*'\"();:@&=+$,/?%#[]% "),
                                                                  kCFStringEncodingUTF8);
    CFRelease(stringRef);
    return CFBridgingRelease(encoded);
}

- (void)downloadedVersionsData
{
    
#if !TARGET_OS_IPHONE
    
    //only show when main window is available
    if (self.onlyPromptIfMainWindowIsAvailable && ![[NSApplication sharedApplication] mainWindow])
    {
        [self performSelector:@selector(downloadedVersionsData) withObject:nil afterDelay:0.5];
        return;
    }
    
#endif
    
    if (self.checkingForNewVersion)
    {
        //no longer checking
        self.checkingForNewVersion = NO;
    
        //check if data downloaded
        if (!self.remoteVersionsDict)
        {
            //log the error
            if (self.downloadError)
            {
                NSLog(@"iVersion update check failed because: %@", [self.downloadError localizedDescription]);
            }
            else
            {
                NSLog(@"iVersion update check failed because an unknown error occured");
            }
            
            if ([self.delegate respondsToSelector:@selector(iVersionVersionCheckDidFailWithError:)])
            {
                [self.delegate iVersionVersionCheckDidFailWithError:self.downloadError];
            }
            
            //deprecated code path
            else if ([self.delegate respondsToSelector:@selector(iVersionVersionCheckFailed:)])
            {
                NSLog(@"iVersionVersionCheckFailed: delegate method is deprecated, use iVersionVersionCheckDidFailWithError: instead");
                [self.delegate performSelector:@selector(iVersionVersionCheckFailed:) withObject:self.downloadError];
            }
            return;
        }
        
        //get version details
        NSString *details = [self versionDetailsSince:self.applicationVersion inDict:self.remoteVersionsDict];
        NSString *mostRecentVersion = [self mostRecentVersionInDict:self.remoteVersionsDict];
        if (details)
        {
            //inform delegate of new version
            if ([self.delegate respondsToSelector:@selector(iVersionDidDetectNewVersion:details:)])
            {
                [self.delegate iVersionDidDetectNewVersion:mostRecentVersion details:details];
            }
            
            //deprecated code path
            else if ([self.delegate respondsToSelector:@selector(iVersionDetectedNewVersion:details:)])
            {
                NSLog(@"iVersionDetectedNewVersion:details: delegate method is deprecated, use iVersionDidDetectNewVersion:details: instead");
                [self.delegate performSelector:@selector(iVersionDetectedNewVersion:details:) withObject:mostRecentVersion withObject:details];
            }
            
            //check if ignored
            BOOL showDetails = ![self.ignoredVersion isEqualToString:mostRecentVersion] || self.previewMode;
            if (showDetails)
            {
                if ([self.delegate respondsToSelector:@selector(iVersionShouldDisplayNewVersion:details:)])
                {
                    showDetails = [self.delegate iVersionShouldDisplayNewVersion:mostRecentVersion details:details];
                    if (!showDetails && self.verboseLogging)
                    {
                        NSLog(@"iVersion did not display the new version because the iVersionShouldDisplayNewVersion:details: delegate method returned NO");
                    }
                }
            }
            else if (self.verboseLogging)
            {
                NSLog(@"iVersion did not display the new version because it was marked as ignored");
            }
            
            //show details
            if (showDetails && !self.visibleRemoteAlert)
            {
                NSString *title = self.updateAvailableTitle;
                if (!self.groupNotesByVersion)
                {
                    title = [title stringByAppendingFormat:@" (%@)", mostRecentVersion];
                }
                
                self.visibleRemoteAlert = [self showAlertWithTitle:title
                                                           details:details
                                                     defaultButton:self.downloadButtonLabel
                                                      ignoreButton:[self showIgnoreButton]? self.ignoreButtonLabel: nil
                                                      remindButton:[self showRemindButton]? self.remindButtonLabel: nil];
            }
        }
        else if ([self.delegate respondsToSelector:@selector(iVersionDidNotDetectNewVersion)])
        {
            [self.delegate iVersionDidNotDetectNewVersion];
        }
    }
}

- (BOOL)shouldCheckForNewVersion
{
    //debug mode?
    if (!self.previewMode)
    {
        //check if within the reminder period
        if (self.lastReminded != nil)
        {
            //reminder takes priority over check period
            if ([[NSDate date] timeIntervalSinceDate:self.lastReminded] < self.remindPeriod * SECONDS_IN_A_DAY)
            {
                if (self.verboseLogging)
                {
                    NSLog(@"iVersion did not check for a new version because the user last asked to be reminded less than %g days ago", self.remindPeriod);
                }
                return NO;
            }
        }
        
        //check if within the check period
        else if (self.lastChecked != nil && [[NSDate date] timeIntervalSinceDate:self.lastChecked] < self.checkPeriod * SECONDS_IN_A_DAY)
        {
            if (self.verboseLogging)
            {
                NSLog(@"iVersion did not check for a new version because the last check was less than %g days ago", self.checkPeriod);
            }
            return NO;
        }
    }
    else if (self.verboseLogging)
    {
        NSLog(@"iVersion debug mode is enabled - make sure you disable this for release");
    }
    
    //confirm with delegate
    if ([self.delegate respondsToSelector:@selector(iVersionShouldCheckForNewVersion)])
    {
        BOOL shouldCheck = [self.delegate iVersionShouldCheckForNewVersion];
        if (!shouldCheck && self.verboseLogging)
        {
            NSLog(@"iVersion did not check for a new version because the iVersionShouldCheckForNewVersion delegate method returned NO");
        }
        return shouldCheck;
    }
    
    //perform the check
    return YES;
}

- (NSString *)valueForKey:(NSString *)key inJSON:(id)json
{
    if ([json isKindOfClass:[NSString class]])
    {
        //use legacy parser
        NSRange keyRange = [json rangeOfString:[NSString stringWithFormat:@"\"%@\"", key]];
        if (keyRange.location != NSNotFound)
        {
            NSInteger start = keyRange.location + keyRange.length;
            NSRange valueStart = [json rangeOfString:@":" options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
            if (valueStart.location != NSNotFound)
            {
                start = valueStart.location + 1;
                NSRange valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
                if (valueEnd.location != NSNotFound)
                {
                    NSString *value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    while ([value hasPrefix:@"\""] && ![value hasSuffix:@"\""])
                    {
                        if (valueEnd.location == NSNotFound)
                        {
                            break;
                        }
                        NSInteger newStart = valueEnd.location + 1;
                        valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(newStart, [(NSString *)json length] - newStart)];
                        value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    }
                    
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                    value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\f" withString:@"\f"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\b" withString:@"\f"];
                    
                    while (YES)
                    {
                        NSRange unicode = [value rangeOfString:@"\\u"];
                        if (unicode.location == NSNotFound || unicode.location + unicode.length == 0)
                        {
                            break;
                        }
                        
                        uint32_t c = 0;
                        NSString *hex = [value substringWithRange:NSMakeRange(unicode.location + 2, 4)];
                        NSScanner *scanner = [NSScanner scannerWithString:hex];
                        [scanner scanHexInt:&c];
                        
                        if (c <= 0xffff)
                        {
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C", (unichar)c]];
                        }
                        else
                        {
                            //convert character to surrogate pair
                            uint16_t x = (uint16_t)c;
                            uint16_t u = (c >> 16) & ((1 << 5) - 1);
                            uint16_t w = (uint16_t)u - 1;
                            unichar high = 0xd800 | (w << 6) | x >> 10;
                            unichar low = (uint16_t)(0xdc00 | (x & ((1 << 10) - 1)));
                            
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C%C", high, low]];
                        }
                    }
                    return value;
                }
            }
        }
    }
    else
    {
        return json[key];
    }
    return nil;
}

- (void)setAppStoreIDOnMainThread:(NSString *)appStoreIDString
{
    self.appStoreID = [appStoreIDString longLongValue];
}

- (void)checkForNewVersionInBackground
{
    @synchronized (self)
    {
        @autoreleasepool
        {
            BOOL newerVersionAvailable = NO;
            BOOL osVersionSupported = NO;
            NSString *latestVersion = nil;
            NSDictionary *versions = nil;
            
            //first check iTunes
            NSString *iTunesServiceURL = [NSString stringWithFormat:iVersionAppLookupURLFormat, self.appStoreCountry];
            if (self.appStoreID)
            {
                iTunesServiceURL = [iTunesServiceURL stringByAppendingFormat:@"?id=%@", @(self.appStoreID)];
            }
            else
            {
                iTunesServiceURL = [iTunesServiceURL stringByAppendingFormat:@"?bundleId=%@", self.applicationBundleID];
            }
            
            if (self.verboseLogging)
            {
                NSLog(@"iVersion is checking %@ for a new app version...", iTunesServiceURL);
            }
            
            NSError *error = nil;
            NSURLResponse *response = nil;
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iTunesServiceURL]
                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                 timeoutInterval:REQUEST_TIMEOUT];
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (data && statusCode == 200)
            {
                //in case error is garbage...
                error = nil;
                
                id json = nil;
                if ([NSJSONSerialization class])
                {
                    json = [[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&error][@"results"] lastObject];
                }
                else
                {
                    //convert to string
                    json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                
                if (!error)
                {
                    //check bundle ID matches
                    NSString *bundleID = [self valueForKey:@"bundleId" inJSON:json];
                    if (bundleID)
                    {
                        if ([bundleID isEqualToString:self.applicationBundleID])
                        {
                            //get supported OS version
                            NSString *minimumSupportedOSVersion = [self valueForKey:@"minimumOsVersion" inJSON:json];
                            
#if TARGET_OS_IPHONE
                            
                            NSString *systemVersion = [UIDevice currentDevice].systemVersion;
                            
#else
                            NSString *systemVersion = nil;
                            
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1100
                            
                            if ([[NSProcessInfo class] respondsToSelector:@selector(processInfo)])
                            {
                                NSOperatingSystemVersion version = [NSProcessInfo processInfo].operatingSystemVersion;
                                systemVersion = [NSString stringWithFormat:@"%zd.%zd.%zd", version.majorVersion, version.minorVersion, version.patchVersion];
                            }
                            else
#endif
                            {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                            
                                SInt32 majorVersion = 0, minorVersion = 0, patchVersion = 0;
                                Gestalt(gestaltSystemVersionMajor, &majorVersion);
                                Gestalt(gestaltSystemVersionMinor, &minorVersion);
                                Gestalt(gestaltSystemVersionBugFix, &patchVersion);
                                systemVersion = [NSString stringWithFormat:@"%d.%d.%d", majorVersion, minorVersion, patchVersion];
                                
#pragma clang diagnostic pop
                                
                            }
#endif
                            osVersionSupported = ([systemVersion compare:minimumSupportedOSVersion options:NSNumericSearch] != NSOrderedAscending);
                            if (!osVersionSupported)
                            {
                                error = [NSError errorWithDomain:iVersionErrorDomain
                                                            code:iVersionErrorOSVersionNotSupported
                                                        userInfo:@{NSLocalizedDescriptionKey: @"Current OS version is not supported."}];
                            }

                            //get version details
                            NSString *releaseNotes = [self valueForKey:@"releaseNotes" inJSON:json];
                            latestVersion = [self valueForKey:@"version" inJSON:json];
                            if (latestVersion && osVersionSupported)
                            {
                                versions = @{latestVersion: releaseNotes ?: @""};
                            }
                            
                            //get app id
                            if (!self.appStoreID)
                            {
                                NSString *appStoreIDString = [self valueForKey:@"trackId" inJSON:json];
                                [self performSelectorOnMainThread:@selector(setAppStoreIDOnMainThread:) withObject:appStoreIDString waitUntilDone:YES];
                                
                                if (self.verboseLogging)
                                {
                                    NSLog(@"iVersion found the app on iTunes. The App Store ID is %@", appStoreIDString);
                                }
                            }

                            //check for new version
                            newerVersionAvailable = ([latestVersion compareVersion:self.applicationVersion] == NSOrderedDescending);
                            if (self.verboseLogging)
                            {
                                if (newerVersionAvailable)
                                {
                                    NSLog(@"iVersion found a new version (%@) of the app on iTunes. Current version is %@", latestVersion, self.applicationVersion);
                                }
                                else
                                {
                                    NSLog(@"iVersion did not find a new version of the app on iTunes. Current version is %@, latest version is %@", self.applicationVersion, latestVersion);
                                }
                            }
                        }
                        else
                        {
                            if (self.verboseLogging)
                            {
                                NSLog(@"iVersion found that the application bundle ID (%@) does not match the bundle ID of the app found on iTunes (%@) with the specified App Store ID (%@)", self.applicationBundleID, bundleID, @(self.appStoreID));
                            }
                            
                            error = [NSError errorWithDomain:iVersionErrorDomain
                                                        code:iVersionErrorBundleIdDoesNotMatchAppStore
                                                    userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Application bundle ID does not match expected value of %@", bundleID]}];
                        }
                    }
                    else if (self.appStoreID || !self.remoteVersionsPlistURL)
                    {
                        if (self.verboseLogging)
                        {
                            NSLog(@"iVersion could not find this application on iTunes. If your app is not intended for App Store release then you must specify a remoteVersionsPlistURL. If this is the first release of your application then it's not a problem that it cannot be found on the store yet");
                        }
                        
                        error = [NSError errorWithDomain:iVersionErrorDomain
                                                    code:iVersionErrorApplicationNotFoundOnAppStore
                                                userInfo:@{NSLocalizedDescriptionKey: @"The application could not be found on the App Store."}];
                    }
                    else if (!self.appStoreID && self.verboseLogging)
                    {
                        NSLog(@"iVersion could not find your app on iTunes. If your app is not yet on the store or is not intended for App Store release then don't worry about this");
                    }

                    //now check plist for alternative release notes
                    if (((self.appStoreID && newerVersionAvailable && osVersionSupported) || !self.appStoreID || self.previewMode) && self.remoteVersionsPlistURL)
                    {
                        if (self.verboseLogging)
                        {
                            NSLog(@"iVersion will check %@ for %@", self.remoteVersionsPlistURL, self.appStoreID? @"release notes": @"a new app version");
                        }
                        
                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.remoteVersionsPlistURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
                        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                        if (data)
                        {
                            NSPropertyListFormat format;
                            NSDictionary *plistVersions = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:&error];
                            
                            if (latestVersion)
                            {
                                //remove versions that are greater than latest in app store
                                NSMutableDictionary *versions = [NSMutableDictionary dictionary];
                                for (NSString *version in plistVersions)
                                {
                                    if ([version compareVersion:latestVersion] != NSOrderedDescending)
                                    {
                                        versions[version] = plistVersions[version];
                                    }
                                }
                                plistVersions = versions;
                            }
                            if (!latestVersion || plistVersions[latestVersion] || !_useAppStoreDetailsIfNoPlistEntryFound)
                            {
                                versions = [plistVersions copy];
                            }
                        }
                        else if (self.verboseLogging)
                        {
                            NSLog(@"iVersion was unable to download the user-specified release notes");
                        }
                    }
                }
                else if (statusCode >= 400)
                {
                    //http error
                    NSString *message = [NSString stringWithFormat:@"The server returned a %@ error", @(statusCode)];
                    error = [NSError errorWithDomain:@"HTTPResponseErrorDomain" code:statusCode userInfo:@{NSLocalizedDescriptionKey: message}];
                }
            }
            [self performSelectorOnMainThread:@selector(setDownloadError:) withObject:error waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(setRemoteVersionsDict:) withObject:versions waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(setLastChecked:) withObject:[NSDate date] waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(downloadedVersionsData) withObject:nil waitUntilDone:YES];
        }
    }
}

- (void)checkForNewVersion
{
    if (!self.checkingForNewVersion)
    {
        self.checkingForNewVersion = YES;
        [self performSelectorInBackground:@selector(checkForNewVersionInBackground) withObject:nil];
    }
}

- (void)checkIfNewVersion
{
    
#if !TARGET_OS_IPHONE
    
    //only show when main window is available
    if (self.onlyPromptIfMainWindowIsAvailable && ![[NSApplication sharedApplication] mainWindow])
    {
        [self performSelector:@selector(checkIfNewVersion) withObject:nil afterDelay:0.5];
        return;
    }
    
#endif
    
    if (self.lastVersion != nil || self.showOnFirstLaunch || self.previewMode)
    {
        if ([self.applicationVersion compareVersion:self.lastVersion] == NSOrderedDescending || self.previewMode)
        {
            //clear reminder
            self.lastReminded = nil;
            
            //get version details
            BOOL showDetails = !!self.versionDetails;
            if (showDetails && [self.delegate respondsToSelector:@selector(iVersionShouldDisplayCurrentVersionDetails:)])
            {
                showDetails = [self.delegate iVersionShouldDisplayCurrentVersionDetails:self.versionDetails];
            }
            
            //show details
            if (showDetails && !self.visibleLocalAlert && !self.visibleRemoteAlert)
            {
                self.visibleLocalAlert = [self showAlertWithTitle:self.inThisVersionTitle
                                                          details:self.versionDetails
                                                    defaultButton:self.okButtonLabel
                                                     ignoreButton:nil
                                                     remindButton:nil];
            }
        }
    }
    else
    {
        //record this as last viewed release
        self.viewedVersionDetails = YES;
    }
}

- (BOOL)showIgnoreButton
{
    return [self.ignoreButtonLabel length] && self.updatePriority < iVersionUpdatePriorityMedium;
}

- (BOOL)showRemindButton
{
    return [self.remindButtonLabel length] && self.updatePriority < iVersionUpdatePriorityHigh;
}

- (id)showAlertWithTitle:(NSString *)title
                 details:(NSString *)details
           defaultButton:(NSString *)defaultButton
            ignoreButton:(NSString *)ignoreButton
            remindButton:(NSString *)remindButton
{
    
#if TARGET_OS_IPHONE
    
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    if ([UIAlertController class] && topController && self.useUIAlertControllerIfAvailable)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:details preferredStyle:UIAlertControllerStyleAlert];
        
        //download/ok action
        [alert addAction:[UIAlertAction actionWithTitle:self.downloadButtonLabel style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            [self didDismissAlert:alert withButtonAtIndex:0];
        }]];
        
        //ignore action
        if ([self showIgnoreButton])
        {
            [alert addAction:[UIAlertAction actionWithTitle:self.ignoreButtonLabel style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action) {
                [self didDismissAlert:alert withButtonAtIndex:1];
            }]];
        }
        
        //remind action
        if ([self showRemindButton])
        {
            [alert addAction:[UIAlertAction actionWithTitle:self.remindButtonLabel style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                [self didDismissAlert:alert withButtonAtIndex:[self showIgnoreButton]? 2: 1];
            }]];
        }
        
        //get current view controller and present alert
        [topController presentViewController:alert animated:YES completion:NULL];
        
        return alert;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:details
                                                       delegate:(id<UIAlertViewDelegate>)self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:defaultButton, nil];
        if (ignoreButton)
        {
            [alert addButtonWithTitle:ignoreButton];
            alert.cancelButtonIndex = 1;
        }
        
        if (remindButton)
        {
            [alert addButtonWithTitle:remindButton];
        }
        
        [alert show];
        
        return alert;
    }
    
#else
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    alert.informativeText = self.inThisVersionTitle;
    [alert addButtonWithTitle:defaultButton];
    
    NSScrollView *scrollview = [[NSScrollView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 380.0, 15.0)];
    NSSize contentSize = [scrollview contentSize];
    scrollview.borderType = NSBezelBorder;
    scrollview.hasVerticalScroller = YES;
    scrollview.hasHorizontalScroller = NO;
    scrollview.autoresizingMask = (NSAutoresizingMaskOptions)(NSViewWidthSizable|NSViewHeightSizable);
    
    NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, contentSize.width, contentSize.height)];
    textView.minSize = NSMakeSize(0.0, contentSize.height);
    textView.maxSize = NSMakeSize(FLT_MAX, FLT_MAX);
    textView.verticallyResizable = YES;
    textView.horizontallyResizable = NO;
    textView.autoresizingMask = NSViewWidthSizable;
    textView.textContainer.containerSize = NSMakeSize(contentSize.width, FLT_MAX);
    textView.textContainer.widthTracksTextView = YES;
    textView.string = details;
    scrollview.documentView = textView;
    [textView sizeToFit];
    
    CGFloat height = MIN(200.0, [[scrollview documentView] frame].size.height) + 3.0;
    scrollview.frame = NSMakeRect(0.0, 0.0, scrollview.frame.size.width, height);
    alert.accessoryView = scrollview;
    
    if (ignoreButton)
    {
        [alert addButtonWithTitle:ignoreButton];
    }
    
    if (remindButton)
    {
        [alert addButtonWithTitle:remindButton];
    }
    
#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9
    
    if (![alert respondsToSelector:@selector(beginSheetModalForWindow:completionHandler:)])
    {
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow
                          modalDelegate:self
                         didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                            contextInfo:nil];
    }
    else
    
#endif
    
    {
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow completionHandler:^(NSModalResponse returnCode) {
            [self didDismissAlert:alert withButtonAtIndex:returnCode - NSAlertFirstButtonReturn];
        }];
    }
    
    return alert;
    
#endif
    
}

- (void)didDismissAlert:(id)alertView withButtonAtIndex:(NSInteger)buttonIndex
{
    //get button indices
    NSInteger downloadButtonIndex = 0;
    NSInteger ignoreButtonIndex = [self showIgnoreButton]? 1: 0;
    NSInteger remindButtonIndex = [self showRemindButton]? ignoreButtonIndex + 1: 0;
    
    //latest version
    NSString *latestVersion = [self mostRecentVersionInDict:self.remoteVersionsDict];
    
    if (alertView == self.visibleLocalAlert)
    {
        //record that details have been viewed
        self.viewedVersionDetails = YES;
        
        //release alert
        self.visibleLocalAlert = nil;
        return;
    }
    
    if (buttonIndex == downloadButtonIndex)
    {
        //clear reminder
        self.lastReminded = nil;
        
        //log event
        if ([self.delegate respondsToSelector:@selector(iVersionUserDidAttemptToDownloadUpdate:)])
        {
            [self.delegate iVersionUserDidAttemptToDownloadUpdate:latestVersion];
        }
        
        if (![self.delegate respondsToSelector:@selector(iVersionShouldOpenAppStore)] ||
            [self.delegate iVersionShouldOpenAppStore])
        {
            //go to download page
            [self openAppPageInAppStore];
        }
    }
    else if (buttonIndex == ignoreButtonIndex)
    {
        //ignore this version
        self.ignoredVersion = latestVersion;
        self.lastReminded = nil;
        
        //log event
        if ([self.delegate respondsToSelector:@selector(iVersionUserDidIgnoreUpdate:)])
        {
            [self.delegate iVersionUserDidIgnoreUpdate:latestVersion];
        }
    }
    else if (buttonIndex == remindButtonIndex)
    {
        //remind later
        self.lastReminded = [NSDate date];
        
        //log event
        if ([self.delegate respondsToSelector:@selector(iVersionUserDidRequestReminderForUpdate:)])
        {
            [self.delegate iVersionUserDidRequestReminderForUpdate:latestVersion];
        }
    }

    //release alert
    self.visibleRemoteAlert = nil;
}

#if TARGET_OS_IPHONE

- (BOOL)openAppPageInAppStore
{
    if (!_updateURL && !self.appStoreID)
    {
        if (self.verboseLogging)
        {
            NSLog(@"iVersion was unable to open the App Store because the app store ID is not set.");
        }
        return NO;
    }
    
#if defined(IVERSION_USE_STOREKIT) && IVERSION_USE_STOREKIT
    
    if (!_updateURL && [SKStoreProductViewController class])
    {
        if (self.verboseLogging)
        {
            NSLog(@"iVersion will attempt to open the StoreKit in-app product page using the following app store ID: %@", @(self.appStoreID));
        }
        
        //create store view controller
        SKStoreProductViewController *productController = [[SKStoreProductViewController alloc] init];
        productController.delegate = (id<SKStoreProductViewControllerDelegate>)self;
        
        //load product details
        NSDictionary *productParameters = @{SKStoreProductParameterITunesItemIdentifier: [@(_appStoreID) description]};
        [productController loadProductWithParameters:productParameters completionBlock:NULL];
        
        //get root view controller
        UIWindow *window = [[UIApplication sharedApplication] delegate].window;
        UIViewController *rootViewController = window.rootViewController;
        if (!rootViewController)
        {
            if (self.verboseLogging)
            {
                NSLog(@"iVersion couldn't find a root view controller from which to display StoreKit product page");
            }
        }
        else
        {
            while (rootViewController.presentedViewController)
            {
                rootViewController = rootViewController.presentedViewController;
            }
            
            //present product view controller
            [rootViewController presentViewController:productController animated:YES completion:nil];
            if ([self.delegate respondsToSelector:@selector(iVersionDidPresentStoreKitModal)])
            {
                [self.delegate iVersionDidPresentStoreKitModal];
            }
            return YES;
        }
    }
    
#endif
    
    if (self.verboseLogging)
    {
        NSLog(@"iVersion will open the App Store using the following URL: %@", self.updateURL);
    }
    
    [[UIApplication sharedApplication] openURL:self.updateURL];
    return YES;
}

- (void)productViewControllerDidFinish:(UIViewController *)controller
{
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    if ([self.delegate respondsToSelector:@selector(iVersionDidDismissStoreKitModal)])
    {
        [self.delegate iVersionDidDismissStoreKitModal];
    }
}

- (void)resizeAlertView:(UIAlertView *)alertView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) &&
        [[UIDevice currentDevice].systemVersion floatValue] < 7.0f)
    {
        CGFloat max = alertView.window.bounds.size.height - alertView.frame.size.height - 10.0f;
        CGFloat offset = 0.0f;
        for (UIView *view in alertView.subviews)
        {
            CGRect frame = view.frame;
            if ([view isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)view;
                if ([label.text isEqualToString:alertView.message])
                {
                    label.lineBreakMode = NSLineBreakByWordWrapping;
                    label.numberOfLines = 0;
                    label.alpha = 1.0f;
                    [label sizeToFit];
                    offset = label.frame.size.height - frame.size.height;
                    frame.size.height = label.frame.size.height;
                    if (offset > max)
                    {
                        frame.size.height -= (offset - max);
                        offset = max;
                    }
                    if (offset > max - 10.0f)
                    {
                        frame.size.height -= (offset - max - 10);
                        frame.origin.y += (offset - max - 10) / 2.0f;
                    }
                }
            }
            else if ([view isKindOfClass:[UITextView class]])
            {
                view.alpha = 0.0f;
            }
            else if ([view isKindOfClass:[UIControl class]])
            {
                frame.origin.y += offset;
            }
            view.frame = frame;
        }
        CGRect frame = alertView.frame;
        frame.origin.y -= roundf(offset/2.0f);
        frame.size.height += offset;
        alertView.frame = frame;
    }
}

- (void)didRotate
{
    [self performSelectorOnMainThread:@selector(resizeAlertView:) withObject:self.visibleLocalAlert waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(resizeAlertView:) withObject:self.visibleRemoteAlert waitUntilDone:NO];
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    [self resizeAlertView:alertView];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self didDismissAlert:alertView withButtonAtIndex:buttonIndex];
}

#else

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(__unused void *)contextInfo
{
    [self didDismissAlert:alert withButtonAtIndex:returnCode - NSAlertFirstButtonReturn];
}

- (void)openAppPageWhenAppStoreLaunched
{
    //check if app store is running
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications])
    {
        if ([app.bundleIdentifier isEqualToString:iVersionMacAppStoreBundleID])
        {
            //open app page
            [[NSWorkspace sharedWorkspace] performSelector:@selector(openURL:) withObject:self.updateURL afterDelay:MAC_APP_STORE_REFRESH_DELAY];
            return;
        }
    }
    
    //try again
    [self performSelector:@selector(openAppPageWhenAppStoreLaunched) withObject:nil afterDelay:0.0];
}

- (BOOL)openAppPageInAppStore
{
    if (!_updateURL && !self.appStoreID)
    {
        if (self.verboseLogging)
        {
            NSLog(@"iVersion was unable to open the App Store because the app store ID is not set.");
        }
        return NO;
    }
    
    if (self.verboseLogging)
    {
        NSLog(@"iVersion will open the App Store using the following URL: %@", self.updateURL);
    }
    
    [[NSWorkspace sharedWorkspace] openURL:self.updateURL];
    if (!_updateURL) [self openAppPageWhenAppStoreLaunched];
    return YES;
}

#endif

- (void)applicationLaunched
{
    
    if (self.checkAtLaunch)
    {
        [self checkIfNewVersion];
        if ([self shouldCheckForNewVersion]) [self checkForNewVersion];
    }
    else if (self.verboseLogging)
    {
        NSLog(@"iVersion will not check for updates because the checkAtLaunch option is disabled");
    }
}

#if TARGET_OS_IPHONE

- (void)applicationWillEnterForeground
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        if (self.checkAtLaunch)
        {
            if ([self shouldCheckForNewVersion]) [self checkForNewVersion];
        }
        else if (self.verboseLogging)
        {
            NSLog(@"iVersion will not check for updates because the checkAtLaunch option is disabled");
        }
    }
}

#endif

@end
