//
//  ProjectTagLabel.h
//  Coding_iOS
//
//  Created by Ease on 15/7/21.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectTag.h"

@interface ProjectTagLabel : UILabel
@property (strong, nonatomic) ProjectTag *curTag;
- (void)setup;//调整UI。设置 curTag 的时候会自动调整，其他属性默认不调整。

+ (instancetype)labelWithTag:(ProjectTag *)curTag font:(UIFont *)font height:(CGFloat)height widthPadding:(CGFloat)width_padding;
@end
