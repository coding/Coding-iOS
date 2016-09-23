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
#import "EditColorViewController.h"

#define kCellIdentifier_EditLabelHeadCell @"EditLabelHeadCell"
#define kCellIdentifier_EditLabelCell @"EditLabelCell"

@interface EditLabelViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UITextFieldDelegate>
@property (strong, nonatomic) NSMutableArray *tagList, *selectedTags;
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) ProjectTag *tagToAdd;
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

- (void)setOrignalTags:(NSArray *)orignalTags{
    _orignalTags = orignalTags;
    if (_orignalTags.count > 0) {
        _selectedTags = [_orignalTags mutableCopy];
    }else{
        _selectedTags = [NSMutableArray new];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"标签管理";
    self.tagToAdd = [ProjectTag new];

    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"保存" target:self action:@selector(okBtnClick)];
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    
    self.view.backgroundColor = kColorTableSectionBg;
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
    [self sendRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.myTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (_tagList.count > 0 && _selectedTags.count > 0) {
        for (ProjectTag *tag in _tagList) {
            ProjectTag *orignalTag = [ProjectTag tags:_selectedTags hasTag:tag];
            if (orignalTag) {
                [_selectedTags replaceObjectAtIndex:[_selectedTags indexOfObject:orignalTag] withObject:tag];
            }
        }
    }
    if (_tagsSelectedBlock) {
        _tagsSelectedBlock(self, _selectedTags);
    }
}

- (void)sendRequest
{
    [self.view beginLoading];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_TagListInProject:_curProject type:ProjectTagTypeTopic andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        if (data) {
            weakSelf.tagList = data;
            [weakSelf.myTableView reloadData];
        }
    }];}

#pragma mark - click
- (void)okBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addBtnClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (_tagToAdd.name.length > 0) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_AddTag:_tagToAdd toProject:_curProject andBlock:^(id data, NSError *error) {
            if (data) {
                weakSelf.tagToAdd.id = data;
                [weakSelf.tagList addObject:weakSelf.tagToAdd];
                [weakSelf.selectedTags addObject:weakSelf.tagToAdd];
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;

                weakSelf.tagToAdd = [ProjectTag new];
                [weakSelf.myTableView reloadData];
                sender.enabled = FALSE;
                [NSObject showHudTipStr:@"添加标签成功^^"];
            }
        }];
    }
}
- (void)colorBtnClick:(UIButton *)sender{
    EditColorViewController *vc = [EditColorViewController new];
    vc.curTag = _tagToAdd;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tagList.count > 0 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 1;
    if (section == 1) {
        row = _tagList.count;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        EditLabelHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_EditLabelHeadCell forIndexPath:indexPath];
        [cell.addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.colorBtn addTarget:self action:@selector(colorBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.colorBtn.backgroundColor = [UIColor colorWithHexString:[_tagToAdd.color stringByReplacingOccurrencesOfString:@"#" withString:@"0x"]];
        cell.labelField.text = _tagToAdd.name;
        cell.labelField.delegate = self;
        [cell.labelField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        ProjectTag *ptLabel = _tagList[indexPath.row];
        
        EditLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_EditLabelCell forIndexPath:indexPath];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:[EditLabelCell cellHeight]];
        cell.delegate = self;
        
        BOOL selected = FALSE;
        for (ProjectTag *lbl in _selectedTags) {
            if ([lbl.id integerValue] == [ptLabel.id integerValue]) {
                selected = TRUE;
                break;
            }
        }
        [cell setTag:ptLabel andSelected:selected];
        
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
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
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section > 0) {
        EditLabelCell *cell = (EditLabelCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.selectBtn.selected = !cell.selectBtn.selected;
        
        ProjectTag *tagInSelected = [ProjectTag tags:_selectedTags hasTag:_tagList[indexPath.row]];
        if (cell.selectBtn.selected && !tagInSelected) {
            [_selectedTags addObject:_tagList[indexPath.row]];
        }else if (!cell.selectBtn.selected && tagInSelected){
            [_selectedTags removeObject:tagInSelected];
        }
        self.navigationItem.rightBarButtonItem.enabled = ![ProjectTag tags:_selectedTags isEqualTo:_orignalTags];
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:@"icon_file_cell_rename"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:kColorBrandRed icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
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
        ProjectTag *ptLabel = [_tagList objectAtIndex:indexPath.row];
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
    vc.ptLabel = [_tagList objectAtIndex:index];
    vc.curProject = _curProject;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteBtnClick:(NSInteger)index
{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteTag:_tagList[index] inProject:_curProject andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf deleteLabel:index];
        }
    }];
}

- (void)deleteLabel:(NSInteger)index
{
    ProjectTag *lbl = _tagList[index];
    for (ProjectTag *tempLbl in _selectedTags) {
        if ([tempLbl.id integerValue] == [lbl.id integerValue]) {
            [_selectedTags removeObject:tempLbl];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            break;
        }
    }
    [self.tagList removeObjectAtIndex:index];
    [self.myTableView reloadData];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField
{
    _tagToAdd.name = [textField.text trimWhitespace];
    BOOL enabled = _tagToAdd.name.length > 0 ? TRUE : FALSE;
    if (enabled) {
        for (ProjectTag *lbl in _tagList) {
            if ([lbl.name isEqualToString:_tagToAdd.name]) {
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
    [self.view endEditing:YES];
}

@end
