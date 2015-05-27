//
//  TweetMediaItemCCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCCellIdentifier_TweetMediaItem @"TweetMediaItemCCell"

#import <UIKit/UIKit.h>
#import "HtmlMedia.h"
#import "YLImageView.h"

@interface TweetMediaItemCCell : UICollectionViewCell
@property (strong, nonatomic) HtmlMediaItem *curMediaItem;
@property (strong, nonatomic) YLImageView *imgView;
@property (strong, nonatomic) UIImageView *gifMarkView;

+(CGSize)ccellSizeWithObj:(id)obj;
@end
