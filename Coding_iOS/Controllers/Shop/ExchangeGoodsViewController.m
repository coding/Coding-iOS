    
//  Created by liaoyp on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ExchangeGoodsViewController.h"

#import "ResetLabelViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTag.h"
#import "MBProgressHUD+Add.h"
#import "ShopOrderTextFieldCell.h"

#define kCellIdentifier_ShopOrderTextFieldCell @"ShopOrderTextFieldCell.h"

@interface ExchangeGoodsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

{
}

@property (strong, nonatomic) NSString *tagNameToAdd;
@property (strong, nonatomic) NSMutableArray *tagList, *selectedTags;
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *shopOrderBtn;

@end

@implementation ExchangeGoodsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)orderCommitAction:(UIButton *)button
{

}

#pragma mark-
#pragma mark---------------------- ControllerLife ---------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"提交订单";
    
    self.view.backgroundColor = kColorTableSectionBg;
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ShopOrderTextFieldCell class] forCellReuseIdentifier:kCellIdentifier_ShopOrderTextFieldCell];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = [UIColor colorWithHexString:@"0xFFDDDDDD"];
        tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_myTableView.frame), 303/2.0)];
    headView.backgroundColor = [UIColor whiteColor];
    _myTableView.tableHeaderView = headView;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_myTableView.frame), 136/2)];
    _shopOrderBtn = ({
        UIButton *orderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [orderBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xFF3BBD79"]] forState:UIControlStateNormal];
        [orderBtn addTarget:self action:@selector(orderCommitAction:) forControlEvents:UIControlEventTouchUpInside];
        [orderBtn setTitle:@"提交订单" forState:UIControlStateNormal];
        [orderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        orderBtn.layer.masksToBounds = YES;
        orderBtn.layer.cornerRadius = 44/2;
        [footView addSubview:orderBtn];
        [orderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@288);
            make.height.equalTo(@44);
            make.centerX.centerY.equalTo(footView);
        }];
        orderBtn;
    });
    _shopOrderBtn.enabled = NO;
    _myTableView.tableFooterView = footView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sendRequest];
}

- (void)sendRequest
{
//    [self.view beginLoading];
//    __weak typeof(self) weakSelf = self;
//    [[Coding_NetAPIManager sharedManager] request_TagListInProject:_curProject type:ProjectTagTypeTopic andBlock:^(id data, NSError *error) {
//        [weakSelf.view endLoading];
//        if (data) {
//            weakSelf.tagList = data;
//            [weakSelf.myTableView reloadData];
//        }
//    }];
}

#pragma mark - click
//- (void)okBtnClick
//{
//    if (self.tagsChangedBlock) {
//        self.tagsChangedBlock(self, _selectedTags);
//    }
//}
//
//- (void)addBtnClick:(UIButton *)sender
//{
//    [self.view endEditing:YES];
//    if (_tagNameToAdd.length > 0) {
//        __weak typeof(self) weakSelf = self;
//        ProjectTag *curTag = [ProjectTag tagWithName:_tagNameToAdd];
//        [[Coding_NetAPIManager sharedManager] request_AddTag:curTag toProject:_curProject andBlock:^(id data, NSError *error) {
//            if (data) {
//                curTag.id = data;
//                [weakSelf.tagList addObject:curTag];
//                weakSelf.tagNameToAdd = @"";
//                [weakSelf.myTableView reloadData];
//                sender.enabled = FALSE;
//                
//                [NSObject showHudTipStr:@"添加标签成功^^"];
//            }
//        }];
//    }
//}
//
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 4;
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ShopOrderTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ShopOrderTextFieldCell forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
        {
            cell.nameLabel.text = @"收货人 *";
            cell.textField.placeholder  = @"小王";
            break;
        }
        case 1:
        {
            cell.nameLabel.text = @"详细地址 *";
            cell.textField.placeholder  = @"省，市，县（镇），街道";
            break;
        }
        case 2:
        {
            cell.nameLabel.text = @"联系电话 *";
            cell.textField.placeholder  = @"电话";
            break;
        }
        case 3:
        {
            cell.nameLabel.text = @"备注";
            cell.textField.placeholder  = @"备注信息如:衣服码数XXL";
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"填写并核对订单信息";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ShopOrderTextFieldCell cellHeight];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0) {
        return YES;
    }
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 52;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.section > 0) {
//        EditLabelCell *cell = (EditLabelCell *)[tableView cellForRowAtIndexPath:indexPath];
//        cell.selectBtn.selected = !cell.selectBtn.selected;
//        
//        ProjectTag *tagInSelected = [ProjectTag tags:_selectedTags hasTag:_tagList[indexPath.row]];
//        if (cell.selectBtn.selected && !tagInSelected) {
//            [_selectedTags addObject:_tagList[indexPath.row]];
//        }else if (!cell.selectBtn.selected && tagInSelected){
//            [_selectedTags removeObject:tagInSelected];
//        }
//        self.navigationItem.rightBarButtonItem.enabled = ![ProjectTag tags:_selectedTags isEqualTo:_orignalTags];
//    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField
{
    _tagNameToAdd = [textField.text trimWhitespace];
    BOOL enabled = _tagNameToAdd.length > 0 ? TRUE : FALSE;
    if (enabled) {
        for (ProjectTag *lbl in _tagList) {
            if ([lbl.name isEqualToString:_tagNameToAdd]) {
                enabled = FALSE;
                break;
            }
        }
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    ShopOrderTextFieldCell *cell = (ShopOrderTextFieldCell *)[_myTableView cellForRowAtIndexPath:indexPath];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end

