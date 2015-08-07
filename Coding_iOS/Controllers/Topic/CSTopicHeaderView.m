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
@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,strong)NSMutableArray *avatalist;
@property (nonatomic,assign)BOOL watched;
@end

@implementation CSTopicHeaderView{
    UILabel *_nameLabel;
    UILabel *_userCountLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xeeeeee"];
        
        //count区域
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, kScreen_Width - 110, 18)];//12
        _nameLabel.font = [UIFont boldSystemFontOfSize:15];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_nameLabel];
        
        _userCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 36, _nameLabel.width, 12)];
        _userCountLabel.font = [UIFont systemFontOfSize:12];
        _userCountLabel.backgroundColor = [UIColor clearColor];
        _userCountLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        _userCountLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_userCountLabel];
        
        _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 32)];
        _rightBtn.centerY = 58/2;
        _rightBtn.right = kScreen_Width - 13;
        [_rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightBtn];
        
        
        //头像区域
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 58, kScreen_Width, 115)];
        subView.backgroundColor = [UIColor whiteColor];
        [self addSubview:subView];
        
        UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(12, 41, kScreen_Width - 12, 0.5)];
        sepLine.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        [subView addSubview:sepLine];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(12, 15, 150, 15)];
        label1.font = [UIFont systemFontOfSize:13];
        label1.backgroundColor = [UIColor clearColor];
        label1.textColor = [UIColor colorWithHexString:@"0x333333"];
        label1.textAlignment = NSTextAlignmentLeft;
        label1.text = @"热门参与者";
        [subView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 100, 15)];
        label2.right = kScreen_Width - 25;
        label2.font = [UIFont systemFontOfSize:13];
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor colorWithHexString:@"0x999999"];
        label2.textAlignment = NSTextAlignmentRight;
        label2.text = @"查看全部";
        [subView addSubview:label2];
        
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"task_icon_arrow"]];
        arrow.centerY = label2.centerY;
        arrow.right = kScreen_Width - 12;
        [subView addSubview:arrow];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 42)];
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(goAllUsers) forControlEvents:UIControlEventTouchUpInside];
        [subView addSubview:btn];
        
        _avatalist = nil;
    }
    return self;
}

- (void)goAllUsers {
    CSLikesVC *vc = [[CSLikesVC alloc] init];
    vc.topicID = [self.refTopic[@"id"]intValue];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)rightBtnClicked {
    if (!self.refTopic) {
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"api/tweet_topic/%@/%@", _refTopic[@"id"], (_watched? @"unwatch":@"watch")];
    
    [[Coding_NetAPIManager sharedManager]request_Topic_DoWatch_WithUrl:path andBlock:^(id data, NSError *error) {
        if (data) {
            self.watched = !self.watched;
            NSString *imageName = self.watched? @"btn_followed_yes":@"btn_followed_not";
            [self.rightBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        }
    }];
    
}

- (void)updateWithTopic:(NSDictionary *)data {
    _watched = [data[@"watched"] boolValue];
    _refTopic = data;
    _nameLabel.text = [NSString stringWithFormat:@"#%@#",data[@"name"]];
    
    _userCountLabel.text = [NSString stringWithFormat:@"%@人参与/%@人关注",data[@"speackers"],data[@"watchers"]];
    
    NSString *imageName = self.watched? @"btn_followed_yes":@"btn_followed_not";
    [_rightBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
}

- (void)updateWithJoinedUsers:(NSArray*)userlist {
    if (!_avatalist) {
        _avatalist = [NSMutableArray array];
        
        for (int i=0; i<userlist.count; i++) {
            User *user = userlist[i];
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 114, 42, 42)];
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


