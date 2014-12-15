//
//  BasicPreviewItem.h
//  Coding_iOS
//
//  Created by Ease on 14/11/20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface BasicPreviewItem : NSObject<QLPreviewItem>
+ (BasicPreviewItem *)itemWithUrl:(NSURL *)itemUrl;
- (instancetype)initWithUrl:(NSURL *)itemUrl title:(NSString *)title;
@end
