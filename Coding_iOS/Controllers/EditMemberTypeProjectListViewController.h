//
//  EditMemberTypeProjectListViewController.h
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/6/6.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Team.h"
#import "TeamMember.h"

@interface EditMemberTypeProjectListViewController : BaseViewController
@property (strong, nonatomic) Team *curTeam;
@property (strong, nonatomic) TeamMember *curMember;
@end
