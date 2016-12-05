//
//  UserActiveStatusView.m
//  Coding_iOS
//
//  Created by 张达棣 on 16/11/30.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "UserActiveStatusView.h"

@interface UserActiveStatusView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailsLabel;

@end

@implementation UserActiveStatusView

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
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:17];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    _titleLabel.sd_layout.leftEqualToView(self).topSpaceToView(self, 8).rightEqualToView(self).heightIs(24);
    
    _detailsLabel = [[UILabel alloc] init];
    _detailsLabel.font = [UIFont systemFontOfSize:10];
    _detailsLabel.textAlignment = NSTextAlignmentCenter;
    _detailsLabel.textColor = [UIColor colorWithRGBHex:0x76808e];
    [self addSubview:_detailsLabel];
    _detailsLabel.sd_layout.leftEqualToView(self).topSpaceToView(_titleLabel, 5).rightEqualToView(self).heightIs(14);
}

#pragma mark - get/set方法

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setDetails:(NSString *)details {
    _details = details;
    _detailsLabel.text = details;
}

@end
