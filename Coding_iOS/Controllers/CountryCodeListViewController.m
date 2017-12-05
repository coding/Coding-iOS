//
//  CountryCodeListViewController.m
//  CodingMart
//
//  Created by Ease on 16/5/11.
//  Copyright © 2016年 net.coding. All rights reserved.
//

#import "CountryCodeListViewController.h"
#import "CountryCodeCell.h"

@interface CountryCodeListViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSDictionary *countryCodeListDict, *searchResults;
@property (strong, nonatomic) NSMutableArray *keyList;

@end

@implementation CountryCodeListViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"选择国家或地区";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[CountryCodeCell class] forCellReuseIdentifier:kCellIdentifier_CountryCodeCell];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = kColor666;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _mySearchBar = ({
        UISearchBar *searchBar = [UISearchBar new];
        searchBar.delegate = self;
        [searchBar sizeToFit];
        [searchBar setPlaceholder:@"国家/地区名称"];
        searchBar;
    });
    [self setupData];
    
    _myTableView.tableHeaderView = _mySearchBar;
    _myTableView.tableFooterView = [UIView new];
}

#pragma mark Data
- (void)setupData{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country_code" ofType:@"plist"];
    _searchResults = _countryCodeListDict = [NSDictionary dictionaryWithContentsOfFile:path];
    [self p_updateKeyList];
}

- (void)p_updateKeyList{
    _keyList = [_searchResults allKeys].mutableCopy;
    [_keyList sortUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        if ([obj1 isEqualToString:@"#"]) {
            return NSOrderedAscending;
        }else if ([obj2 isEqualToString:@"#"]){
            return NSOrderedDescending;
        }else{
            return [obj1 compare:obj2];
        }
    }];
    [_keyList insertObject:UITableViewIndexSearch atIndex:0];
}

#pragma mark Table M

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.myTableView) {
        [_mySearchBar resignFirstResponder];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _keyList.count - 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_searchResults[_keyList[section+ 1]] count];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index > 0? index - 1: index;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _keyList;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerV = [UIView new];
    headerV.backgroundColor = self.myTableView.backgroundColor;
    UILabel *titleL = [UILabel new];
    titleL.font = [UIFont systemFontOfSize:12];
    titleL.textColor = kColor999;
    titleL.text = [_keyList[section+ 1] isEqualToString:@"#"]? @"常用": _keyList[section+ 1];
    [headerV addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headerV).insets(UIEdgeInsetsMake(4, 15, 4, 15));
    }];
    return headerV;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CountryCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_CountryCodeCell forIndexPath:indexPath];
    cell.countryCodeDict = _searchResults[_keyList[indexPath.section+ 1]][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, (kScreen_Width - cell.contentView.width) + 15);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_selectedBlock) {
        _selectedBlock(_searchResults[_keyList[indexPath.section+ 1]][indexPath.row]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSMutableDictionary *searchResults = @{}.mutableCopy;
    NSString *strippedStr = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *searchItems = [strippedStr componentsSeparatedByString:@" "];
    if (strippedStr.length == 0) {
        searchResults = _countryCodeListDict.mutableCopy;
    }else{
        NSMutableArray *andMatchPredicates = [NSMutableArray array];
        for (NSString *searchString in searchItems){
            NSMutableArray *searchItemsPredicate = [NSMutableArray new];
            
            NSExpression *lhs = [NSExpression expressionForKeyPath:@"country"];
            NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
            NSPredicate *finalPredicate = [NSComparisonPredicate
                                           predicateWithLeftExpression:lhs
                                           rightExpression:rhs
                                           modifier:NSDirectPredicateModifier
                                           type:NSContainsPredicateOperatorType
                                           options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
            
            lhs = [NSExpression expressionForKeyPath:@"country_code"];
            rhs = [NSExpression expressionForConstantValue:searchString];
            finalPredicate = [NSComparisonPredicate
                              predicateWithLeftExpression:lhs
                              rightExpression:rhs
                              modifier:NSDirectPredicateModifier
                              type:NSContainsPredicateOperatorType
                              options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
            
            lhs = [NSExpression expressionForKeyPath:@"iso_code"];
            rhs = [NSExpression expressionForConstantValue:searchString];
            finalPredicate = [NSComparisonPredicate
                              predicateWithLeftExpression:lhs
                              rightExpression:rhs
                              modifier:NSDirectPredicateModifier
                              type:NSContainsPredicateOperatorType
                              options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
            
            NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
            [andMatchPredicates addObject:orMatchPredicates];
        }
        NSCompoundPredicate *finalCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
        for (NSString *key in [_countryCodeListDict allKeys]) {
            NSArray *finalList = [_countryCodeListDict[key] filteredArrayUsingPredicate:finalCompoundPredicate];
            if (finalList.count > 0) {
                [searchResults setValue:finalList forKey:key];
            }else{
                [searchResults removeObjectForKey:key];
            }
        }
    }
    _searchResults = searchResults;
    [self p_updateKeyList];
    [self.myTableView reloadData];
}


@end
