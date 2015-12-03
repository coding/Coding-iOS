//
//  PublicSearchModel.h
//  Coding_iOS
//
//  Created by jwill on 15/11/19.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweets.h"
#import "Projects.h"
#import "Tasks.h"
#import "Users.h"
#import "ProjectTopics.h"
#import "MRPRS.h"
#import "ProjectFiles.h"

@interface PublicSearchModel : NSObject
@property(nonatomic,strong)Tweets *tweets;
@property(nonatomic,strong)Projects *projects;
@property(nonatomic,strong)Tasks *tasks;
@property(nonatomic,strong)Users *friends;
@property(nonatomic,strong)ProjectTopics *project_topics;
@property(nonatomic,strong)MRPRS *pull_requests;
@property(nonatomic,strong)MRPRS *merge_requests;
@property(nonatomic,strong)ProjectFiles *files;

@end
