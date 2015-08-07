//
//  HotTopicBannerView.h
//  Coding_iOS
//
//  Created by Lambda on 15/8/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotTopicBannerView : UIView
@property (strong, nonatomic) NSArray *curBannerList;
@property (nonatomic , copy) void (^tapActionBlock)(NSDictionary *bannerData);
- (void)reloadData;
@end
