//
//  TaskResourceReferenceViewController.h
//  Coding_iOS
//
//  Created by Ease on 16/2/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Task.h"

@interface TaskResourceReferenceViewController : BaseViewController
@property (strong, nonatomic) NSString *resourceReferencePath;
@property (strong, nonatomic) NSNumber *resourceReferenceFromType; // 1 task, 0 merge
@property (strong, nonatomic) NSNumber *number;
@property (strong, nonatomic) ResourceReference *resourceReference;
@end
