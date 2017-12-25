//
//  SkillCCell.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/12/25.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "SkillCCell.h"

@interface SkillCCell ()

@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIButton *deleteB;

@end

@implementation SkillCCell

- (void)setCurSkill:(CodingSkill *)curSkill{
    _curSkill = curSkill;
    if (!_curSkill) {
        return;
    }
    if (!_contentLabel) {
        self.contentView.backgroundColor = kColorBrandGreen;
        self.contentView.layer.cornerRadius = 2.0;
        self.layer.cornerRadius = 2.0;
        _contentLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorWhite];
        _contentLabel.minimumScaleFactor = 0.5;
        _contentLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_contentLabel];
        _deleteB = [UIButton new];
        [_deleteB setImage:[UIImage imageNamed:@"skill_delete"] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_deleteB bk_addEventHandler:^(id sender) {
            if (weakSelf.deleteBlock) {
                weakSelf.deleteBlock(weakSelf.curSkill);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteB];
        [_deleteB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self.contentView);
            make.width.mas_equalTo(30);
        }];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(10);
            make.right.equalTo(_deleteB.mas_left).offset(-5);
        }];
    }
    _contentLabel.text = _curSkill.skill_str;
}

+ (CGSize)ccellSizeWithObj:(id)obj{
    CGSize ccellSize = CGSizeZero;
    if ([obj isKindOfClass:[CodingSkill class]]) {
        ccellSize = CGSizeMake((kScreen_Width - 30 - 10)/ 2, 30);
    }
    return ccellSize;
}

@end
