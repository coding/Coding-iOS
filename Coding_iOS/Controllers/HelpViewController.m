//
//  HelpViewController.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/8.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "HelpViewController.h"
#import "EditTopicViewController.h"

@implementation HelpViewController

+ (instancetype)vcWithHelpStr{
    NSString *curUrlStr = @"/help/doc/mobile/index.html";
    NSURL *curUrl = [NSURL URLWithString:curUrlStr relativeToURL:[NSURL URLWithString:[NSObject baseURLStr]]];
    return [[self alloc] initWithURL:curUrl];
}

- (void)setTitle:(NSString *)title{
    [super setTitle:@"帮助中心"];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"反馈" style:UIBarButtonItemStylePlain target:self action:@selector(goToFeedBack)] animated:YES];
}

- (void)goToFeedBack{
    EditTopicViewController *vc = [[EditTopicViewController alloc] init];
    vc.curProTopic = [ProjectTopic feedbackTopic];
    vc.type = TopicEditTypeFeedBack;
    vc.topicChangedBlock = nil;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
