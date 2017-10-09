//
//  EditColorViewController.m
//  Coding_iOS
//
//  Created by Ease on 16/2/19.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "EditColorViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "TagColorEditCell.h"
#import "TagColorDisplayCell.h"

@interface EditColorViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) NSArray *colorList;
@end

@implementation EditColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"标签颜色";
    _colorList = @[@{@"name": @"灰色",
                     @"value": @"#90A4AE"},
                   @{@"name": @"黄色",
                     @"value": @"#FFC107"},
                   @{@"name": @"红色",
                     @"value": @"#FF5722"},
                   @{@"name": @"绿色",
                     @"value": @"#4CAF50"},
                   @{@"name": @"蓝色",
                     @"value": @"#03A9F4"},
                   @{@"name": @"紫色",
                     @"value": @"#AB44BC"},
                   ];
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[TagColorEditCell class] forCellReuseIdentifier:kCellIdentifier_TagColorEditCell];
        [tableView registerClass:[TagColorDisplayCell class] forCellReuseIdentifier:kCellIdentifier_TagColorDisplayCell];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
}

#pragma matk Table 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0? 1: _colorList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TagColorEditCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TagColorEditCell forIndexPath:indexPath];
        cell.colorF.text = _curTag.color;
        @weakify(self);
        @weakify(cell);
        [cell.colorF.rac_textSignal subscribeNext:^(NSString *value) {
            if (![value hasPrefix:@"#"] || value.length != 7) {
                return ;
            }
            UIColor *color = [UIColor colorWithHexString:[value stringByReplacingOccurrencesOfString:@"#" withString:@"0x"]];
            if (!color || ![[value uppercaseString] hasSuffix:[color hexStringFromColor]]) {
                return ;
            }
            @strongify(self);
            @strongify(cell);
            self.curTag.color = [value uppercaseString];
            cell.colorView.backgroundColor = color;
        }];
        cell.colorView.backgroundColor = [UIColor colorWithHexString:[_curTag.color stringByReplacingOccurrencesOfString:@"#" withString:@"0x"]];
        [cell.randomBtn addTarget:self action:@selector(randomColorBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        TagColorDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TagColorDisplayCell forIndexPath:indexPath];
        NSDictionary *colorDict = _colorList[indexPath.row];
        cell.colorView.backgroundColor = [UIColor colorWithHexString:[colorDict[@"value"] stringByReplacingOccurrencesOfString:@"#" withString:@"0x"]];
        cell.colorL.text = colorDict[@"name"];
        cell.accessoryType = [_curTag.color isEqualToString:colorDict[@"value"]]? UITableViewCellAccessoryCheckmark: UITableViewCellAccessoryNone;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:CGRectGetMinX(cell.colorL.frame)];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSDictionary *colorDict = _colorList[indexPath.row];
        _curTag.color = [colorDict[@"value"] uppercaseString];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark Btn
- (void)randomColorBtnClicked{
    _curTag.color = [NSString stringWithFormat:@"#%@", [[UIColor randomColor] hexStringFromColor]];
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}
@end
