//
//  CodingBannersView.h
//  Coding_iOS
//
//  Created by Ease on 15/7/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodingBanner.h"

@interface CodingBannersView : UIView
@property (strong, nonatomic) NSArray *curBannerList;
@property (nonatomic , copy) void (^tapActionBlock)(CodingBanner *tapedBanner);
- (void)reloadData;
@end
