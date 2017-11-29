//
//  NSLayoutConstraintLine.m
//  CodingMart
//
//  Created by Ease on 16/3/22.
//  Copyright © 2016年 net.coding. All rights reserved.
//

#import "NSLayoutConstraintLine.h"

@implementation NSLayoutConstraintLine
- (void)awakeFromNib{
    [super awakeFromNib];
    if (self.constant == 1) {
        self.constant = 1/[UIScreen mainScreen].scale;
    }
}
@end
