//
//  NSObject+DynamicActivityCell.m
//  Coding_iOS
//
//  Created by hardac on 16/3/27.
//  Copyright © 2016年 Coding. All rights reserved.
//


#define kTaskActivityCell_LeftContentPading (kPaddingLeftWidth + 40)
#define kTaskActivityCell_ContentWidth (kScreen_Width - kTaskActivityCell_LeftContentPading - kPaddingLeftWidth)

#import "DynamicActivityCell.h"


@interface DynamicActivityCell ()
@property (strong, nonatomic) UIImageView *tipIconView;
@property (strong, nonatomic) UIImageView *timeLineView;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UILabel *tipLabel;
@end

@implementation DynamicActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_timeLineView) {
            _timeLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2, 1)];
            [_timeLineView setImage:[UIImage imageNamed:@"timeline_line_read"]];
            [self.contentView addSubview:_timeLineView];
        }
        if (!_tipIconView) {
            CGFloat borderWidth = 2;
            _tipIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth - borderWidth, 10, 28 + 2*borderWidth, 28 + 2*borderWidth)];
            _tipIconView.contentMode = UIViewContentModeCenter;
            _tipIconView.layer.masksToBounds = YES;
            _tipIconView.layer.cornerRadius = _tipIconView.frame.size.width/2;
            _tipIconView.layer.borderWidth = borderWidth;
            _tipIconView.layer.borderColor = kColorTableBG.CGColor;
            
            [self.contentView addSubview:_tipIconView];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kTaskActivityCell_LeftContentPading, 13, kTaskActivityCell_ContentWidth, 15)];
            _contentLabel.numberOfLines = 0;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_tipLabel) {
            _tipLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kTaskActivityCell_LeftContentPading, 50, kTaskActivityCell_ContentWidth, 35)];
            _contentLabel.numberOfLines = 0;
            [self.contentView addSubview:_tipLabel];
        }
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(50, 60, 5, 20));
        }];
        [_tipLabel setBackgroundColor:[UIColor colorWithHexString:@"0xF0F0F0"]];
        [_tipLabel setTextColor:[UIColor colorWithHexString:@"0x3BBD79"]];
        _tipLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    }
    return self;
}


- (void)setCurActivity:(ProjectLineNote *)curActivity{
    _curActivity = curActivity;
    if (!_curActivity) {
        return;
    }
    NSString *tipIconImageName= [NSString stringWithFormat:@"PR_%@", _curActivity.action];
    _tipIconView.image = [UIImage imageNamed:tipIconImageName];
    NSAttributedString *attrContent = [[self class] attrContentWithObj:_curActivity];
    CGFloat contentHeight = [attrContent boundingRectWithSize:CGSizeMake(kTaskActivityCell_ContentWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    [self.contentLabel setHeight:contentHeight];
    self.contentLabel.attributedText = attrContent;
}

- (void)configTop:(BOOL)isTop andBottom:(BOOL)isBottom{
    if([self.curActivity.action isEqualToString:@"mergeChanges"]) {
        _tipLabel.hidden = NO;
        _tipLabel.text = @"   点击查看详情";
    } else {
        _tipLabel.hidden = YES;
    }
    if (isTop && isBottom) {
        _timeLineView.hidden = YES;
    }else{
        _timeLineView.hidden = NO;
        [_timeLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(2.0);
            make.centerX.equalTo(_tipIconView);
            make.top.equalTo(isTop? _tipIconView.mas_centerY: self.contentView);
            make.bottom.equalTo(isBottom? _tipIconView.mas_centerY: self.contentView);
        }];
    }
}

+ (NSAttributedString *)attrContentWithObj:(ProjectLineNote*)curActivity{
    NSString *userName, *contentStr;
    userName = curActivity.author.name? curActivity.author.name: @"";
    NSMutableAttributedString *attrContent;
    if ([curActivity.action isEqualToString:@"create"]) {
        contentStr = [NSString stringWithFormat:@"创建了合并请求 - %@", [curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"merge"]) {
        contentStr = [NSString stringWithFormat:@"合并了合并请求 - %@", [curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"review_undo"]) {
        contentStr = [NSString stringWithFormat:@"撤销了对此合并请求评审+1 - %@",[curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"review"]) {
        contentStr = [NSString stringWithFormat:@"对此合并请求评审+1 - %@",[curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"mergeChanges"]) {
        contentStr = [NSString stringWithFormat:@"对文件改动发起了讨论 - %@", [curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"grant"]) {
        contentStr = [NSString stringWithFormat:@"对此合并请求授权了合并权限 - %@", [curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"grant_undo"]) {
        contentStr = [NSString stringWithFormat:@"取消了此合并请求授权了合并权限 - %@", [curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"refuse"]) {
        contentStr = [NSString stringWithFormat:@"拒绝了合并请求 - %@", [curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"push"]) {
        contentStr = [NSString stringWithFormat:@"推送了新的提交，更新了合并请求 - %@", [curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"update_content"]) {
        contentStr = [NSString stringWithFormat:@"编辑了描述 - %@", [curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"update"]) {
        contentStr = [NSString stringWithFormat:@"编辑合并请求 - %@", [curActivity.created_at stringDisplay_HHmm]];
    } else if ([curActivity.action isEqualToString:@"update_title"]) {
        contentStr = [NSString stringWithFormat:@"编辑了标题 - %@", [curActivity.created_at stringDisplay_HHmm]];
    }
    contentStr = contentStr? contentStr: @"...";
    attrContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", userName, contentStr]];
    [attrContent addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:13],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x222222"]}
                         range:NSMakeRange(0, userName.length)];
    [attrContent addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x999999"]}
                         range:NSMakeRange(userName.length + 1, contentStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.minimumLineHeight = 18;
    [attrContent addAttribute:NSParagraphStyleAttributeName
                        value:paragraphStyle
                        range:NSMakeRange(0, [attrContent length])];
    return attrContent;
}

+ (CGFloat)cellHeightWithObj:(id)obj
               contentHeight:(CGFloat)height{
    CGFloat cellHeight = 0;
    ProjectLineNote *tmpProject = (ProjectLineNote*)obj;
    if ([obj isKindOfClass:[ProjectLineNote class]]) {
        NSAttributedString *attrContent = [self  attrContentWithObj:obj];
        CGFloat contentHeight = [attrContent boundingRectWithSize:CGSizeMake(kTaskActivityCell_ContentWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        cellHeight = ceilf(contentHeight + 26);
        cellHeight = MAX(50, cellHeight);
    }
    if([tmpProject.action isEqual:@"mergeChanges"]) {
        cellHeight += 44;
    }
    return cellHeight + height;
}
@end
