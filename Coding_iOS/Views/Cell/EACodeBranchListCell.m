//
//  EACodeBranchListCell.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EACodeBranchListCell.h"

@interface EACodeBranchListCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *commitTimeL;
@property (weak, nonatomic) IBOutlet UIImageView *is_protectedV;
@property (weak, nonatomic) IBOutlet UIView *metricV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *metric_leadingC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *metric_trailingC;
@property (weak, nonatomic) IBOutlet UILabel *aheadL;
@property (weak, nonatomic) IBOutlet UILabel *behindL;

@end

@implementation EACodeBranchListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setCurBranch:(CodeBranchOrTag *)curBranch{
    _curBranch = curBranch;
    _nameL.text = [NSString stringWithFormat:@"  %@  ", _curBranch.name];
    _nameL.textColor = _curBranch.is_default_branch.boolValue? kColorWhite: kColorDark7;
    _nameL.backgroundColor = _curBranch.is_default_branch.boolValue? kColorDark3: kColorD8DDE4;
    _commitTimeL.text = [NSString stringWithFormat:@"更新于 %@", [_curBranch.last_commit.commitTime stringTimesAgo]];
    _is_protectedV.hidden = !_curBranch.is_protected.boolValue;
    _metricV.hidden = _curBranch.is_default_branch.boolValue;
    
    _metric_leadingC.constant = -MIN(_curBranch.branch_metric.ahead.floatValue, 40);
    _metric_trailingC.constant = MIN(_curBranch.branch_metric.behind.floatValue, 40);
    _aheadL.text = [NSString stringWithFormat:@"%ld", (long)_curBranch.branch_metric.ahead.integerValue];
    _behindL.text = [NSString stringWithFormat:@"%ld", (long)_curBranch.branch_metric.behind.integerValue];
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xF66262"] icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:80];
}

@end

