//
//  EABoardTaskList.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/27.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EABoardTaskList.h"

@implementation EABoardTaskList

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.propertyArrayMap = @{@"list": @"Task"};
    }
    return self;
}

- (BOOL)canEdit{
    return _type == EABoardTaskListCustom;
}

- (BOOL)isBlankType{
    return _type == EABoardTaskListBlank;
}

- (NSString *)toTaskListPath{
    return [NSString stringWithFormat:@"api/user/%@/project/%@/tasks/board/%@/list/%@/tasks", _curPro.owner_user_name, _curPro.name, _board_id, _id];
}

+ (instancetype)blankBoardTLWithProject:(Project *)project{
    EABoardTaskList *blankItem = [self new];
    blankItem.id = @(-1);
    blankItem.curPro = project;
    blankItem.type = EABoardTaskListBlank;
    return blankItem;
}

@end
