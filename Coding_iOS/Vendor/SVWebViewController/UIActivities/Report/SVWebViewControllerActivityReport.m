//
//  SVWebViewControllerActivityReport.m
//  Coding_iOS
//
//  Created by Ease on 15/2/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "SVWebViewControllerActivityReport.h"
#import "ReportIllegalViewController.h"

@implementation SVWebViewControllerActivityReport

- (NSString *)activityTitle {
    return NSLocalizedStringFromTable(@"Inform", @"SVWebViewController", nil);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSURL class]]) {
            NSURL *inputURL = activityItem;
            if (inputURL.absoluteString.length > 0) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)performActivity {
    NSURL *inputURL = self.URLToOpen;
    NSString *absoluteString = [inputURL absoluteString];
    if (absoluteString.length > 0) {
        [ReportIllegalViewController showReportWithIllegalContent:absoluteString andType:IllegalContentTypeTweet];
    }
}

@end
