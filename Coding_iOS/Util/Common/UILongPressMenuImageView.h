//
//  UILongPressMenuImageView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/25.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILongPressMenuImageView : UIImageView
@property (copy, nonatomic) void(^longPressMenuBlock)(NSInteger index, NSString *title);
@property (strong, nonatomic) NSArray *longPressTitles;
- (void)addLongPressMenu:(NSArray *)titles clickBlock:(void(^)(NSInteger index, NSString *title))block;
@end
