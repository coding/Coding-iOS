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
@property (assign, nonatomic) NSInteger defaultIndex;
@property (assign, nonatomic) ValueListType type;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTitle:(NSString *)title valueList:(NSArray *)list defaultSelectIndex:(NSInteger)index type:(ValueListType)type selectBlock:(IndexSelectedBlock)selectBlock{
    self.titleStr = title;
    self.dataList = list;
    self.defaultIndex = index;
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
    if (_type == ValueListTypeTaskPriority) {
        row = self.dataList.count-1 -row;
    }
    switch (_type) {
        case ValueListTypeTaskStatus:
            [cell setTitleStr:[_dataList objectAtIndex:row] imageStr:nil isSelected:(_defaultIndex == row)];
            break;
        case ValueListTypeTaskPriority:
            [cell setTitleStr:[_dataList objectAtIndex:row] imageStr:[NSString stringWithFormat:@"taskPriority%ld", (long)row] isSelected:(_defaultIndex == row)];
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
    NSInteger index = indexPath.row;
    if (_type == ValueListTypeTaskPriority) {
        index = self.dataList.count-1 -index;
    }
    if (_selectBlock) {
        _selectBlock(index);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
