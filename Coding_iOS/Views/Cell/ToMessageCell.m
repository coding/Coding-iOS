//
//  ToMessageCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ToMessageCell.h"

@implementation ToMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.font = [UIFont systemFontOfSize:17];
        self.textLabel.textColor = kColor222;
    }
    return self;
}

- (void)setType:(ToMessageType)type{
    _type = type;
    NSString *imageName, *titleStr;
    switch (_type) {
        case ToMessageTypeAT:
            imageName = @"messageAT";
            titleStr = @"@我的";
            break;
        case ToMessageTypeComment:
            imageName = @"messageComment";
            titleStr = @"评论";
            break;
        case ToMessageTypeSystemNotification:
            imageName = @"messageSystem";
            titleStr = @"系统通知";
            break;
            case ToMessageTypeProjectFollows:
            imageName = @"messageProjectFollows";
            titleStr = @"我的关注";
            break;
            case ToMessageTypeProjectFans:
            imageName = @"messageProjectFans";
            titleStr = @"我的粉丝";
            break;
        default:
            break;
    }
    self.imageView.image = [UIImage imageNamed:imageName];
    self.textLabel.text = titleStr;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(kPaddingLeftWidth, ([ToMessageCell cellHeight]-48)/2, 48, 48);
    self.textLabel.frame = CGRectMake(75, ([ToMessageCell cellHeight]-30)/2, (kScreen_Width - 120), 30);
    NSString *badgeTip = @"";
    if (_unreadCount && _unreadCount.integerValue > 0) {
        if (_unreadCount.integerValue > 99) {
            badgeTip = @"99+";
        }else{
            badgeTip = _unreadCount.stringValue;
        }
        self.accessoryType = UITableViewCellAccessoryNone;
    }else{
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [self.contentView addBadgeTip:badgeTip withCenterPosition:CGPointMake(kScreen_Width-25, [ToMessageCell cellHeight]/2)];
}

+ (CGFloat)cellHeight{
    return 61.0;
}

@end
