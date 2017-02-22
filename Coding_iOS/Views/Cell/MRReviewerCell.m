//
//  NSObject+PRReviewerCell.m
//  Coding_iOS
//
//  Created by hardac on 16/3/22.
//  Copyright © 2016年 Coding. All rights reserved.
//


#import "MRReviewerCell.h"

@interface MRReviewerCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *rightLabel;
@property (strong, nonatomic) UIImageView *likeImgView;
@end

@implementation MRReviewerCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kColorTableBG;
        if (!_imgView) {
            _imgView = [UIImageView new];
            [self.contentView addSubview:_imgView];
            [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20, 20));
                make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
        }
        if (!_titleLabel) {
            _titleLabel = [UILabel new];
            _titleLabel.font = [UIFont systemFontOfSize:15];
            _titleLabel.textColor = kColor222;
            [self.contentView addSubview:_titleLabel];
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imgView.mas_right).offset(15);
                make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
                make.centerY.height.equalTo(self.contentView);
            }];
        }
        if (!self.rightLabel) {
            self.rightLabel = [UILabel new];
            self.rightLabel.text = @"添加";
            self.rightLabel.font = [UIFont systemFontOfSize:15];
            //[self.rightLabel setTextColor:kColor999];
            [self.contentView addSubview:self.rightLabel];
            [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                //make.left.equalTo(_imgView.mas_right).offset(15);
                make.right.equalTo(self.contentView).offset(0);
                make.centerY.height.equalTo(self.contentView);
            }];
        }
        if (!self.likeImgView) {
            self.likeImgView = [UIImageView new];
            [self.contentView addSubview:self.likeImgView];
            [self.likeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20, 20));
                make.right.equalTo(self.contentView).offset(-40);
                make.centerY.equalTo(self.contentView);
            }];
        }
        UIView *rightSideV = [UIView new];
        [self.contentView addSubview:rightSideV];
        [rightSideV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self.contentView);
            make.width.equalTo(self.contentView).multipliedBy(1.0/4);
        }];
        __weak typeof(self) weakSelf = self;
        [rightSideV bk_whenTapped:^{
            if (weakSelf.rightSideClickedBlock) {
                weakSelf.rightSideClickedBlock();
            }
        }];
    }
    return self;
}

- (void)prepareForReuse{
    [self removeTip];
}

- (void)addTip:(NSString *)countStr{
    CGFloat pointX = kScreen_Width - 25;
    CGFloat pointY = [[self class] cellHeight]/2;
    [self.contentView addBadgeTip:countStr withCenterPosition:CGPointMake(pointX, pointY)];
}

- (void)addTipIcon{
    CGFloat pointX = kScreen_Width - 40;
    CGFloat pointY = [[self class] cellHeight]/2;
    [self.contentView addBadgeTip:kBadgeTipStr withCenterPosition:CGPointMake(pointX, pointY)];
}

- (void)addTipHeadIcon:(NSString *)IconString {
    CGFloat pointX = kScreen_Width - 40;
    CGFloat pointY = [[self class] cellHeight]/2;
    [self.contentView addBadgeTip:IconString withCenterPosition:CGPointMake(pointX, pointY)];
}

- (void)removeTip{
    [self.contentView removeBadgeTips];
}

- (void)setImageStr:(NSString *)imgStr
            isowner:(BOOL)ower
          hasLikeMr:(NSNumber *)hasLikeMr {
    self.imgView.image = [UIImage imageNamed:imgStr];
    self.titleLabel.text = @"评审者";
    if(!ower) {
        [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.left.equalTo(_imgView.mas_right).offset(15);
            make.right.equalTo(self.contentView).offset(-20);
            make.centerY.height.equalTo(self.contentView);
        }];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if([hasLikeMr isEqual:@1]) {
            self.rightLabel.text = @"+1";
            [self.rightLabel setTextColor:kColorBrandGreen];
            [self.likeImgView setHidden:NO];
            self.likeImgView.image = [UIImage imageNamed:@"EPointLikeHead"];
        } else {
            [self.rightLabel setTextColor:kColorBrandGreen];
            self.rightLabel.text = @"撤销 +1";
            [self.likeImgView setHidden:YES];
        }
    } else {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.rightLabel.text = @"添加";
        [self.rightLabel setTextColor:kColor999];
        [self.likeImgView setHidden:YES];
    }
}

-(void) cantReviewer {
    self.rightLabel.hidden = YES;
    self.likeImgView.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryNone;
}

+ (CGFloat)cellHeight{
    return 44.0;
}

@end
