//
//  ProjectListView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectListView.h"
#import "ProjectListCell.h"
#import "ProjectListTaCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"

//新系列 cell
#import "ProjectAboutMeListCell.h"
#import "ProjectAboutOthersListCell.h"
#import "ProjectPublicListCell.h"
#import "SVPullToRefresh.h"

@interface ProjectListView ()<UISearchBarDelegate, SWTableViewCellDelegate>
@property (nonatomic, strong) Projects *myProjects;
@property (nonatomic , copy) ProjectListViewBlock block;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (nonatomic, strong) UIView *statusView;
@property (nonatomic,strong) UILabel *noticeLab;
@end

@implementation ProjectListView

static NSString *const kTitleKey = @"kTitleKey";
static NSString *const kValueKey = @"kValueKey";

#pragma TabBar
- (void)tabBarItemClicked{
    if (_myTableView.contentOffset.y > 0) {
        [_myTableView setContentOffset:CGPointZero animated:YES];
    }else if (!self.myRefreshControl.isAnimating){
        [self.myRefreshControl beginRefreshing];
        [self.myTableView setContentOffset:CGPointMake(0, -44)];
        [self refresh];
    }
}


- (id)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(ProjectListViewBlock)block  tabBarHeight:(CGFloat)tabBarHeight
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
            [tableView registerClass:[ProjectListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectList];
            [tableView registerClass:[ProjectListTaCell class] forCellReuseIdentifier:kCellIdentifier_ProjectListTaCell];
            [tableView registerClass:[ProjectAboutMeListCell class] forCellReuseIdentifier:@"ProjectAboutMeListCell"];
            [tableView registerClass:[ProjectAboutOthersListCell class] forCellReuseIdentifier:@"ProjectAboutOthersListCell"];
            [tableView registerClass:[ProjectPublicListCell class] forCellReuseIdentifier:@"ProjectPublicListCell"];
            
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            if (tabBarHeight != 0 && projects.type < ProjectsTypeTaProject) {
                UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, tabBarHeight, 0);
                tableView.contentInset = insets;
                tableView.scrollIndicatorInsets = insets;
            }
            tableView;
        });
        if (projects.type < ProjectsTypeToChoose||projects.type==ProjectsTypeAllPublic) {
            _mySearchBar = nil;
            _myTableView.tableHeaderView = nil;
        }else{
            _mySearchBar = ({
                UISearchBar *searchBar = [[UISearchBar alloc] init];
                searchBar.delegate = self;
                [searchBar sizeToFit];
                [searchBar setPlaceholder:@"项目名称/创建人"];
                searchBar;
            });
            _myTableView.tableHeaderView = _mySearchBar;
        }

        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        __weak typeof(self) weakSelf = self;
        
        [_myTableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf refreshMore];
        }];

        if (_myProjects.list.count > 0) {
            [_myTableView reloadData];
        }else{
            [self sendRequest];
        }
        
        NSString *headerTitle=[weakSelf getSectionHeaderName];
        if (headerTitle.length>0) {
            self.statusView=[self getHeaderViewWithStr:headerTitle color:kColorTableBG leftNoticeColor:[UIColor colorWithHexString:@"3BBD79"]];
            [self addSubview:self.statusView];
        }
//        _statusView.hidden=TRUE;

    }
    return self;
}
- (void)setProjects:(Projects *)projects{
    self.myProjects = projects;
    [self setupDataList];
    [self refreshUI];
}

-(void)setUseNewStyle:(BOOL)useNewStyle{
    _useNewStyle=useNewStyle;
    if (_useNewStyle) {
        [_myTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.top.equalTo(@(44));
        }];
    }
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

- (void)refreshUI{
    [_myTableView reloadData];
    [self refreshFirst];
}
- (void)refreshToQueryData{
    [self refresh];
}

- (void)refresh{
//    _statusView.hidden=TRUE;
    NSString *headerTitle=[self getSectionHeaderName];
    if (headerTitle.length>0) {
        self.noticeLab.text=headerTitle;
        self.statusView.hidden=FALSE;
    }
    
    if (_myProjects.isLoading) {
        return;
    }
    [self sendRequest];
}

- (void)refreshFirst{
    if (_myProjects && !_myProjects.list) {
        [self performSelector:@selector(refresh) withObject:nil afterDelay:0.3];
    }
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
        [weakSelf.myRefreshControl endRefreshing];
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
            [weakSelf refresh];
        }];
        
        //空白页按钮事件
        self.blankPageView.clickButtonBlock=^(EaseBlankPageType curType) {
            weakSelf.clickButtonBlock(curType);
        };
        
        weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myProjects.canLoadMore;
        //空白页加载后显示 开启header
//        self.blankPageView.loadAndShowStatusBlock=^() {
//            NSString *headerTitle=[weakSelf getSectionHeaderName];
//            if (headerTitle.length>0) {
//                weakSelf.noticeLab.text=headerTitle;
//                weakSelf.statusView.hidden=FALSE;
//            }
//        };

    }];
}

-(NSString*)getSectionHeaderName{
    switch (self.myProjects.type) {
        case ProjectsTypeAll:
            return @"全部项目";
            break;
        case ProjectsTypeJoined:
            return @"我参与的";
            break;
        case ProjectsTypeCreated:
            return @"我创建的";
            break;
        case ProjectsTypeWatched:
            return @"我关注的";
            break;
        case ProjectsTypeStared:
            return @"我收藏的";
            break;
        default:
            return nil;
            break;
    }
}

#pragma mark Table M

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //开启header模式
//    return (self.myProjects.type < ProjectsTypeToChoose)&&(section==0)? 44: 0;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //开启header模式

//    if(self.myProjects.type < ProjectsTypeToChoose){
//        NSString *headerTitle=[self getSectionHeaderName];
//        if (headerTitle.length==0) {
//            return nil;
//        }
//        UIView *headerView=[tableView getHeaderViewWithStr:headerTitle color:kColorTableBG leftNoticeColor:[UIColor colorWithHexString:@"3BBD79"] andBlock:nil];
//        return headerView;
//    }else{
//        return nil;
//    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_dataList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self valueForSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Project *curPro = [[self valueForSection:indexPath.section] objectAtIndex:indexPath.row];

    if (_useNewStyle) {
        if (_myProjects.type < ProjectsTypeWatched) {
            ProjectAboutMeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectAboutMeListCell" forIndexPath:indexPath];
            [cell setProject:curPro hasSWButtons:self.myProjects.type == ProjectActivityTypeAll?YES:NO hasBadgeTip:YES hasIndicator:NO];
            cell.delegate = self;
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpaceAndSectionLine:kPaddingLeftWidth];
            return cell;
        }else if (_myProjects.type==ProjectsTypeWatched||_myProjects.type==ProjectsTypeStared){
            ProjectAboutOthersListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectAboutOthersListCell" forIndexPath:indexPath];
            [cell setProject:curPro hasSWButtons:self.myProjects.type == ProjectActivityTypeAll?YES:NO hasBadgeTip:YES hasIndicator:NO];
            cell.delegate = self;
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpaceAndSectionLine:kPaddingLeftWidth];
            return cell;
        }else if (_myProjects.type==ProjectsTypeAllPublic){
            ProjectPublicListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectPublicListCell" forIndexPath:indexPath];
            [cell setProject:curPro hasSWButtons:self.myProjects.type == ProjectActivityTypeAll?YES:NO hasBadgeTip:YES hasIndicator:NO];
            cell.delegate = self;
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpaceAndSectionLine:kPaddingLeftWidth];
            return cell;
        }
        else{
            ProjectListTaCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectListTaCell forIndexPath:indexPath];
            cell.project = curPro;
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpaceAndSectionLine:kPaddingLeftWidth];
            return cell;
        }
    }else
    {
        if (_myProjects.type < ProjectsTypeTaProject) {
            ProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectList forIndexPath:indexPath];
            if (self.myProjects.type == ProjectsTypeToChoose) {
                [cell setProject:curPro hasSWButtons:NO hasBadgeTip:NO hasIndicator:NO];
            }else{
                [cell setProject:curPro hasSWButtons:YES hasBadgeTip:YES hasIndicator:YES];
            }
            cell.delegate = self;
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
            return cell;
        }else{
            ProjectListTaCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectListTaCell forIndexPath:indexPath];
            cell.project = curPro;
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
            return cell;
        }

    }
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_block) {
        _block([[self valueForSection:indexPath.section] objectAtIndex:indexPath.row]);
    }
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


- (UIView *)getHeaderViewWithStr:(NSString *)headerStr color:(UIColor *)color leftNoticeColor:(UIColor*)noticeColor {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width,44)];
    headerView.backgroundColor=color;
    
    UIView* noticeView=[[UIView alloc] initWithFrame:CGRectMake(12, 14, 3, 16)];
    noticeView.backgroundColor=noticeColor;
    [headerView addSubview:noticeView];
    
    
    _noticeLab = [[UILabel alloc] initWithFrame:CGRectMake(12+3+10, 7, kScreen_Width-20, 30)];
    _noticeLab.backgroundColor = [UIColor clearColor];
    _noticeLab.textColor = [UIColor colorWithHexString:@"0x999999"];
    if (kDevice_Is_iPhone6Plus) {
        _noticeLab.font = [UIFont systemFontOfSize:14];
    }else{
        _noticeLab.font = [UIFont systemFontOfSize:kScaleFrom_iPhone5_Desgin(12)];
    }
    
    CGFloat lineHeight = (1.0f / [UIScreen mainScreen].scale);
    UIView *seperatorline=[[UIView alloc] initWithFrame:CGRectMake(0, 44-lineHeight,kScreen_Width , lineHeight)];
    seperatorline.backgroundColor=[UIColor colorWithHexString:@"0xdddddd"];
    [headerView addSubview:seperatorline];
    
    _noticeLab.text = headerStr;
    [headerView addSubview:_noticeLab];
    return headerView;
}

@end
