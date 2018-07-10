//
//  EACodeReleaseTopCell.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/23.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EACodeReleaseTopCell.h"

@interface EACodeReleaseTopCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *tag_nameL;
@property (weak, nonatomic) IBOutlet UILabel *authorL;
@property (weak, nonatomic) IBOutlet UILabel *created_atL;
@property (weak, nonatomic) IBOutlet UIView *preV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *created_atLeftC;

@end

@implementation EACodeReleaseTopCell

- (void)setCurR:(EACodeRelease *)curR{
    _curR = curR;
    
    _titleL.text = _curR.title;
    _tag_nameL.text = _curR.tag_name;
    _authorL.text = _curR.author.name;
    _created_atL.text = [_curR.created_at stringTimesAgo];
//    _preV.hidden = !_curR.pre.boolValue;
    _preV.hidden = YES;
    _created_atLeftC.constant = _preV.hidden? 15: 60+ 15;
}

- (IBAction)tagButtonClicked:(id)sender {
    if (_tagClickedBlock) {
        _tagClickedBlock(_curR);
    }
}


+ (CGFloat)cellHeightWithObj:(EACodeRelease *)obj{
    CGFloat cellHeight = 15 + [obj.title getHeightWithFont:[UIFont systemFontOfSize:17 weight:UIFontWeightMedium] constrainedToSize:CGSizeMake(kScreen_Width - 2* kPaddingLeftWidth, CGFLOAT_MAX)] + 10 + 20 + 15;

    return cellHeight;
}

@end
