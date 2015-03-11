//
//  TweetSendLocationViewController.m
//  Coding_iOS
//
//  Created by Kevin on 3/10/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendLocationViewController.h"
#import "TweetSendLocation.h"

@interface TweetSendLocationViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;

@property (nonatomic, strong) NSArray *locationArray;
@property (nonatomic, strong) NSArray *searchArray;
@end

@implementation TweetSendLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"所在位置";
    
    [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(cancelBtnClicked:)] animated:YES];
    [self configData];
    [self configSearchBar];
//    TweetSendLocationRequest *obj = [[TweetSendLocationRequest alloc]init];
//    
//    [[TweetSendLocationClient sharedJsonClient] requestPlaceAPIWithParams:obj andBlock:^(id data, NSError *error) {
//        NSLog(@"data = %@",data);
//    }];

}

- (void)configData
{
    self.locationArray = [NSArray new];
    self.searchArray = [NSArray new];
}

- (void)configSearchBar
{
    CGRect frame = self.tableView.bounds;
    frame.size.height = 44;
    self.mySearchBar = [[UISearchBar alloc]initWithFrame:frame];
    self.mySearchBar.delegate = self;
    self.mySearchBar.placeholder = @"搜索附近位置";
    self.mySearchBar.tintColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.mySearchBar;
    
    self.mySearchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:self.mySearchBar contentsController:self];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    
}

#pragma mark Nav Btn M
- (void)cancelBtnClicked:(id)sender{
    [self dismissSelf];
}

- (void)dismissSelf{
//    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
//        [self.view endEditing:YES];
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}

- (void)dealloc
{

}

#pragma mark- SearchDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.mySearchDisplayController setActive:YES animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"clcik");
}


- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"clcik");
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{

}
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{

}
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{

}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return NO;
}



#pragma mark – tableviewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        NSString *DefaultCellIdentifier = @"DefaultTableIdentifier";
        NSString *SubtitleCellIdentifier = @"SubtitleTableIdentifier";
        
        NSString *CellIdentifier = @"";
        
        if (indexPath.row == 0 || indexPath.row == 1) {
            CellIdentifier = DefaultCellIdentifier;
        }
        else{
            CellIdentifier = SubtitleCellIdentifier;
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                 CellIdentifier];
        //第一行，『不显示位置』
        if((indexPath.row == 0  || indexPath.row == 1) && cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }else if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"不显示位置";
            cell.textLabel.textColor = [UIColor colorWithHexString:@"0x4176a6"];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else if (indexPath.row == 1) {
            cell.textLabel.text = @"佛山市";
            cell.textLabel.textColor = [UIColor blackColor];
        }else {
            cell.textLabel.text = @"万科金域蓝湾";
            cell.detailTextLabel.text = @"广东省佛山市南海区桂城东环路11号";
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
        
        return cell;
    }
    else
    {
        return [self searchResultTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
}

- (UITableViewCell *)searchResultTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = @"Search Controller";
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return  10 ;//self.searchArray.count;
    }
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    if (tableView != self.tableView) {
        [self.mySearchDisplayController setActive:NO animated:YES];
    }
    
}
@end
