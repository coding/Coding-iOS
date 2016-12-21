//
//  ActivityMonScrollView.m
//  Coding_iOS
//
//  Created by 张达棣 on 16/11/29.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "ActivityMonScrollView.h"
#import "ActivityView.h"

#define KMon  12

@interface ActivityMonScrollView ()
@property (nonatomic, strong) ActivityView *activityView;
@property (nonatomic, strong) NSMutableArray *monLabelArray;
@end

@implementation ActivityMonScrollView

#pragma mark - 生命周期方法

- (void)awakeFromNib {
    [super awakeFromNib];
    [self creatView];
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self creatView];
    }
    return self;
}

#pragma mark - 外部方法

#pragma makr - 消息

#pragma mark - 系统委托

#pragma mark - 自定义委托

#pragma mark - 响应方法

#pragma mark - 私有方法

- (void)creatView {
    self.showsHorizontalScrollIndicator = NO;
    _activityView = [[ActivityView alloc] init];
    [self addSubview:_activityView];
    [self setupAutoContentSizeWithRightView:_activityView rightMargin:15];
    
    self.monLabelArray = [NSMutableArray arrayWithCapacity:KMon];
    for (int i = 0; i < KMon; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorWithRGBHex:0x666666];
        label.font = [UIFont systemFontOfSize:12];
        [self addSubview:label];
        label.sd_layout.leftSpaceToView(self, 22 + i * 48).topSpaceToView(self, 0).heightIs(17).widthIs(24);
        [_monLabelArray addObject:label];
    }
}

#pragma mark - get/set方法

- (void)setDailyActiveness:(NSArray<DailyActiveness *> *)dailyActiveness {
    _dailyActiveness = dailyActiveness;
    
    NSMutableArray *colorArray = [NSMutableArray array];
    for (DailyActiveness *item in dailyActiveness) {
        UIColor *color;
        if (item.count.integerValue == 0) {
            color = [UIColor colorWithRGBHex:0xeeeeee];
        } else if (1 <= item.count.integerValue && item.count.integerValue <= 24) {
            color = [UIColor colorWithRGBHex:0xd6e685];
        } else if (25 <= item.count.integerValue && item.count.integerValue <= 49) {
            color = [UIColor colorWithRGBHex:0x8cc665];
        } else if (50 <= item.count.integerValue && item.count.integerValue <= 74) {
            color = [UIColor colorWithRGBHex:0x44a340];
        } else if (75 <= item.count.integerValue) {
            color = [UIColor colorWithRGBHex:0x1e6923];
        }
        [colorArray addObject:color];
    }
    _activityView.colorArray = colorArray;
    NSInteger row = colorArray.count / 7;
    if (colorArray.count % 7 != 0) {
        row++;
    }
    _activityView.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self, 22).heightIs(77).widthIs(row * 11);

}

- (void)setStartMon:(NSInteger)startMon {
    _startMon = startMon;
    
    NSArray *monArray = @[@"Dec", @"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov"];
    for (NSInteger i = _startMon; i < _startMon + KMon; i++) {
        NSString *mon = monArray[i % KMon];
        UILabel *label = _monLabelArray[i - _startMon];
        label.text = mon;
    }
}


@end
