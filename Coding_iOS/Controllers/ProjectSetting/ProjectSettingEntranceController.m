//
//  ProjectSettingEntranceController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/25.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "ProjectSettingEntranceController.h"
#import "UserOrProjectTweetsViewController.h"
#import "ProjectViewController.h"

@interface ProjectSettingEntranceController ()

@end

@implementation ProjectSettingEntranceController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        UserOrProjectTweetsViewController *vc = [UserOrProjectTweetsViewController new];
        vc.curTweets = [Tweets tweetsWithProject:self.project];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1){
        ProjectViewController *vc = [[ProjectViewController alloc] init];
        vc.myProject = self.project;
        vc.curType = ProjectViewTypeMembers;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *vc = segue.destinationViewController;
    [vc setValue:self.project forKey:@"project"];
}

@end
