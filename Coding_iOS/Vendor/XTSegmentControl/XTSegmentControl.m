//
//  SegmentControl.m
//  GT
//
//  Created by tage on 14-2-26.
//  Copyright (c) 2014年 cn.kaakoo. All rights reserved.
//

#import "XTSegmentControl.h"
#import "ProjectMember.h"
#import "Projects.h"

#define XTSegmentControlItemFont (15)

#define XTSegmentControlHspace (0)

#define XTSegmentControlLineHeight (2)

#define XTSegmentControlAnimationTime (0.3)

#define XTSegmentControlIconWidth (50.0)


typedef NS_ENUM(NSInteger, XTSegmentControlItemType)
{
    XTSegmentControlItemTypeTitle = 0,
    XTSegmentControlItemTypeIconUrl
};

@interface XTSegmentControlItem : UIView

@property (nonatomic , strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *titleIconView;
@property (nonatomic, assign) XTSegmentControlItemType type;

- (void)setSelected:(BOOL)selected;
@end

@implementation XTSegmentControlItem

- (id)initWithFrame:(CGRect)frame title:(NSString *)title type:(XTSegmentControlItemType)type
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _type = type;
        switch (_type) {
            case XTSegmentControlItemTypeIconUrl:
            {
                _titleIconView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds)-40)/2, (CGRectGetHeight(self.bounds)-40)/2, 40, 40)];
                [_titleIconView doCircleFrame];
                if (title) {
                    [_titleIconView sd_setImageWithURL:[title urlImageWithCodePathResizeToView:_titleIconView] placeholderImage:kPlaceholderMonkeyRoundView(_titleIconView)];
                }else{
                    [_titleIconView setImage:[UIImage imageNamed:@"tasks_all"]];
                }
                [self addSubview:_titleIconView];
            }
                break;
            case XTSegmentControlItemTypeTitle:
            default:
            {
                _titleLabel = ({
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(XTSegmentControlHspace, 0, CGRectGetWidth(self.bounds) - 2 * XTSegmentControlHspace, CGRectGetHeight(self.bounds))];
                    label.font = [UIFont systemFontOfSize:XTSegmentControlItemFont];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.text = title;
                    label.textColor = [UIColor colorWithHexString:@"0x222222"];
                    label.backgroundColor = [UIColor clearColor];
                    label;
                });
                [self addSubview:_titleLabel];
            }
                break;
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    switch (_type) {
        case XTSegmentControlItemTypeIconUrl:
        {
        }
            break;
        default:
        {
            if (_titleLabel) {
                [_titleLabel setTextColor:(selected? [UIColor colorWithHexString:@"0x3bbd79"]:[UIColor colorWithHexString:@"0x222222"])];
            }
        }
            break;
    }
}


@end

@interface XTSegmentControl ()<UIScrollViewDelegate>

@property (nonatomic , strong) UIScrollView *contentView;

@property (nonatomic , strong) UIView *leftShadowView;

@property (nonatomic , strong) UIView *rightShadowView;

@property (nonatomic , strong) UIView *lineView;

@property (nonatomic , strong) NSMutableArray *itemFrames;

@property (nonatomic , strong) NSMutableArray *items;

@property (nonatomic) NSInteger currentIndex;

@property (nonatomic , assign) id <XTSegmentControlDelegate> delegate;

@property (nonatomic , copy) XTSegmentControlBlock block;

@end

@implementation XTSegmentControl

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)titleItem
{
    if (self = [super initWithFrame:frame]) {
        _contentView = ({
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
            scrollView.backgroundColor = [UIColor clearColor];
            scrollView.delegate = self;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.scrollsToTop = NO;
            [self addSubview:scrollView];
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
            [scrollView addGestureRecognizer:tapGes];
            [tapGes requireGestureRecognizerToFail:scrollView.panGestureRecognizer];
            scrollView;
        });
        
        [self initItemsWithTitleArray:titleItem];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame Items:(NSArray *)titleItem delegate:(id<XTSegmentControlDelegate>)delegate
{
    if (self = [self initWithFrame:frame Items:titleItem]) {
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame Items:(NSArray *)titleItem selectedBlock:(XTSegmentControlBlock)selectedHandle
{
    if (self = [self initWithFrame:frame Items:titleItem]) {
        self.block = selectedHandle;
    }
    return self;
}

- (void)doTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];
    
    __weak typeof(self) weakSelf = self;
    
    [_itemFrames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CGRect rect = [obj CGRectValue];
        
        if (CGRectContainsPoint(rect, point)) {
            
            [weakSelf selectIndex:idx];
            
            [weakSelf transformAction:idx];
            
            *stop = YES;
        }
    }];
}

- (void)transformAction:(NSInteger)index
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(XTSegmentControlDelegate)] && [self.delegate respondsToSelector:@selector(segmentControl:selectedIndex:)]) {
        
        [self.delegate segmentControl:self selectedIndex:index];
        
    }else if (self.block) {
        
        self.block(index);
    }
}

- (void)initItemsWithTitleArray:(NSArray *)titleArray
{
    _itemFrames = @[].mutableCopy;
    _items = @[].mutableCopy;
    float y = 0;
    float height = CGRectGetHeight(self.bounds);

    NSObject *obj = [titleArray firstObject];
    if ([obj isKindOfClass:[NSString class]]) {
        for (int i = 0; i < titleArray.count; i++) {
            float x = i > 0 ? CGRectGetMaxX([_itemFrames[i-1] CGRectValue]) : 0;
            float width = kScreen_Width/titleArray.count;
            CGRect rect = CGRectMake(x, y, width, height);
            [_itemFrames addObject:[NSValue valueWithCGRect:rect]];
        }
        
        for (int i = 0; i < titleArray.count; i++) {
            CGRect rect = [_itemFrames[i] CGRectValue];
            NSString *title = titleArray[i];
            XTSegmentControlItem *item = [[XTSegmentControlItem alloc] initWithFrame:rect title:title type:XTSegmentControlItemTypeTitle];
            if (i == 0) {
                [item setSelected:YES];
            }
            [_items addObject:item];
            [_contentView addSubview:item];
        }

    }else if ([obj isKindOfClass:[ProjectMember class]] ||
              [obj isKindOfClass:[Project class]]){
        
//        全部任务的frame
        CGRect firstFrame = CGRectMake(5.0, 0, XTSegmentControlIconWidth, height);
        [_itemFrames addObject:[NSValue valueWithCGRect:firstFrame]];

        for (int i = 1; i < titleArray.count; i++) {
            float x = CGRectGetMaxX([_itemFrames[i-1] CGRectValue]);
            CGRect rect = CGRectMake(x, y, XTSegmentControlIconWidth, height);
            [_itemFrames addObject:[NSValue valueWithCGRect:rect]];
        }
        
        for (int i = 0; i < titleArray.count; i++) {
            CGRect rect = [_itemFrames[i] CGRectValue];
            XTSegmentControlItem *item;
            if ([obj isKindOfClass:[ProjectMember class]]) {
                ProjectMember *title = titleArray[i];
                item = [[XTSegmentControlItem alloc] initWithFrame:rect title:title.user.avatar type:XTSegmentControlItemTypeIconUrl];
            }else if ([obj isKindOfClass:[Project class]]){
                Project *title = titleArray[i];
                item = [[XTSegmentControlItem alloc] initWithFrame:rect title:title.icon type:XTSegmentControlItemTypeIconUrl];
            }
            if (item) {
                if (i == 0) {
                    [item setSelected:YES];
                }
                [_items addObject:item];
                [_contentView addSubview:item];
            }
        }
    }
    
    [_contentView setContentSize:CGSizeMake(CGRectGetMaxX([[_itemFrames lastObject] CGRectValue]), CGRectGetHeight(self.bounds))];
    self.currentIndex = 0;
    [self selectIndex:0];
}

- (void)addRedLine
{
    if (!_lineView) {
        CGRect rect = [_itemFrames[0] CGRectValue];
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(
                                                             CGRectGetMinX(rect),
                                                             CGRectGetHeight(rect) - XTSegmentControlLineHeight,
                                                             CGRectGetWidth(rect) - 2 * XTSegmentControlHspace,
                                                             XTSegmentControlLineHeight)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"0x3bbd79"];
        [_contentView addSubview:_lineView];
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(rect)-0.5, CGRectGetWidth(self.bounds), 0.5)];
        bottomLineView.backgroundColor = [UIColor colorWithHexString:@"0xc8c7cc"];
        [self addSubview:bottomLineView];
    }
}

- (void)selectIndex:(NSInteger)index
{
    [self addRedLine];
    if (index != _currentIndex) {
        XTSegmentControlItem *curItem = [_items objectAtIndex:index];
        CGRect rect = [_itemFrames[index] CGRectValue];
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + XTSegmentControlHspace, CGRectGetHeight(rect) - XTSegmentControlLineHeight, CGRectGetWidth(rect) - 2 * XTSegmentControlHspace, XTSegmentControlLineHeight);
        [UIView animateWithDuration:XTSegmentControlAnimationTime animations:^{
            _lineView.frame = lineRect;
        } completion:^(BOOL finished) {
            [_items enumerateObjectsUsingBlock:^(XTSegmentControlItem *item, NSUInteger idx, BOOL *stop) {
                [item setSelected:NO];
            }];
            [curItem setSelected:YES];
            _currentIndex = index;
        }];
    }
    [self setScrollOffset:index];
}

- (void)moveIndexWithProgress:(float)progress
{
    float delta = progress - _currentIndex;

    CGRect origionRect = [_itemFrames[_currentIndex] CGRectValue];;
    
    CGRect origionLineRect = CGRectMake(CGRectGetMinX(origionRect) + XTSegmentControlHspace, CGRectGetHeight(origionRect) - XTSegmentControlLineHeight, CGRectGetWidth(origionRect) - 2 * XTSegmentControlHspace, XTSegmentControlLineHeight);
    
    CGRect rect;
    
    if (delta > 0) {
//        如果delta大于1的话，不能简单的用相邻item间距的乘法来计算距离
        if (delta > 1) {
            self.currentIndex += floorf(delta);
            delta -= floorf(delta);
            origionRect = [_itemFrames[_currentIndex] CGRectValue];;
            origionLineRect = CGRectMake(CGRectGetMinX(origionRect) + XTSegmentControlHspace, CGRectGetHeight(origionRect) - XTSegmentControlLineHeight, CGRectGetWidth(origionRect) - 2 * XTSegmentControlHspace, XTSegmentControlLineHeight);
        }

        
        
        if (_currentIndex == _itemFrames.count - 1) {
            return;
        }
        
        rect = [_itemFrames[_currentIndex + 1] CGRectValue];
        
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + XTSegmentControlHspace, CGRectGetHeight(rect) - XTSegmentControlLineHeight, CGRectGetWidth(rect) - 2 * XTSegmentControlHspace, XTSegmentControlLineHeight);
        
        CGRect moveRect = CGRectZero;
        
        moveRect.size = CGSizeMake(CGRectGetWidth(origionLineRect) + delta * (CGRectGetWidth(lineRect) - CGRectGetWidth(origionLineRect)), CGRectGetHeight(lineRect));
        moveRect.origin = CGPointMake(CGRectGetMidX(origionLineRect) + delta * (CGRectGetMidX(lineRect) - CGRectGetMidX(origionLineRect)) - CGRectGetMidX(moveRect), CGRectGetMidY(origionLineRect) - CGRectGetMidY(moveRect));
        _lineView.frame = moveRect;
    }else if (delta < 0){
        
        if (_currentIndex == 0) {
            return;
        }
        rect = [_itemFrames[_currentIndex - 1] CGRectValue];
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + XTSegmentControlHspace, CGRectGetHeight(rect) - XTSegmentControlLineHeight, CGRectGetWidth(rect) - 2 * XTSegmentControlHspace, XTSegmentControlLineHeight);
        CGRect moveRect = CGRectZero;
        moveRect.size = CGSizeMake(CGRectGetWidth(origionLineRect) - delta * (CGRectGetWidth(lineRect) - CGRectGetWidth(origionLineRect)), CGRectGetHeight(lineRect));
        moveRect.origin = CGPointMake(CGRectGetMidX(origionLineRect) - delta * (CGRectGetMidX(lineRect) - CGRectGetMidX(origionLineRect)) - CGRectGetMidX(moveRect), CGRectGetMidY(origionLineRect) - CGRectGetMidY(moveRect));
        _lineView.frame = moveRect;
        if (delta < -1) {
            self.currentIndex -= 1;
        }
    }    
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (currentIndex != _currentIndex) {
        XTSegmentControlItem *preItem = [_items objectAtIndex:_currentIndex];
        XTSegmentControlItem *curItem = [_items objectAtIndex:currentIndex];
        [preItem setSelected:NO];
        [curItem setSelected:YES];
        _currentIndex = currentIndex;
    }
}

- (void)endMoveIndex:(NSInteger)index
{
    [self selectIndex:index];
}

- (void)setScrollOffset:(NSInteger)index
{
    if (_contentView.contentSize.width <= kScreen_Width) {
        return;
    }
    
    CGRect rect = [_itemFrames[index] CGRectValue];

    float midX = CGRectGetMidX(rect);
    
    float offset = 0;
    
    float contentWidth = _contentView.contentSize.width;
    
    float halfWidth = CGRectGetWidth(self.bounds) / 2.0;
    
    if (midX < halfWidth) {
        offset = 0;
    }else if (midX > contentWidth - halfWidth){
        offset = contentWidth - 2 * halfWidth;
    }else{
        offset = midX - halfWidth;
    }
    
    [UIView animateWithDuration:XTSegmentControlAnimationTime animations:^{
        [_contentView setContentOffset:CGPointMake(offset, 0) animated:NO];
    }];
}

int ExceMinIndex(float f)
{
    int i = (int)f;
    if (f != i) {
        return i+1;
    }
    return i;
}

@end

