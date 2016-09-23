//
//  TopicListButton.m
//  Coding_iOS
//
//  Created by 周文敏 on 15/4/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "TopicListButton.h"

@interface TopicListButton ()
{
    UILabel *_titleLbl;
    UIImageView *_iconImg;
}
@end

@implementation TopicListButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - kPaddingLeftWidth - 20, kMySegmentControl_Height)];
        _titleLbl.font = [UIFont systemFontOfSize:16];
        _titleLbl.textColor = kColor666;
        [self addSubview:_titleLbl];
        
        _iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 18, (kMySegmentControl_Height - 18) * 0.5, 18, 18)];
        [_iconImg setImage:[UIImage imageNamed:@"tag_list_s"]];
        [self addSubview:_iconImg];
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kMySegmentControl_Height - 0.6, kScreen_Width - kPaddingLeftWidth, 0.6)];
        bottomLineView.backgroundColor = kColorDDD;
        [self addSubview:bottomLineView];
    }
    return self;
}

+ (instancetype)buttonWithTitle:(NSString *)title andNumber:(NSInteger)number
{
    TopicListButton *button = [[TopicListButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height)];
    [button setTitleLbl:[NSString stringWithFormat:@"%@（%ld）", title, (long)number]];
    return button;
}

+ (instancetype)buttonWithTitle:(NSString *)title
{
    TopicListButton *button = [[TopicListButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height)];
    [button setTitleLbl:title];
    return button;
}

- (void)setTitleLbl:(NSString *)title
{
    _titleLbl.text = title;
}

- (void)setIconHide:(BOOL)hide
{
    _iconImg.hidden = hide;
}

@end
