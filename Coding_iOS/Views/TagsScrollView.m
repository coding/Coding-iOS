//
//  TagsScrollView.h
//  Coding_iOS
//
//  Created by 张达棣 on 16/11/29.
//  Copyright © 2016年 Coding. All rights reserved.
//


#import "TagsScrollView.h"
#import "UIView+SDAutoLayout.h"

@interface TagsScrollView ()
@property (nonatomic, strong) NSMutableArray *signatureLabelArray;
@end

@implementation TagsScrollView



#pragma mark - 生命周期方法

- (instancetype)init {
    self = [super init];
    if (self) {
        [self creatView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self creatView];
}

#pragma mark - 外部方法

#pragma makr - 消息

#pragma mark - 系统委托

#pragma mark - 自定义委托

#pragma mark - 响应方法

#pragma mark - 私有方法

- (void)creatView {
    _signatureLabelArray = [NSMutableArray array];
    self.showsHorizontalScrollIndicator = NO;
}

#pragma mark - get/set方法

- (void)setTags:(NSString *)tags {
    _tags = tags;
    
    NSArray *signatureArray = [tags componentsSeparatedByString:@","];
    for (int i = 0; i < signatureArray.count; i++) {
        UILabel *_signatureLabel;
        if (i < _signatureLabelArray.count) {
            _signatureLabel = _signatureLabelArray[i];
            [_signatureLabel removeFromSuperview];
        } else {
            _signatureLabel = [[UILabel alloc] init];
            _signatureLabel.textColor = [UIColor colorWithRGBHex:0x76808e];
            _signatureLabel.cornerRadius = 2;
            _signatureLabel.backgroundColor = [UIColor colorWithRGBHex:0xf2f4f6];
            _signatureLabel.font = [UIFont systemFontOfSize:12];
            [_signatureLabelArray addObject:_signatureLabel];
        }
        _signatureLabel.text = [NSString stringWithFormat:@"  %@  ", signatureArray[i]];
        [self addSubview:_signatureLabel];
        _signatureLabel.sd_layout.centerYEqualToView(self).heightIs(self.frame.size.height);
        [_signatureLabel setSingleLineAutoResizeWithMaxWidth:300];
    }
    [self setupAutoWidthFlowItems:[_signatureLabelArray copy] withPerRowItemsCount:_signatureLabelArray.count verticalMargin:0 horizontalMargin:8];
    [self setupAutoContentSizeWithRightView:_signatureLabelArray[_signatureLabelArray.count - 1] rightMargin:4];

}

@end
