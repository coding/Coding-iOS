//
//  EACodeBranches.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EABasePageModel.h"
#import "CodeBranchOrTag.h"
#import "Project.h"

@interface EACodeBranches : EABasePageModel

@property (strong, nonatomic) NSString *queryStr;
@property (strong, nonatomic) Project *curPro;

@property (strong, nonatomic) CodeBranchOrTag *defaultBranch;

- (NSString *)toPath;
- (NSDictionary *)toParams;

//branch_metrics:
//https://coding.net/api/user/ease/project/CodingTest/git/branch_metrics?base=e5d4955b8201309874dcb64f7cbdf314014fa3bf&targets=e5d4955b8201309874dcb64f7cbdf314014fa3bf%2C719ff69d71d306641ceaa894a1eea6abb08d00ec%2Ca5739517e0490ce3cdf0902e6da866ebb6aab3b1%2C1802d88cb77846b257f92029eae4a22933bfffb6%2Ce5d6e7ba21db8e22d641fb47fc52c5f6632b5559%2Cbdcb860a7780c79fb365276d3b8836f8068178c4%2Cb85c2f817364a3662abce8012073a63af89c1e95%2C5f209a9743367af232e624742743aeabb0a85f10%2Cf03dd077b2a2c1a5474e45a4fb8f4acb343694e1%2Cf304e9aa98158da4adaba3bb9295cc3fdf468f02

@end
