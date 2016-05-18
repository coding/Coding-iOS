//
//  SVWebViewControllerActivityChrome.h
//
//  Created by Sam Vermette on 11 Nov, 2013.
//  Copyright 2013 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVWebViewControllerActivityChrome.h"

@implementation SVWebViewControllerActivityChrome

- (NSString *)activityTitle {
	return NSLocalizedStringFromTable(@"Open in Chrome", @"SVWebViewController", nil);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
			return YES;
		}
	}
	return NO;
}

- (void)performActivity {
	NSURL *inputURL = self.URLToOpen;
	NSString *scheme = inputURL.scheme;

	// Replace the URL Scheme with the Chrome equivalent.
	NSString *chromeScheme = nil;
	if ([scheme isEqualToString:@"http"]) {
		chromeScheme = @"googlechrome";
	} else if ([scheme isEqualToString:@"https"]) {
		chromeScheme = @"googlechromes";
	}

	// Proceed only if a valid Google Chrome URI Scheme is available.
	if (chromeScheme) {
		NSString *absoluteString = [inputURL absoluteString];
		NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
		NSString *urlNoScheme =
		[absoluteString substringFromIndex:rangeForScheme.location];
		NSString *chromeURLString =
		[chromeScheme stringByAppendingString:urlNoScheme];
		NSURL *chromeURL = [NSURL URLWithString:chromeURLString];

		// Open the URL with Chrome.
		[[UIApplication sharedApplication] openURL:chromeURL];
	}
}

@end
