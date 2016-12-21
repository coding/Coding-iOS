//
//  ScreenView.m
//  Coding_iOS
//
//  Created by 张达棣 on 16/12/7.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "ScreenView.h"
#import "Coding_NetAPIManager.h"
#import "TaskSelectionCell.h"
#import "ScreenCell.h"

#define KMainLeftWith  45

@interface ScreenView ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger selectNum;  //选中数据
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *mainView;
@end

@implementation ScreenView

#pragma mark - 生命周期方法

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self creatView];
    }
    return self;
}


#pragma mark - 外部方法

+ (instancetype)creat {
    ScreenView *screenView = [[ScreenView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    screenView.hidden = YES;
    [kKeyWindow addSubview:screenView];
    return screenView;
}

- (void)showOrHide {
    if (self.hidden) {
        [self show];
    } else {
        [self hide];
    }
}

#pragma makr - 消息

#pragma mark - 系统委托
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _labels.count + _tastArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _tastArray.count) {
        TaskSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskSelectionCell forIndexPath:indexPath];
        cell.title = _tastArray[indexPath.row];
        cell.isSel = indexPath.row == _selectNum;
        cell.isShowLine = indexPath.row == _tastArray.count - 1;
        return cell;

    } else {
        ScreenCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ScreenCell forIndexPath:indexPath];
        cell.color = _labels[indexPath.row - _tastArray.count][@"color"];
        cell.title = _labels[indexPath.row - _tastArray.count][@"name"];
        cell.isSel = indexPath.row == _selectNum;

        return cell;

    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.keyword = nil;
    _searchBar.text = nil;
    _selectNum = indexPath.row;
    [tableView reloadData];
    if (indexPath.row < _tastArray.count) {
        self.label = nil;
        self.status = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
    } else {
        self.status = nil;
        self.label = _labels[indexPath.row - _tastArray.count][@"name"];
    }
    [self clickDis];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-  (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.keyword = _searchBar.text;
    [self clickDis];
}

#pragma mark - 自定义委托

#pragma mark - 响应方法

#pragma mark - 私有方法

- (void)creatView {
    self.hidden = YES;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.5];
    _selectNum = -1;
    
    UIButton *bgButton = [[UIButton alloc] init];
    [bgButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchDown];
    [self addSubview:bgButton];
    bgButton.sd_layout.leftSpaceToView(self, 0).topEqualToView(self).bottomEqualToView(self).rightEqualToView(self);
    
    UIView *mainView = [[UIView alloc] init];
    mainView.backgroundColor = [UIColor whiteColor];
    [self addSubview:mainView];
    mainView.sd_layout.leftSpaceToView(self, KMainLeftWith).topSpaceToView(self, 0).bottomEqualToView(self).rightEqualToView(self);
    _mainView = mainView;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    UITextField *searchField = [searchBar valueForKey:@"searchField"];
    searchField.backgroundColor = [UIColor clearColor];
    searchField.borderStyle = UITextBorderStyleNone;
    searchField.placeholder = @"查找相关任务";
    searchBar.barTintColor = [UIColor colorWithRGBHex:0xf0f2f5];
    searchBar.cornerRadius = 4;
    searchBar.masksToBounds = YES;
    searchBar.returnKeyType = UIReturnKeySearch;
    searchBar.delegate = self;
    [mainView addSubview:searchBar];
    searchBar.sd_layout.leftSpaceToView(mainView, 15).topSpaceToView(mainView, 35).rightSpaceToView(mainView, 15).heightIs(31);
    _searchBar = searchBar;
    
    UIButton *resetButton = [[UIButton alloc] init];
    [resetButton setTitle:@"重置" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor colorWithRGBHex:0x222222] forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:15];
    resetButton.backgroundColor = [UIColor whiteColor];
    [resetButton addTarget:self action:@selector(resetButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:resetButton];
    resetButton.sd_layout.leftSpaceToView(mainView, 0).bottomSpaceToView(mainView, 0).rightSpaceToView(mainView, 0).heightIs(48.5);
    
    UILabel *line = [[UILabel alloc] init];
    line.backgroundColor = [UIColor colorWithRGBHex:0xdddddd];
    [mainView addSubview:line];
    line.sd_layout.leftSpaceToView(mainView, 0).rightSpaceToView(mainView, 0).bottomSpaceToView(resetButton, 0).heightIs(.5);

    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"zcell"];
    [tableView registerClass:[TaskSelectionCell class] forCellReuseIdentifier:kCellIdentifier_TaskSelectionCell];
    [tableView registerClass:[ScreenCell class] forCellReuseIdentifier:kCellIdentifier_ScreenCell];
    [mainView addSubview:tableView];
    tableView.sd_layout.leftSpaceToView(mainView, 0).topSpaceToView(searchBar, 0).bottomSpaceToView(resetButton, 0).rightEqualToView(mainView);
    _tableView = tableView;
    
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePan:)];
    [self addGestureRecognizer:panGestureRecognizer];
}


- (void)clickDis {
    [self hide];
    if (_selectBlock) {
        _selectBlock(_keyword, _status, _label);
    }
}


- (void)resetButtonClick {
    [self hide];
    _keyword = _status = _label = nil;
    _selectNum = -1;
    _searchBar.text = nil;
    [_tableView reloadData];
    if (_selectBlock) {
        _selectBlock(_keyword, _status, _label);
    }
}

#pragma mark - get/set方法

- (void)show {
    if (![_searchBar.text isEqualToString:_keyword]) {
        _searchBar.text = _keyword;
    }
    _mainView.x = kScreen_Width - KMainLeftWith;
     self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.5];
    
    self.hidden = NO;
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 1;
        _mainView.x = KMainLeftWith;
    }];

}

- (void)hide {
    [self.searchBar resignFirstResponder];

    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0;
        _mainView.x += (kScreen_Width - KMainLeftWith);
    } completion:^(BOOL finished) {
        self.hidden = YES;

    }];
}

- (void)handlePan:(UIPanGestureRecognizer*) recognizer {
    [_searchBar resignFirstResponder];
    CGPoint translation = [recognizer translationInView:_mainView];
    if (_mainView.x + translation.x > KMainLeftWith) {
        _mainView.x += translation.x;
        [recognizer setTranslation:CGPointZero inView:_mainView];
    } else {
        _mainView.x = KMainLeftWith;
    }
    
    CGFloat alpha = .5;
    alpha -= (_mainView.x / kScreen_Width * alpha);
    
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:alpha];
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
         [self hide];
    }
}

- (void)setTastArray:(NSArray *)tastArray {
    _tastArray = tastArray;
    [_tableView reloadData];
    
}

- (void)setLabels:(NSArray *)labels {
    _labels = labels;
    [_tableView reloadData];
}


@end
