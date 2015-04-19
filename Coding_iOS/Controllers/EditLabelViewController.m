//
//  EditLabelViewController.m
//  Coding_iOS
//
//  Created by zwm on 15/4/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "EditLabelViewController.h"
#import "EditLabelHeadCell.h"
#import "EditLabelCell.h"
#import "ResetLabelViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTopicLabel.h"

#define kCellIdentifier_EditLabelHeadCell @"EditLabelHeadCell"
#define kCellIdentifier_EditLabelCell @"EditLabelCell"

@interface EditLabelViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UITextFieldDelegate>
{
    NSString *_tempLabel;
}
@property (strong, nonatomic) NSMutableArray *labels;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;

@property (nonatomic, weak) UITextField *mCurrentTextField;
@end

@implementation EditLabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"标签管理";
    self.navigationController.title = @"标签管理";
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(okBtnClick)];
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    
    self.view.backgroundColor = kColorTableSectionBg;
    
    _labels = [[NSMutableArray alloc] initWithCapacity:4];
    
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[EditLabelHeadCell class] forCellReuseIdentifier:kCellIdentifier_EditLabelHeadCell];
        [tableView registerClass:[EditLabelCell class] forCellReuseIdentifier:kCellIdentifier_EditLabelCell];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_labels removeAllObjects];
    [self sendRequest];
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

- (void)sendRequest
{
    [self.view beginLoading];
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectTopicLabel_WithPath:[self toLabelPath] andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        if (data) {
            [_labels addObjectsFromArray:data];

            [weakSelf.myTableView reloadData];
        }
    }];
}

- (NSString *)toLabelPath
{
    return [NSString stringWithFormat:@"api/project/%d/topic/label?", _curProTopic.project_id.intValue];
}

#pragma mark - click
- (void)okBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addBtnClick:(UIButton *)sender
{
    [_mCurrentTextField resignFirstResponder];
    if (_tempLabel.length > 0) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_ProjectTopicLabel_Add_WithPath:[self toLabelPath] withParams:@{@"name" : [_tempLabel aliasedString], @"color" : @"#d8f3e4"} andBlock:^(id data, NSError *error) {
            if (!error) {
                ProjectTopicLabel *ptLabel = [[ProjectTopicLabel alloc] init];
                ptLabel.name = _tempLabel;
                ptLabel.id = data;
                ptLabel.owner_id = _curProTopic.project_id;
                ptLabel.color = @"#d8f3e4";
                [_labels addObject:ptLabel];
                [weakSelf.myTableView reloadData];
                _tempLabel = @"";
                sender.enabled = FALSE;
           }
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _labels.count > 0 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 1;
    if (section == 1) {
        row = _labels.count;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        EditLabelHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_EditLabelHeadCell forIndexPath:indexPath];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        [cell.addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.labelField.delegate = self;
        [cell.labelField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        cell.backgroundColor = kColorTableBG;
        return cell;
    }
    
    ProjectTopicLabel *ptLabel = _labels[indexPath.row];
    
    EditLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_EditLabelCell forIndexPath:indexPath];
    cell.nameLbl.text = ptLabel.name;
    
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:[EditLabelCell cellHeight]];
    cell.delegate = self;
    
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    cell.backgroundColor = kColorTableBG;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EditLabelCell cellHeight];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0) {
        return TRUE;
    }
    return FALSE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_mCurrentTextField resignFirstResponder];

    if (indexPath.section > 0) {
        EditLabelCell *cell = (EditLabelCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.selectBtn.selected = !cell.selectBtn.selected;
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:@"icon_file_cell_rename"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xff5846"] icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
    return rightUtilityButtons;
}

#pragma mark - SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
        {
            EditLabelCell *eCell = (EditLabelCell *)cell;
            [eCell showRightBtn:FALSE];
        }   break;
        case 1:
            break;
        case 2:
        {
            EditLabelCell *eCell = (EditLabelCell *)cell;
            [eCell showRightBtn:TRUE];
        }   break;
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
        return NO;
    }
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];

    if (index == 0) {
        [self renameLabel:indexPath.row];
    } else {
        __weak typeof(self) weakSelf = self;
        ProjectTopicLabel *ptLabel = [_labels objectAtIndex:indexPath.row];
        NSString *tip = [NSString stringWithFormat:@"确定要删除标签:%@？", ptLabel.name];
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:tip buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf deleteLabel:indexPath.row];
            }
        }];
        [actionSheet showInView:self.view];
    }
}

- (void)renameLabel:(NSInteger)index
{
    ResetLabelViewController *vc = [[ResetLabelViewController alloc] init];
    vc.ptLabel = [_labels objectAtIndex:index];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteLabel:(NSInteger)index
{
    __weak typeof(self) weakSelf = self;
    ProjectTopicLabel *ptLabel = [_labels objectAtIndex:index];
   [[Coding_NetAPIManager sharedManager] request_ProjectTopicLabel_Del_WithPath:[ptLabel toDelPath] andBlock:^(id data, NSError *error) {
        if (!error) {
            [weakSelf.labels removeObjectAtIndex:index];
            [weakSelf.myTableView reloadData];
        }
    }];
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
    _tempLabel = textField.text;
    BOOL enabled = _tempLabel.length > 0 ? TRUE : FALSE;
    if (enabled) {
        for (ProjectTopicLabel *lbl in _labels) {
            if ([lbl.name isEqualToString:_tempLabel]) {
                enabled = FALSE;
                break;
            }
        }
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    EditLabelHeadCell *cell = (EditLabelHeadCell *)[_myTableView cellForRowAtIndexPath:indexPath];
    cell.addBtn.enabled = enabled;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [_mCurrentTextField resignFirstResponder];
}

@end
