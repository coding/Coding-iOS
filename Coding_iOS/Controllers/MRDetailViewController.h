//
//  MRDetailViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/10/23.
//  Copyright © 2015年 Coding. All rights reserved.
//


#import "BaseViewController.h"
#import "MRPRBaseInfo.h"
#import "ReviewersInfo.h"
#import "Reviewer.h"
#import "user.h"
#import "Project.h"

@interface MRDetailViewController : BaseViewController
@property (strong, nonatomic) MRPR *curMRPR;
@property (strong, nonatomic) Project *curProject;//非必需
+ (MRDetailViewController *)vcWithPath:(NSString *)path;
- (Reviewer*)checkUserisReviewer;
- (BOOL)CurrentUserIsOwer;
- (void)refresh;
@end
