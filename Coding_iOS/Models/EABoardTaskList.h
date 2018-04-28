//
//  EABoardTaskList.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/27.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EABasePageModel.h"
#import "Task.h"
#import "Project.h"

typedef enum : NSUInteger {
    EABoardTaskListCustom = 0,
    EABoardTaskListDoing,
    EABoardTaskListDone,
    EABoardTaskListBlank
} EABoardTaskListType;

@interface EABoardTaskList : EABasePageModel

@property (strong, nonatomic) NSNumber *id, *board_id, *owner_id, *project_id;
@property (assign, nonatomic) EABoardTaskListType type;
@property (assign, nonatomic) NSInteger order;
@property (strong, nonatomic) NSString *title;

@property (assign, nonatomic, readonly) BOOL canEdit, isBlankType;
@property (assign, nonatomic) Project *curPro;//辅助属性

- (NSString *)toTaskListPath;

+ (instancetype)blankBoardTLWithProject:(Project *)project;
@end
