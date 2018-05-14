//
//  EAMilestone.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/5/14.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EABasePageModel.h"

@interface EAMilestone : EABasePageModel
@property (strong, nonatomic) NSNumber *id, *project_id, *status, *processing, *finished, *percentage, *remaining_days, *expire_days;
@property (strong, nonatomic) NSString *name, *description_mine, *start_date, *publish_date;
@end

//"start_date": "2018-05-14",
//"publish_date": "2018-05-30",
