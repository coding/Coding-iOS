//
//  TaskResourceReferenceViewController.m
//  Coding_iOS
//
//  Created by Ease on 16/2/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TaskResourceReferenceViewController.h"
#import "TaskResourceReferenceCell.h"
#import "Coding_NetAPIManager.h"

@interface TaskResourceReferenceViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;

@end

@implementation TaskResourceReferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"关联资源";
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TaskResourceReferenceCell class] forCellReuseIdentifier:kCellIdentifier_TaskResourceReferenceCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });

}

- (void)viewWillAppear:(BOOL)animated {
    if(self.resourceReference.itemList.count <= 0) {
        [self.view configBlankPage:EaseBlankPageTypeTaskResource hasData:NO hasError:NO reloadButtonBlock:nil];
    }
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.resourceReference.itemList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TaskResourceReferenceCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskResourceReferenceCell forIndexPath:indexPath];
    cell.item = self.resourceReference.itemList[indexPath.row];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:45];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ResourceReferenceItem *item = self.resourceReference.itemList[indexPath.row];
    [self goToItem:item];
}

#pragma mark Table M - Edit
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ResourceReferenceItem *item = self.resourceReference.itemList[indexPath.row];
        __weak typeof(self) weakSelf = self;
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:[NSString stringWithFormat:@"确定取消关联：%@", item.title] buttonTitles:nil destructiveTitle:@"确定" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf deleteItem:item];
            }
        }];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - Actiom
- (void)deleteItem:(ResourceReferenceItem *)item{
    __weak typeof(self) weakSelf = self;
    NSString *requestPath = self.resourceReferencePath;
    if([self.resourceReferenceFromType isEqual:@1]) {
        requestPath = [NSString stringWithFormat:@"api%@/resource_reference/%ld", self.resourceReferencePath, (long)self.number.integerValue];

    }
    [[Coding_NetAPIManager sharedManager] request_DeleteResourceReference:item.code ResourceReferencePath:requestPath andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.resourceReference.itemList removeObject:item];
            [weakSelf.myTableView reloadData];
        }
    }];
    
}

- (void)goToItem:(ResourceReferenceItem *)item{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:item.link];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [NSObject showHudTipStr:@"暂时不支持查看该资源"];
    }
}
@end
