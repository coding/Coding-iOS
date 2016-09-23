//
//  CSTopicUsersCell.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/27.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSTopicHeaderView.h"
#import "Coding_NetAPIManager.h"
#import "User.h"
#import "CSLikesVC.h"

@interface CSTopicHeaderView ()
@property (nonatomic,strong)NSDictionary *refTopic;
//@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,strong)NSMutableArray *avatalist;
@property (nonatomic,assign)BOOL watched;
@end

@implementation CSTopicHeaderView{
//    UILabel *_nameLabel;
    UILabel *_userCountLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(12, 41, kScreen_Width - 12, 0.5)];
        sepLine.backgroundColor = kColorDDD;
        [self addSubview:sepLine];
        
        _userCountLabel = ({
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(12, 15, 150, 15)];
            label1.font = [UIFont systemFontOfSize:13];
            label1.backgroundColor = [UIColor clearColor];
            label1.textColor = [UIColor colorWithHexString:@"0x333333"];
            label1.textAlignment = NSTextAlignmentLeft;
            [self addSubview:label1];
            label1;
        });
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 100, 15)];
        label2.right = kScreen_Width - 25;
        label2.font = [UIFont systemFontOfSize:13];
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = kColor999;
        label2.textAlignment = NSTextAlignmentRight;
        label2.text = @"查看全部";
        [self addSubview:label2];
        
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"task_icon_arrow"]];
        arrow.centerY = label2.centerY;
        arrow.right = kScreen_Width - 12;
        [self addSubview:arrow];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 42)];
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(goAllUsers) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        _avatalist = nil;
    }
    return self;
}

- (void)goAllUsers {
    CSLikesVC *vc = [[CSLikesVC alloc] init];
    vc.topicID = [self.refTopic[@"id"]intValue];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)updateWithTopic:(NSDictionary *)data {
    _refTopic = data;
    _userCountLabel.text = [NSString stringWithFormat:@"%@人参与",data[@"speackers"]];
}

- (void)updateWithJoinedUsers:(NSArray*)userlist {
    if (!_avatalist) {
        _avatalist = [NSMutableArray array];
        
        for (int i=0; i<userlist.count; i++) {
            User *user = userlist[i];
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 57, 42, 42)];
            [iconView doCircleFrame];
            iconView.left = 16 + i *(9 + 42);
            if (iconView.right > kScreen_Width) {
                break;
            }
            
            [self addSubview:iconView];
            
            [iconView sd_setImageWithURL:[user.avatar urlImageWithCodePathResizeToView:iconView] placeholderImage:[UIImage imageNamed:@"placeholder_monkey_round_48"]];
            
            [_avatalist addObject:iconView];
        }
    }
}

@end


