//
//  ActivenessModel.h
//  Coding_iOS
//
//  Created by 张达棣 on 16/11/29.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ActiveDuration, DailyActiveness;

@interface ActivenessModel : NSObject
@property (nonatomic, strong) NSString *total_with_seal_top_line;
@property (nonatomic, strong) NSString *start_date;
@property (nonatomic, strong) ActiveDuration *longest_active_duration;
@property (nonatomic, strong) ActiveDuration *current_active_duration;
@property (nonatomic, strong) NSArray<DailyActiveness *> *dailyActiveness;
@end



@interface ActiveDuration : NSObject
@property (nonatomic, strong) NSString *days, *start_date, *end_date;
@end

@interface DailyActiveness : NSObject
@property (nonatomic, strong) NSString *date, *count;
@end
