//
//  UIMessageInputView_CCell.h
//  Coding_iOS
//
//  Created by Ease on 15/4/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCCellIdentifier_UIMessageInputView_CCell @"UIMessageInputView_CCell"

#import <UIKit/UIKit.h>
#import "UIMessageInputView_Media.h"


@interface UIMessageInputView_CCell : UICollectionViewCell
@property (copy, nonatomic) void (^deleteBlock)(UIMessageInputView_Media *toDelete);
- (void)setCurMedia:(UIMessageInputView_Media *)curMedia andTotalCount:(NSInteger)totalCount;
@end
