//
//  HotTopicBannerView.h
//  Coding_iOS
//
//  Created by liaoyp on 15/11/21.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShopBanner;

@interface ShopBannerView : UIView
@property (strong, nonatomic) NSArray *curBannerList;
@property (nonatomic , copy) void (^tapActionBlock)(ShopBanner *bannerData);
- (void)reloadData;
@end
