//
//  ValueListViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ValueListViewController.h"
#import "ValueListCell.h"

@interface ValueListViewController ()
@property (strong, nonatomic) UITableView *myTableView;
@property (copy, nonatomic) IndexSelectedBlock selectBlock;
@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) NSArray *dataList;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (assign, nonatomic) ValueListType type;
@property (strong, nonatomic) UIView *tipView;
@end

@implementation ValueListViewController

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
    // Do any additional setup after loading the view.
    self.title = self.titleStr;
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ValueListCell class] forCellReuseIdentifier:kCellIdentifier_ValueList];
        tableView.backgroundColor = kColorTableSectionBg;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    if (self.type == ValueListTypeProjectMemberType) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(showMemberTypeTip)] animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_selectBlock) {
        _selectBlock(self.selectedIndex);
    }
}

- (void)setTitle:(NSString *)title valueList:(NSArray *)list defaultSelectIndex:(NSInteger)index type:(ValueListType)type selectBlock:(IndexSelectedBlock)selectBlock{
    self.titleStr = title;
    self.dataList = list;
    self.selectedIndex = index;
    self.type = type;
    self.selectBlock = selectBlock;
}

#pragma mark TableM

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ValueListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ValueList forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    if (_type == ValueListTypeTaskPriority || _type == ValueListTypeProjectMemberType) {
        row = self.dataList.count-1 -row;
    }
    switch (_type) {
        case ValueListTypeTaskStatus:
        case ValueListTypeProjectMemberType:
            [cell setTitleStr:[_dataList objectAtIndex:row] imageStr:nil isSelected:(_selectedIndex == row)];
            break;
        case ValueListTypeTaskPriority:
            [cell setTitleStr:[_dataList objectAtIndex:row] imageStr:[NSString stringWithFormat:@"taskPriority%ld", (long)row] isSelected:(_selectedIndex == row)];
            break;
        default:
            break;
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 30)];
    headerView.backgroundColor = kColorTableSectionBg;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger value = indexPath.row;
    if (_type == ValueListTypeTaskPriority || _type == ValueListTypeProjectMemberType) {
        value = self.dataList.count-1 -value;
    }
    self.selectedIndex = value;

    if (_type == ValueListTypeTaskPriority || _type == ValueListTypeTaskStatus) {
        [self.navigationController popViewControllerAnimated:YES];
        if (_selectBlock) {
            _selectBlock(self.selectedIndex);
        }
    }else{
        [self.myTableView reloadData];
    }
}

#pragma mark - Tip
- (void)showMemberTypeTip{
    if (self.tipView) {
        [self dismissTipView];
        return;
    }
    
    NSString *tipStr =
    
@"项目所有者：拥有对项目的所有权限。\n\
项目管理员：拥有对项目的部分权限。不能删除，转让项目，不能对其他管理员进行操作。\n\
普通成员：可以阅读和推送代码。\n\
受限成员：不能进入与代码相关的页面。\n";
    
    self.tipView = [self showTipStr:tipStr];
}
- (UIView *)showTipStr:(NSString *)tipStr{
    if (tipStr.length <= 0) {
        return nil;
    }
    UIView *tipV = [[UIView alloc] initWithFrame:self.view.bounds];
    tipV.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.9];
    [tipV bk_whenTapped:^{
        [self dismissTipView];
    }];
    UITextView *textV = [UITextView new];
    textV.backgroundColor = [UIColor clearColor];
    textV.editable = NO;

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.maximumLineHeight = 25;
    paragraphStyle.minimumLineHeight = 25;
    NSDictionary *attributes = @{
                          NSFontAttributeName : [UIFont systemFontOfSize:15],
                          NSForegroundColorAttributeName: [UIColor whiteColor],
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    textV.attributedText = [[NSAttributedString alloc] initWithString:tipStr attributes:attributes];

    [RACObserve(textV, contentSize) subscribeNext:^(id x) {
        CGFloat diffY = MAX(0, (textV.size.height - textV.contentSize.height)/3);
        textV.contentInset = UIEdgeInsetsMake(diffY, 0, 0, 0);
    }];
    [tipV addSubview:textV];
    [textV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tipV).insets(UIEdgeInsetsMake(0, 7, 0, 7));
    }];
    tipV.alpha = 0.0;
    
    [self.view addSubview:tipV];
    [UIView animateWithDuration:0.3 animations:^{
        tipV.alpha = 1.0;
        self.myTableView.scrollEnabled = NO;
    }];
    return tipV;
}

- (void)dismissTipView{
    [UIView animateWithDuration:0.3 animations:^{
        self.tipView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.tipView removeFromSuperview];
        self.tipView = nil;
        self.myTableView.scrollEnabled = YES;
    }];
}

@end
