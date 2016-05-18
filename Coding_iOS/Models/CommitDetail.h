//
//  CommitDetail.h
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "Commit.h"
#import "FileChanges.h"

@interface CommitDetail : Commit
@property (strong, nonatomic) FileChanges *diffStat;

@end
