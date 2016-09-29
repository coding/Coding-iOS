//
//  ConversationCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ConversationCell.h"

@interface ConversationCell ()
@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *name, *msg, *time;

@end

@implementation ConversationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([ConversationCell cellHeight]-48)/2, 48, 48)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        if (!_name) {
            _name = [[UILabel alloc] initWithFrame:CGRectMake(75, 8, 150, 25)];
            _name.font = [UIFont systemFontOfSize:17];
            _name.textColor = kColor222;
            _name.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:_name];
        }
        if (!_time) {
            _time = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 100-kPaddingLeftWidth, 8, 100, 25)];
            _time.font = [UIFont systemFontOfSize:12];
            _time.textColor = kColor999;
            _time.textAlignment = NSTextAlignmentRight;
            _time.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:_time];
        }
        if (!_msg) {
            _msg = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, kScreen_Width-75-30 -kPaddingLeftWidth, 25)];
            _msg.font = [UIFont systemFontOfSize:15];
            _msg.backgroundColor = [UIColor clearColor];
            _msg.textColor = kColor999;
            [self.contentView addSubview:_msg];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_curPriMsg) {
        return;
    }
    [_userIconView sd_setImageWithURL:[_curPriMsg.friend.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];

    
    _name.text = _curPriMsg.friend.name;
    _time.text = [_curPriMsg.created_at stringDisplay_MMdd];
    _msg.textColor = kColor999;
    NSMutableString *textMsg = [[NSMutableString alloc] initWithString:_curPriMsg.content];
    if (_curPriMsg.hasMedia) {
        [textMsg appendString:@"[图片]"];
    }
    if ([_curPriMsg isVoice]) {
        [textMsg setString:@"[语音]"];
        if (_curPriMsg.played.intValue == 0) {
            _msg.textColor = kColorBrandGreen;
        }
    }
    _msg.text = textMsg;
    
    NSString *badgeTip = @"";
    if (_curPriMsg.unreadCount && _curPriMsg.unreadCount.integerValue > 0) {
        if (_curPriMsg.unreadCount.integerValue > 99) {
            badgeTip = @"99+";
        }else{
            badgeTip = _curPriMsg.unreadCount.stringValue;
        }
    }
    [self.contentView addBadgeTip:badgeTip withCenterPosition:CGPointMake(kScreen_Width-25, CGRectGetMaxY(_time.frame) +10)];
}

+ (CGFloat)cellHeight{
    return 61;
}

@end
