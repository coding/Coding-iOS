//
//  ResetLabelViewController.m
//  Coding_iOS
//
//  Created by zwm on 15/4/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ResetLabelViewController.h"
#import "ResetLabelCell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTag.h"
#import "EditColorViewController.h"

#define kCellIdentifier_ResetLabelCell @"ResetLabelCell"

@interface ResetLabelViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) NSString *tempStr;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;

@property (nonatomic, weak) UITextField *mCurrentTextField;

@end

@implementation ResetLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"编辑标签";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(cancelBtnClick)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(okBtnClick)];
    
    self.view.backgroundColor = kColorTableSectionBg;
 
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ResetLabelCell class] forCellReuseIdentifier:kCellIdentifier_ResetLabelCell];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _tempStr = _ptLabel.name;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

#pragma mark - click
- (void)cancelBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)okBtnClick
{
    if (_tempStr.length > 0) {
        __weak typeof(self) weakSelf = self;
        _ptLabel.name = _tempStr;
        [[Coding_NetAPIManager sharedManager] request_ModifyTag:_ptLabel inProject:_curProject andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResetLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ResetLabelCell forIndexPath:indexPath];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    cell.labelField.delegate = self;
    [cell.labelField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [cell.colorBtn addTarget:self action:@selector(colorBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.backgroundColor = kColorTableBG;
    cell.labelField.text = _tempStr;
    cell.colorBtn.backgroundColor = [UIColor colorWithHexString:[_ptLabel.color stringByReplacingOccurrencesOfString:@"#" withString:@"0x"]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ResetLabelCell cellHeight];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FALSE;
}

#pragma mark - color
- (void)colorBtnClick:(UIButton *)sender{
    EditColorViewController *vc = [EditColorViewController new];
    vc.curTag = _ptLabel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.mCurrentTextField = textField;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    self.tempStr = textField.text;
    self.navigationItem.rightBarButtonItem.enabled = _tempStr.length > 0;;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.mCurrentTextField resignFirstResponder];
}

@end
