//
//  ProjectCount.m
//  Coding_iOS
//
//  Created by jwill on 15/11/10.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ProjectCount.h"

@implementation ProjectCount

- (void)configWithProjects:(ProjectCount *)ProjectCount
{
    self.all = ProjectCount.all;
    self.watched = ProjectCount.watched;
    self.created = ProjectCount.created;
    self.joined = ProjectCount.joined;
    self.stared = ProjectCount.stared;
    self.deploy = ProjectCount.deploy;
}

@end
