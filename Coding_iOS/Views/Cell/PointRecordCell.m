//
//  PointRecordCell.m
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "PointRecordCell.h"

@interface PointRecordCell ()
@property (strong, nonatomic) UILabel *usageL, *timeL, *pointsLeftL, *pointsChangeL;
@end

@implementation PointRecordCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_usageL) {
            _usageL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColor222];
            [self.contentView addSubview:_usageL];
        }
        if (!_timeL) {
            _timeL = [UILabel labelWithFont:[UIFont systemFontOfSize:12] textColor:kColor999];
            [self.contentView addSubview:_timeL];
        }
        if (!_pointsLeftL) {
            _pointsLeftL = [UILabel labelWithFont:[UIFont systemFontOfSize:12] textColor:kColor999];
            [self.contentView addSubview:_pointsLeftL];
        }
        if (!_pointsChangeL) {
            _pointsChangeL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorBrandGreen];
            [self.contentView addSubview:_pointsChangeL];
        }
        [_usageL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(10);
            make.height.mas_equalTo(25);
        }];
        [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.bottom.equalTo(self.contentView).offset(-10);
            make.height.mas_equalTo(20);
        }];
        [_pointsLeftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(_timeL);
            make.height.mas_equalTo(20);
        }];
        [_pointsChangeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(_usageL);
            make.height.mas_equalTo(25);
        }];
    }
    return self;
}
- (void)setCurRecord:(PointRecord *)curRecord{
    _curRecord = curRecord;
    if (!_curRecord) {
        return;
    }
    _usageL.text = _curRecord.usage;
    _timeL.text = [_curRecord.created_at stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    _pointsLeftL.text = [NSString stringWithFormat:@"余额:%.2f", _curRecord.points_left.floatValue];
    _pointsChangeL.textColor = [UIColor colorWithHexString:_curRecord.action.intValue == 1? @"0x2EBE76": @"0xFB8638"];
    _pointsChangeL.text = [NSString stringWithFormat:@"%@%.2f", _curRecord.action.intValue == 1? @"+": @"-", _curRecord.points_change.floatValue];
}
+ (CGFloat)cellHeight{
    return 70.0;
}
@end
