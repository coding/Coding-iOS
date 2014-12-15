//
//  TweetMediaItemSingleCCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TweetMediaItemCCell.h"
#import "HtmlMedia.h"

@interface TweetMediaItemSingleCCell : TweetMediaItemCCell
@property (copy, nonatomic) void (^refreshSingleCCellBlock)();
+(CGSize)ccellSizeWithObj:(id)obj;

@end
