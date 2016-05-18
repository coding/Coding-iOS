//
//  UIMessageInputView_Add.h
//  Coding_iOS
//
//  Created by Ease on 15/4/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMessageInputView_Add : UIView
@property (copy, nonatomic) void(^addIndexBlock)(NSInteger);

@end
