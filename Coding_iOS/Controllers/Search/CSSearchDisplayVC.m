//
//  CSSearchDisplayVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/14.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSSearchDisplayVC.h"

#import <QuartzCore/QuartzCore.h>
#import "TopicHotkeyView.h"

@interface CSSearchDisplayVC ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIButton *btnMore;

- (void)initSubViewsInContentView;

- (void)didClickedMoreHotkey:(id)sender;

@end

@implementation CSSearchDisplayVC

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    
    if(!visible) {
    
        if(_contentView) {
        
            [_contentView removeFromSuperview];
            [super setActive:visible animated:animated];
        }
    }else {
    
        [super setActive:visible animated:animated];
        NSArray *subViews = self.searchContentsController.view.subviews;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
            
            for (UIView *view in subViews) {
                
                if ([view isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                    
                    NSArray *sub = view.subviews;
                    ((UIView*)sub[2]).hidden = YES;
                }
            }
            
            if(!_contentView) {
                
                _contentView = [[UIView alloc] init];
                _contentView.frame = CGRectMake(0.0f, 60.0f, kScreen_Width, kScreen_Height - 60.0f);
                _contentView.backgroundColor = [UIColor whiteColor];
                
                [self initSubViewsInContentView];
            }
            
            [self.searchBar.superview addSubview:_contentView];
            [self.searchBar.superview bringSubviewToFront:_contentView];
            
        } else {
            
            [[subViews lastObject] removeFromSuperview];
        }
    }
}

#pragma mark -
#pragma mark Private Method

- (void)initSubViewsInContentView {

    UILabel *lblHotKey = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 5.0f, 100, 30.0f)];
//    lblHotKey.backgroundColor = [UIColor redColor];
    [lblHotKey setText:@"热门话题"];
    [lblHotKey setFont:[UIFont systemFontOfSize:14.0f]];
    [lblHotKey setTextColor:[UIColor colorWithHexString:@"0x999999"]];
    [_contentView addSubview:lblHotKey];
    
    UIImage *imgMore = [UIImage imageNamed:@"me_info_arrow_left"];
    _btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMore = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 31.0f, 10.0f, 20.0f, 20.0f)];
    [_btnMore setImage:imgMore forState:UIControlStateNormal];
    [_btnMore addTarget:self action:@selector(didClickedMoreHotkey:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_btnMore];
    
//    UILabel *lblTopic = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 30.0f, 160.0f, 25.0f)];
//    [lblTopic setText:@"    #我最爱的编程语言#  "];
//    [lblTopic setFont:[UIFont systemFontOfSize:14.0f]];
//    [lblTopic setTextColor:[UIColor colorWithHexString:@"0x3bbd79"]];
//    lblTopic.layer.borderColor = [[UIColor colorWithHexString:@"0x3bbd79"] CGColor];
//    lblTopic.layer.borderWidth = 1.0f;
//    lblTopic.layer.cornerRadius = 13.0f;
//    [_contentView addSubview:lblTopic];
    
//    TopicItemView *itemView = [[TopicItemView alloc] initWithTopic:@"#Coding#" Color:[UIColor colorWithHexString:@"0xb5b5b5"]];
//    itemView.frame = CGRectMake(12.0f, 50.0f, 100.0, 100.0f);
//    [_contentView addSubview:itemView];
    
    TopicHotkeyView *test = [[TopicHotkeyView alloc] initWithHotkeys:@[@"我最爱的编程语言", @"coding", @"PHP", @"gopher china", @"悬赏80,000", @"Coding客户端里私信做个轮询好不好"]
                                                           withFrame:CGRectMake(0.0f, 40.0f, 160.0f, 25.0f)];
    [_contentView addSubview:test];
}

- (void)didClickedMoreHotkey:(id)sender {

    
}

@end
