//
//  TopicListView.m
//  Coding_iOS
//
//  Created by 周文敏 on 15/4/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "TopicListView.h"
#import "TopicListButton.h"

@interface TopicListView ()
{
    UIView *_btnView;
    UIButton *_baseBtn;
    NSInteger _count;
    NSInteger _index;
}

@property (nonatomic , copy) TopicListViewBlock block;

@end

@implementation TopicListView

- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
            numbers:(NSArray *)numbers
       defaultIndex:(NSInteger)index
      selectedBlock:(TopicListViewBlock)selectedHandle
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.block = selectedHandle;
        self.clipsToBounds = YES;
        
        _baseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, self.frame.size.height)];
        _baseBtn.backgroundColor = [UIColor clearColor];
        [_baseBtn addTarget:self action:@selector(baseBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_baseBtn];
        
        _index = index;
        _count = titles.count;
        CGFloat h = _count * kMySegmentControl_Height;
        _btnView = [[UIView alloc] initWithFrame:CGRectMake(0, -h, kScreen_Width, h)];
        _btnView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_btnView];
        
        for (int i=0; i<titles.count; i++) {
            NSString *title = titles[i];
            TopicListButton *btn;
            if (numbers) {
                btn = [TopicListButton buttonWithTitle:title andNumber:[numbers[i] integerValue]];
            } else {
                btn = [TopicListButton buttonWithTitle:title];
            }
            CGRect frame = btn.frame;
            frame.origin.y = i * kMySegmentControl_Height;
            btn.frame = frame;
            btn.tag = 1000 + i;
            [btn setIconHide:(_index == i ? FALSE : TRUE)];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_btnView addSubview:btn];
        }
    }
    return self;
}

- (void)changeWithTitles:(NSArray *)titles
                 numbers:(NSArray *)numbers
            defaultIndex:(NSInteger)index
           selectedBlock:(TopicListViewBlock)selectedHandle
{
    self.block = selectedHandle;
    
    CGRect frame = _btnView.frame;
    frame.origin.y = -frame.size.height;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        _btnView.frame = frame;
    } completion:^(BOOL finished) {
        [_btnView removeFromSuperview];
        
        _index = index;
        _count = titles.count;
        CGFloat h = _count * kMySegmentControl_Height;
        _btnView = [[UIView alloc] initWithFrame:CGRectMake(0, -h, kScreen_Width, h)];
        _btnView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_btnView];
        
        for (int i=0; i<titles.count; i++) {
            NSString *title = titles[i];
            TopicListButton *btn;
            if (numbers) {
                btn = [TopicListButton buttonWithTitle:title andNumber:[numbers[i] integerValue]];
            } else {
                btn = [TopicListButton buttonWithTitle:title];
            }
            CGRect frame = btn.frame;
            frame.origin.y = i * kMySegmentControl_Height;
            btn.frame = frame;
            btn.tag = 1000 + i;
            [btn setIconHide:(_index == i ? FALSE : TRUE)];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
           [_btnView addSubview:btn];
        }
        
        [self showBtnView];
    }];
}

- (void)showBtnView
{
    CGRect frame = _btnView.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:0.3 animations:^{
        _btnView.frame = frame;
    } completion:^(BOOL finished) {
    }];
}

- (void)hideBtnView
{
    CGRect frame = _btnView.frame;
    frame.origin.y = -frame.size.height;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        _btnView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

- (void)baseBtnClick
{
    [self hideBtnView];
}

- (void)btnClick:(TopicListButton *)sender
{
    for (int i=1000; i<_count + 1000; i++) {
        TopicListButton *btn = (TopicListButton *)[_btnView viewWithTag:i];
        [btn setIconHide:(sender.tag == i ? FALSE : TRUE)];
    }
    if (_index!=sender.tag - 1000 && self.block) {
        self.block(sender.tag - 1000);
    }
    [self hideBtnView];
}

@end
