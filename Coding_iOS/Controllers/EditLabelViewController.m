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
#import "ProjectTag.h"
#import "MBProgressHUD+Add.h"

#define kCellIdentifier_EditLabelHeadCell @"EditLabelHeadCell"
#define kCellIdentifier_EditLabelCell @"EditLabelCell"

@interface EditLabelViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UITextFieldDelegate>
{
    NSString *_tempLabel;
    NSMutableArray *_tempArray;
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
    
    //if (!_isSaveChange) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(okBtnClick)];
        self.navigationItem.rightBarButtonItem.enabled = FALSE;
    //}
    
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

- (void)setCurProTopic:(ProjectTopic *)curProTopic
{
    _curProTopic = curProTopic;
    _tempArray = [NSMutableArray arrayWithArray:_curProTopic.mdLabels];
}

- (void)sendRequest
{
    [self.view beginLoading];
    
    __weak typeof(self) weakSelf = self;

    [[Coding_NetAPIManager sharedManager] request_TagListInProject:_curProTopic.project type:ProjectTagTypeTopic andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        if (data) {
            [_labels addObjectsFromArray:data];
            for (ProjectTag *lbl in _labels) {
                for (ProjectTag *tLbl in _curProTopic.mdLabels) {
                    if ([lbl.id integerValue] == [tLbl.id integerValue]) {
                        tLbl.name = lbl.name;
                        break;
                    }
                }
                for (ProjectTag *tLbl in _tempArray) {
                    if ([lbl.id integerValue] == [tLbl.id integerValue]) {
                        tLbl.name = lbl.name;
                        break;
                    }
                }
            }
            [weakSelf.myTableView reloadData];
        }

    }];
}

- (NSString *)toDelPath:(NSInteger)index
{
    ProjectTag *ptLabel = [_labels objectAtIndex:index];
    return [NSString stringWithFormat:@"api/project/%d/topic/label/%lld", _curProTopic.project_id.intValue, ptLabel.id.longLongValue];
}

- (NSString *)toMedifyPath:(NSNumber *)labelID
{
    return [NSString stringWithFormat:@"api/topic/%d/label/%lld", _curProTopic.id.intValue, labelID.longLongValue];
}

#pragma mark - click
- (void)okBtnClick
{
    _curProTopic.mdLabels = _tempArray;
    //_curProTopic.mdTitle = _tempArray;
    //_curProTopic.mdContent = _tempArray;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (_isSaveChange) {
        
        @weakify(self);
        [[Coding_NetAPIManager sharedManager] request_ModifyProjectTpoicLabel:self.curProTopic andBlock:^(id data, NSError *error) {
            @strongify(self);
            self.navigationItem.rightBarButtonItem.enabled = YES;
            if (data) {
                _curProTopic.labels = [NSMutableArray arrayWithArray:_curProTopic.mdLabels];
                if (self.topicChangedBlock) {
                    self.topicChangedBlock();
                }
                [self.navigationController popViewControllerAnimated:YES];
            } 
        }];
    } else {
        if (self.topicChangedBlock) {
            self.topicChangedBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)addBtnClick:(UIButton *)sender
{
    [_mCurrentTextField resignFirstResponder];
    if (_tempLabel.length > 0) {
        __weak typeof(self) weakSelf = self;
        ProjectTag *curTag = [ProjectTag tagWithName:_tempLabel];
        [[Coding_NetAPIManager sharedManager] request_AddTag:curTag toProject:_curProTopic.project andBlock:^(id data, NSError *error) {
            if (data) {
                curTag.id = data;
                [weakSelf.labels addObject:curTag];
                [weakSelf.myTableView reloadData];
                _tempLabel = @"";
                weakSelf.mCurrentTextField.text = @"";
                [weakSelf showHudTipStr:@"添加标签成功^^"];
                sender.enabled = FALSE;
            }
        }];
    }
}

- (void)showHudTipStr:(NSString *)tipStr
{
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = tipStr;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1.0];
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
    
    ProjectTag *ptLabel = _labels[indexPath.row];
    
    EditLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_EditLabelCell forIndexPath:indexPath];
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:[EditLabelCell cellHeight]];
    cell.delegate = self;
    
    BOOL selected = FALSE;
    for (ProjectTag *lbl in _curProTopic.mdLabels) {
        if ([lbl.id integerValue] == [ptLabel.id integerValue]) {
            selected = TRUE;
            break;
        }
    }
    [cell setTag:ptLabel andSelected:selected];

    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
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
        
        ProjectTag *lbl = _labels[indexPath.row];
  
        if (cell.selectBtn.selected) {
            BOOL add = TRUE;
            for (ProjectTag *tempLbl in _tempArray) {
                if ([tempLbl.id integerValue] == [lbl.id integerValue]) {
                    add = FALSE;
                    break;
                }
            }
            if (add) {
//                if (_isSaveChange) {
//                    __weak typeof(self) weakSelf = self;
//                    [[Coding_NetAPIManager sharedManager] request_ProjectTopic_AddLabel_WithPath:[self toMedifyPath:lbl.id] andBlock:^(id data, NSError *error) {
//                        if (!error) {
//                            [_tempArray addObject:lbl];
//                            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
//                        } else {
//                            cell.selectBtn.selected = FALSE;
//                        }
//                    }];
//                    [_tempArray addObject:lbl];
//                    self.navigationItem.rightBarButtonItem.enabled = YES;
//                } else {
                    [_tempArray addObject:lbl];
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                //}
            }
        } else {
            for (ProjectTag *tempLbl in _tempArray) {
                if ([tempLbl.id integerValue] == [lbl.id integerValue]) {
//                    if (_isSaveChange) {
//                        __weak typeof(self) weakSelf = self;
//                        [[Coding_NetAPIManager sharedManager] request_ProjectTopic_DelLabel_WithPath:[self toMedifyPath:lbl.id] andBlock:^(id data, NSError *error) {
//                            if (!error) {
//                                [_tempArray removeObject:tempLbl];
//                                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
//                            } else {
//                                cell.selectBtn.selected = TRUE;
//                            }
//                        }];
//                    } else {
                        [_tempArray removeObject:tempLbl];
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    //}
                    break;
                }
            }
        }
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

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];

    if (index == 0) {
        [self renameBtnClick:indexPath.row];
    } else {
        __weak typeof(self) weakSelf = self;
        ProjectTag *ptLabel = [_labels objectAtIndex:indexPath.row];
        NSString *tip = [NSString stringWithFormat:@"确定要删除标签:%@？", ptLabel.name];
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:tip buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf deleteBtnClick:indexPath.row];
            }
        }];
        [actionSheet showInView:self.view];
    }
}

- (void)renameBtnClick:(NSInteger)index
{
    ResetLabelViewController *vc = [[ResetLabelViewController alloc] init];
    vc.ptLabel = [_labels objectAtIndex:index];
    vc.curProTopic = _curProTopic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteBtnClick:(NSInteger)index
{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteTag:_labels[index] inProject:_curProTopic.project andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf deleteLabel:index];
        }
    }];
}

- (void)deleteLabel:(NSInteger)index
{
    ProjectTag *lbl = _labels[index];
    for (ProjectTag *tempLbl in _tempArray) {
        if ([tempLbl.id integerValue] == [lbl.id integerValue]) {
            [_tempArray removeObject:tempLbl];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            break;
        }
    }
    [self.labels removeObjectAtIndex:index];
    [self.myTableView reloadData];
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
    _tempLabel = [textField.text trimWhitespace];
    BOOL enabled = _tempLabel.length > 0 ? TRUE : FALSE;
    if (enabled) {
        for (ProjectTag *lbl in _labels) {
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
