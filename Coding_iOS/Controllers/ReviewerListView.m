//
//  NSObject+ReviewerListView.m
//  Coding_iOS
//
//  Created by hardac on 16/3/25.
//  Copyright © 2016年 Coding. All rights reserved.
//
#import "ReviewerListView.h"
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

@interface ReviewerListView ()<UISearchBarDelegate, SWTableViewCellDelegate>
@property (nonatomic, strong) Projects *myProjects;
@property (nonatomic , copy) ReviewerListViewBlock block;
@property (nonatomic, strong) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (nonatomic, strong) UIView *statusView;
@property (nonatomic,strong) UILabel *noticeLab;
@end

@implementation ReviewerListView

static NSString *const kTitleKey = @"kTitleKey";
static NSString *const kValueKey = @"kValueKey";


- (id)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(ReviewerListViewBlock)block  tabBarHeight:(CGFloat)tabBarHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myProjects = projects;
        _block = block;
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] init];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
             [tableView registerNib:[UINib nibWithNibName:kCellIdentifier_ReviewCell bundle:nil] forCellReuseIdentifier:kCellIdentifier_ReviewCell];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
                //make.edges.top.equalTo(self.navigationController);
            }];
            tableView;
        });
      
        _mySearchBar = ({
            UISearchBar *searchBar = [[UISearchBar alloc] init];
            searchBar.delegate = self;
            [searchBar sizeToFit];
            [searchBar setPlaceholder:@"项目名称/创建人"];
            searchBar;
            });
        _myTableView.tableHeaderView = _mySearchBar;
       
        
        if (_myProjects.list.count > 0) {
            [_myTableView reloadData];
        }else{
            [self sendRequest];
        }
        
    }
    return self;
}
- (void)setProjects:(Projects *)projects{
    self.myProjects = projects;
    [self setupDataList];
}

- (void)setupDataList{
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    [_dataList removeAllObjects];
    if (_myProjects.type < ProjectsTypeToChoose) {
        NSArray *pinList = _myProjects.pinList, *noPinList = _myProjects.noPinList;
        if (pinList.count > 0) {
            [_dataList addObject:@{kTitleKey : @"常用项目",
                                   kValueKey : pinList}];
        }
        if (noPinList.count > 0) {
            [_dataList addObject:@{kTitleKey : @"一般项目",
                                   kValueKey : noPinList}];
        }
    }else{
        NSMutableArray *list = [self updateFilteredContentForSearchString:self.mySearchBar.text];
        if (list.count > 0) {
            [list sortUsingComparator:^NSComparisonResult(Project *obj1, Project *obj2) {
                return (obj1.pin.integerValue < obj2.pin.integerValue);
            }];
            [_dataList addObject:@{kTitleKey : @"一般项目",
                                   kValueKey : list}];
        }
    }
}

- (NSString *)titleForSection:(NSUInteger)section{
    if (section < self.dataList.count) {
        return [[self.dataList objectAtIndex:section] valueForKey:kTitleKey];
    }
    return nil;
}

- (NSArray *)valueForSection:(NSUInteger)section{
    if (section < self.dataList.count) {
        return [[self.dataList objectAtIndex:section] valueForKey:kValueKey];
    }
    return nil;
}

- (void)refreshMore{
    if (_myProjects.isLoading || !_myProjects.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _myProjects.willLoadMore = YES;
    [self sendRequest];
}


- (void)sendRequest{
    if (_myProjects.list.count <= 0) {
        [self beginLoading];
    }
    //都先隐藏~后续根据数据状态显示~
    self.blankPageView.hidden=TRUE;
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Projects_WithObj:_myProjects andBlock:^(Projects *data, NSError *error) {
        [weakSelf endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        
        if (data) {
            [weakSelf.myProjects configWithProjects:data];
            [weakSelf setupDataList];
            [weakSelf.myTableView reloadData];
        }
        EaseBlankPageType blankPageType;
        if (weakSelf.myProjects.type < ProjectsTypeTaProject
            || [weakSelf.myProjects.curUser.global_key isEqualToString:[Login curLoginUser].global_key]) {
            //            blankPageType = EaseBlankPageTypeProject;
            //再做细分  全部,创建,参与,关注,收藏
            switch (weakSelf.myProjects.type) {
                case ProjectsTypeAll:
                    blankPageType = EaseBlankPageTypeProject_ALL;
                    break;
                case ProjectsTypeCreated:
                    blankPageType = EaseBlankPageTypeProject_CREATE;
                    break;
                case ProjectsTypeJoined:
                    blankPageType = EaseBlankPageTypeProject_JOIN;
                    break;
                case ProjectsTypeWatched:
                    blankPageType = EaseBlankPageTypeProject_WATCHED;
                    break;
                case ProjectsTypeStared:
                    blankPageType = EaseBlankPageTypeProject_STARED;
                    break;
                default:
                    blankPageType = EaseBlankPageTypeProject;
                    break;
            }
        }else{
            blankPageType = EaseBlankPageTypeProjectOther;
        }
        [weakSelf configBlankPage:blankPageType hasData:(weakSelf.myProjects.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            
        }];
        
        //空白页按钮事件
        self.blankPageView.clickButtonBlock=^(EaseBlankPageType curType) {
            weakSelf.clickButtonBlock(curType);
        };
        
        weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myProjects.canLoadMore;
        
    }];
}
#pragma mark Table M

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //开启header模式
    //    return (self.myProjects.type < ProjectsTypeToChoose)&&(section==0)? 44: 0;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_dataList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self valueForSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ReviewCell forIndexPath:indexPath];
    
    [cell configureCellWithHeadIconURL:@"test" reviewIconURL:@"PointLikeHead" userName:@"test" userState:@"test"];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_useNewStyle) {
        if (_myProjects.type < ProjectsTypeTaProject) {
            return kProjectAboutMeListCellHeight;
        }else if (_myProjects.type==ProjectsTypeAllPublic){
            return kProjectPublicListCellHeight;
        }else{
            return [ProjectListTaCell cellHeight];
        }
    }else
    {
        return (_myProjects.type < ProjectsTypeTaProject)?[ProjectListCell cellHeight]:[ProjectListTaCell cellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    currentCell.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    Project *curPro = [[self valueForSection:indexPath.section] objectAtIndex:indexPath.row];
    
    __weak typeof(curPro) weakPro = curPro;
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Project_Pin:curPro andBlock:^(id data, NSError *error) {
        if (data) {
            weakPro.pin = @(!weakPro.pin.boolValue);
            [weakSelf setupDataList];
            [weakSelf.myTableView reloadData];
        }
    }];
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
    [self setupDataList];
    [self.myTableView reloadData];
}

- (NSMutableArray *)updateFilteredContentForSearchString:(NSString *)searchString{
    // start out with the entire list
    NSMutableArray *searchResults = [self.myProjects.list mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedStr = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedStr.length > 0)
    {
        searchItems = [strippedStr componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems)
    {
        // each searchString creates an OR predicate for: name, global_key
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        //        owner_user_name field matching
        lhs = [NSExpression expressionForKeyPath:@"owner_user_name"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // at this OR predicate to ourr master AND predicate
        NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    NSCompoundPredicate *finalCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    
    [searchResults filterUsingPredicate:finalCompoundPredicate];
    return searchResults;
}

@end
