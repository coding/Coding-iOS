//
//  EACodeReleases.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EABasePageModel.h"
#import "EACodeRelease.h"
#import "Project.h"

@interface EACodeReleases : EABasePageModel
@property (strong, nonatomic) Project *curPro;

- (NSString *)toPath;
- (NSDictionary *)toParams;
@end
