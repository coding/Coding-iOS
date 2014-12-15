//
//  TweetMediaItemCCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HtmlMedia.h"

@interface TweetMediaItemCCell : UICollectionViewCell
@property (strong, nonatomic) HtmlMediaItem *curMediaItem;
@property (strong, nonatomic) UIImageView *imgView;

+(CGSize)ccellSizeWithObj:(id)obj;
@end
