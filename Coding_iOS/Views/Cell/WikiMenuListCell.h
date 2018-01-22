//
//  WikiMenuListCell.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/4/5.
//  Copyright © 2017年 Coding. All rights reserved.
//
#define kCellIdentifier_WikiMenuListCellLavel(__lavel__) [NSString stringWithFormat:@"WikiMenuListCellLavel_%d", __lavel__]

#import <UIKit/UIKit.h>
#import "EAWiki.h"

@interface WikiMenuListCell : UITableViewCell
@property (copy, nonatomic) void(^selectedWikiBlock)(EAWiki *wiki);
@property (copy, nonatomic) void (^expandBlock)(EAWiki *wiki);

- (void)setCurWiki:(EAWiki *)curWiki selectedWiki:(EAWiki *)selectedWiki;
+ (CGFloat)cellHeightWithObj:(EAWiki *)obj;
@end
