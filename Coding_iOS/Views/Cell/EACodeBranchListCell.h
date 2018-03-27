//
//  EACodeBranchListCell.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodeBranchOrTag.h"
#import "SWTableViewCell.h"

@interface EACodeBranchListCell : SWTableViewCell
@property (strong, nonatomic) CodeBranchOrTag *curBranch;
@end
