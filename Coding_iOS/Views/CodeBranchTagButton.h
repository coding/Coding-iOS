//
//  CodeBranchTagButton.h
//  Coding_iOS
//
//  Created by Ease on 15/1/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"

@interface CodeBranchTagButton : UIButton
@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) Project *curProject;
@property (nonatomic, strong) NSArray *branchList, *tagList;
@property (nonatomic, strong, readonly) NSArray *dataList;
@property (nonatomic,copy) void(^selectedBranchTagBlock)(NSString *branchTag);

+ (instancetype)buttonWithProject:(Project *)project andTitleStr:(NSString *)titleStr;
@end
