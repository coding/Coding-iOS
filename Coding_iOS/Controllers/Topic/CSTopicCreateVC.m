//
//  CSTopicCreateVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSTopicCreateVC.h"
#import "CSTopicModel.h"
#import "Coding_NetAPIManager.h"

#define kCellIdentifier_TopicNameCell @"kCellIdentifier_TopicNameCell"

@interface CSTopicCreateVC () <UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate,UISearchDisplayDelegate>
@property (nonatomic,strong)UITableView *listView;
@property (nonatomic,strong)UISearchBar *searchBar;
@property (nonatomic,strong)UISearchDisplayController *mySearchDisplayController;
@property (nonatomic,copy)NSString *createdTopicName;
@property (nonatomic,strong)NSArray *historyTopiclist;
@property (nonatomic,strong)NSArray *hotTopiclist;
@end

@implementation CSTopicCreateVC

+ (void)showATSomeoneWithBlock:(void(^)(NSString *topicName))block{
    CSTopicCreateVC *vc = [[CSTopicCreateVC alloc] init];
    vc.selectTopicBlock = block;
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [[BaseViewController presentingVC] presentViewController:nav animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _listView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[CSTopicNameCell class] forCellReuseIdentifier:kCellIdentifier_TopicNameCell];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = kColor666;
        tableView.sectionHeaderHeight = 20;
        tableView.rowHeight = 44;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        [tableView setContentInset:UIEdgeInsetsZero];
        [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _searchBar = ({
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        [searchBar sizeToFit];
        [searchBar setPlaceholder:@"#新话题"];
        searchBar.showsCancelButton = YES;
        [searchBar setTintColor:[UIColor whiteColor]];
        [searchBar insertBGColor:kColorNavBG];
        
        searchBar.searchBarStyle = UISearchBarStyleDefault;
        searchBar.translucent = YES;
        searchBar.backgroundColor = [UIColor clearColor];
        searchBar;
        
    });
    
    _mySearchDisplayController = ({
        UISearchDisplayController *searchVC = [[CSMySearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
        [searchVC.searchResultsTableView registerClass:[CSTopicNameCell class] forCellReuseIdentifier:kCellIdentifier_TopicNameCell];
        searchVC.delegate = self;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
//        if (kHigher_iOS_6_1) {
//            searchVC.displaysSearchBarInNavigationBar = NO;
//        }
        searchVC.displaysSearchBarInNavigationBar = YES;
        searchVC;
    });
    
    _createdTopicName = nil;
    _historyTopiclist = [CSTopicModel latestUseTopiclist];
    _hotTopiclist = @[];
    
    [self.listView reloadData];
    [self refreshHotTopiclist];
}

- (void)refreshHotTopiclist{
    __weak typeof(self) wself = self;
    [[Coding_NetAPIManager sharedManager] request_DefautsHotTopicNamelistWithBlock:^(NSArray *nameList, NSError *error) {
        wself.hotTopiclist = nameList.count > 10? [nameList subarrayWithRange:NSMakeRange(0, 10)]: nameList;
        [wself.listView reloadData];
    }];
}

- (void)dealloc
{
    _listView.delegate = nil;
    _listView.dataSource = nil;
}

#pragma mark -

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return nil;
    }
    if (section == 0) {
        return @"最近使用";
    }
    if (section == 1) {
        return @"热门推荐";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return 0;
    }
    
    if (section == 0 && _historyTopiclist.count == 0) {
        return 0;
    }
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    if (height <= 0) {
        return nil;
    }
    
    if (section == 0 && _historyTopiclist.count == 0) {
        return nil;
    }
        
    
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, height)];
    headerV.backgroundColor = kColorTableSectionBg;
    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.font = [UIFont systemFontOfSize:12];
    titleL.textColor = kColor999;
    titleL.text = [self tableView:tableView titleForHeaderInSection:section];
    [headerV addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headerV).insets(UIEdgeInsetsMake(4, kPaddingLeftWidth, 4, kPaddingLeftWidth));
    }];
    return headerV;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        if (_createdTopicName && _createdTopicName.length > 0) {
            return 1;
        }
        return 0;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        if (_createdTopicName && _createdTopicName.length > 0) {
            return 1;
        }else{
            return 0;
        }
    }
    if (section == 0) {
        return _historyTopiclist.count;
    }
    return _hotTopiclist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CSTopicNameCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicNameCell forIndexPath:indexPath];
    
    NSString *selectedTopicName = nil;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        selectedTopicName = _createdTopicName;
        [cell showCreateBtn:(_createdTopicName && _createdTopicName.length > 0)];
    }else{
        [cell showCreateBtn:NO];
        if (indexPath.section == 0) {
            selectedTopicName = _historyTopiclist[indexPath.row];
        }else if(indexPath.section == 1){
            selectedTopicName = _hotTopiclist[indexPath.row];
        }
    }
    if (!selectedTopicName) {
        selectedTopicName = @"";
    }
    cell.textLabel.text = [NSString stringWithFormat:@"#%@#",selectedTopicName];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:12];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *selectedTopicName = nil;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        selectedTopicName = _createdTopicName;
    }else{
        if (indexPath.section == 0) {
            selectedTopicName = _historyTopiclist[indexPath.row];
        }else if(indexPath.section == 1){
            selectedTopicName = _hotTopiclist[indexPath.row];
        }
    }
    
    [self didSelectByTopicName:selectedTopicName];
}

- (void)didSelectByTopicName:(NSString*)topicName {
    if (!topicName || topicName.length == 0) {
        return;
    }
    
    [CSTopicModel addAnotherUseTopic:topicName];
    
    //为了解决键盘状态混淆的问题
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    
    __weak typeof(self) wself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (wself.selectTopicBlock) {
            wself.selectTopicBlock(topicName);
        }
    }];

}

#pragma mark -

#pragma mark UISearchBarDelegate
//- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
//    [self.mySearchDisplayController.searchResultsTableView reloadData];
//    NSLog(@"--willHideSearchResultsTableView--");
//}
//
//- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
//    [self.mySearchDisplayController.searchResultsTableView reloadData];
//    NSLog(@"--didShowSearchResultsTableView--");
//}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    //解决UISearchDisplayController 顶部的空白区域的问题
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_mySearchDisplayController.searchResultsTableView reloadData];
}


//解决不显示cancel按钮的问题
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [_mySearchDisplayController setActive:YES animated:YES];
    [_mySearchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    
    controller.searchResultsTableView.superview.bounds = CGRectMake(0,22,320,400);
    for(UIView * v in controller.searchResultsTableView.superview.subviews){
        if([v isKindOfClass:NSClassFromString(@"_UISearchDisplayControllerDimmingView")])
        {
            v.frame = CGRectMake(0,20,320,400);
            //
        }
    }
}


- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [_mySearchDisplayController setActive:NO animated:YES];
    [_mySearchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSString *strippedStr = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _createdTopicName = strippedStr;
    [self.mySearchDisplayController.searchResultsTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            //
        }];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *strippedStr = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _createdTopicName = strippedStr;
    [self didSelectByTopicName:_createdTopicName];
}

@end


@implementation CSTopicNameCell{
    UILabel *_createLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;        
        self.textLabel.frame = CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - kPaddingLeftWidth - 15, 44);
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = kColor222;
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UILabel *)createLabel {
    if (!_createLabel) {
        _createLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        _createLabel.right = kScreen_Width - 15;
        _createLabel.text = @"创建";
        _createLabel.textColor = [UIColor colorWithHexString:@"0x7ccd9f"];
        _createLabel.font = [UIFont systemFontOfSize:15];
        _createLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_createLabel];
    }
    return _createLabel;
}

- (void)showCreateBtn:(BOOL)showCreateBtn {
    [self createLabel].hidden = !showCreateBtn;
}

@end

@implementation CSMySearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive:visible animated:animated];
    [self.searchContentsController.navigationController setNavigationBarHidden: NO animated: NO];

}


@end
