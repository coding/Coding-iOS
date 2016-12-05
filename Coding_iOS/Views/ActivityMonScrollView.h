//
//  ActivityMonScrollView.h
//  Coding_iOS
//
//  Created by 张达棣 on 16/11/29.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivenessModel.h"


@interface ActivityMonScrollView : UIScrollView
@property (nonatomic, strong) NSArray<DailyActiveness *> *dailyActiveness;
@property (nonatomic, assign) NSInteger startMon; //开始的月份

@end
