//
//  NSObject+ReviewerListView.m
//  Coding_iOS
//
//  Created by hardac on 16/3/25.
//  Copyright © 2016年 Coding. All rights reserved.
//
#import "ReviewerListController.h"
#import "ReviewCell.h"
#import "ProjectListCell.h"
#import "ProjectListTaCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"

//新系列 cell
#import "ProjectAboutMeListCell.h"
#import "ProjectAboutOthersListCell.h"
#import "ProjectPublicListCell.h"
#import "SVPullToRefresh.h"

@interface ReviewerListController ()<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@end

@implementation ReviewerListController

static NSString *const kTitleKey = @"kTitleKey";
static NSString *const kValueKey = @"kValueKey";

-(void)viewDidLoad {
    self.title = @"评审人";
    [self.myTableView registerNib:[UINib nibWithNibName:kCellIdentifier_ReviewCell bundle:nil] forCellReuseIdentifier:kCellIdentifier_ReviewCell];
    /*_mySearchBar = ({
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        [searchBar sizeToFit];
        [searchBar setPlaceholder:@"项目名称/创建人"];
        searchBar;
    });
    [self.myTableView sizeToFit];
    _myTableView.tableHeaderView = _mySearchBar;*/
}

- (id)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(ReviewerListControllerBlock)block  tabBarHeight:(CGFloat)tabBarHeight
{
    //self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
#pragma mark Table M

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.reviewers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ReviewCell forIndexPath:indexPath];
    
 //   [cell configureCellWithHeadIconURL:@"test" reviewIconURL:@"PointLikeHead" userName:@"test" userState:@"test"];
    [cell initCellWithReviewer:self.reviewers[indexPath.row]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ReviewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    currentCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}
#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.mySearchBar resignFirstResponder];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchProjectWithStr:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self searchProjectWithStr:searchBar.text];
}

- (void)searchProjectWithStr:(NSString *)string{
    [self.myTableView reloadData];
}

@end
