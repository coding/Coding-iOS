//
//  FileChange.h
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileChange : NSObject
@property (strong, nonatomic) NSNumber *insertions, *deletions, *size, *mode;
@property (strong, nonatomic) NSString *changeType, *name, *path, *objectId, *commitId;
@property (readonly, strong, nonatomic) NSString *displayFilePath, *displayFileName;
@end
