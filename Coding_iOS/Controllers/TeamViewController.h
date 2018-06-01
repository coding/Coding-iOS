//
//  TeamViewController.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Team.h"

@interface TeamViewController : BaseViewController
@property (strong, nonatomic) Team *curTeam;
@end

@interface EATeamHeaderView : UIView
@property (strong, nonatomic) UIImageView *bgV;

@property (strong, nonatomic) Team *curTeam;
@end
