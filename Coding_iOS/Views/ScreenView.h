//
//  ScreenView.h
//  Coding_iOS
//
//  Created by 张达棣 on 16/12/7.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreenView : UIView

@property (nonatomic, copy) void(^selectBlock)(NSString *keyword, NSString *status, NSString *label);
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *status; //任务状态，进行中的为1，已完成的为2
@property (nonatomic, strong) NSString *label; //任务标签

@property (nonatomic, strong) NSArray *tastArray;
@property (nonatomic, strong) NSArray *labels;

+ (instancetype)creat;

- (void)showOrHide;

@end


