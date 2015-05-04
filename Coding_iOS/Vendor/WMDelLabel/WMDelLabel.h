//
//  WMDelLabel.h
//  Coding_iOS
//
//  Created by zwm on 15/4/22.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMDelLabel;
@protocol WMDelLabelDelegate <NSObject>
@optional
- (void)delBtnClick:(WMDelLabel *)label;
@end

@interface WMDelLabel : UILabel

@property (nonatomic, weak) id<WMDelLabelDelegate> delLabelDelegate;

@end
