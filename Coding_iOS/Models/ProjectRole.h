//
//  ProjectRole.h
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/6/6.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"

@interface ProjectRole : NSObject
@property (strong, nonatomic) NSString *alias;
@property (strong, nonatomic) NSNumber *id, *project_id, *user_id, *type;
@property (strong, nonatomic) Project *project;
@end
