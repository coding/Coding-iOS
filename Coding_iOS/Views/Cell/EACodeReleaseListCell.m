//
//  EACodeReleaseListCell.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EACodeReleaseListCell.h"

@interface EACodeReleaseListCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *tag_nameL;
@property (weak, nonatomic) IBOutlet UILabel *authorL;
@property (weak, nonatomic) IBOutlet UILabel *created_atL;
@property (weak, nonatomic) IBOutlet UIView *preV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *created_atLeftC;

@end

@implementation EACodeReleaseListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setCurCodeRelease:(EACodeRelease *)curCodeRelease{
    _curCodeRelease = curCodeRelease;
    
    _titleL.text = _curCodeRelease.title.length > 0? _curCodeRelease.title: _curCodeRelease.tag_name;
    _tag_nameL.text = _curCodeRelease.tag_name;
    _authorL.text = _curCodeRelease.author.name;
    _created_atL.text = [_curCodeRelease.created_at stringTimesAgo];
    _preV.hidden = !_curCodeRelease.pre.boolValue;
    _created_atLeftC.constant = _preV.hidden? 15: 60+ 15;
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xF66262"] icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:65];
}
@end
