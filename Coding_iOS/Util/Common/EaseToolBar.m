//
//  EaseToolBar.m
//  Coding_iOS
//
//  Created by Ease on 14/11/27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kEaseToolBar_Height (49.0 + kSafeArea_Bottom)
#define kEaseToolBar_SplitLineViewTag 100

#import "EaseToolBar.h"

@interface EaseToolBar ()
@property (strong, nonatomic) NSArray *buttonItems;
@end

@implementation EaseToolBar
+ (instancetype)easeToolBarWithItems:(NSArray *)buttonItems{
    return [[EaseToolBar alloc] initWithItems:buttonItems];
}
- (id)itemOfIndex:(NSInteger)index{
    if (index >= 0 && self.buttonItems && self.buttonItems.count >= index) {
        return self.buttonItems[index];
    }else{
        return nil;
    }
}
- (instancetype)initWithItems:(NSArray *)buttonItems{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, kScreen_Width, kEaseToolBar_Height);
        self.backgroundColor = kColorWhite;
        self.buttonItems = buttonItems;
    }
    return self;
}
- (void)setButtonItems:(NSArray *)buttonItems{
    if (buttonItems != _buttonItems) {
        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        _buttonItems = buttonItems;
    }
    [self addLineUp:YES andDown:NO andColor:kColorD8DDE4];
    if (_buttonItems.count > 0) {
        NSInteger num = _buttonItems.count;
        CGFloat itemWidth = CGRectGetWidth(self.frame)/num;
        CGFloat itemHeight = CGRectGetHeight(self.frame) - kSafeArea_Bottom;
        
        for (int i = 0; i < num; i++) {
            UIControl *item = _buttonItems[i];
            item.frame = CGRectMake(i*itemWidth, 0, itemWidth, itemHeight);
            [item addTarget:self action:@selector(itemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:item];
            if (i < num-1) {//item之间的分隔线
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((i+1)*itemWidth, 0, 0.5, itemHeight)];
                lineView.tag = kEaseToolBar_SplitLineViewTag;
                lineView.backgroundColor = [UIColor colorWithHexString:@"0xD8DDE4"];
                [self addSubview:lineView];
            }
        }
    }
}

- (void)itemButtonClicked:(UIButton *)sender{
    NSInteger index = [self.buttonItems indexOfObject:sender];
    if (index != NSNotFound && [self.delegate respondsToSelector:@selector(easeToolBar:didClickedIndex:)]) {
        [self.delegate easeToolBar:self didClickedIndex:index];
    }
}

@end


@interface EaseToolBarItem ()
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *disableImageName;
@end

@implementation EaseToolBarItem
+ (instancetype)easeToolBarItemWithTitle:(NSString *)title image:(NSString *)imageName disableImage:(NSString *)disableImageName{
    return [[EaseToolBarItem alloc] initWithTitle:title image:imageName disableImage:disableImageName];
}
- (instancetype)initWithTitle:(NSString *)title image:(NSString *)imageName disableImage:(NSString *)disableImageName{
    self = [super init];
    if (self) {
        self.title = title;
        self.imageName = imageName;
        self.disableImageName = disableImageName;
        
        [self setIconImage:[UIImage imageNamed:_imageName]];
        [self setButtonText:_title];
        
        [self setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                              NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0x323A45"]} forUIControlState:UIControlStateNormal];
        [self setIconPosition:IconPositionLeft];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setControlState:UIControlStateNormal];
        self.enabled = YES;
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    if (title) {
        title = [NSString stringWithFormat:@" %@", title];
    }
    _title = title;
}
- (void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    NSString *imageName = enabled? _imageName:(_disableImageName? _disableImageName: _imageName);
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSForegroundColorAttributeName:enabled? [UIColor colorWithHexString:@"0x323A45"] : [UIColor colorWithHexString:@"0xA9B3BE"]};
    [self setIconImage:[UIImage imageNamed:imageName]];
    [self setAttributes:attributes forUIControlState:UIControlStateNormal];
}
- (void)addTipIcon{
    CGRect iconFrame = [self getIconImageView].frame;
    [self addBadgeTip:kBadgeTipStr withCenterPosition:CGPointMake(iconFrame.origin.x + iconFrame.size.width +2, 12)];
}
- (void)removeTipIcon{
    [self removeBadgeTips];
}
@end

