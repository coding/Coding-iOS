//
//  ProjectTagsView.m
//  Coding_iOS
//
//  Created by Ease on 15/7/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kProjectTagsView_Padding_Icon 28.0
#define kProjectTagsView_Height_PerLine 30.0

#define kProjectTagsViewLabel_Font [UIFont systemFontOfSize:12]
#define kProjectTagsViewLabel_Height_Content 24.0
#define kProjectTagsViewLabel_MinWidth 44.0
#define kProjectTagsViewLabel_Padding_Content 10.0
#define kProjectTagsViewLabel_Padding_Space 5.0

#import "ProjectTagsView.h"

@interface ProjectTagsView ()
@property (strong, nonatomic) NSMutableArray *tagLabelList;
@property (strong, nonatomic) UIButton *addTagButton;
@property (strong, nonatomic) UIImageView *tagIconView;
@end


@implementation ProjectTagsView

- (instancetype)initWithTags:(NSArray *)tags{
    self = [super init];
    if (self) {
        _tagLabelList = [NSMutableArray new];
        self.tags = tags;
    }
    return self;
}
+ (instancetype)viewWithTags:(NSArray *)tags{
    ProjectTagsView *tagsView = [[self alloc] initWithTags:tags];
    return tagsView;
}

+ (CGFloat)getHeightForTags:(NSArray *)tags{
    CGFloat height = 0;
    if (tags.count > 0) {
        CGFloat tagsWidth = kScreen_Width - 2*kPaddingLeftWidth - kProjectTagsView_Padding_Icon;
        CGFloat curX = 0, curY = 0;
        for (ProjectTag *curTag in tags) {
            CGFloat curTagWidth = MAX([curTag.name getWidthWithFont:kProjectTagsViewLabel_Font constrainedToSize:CGSizeMake(CGFLOAT_MAX, kProjectTagsViewLabel_Height_Content)] + kProjectTagsViewLabel_Padding_Content, kProjectTagsViewLabel_MinWidth) ;
            curX += MIN(curTagWidth, tagsWidth);
            if (curX > tagsWidth) {
                curY += kProjectTagsView_Height_PerLine;
                curX = curTagWidth + kProjectTagsViewLabel_Padding_Space;
            }else{
                curX += kProjectTagsViewLabel_Padding_Space;
            }
        }

        CGFloat buttonWidth = [@"添加标签" getWidthWithFont:kProjectTagsViewLabel_Font constrainedToSize:CGSizeMake(CGFLOAT_MAX, kProjectTagsViewLabel_Height_Content)] + kProjectTagsViewLabel_Padding_Content;
        if (curX + buttonWidth > tagsWidth) {
            curY += kProjectTagsView_Height_PerLine;
        }
        height = curY +kProjectTagsView_Height_PerLine;
    }else{
        height = kProjectTagsView_Height_PerLine;
    }
    return height;
}

- (void)setTags:(NSArray *)tags{
    _tags = tags;
    [self p_refreshAddButtonHasTags:_tags.count > 0];
    
    CGPoint curPoint = CGPointZero;
    if (_tags.count > 0) {
//        图标
        if (!_tagIconView) {
            _tagIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"project_tag_icon"]];
        }
        [_tagIconView setCenter:CGPointMake(kPaddingLeftWidth + CGRectGetWidth(_tagIconView.frame)/2, kProjectTagsViewLabel_Height_Content/2)];
        [self addSubview:_tagIconView];
        
//        标签
        CGFloat leftX = kPaddingLeftWidth + kProjectTagsView_Padding_Icon;
        CGFloat tagsWidth = kScreen_Width - kPaddingLeftWidth - leftX;
        curPoint.x = leftX;
        int index;
        for (index = 0; index < _tags.count; index++) {
            ProjectTagsViewLabel *curLabel;
            if (_tagLabelList.count > index) {
                curLabel = _tagLabelList[index];
                curLabel.curTag = _tags[index];
            }else{
                @weakify(self);
                curLabel = [ProjectTagsViewLabel labelWithTag:_tags[index] andDeleteBlock:^(ProjectTag *tag) {
                    @strongify(self);
                    if (self.deleteTagBlock) {
                        self.deleteTagBlock(tag);
                    }
                }];
                [_tagLabelList addObject:curLabel];
            }
            
            CGFloat curPointRightX = curPoint.x + MIN(CGRectGetWidth(curLabel.frame), tagsWidth);
            if (curPointRightX > kScreen_Width - kPaddingLeftWidth) {
                curPoint.x = leftX;
                curPoint.y += kProjectTagsView_Height_PerLine;
            }
            [curLabel setOrigin:curPoint];
            [self addSubview:curLabel];
            
            //下一个点
            curPoint.x += CGRectGetWidth(curLabel.frame) +kProjectTagsViewLabel_Padding_Space;
        }
        if (_tagLabelList.count > index) {
            [_tagLabelList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
                if (idx >= index) {
                    [obj removeFromSuperview];
                }else{
                    *stop = YES;
                }
            }];
            [_tagLabelList removeObjectsInRange:NSMakeRange(index, _tagLabelList.count -index)];
        }
        //按钮
        if (curPoint.x + CGRectGetWidth(self.addTagButton.frame) > kScreen_Width - kPaddingLeftWidth) {
            curPoint.x = leftX;
            curPoint.y += kProjectTagsView_Height_PerLine;
        }
        [self.addTagButton setOrigin:curPoint];
    }else{
        [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            if (![obj isKindOfClass:[UIButton class]]) {
                [obj removeFromSuperview];
            }
        }];
        [_tagLabelList removeAllObjects];
        curPoint.x = kPaddingLeftWidth;
        [self.addTagButton setOrigin:curPoint];
    }

    [self setSize:CGSizeMake(kScreen_Width, curPoint.y + kProjectTagsView_Height_PerLine)];
}

- (void)p_refreshAddButtonHasTags:(BOOL)hasTags{
    if (!_addTagButton) {
        _addTagButton = [UIButton new];
        _addTagButton.layer.cornerRadius = 2;
        _addTagButton.layer.borderColor = kColorDark7.CGColor;
        @weakify(self);
        [_addTagButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.addTagBlock) {
                self.addTagBlock();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addTagButton];
    }
    NSString *buttonTitle = @"添加标签";
    if (hasTags) {
        _addTagButton.layer.borderWidth = 1.0f;
        _addTagButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _addTagButton.titleLabel.font = kProjectTagsViewLabel_Font;
        [_addTagButton setTitleColor:kColorDark7 forState:UIControlStateNormal];
        [_addTagButton setTitleColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateHighlighted];

        CGFloat textWidth = [buttonTitle getWidthWithFont:kProjectTagsViewLabel_Font constrainedToSize:CGSizeMake(CGFLOAT_MAX, kProjectTagsViewLabel_Height_Content)];
        [_addTagButton setTitle:buttonTitle forState:UIControlStateNormal];
        [_addTagButton setImage:nil forState:UIControlStateNormal];
        [_addTagButton setTitleEdgeInsets:UIEdgeInsetsZero];
        [_addTagButton setSize:CGSizeMake(textWidth + kProjectTagsViewLabel_Padding_Content, kProjectTagsViewLabel_Height_Content)];
    }else{
        _addTagButton.layer.borderWidth = 0.f;
        _addTagButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _addTagButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_addTagButton setTitleColor:kColorBrandGreen forState:UIControlStateNormal];
        [_addTagButton setTitleColor:[UIColor colorWithHexString:@"0x2EBE76" andAlpha:0.5] forState:UIControlStateHighlighted];
        
        [_addTagButton setSize:CGSizeMake(kScreen_Width - 2*kPaddingLeftWidth, kProjectTagsViewLabel_Height_Content)];
        [_addTagButton setTitle:buttonTitle forState:UIControlStateNormal];
        [_addTagButton setImage:[UIImage imageNamed:@"project_tag_btn"] forState:UIControlStateNormal];
        [_addTagButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    }
}

@end



@implementation ProjectTagsViewLabel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.font = kProjectTagsViewLabel_Font;
        self.textAlignment = NSTextAlignmentCenter;
        self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.layer.cornerRadius = 2;
        @weakify(self);
        [self addPressMenuTitles:@[@"删除"] menuClickedBlock:^(NSInteger index, NSString *title) {
            @strongify(self);
            if (self.deleteBlock) {
                self.deleteBlock(self.curTag);
            }
        }];
        self.pressGR.minimumPressDuration = 0.2;//菜单更易弹出
    }
    return self;
}

+ (instancetype)labelWithTag:(ProjectTag *)tag andDeleteBlock:(void (^)(ProjectTag *tag))block{
    ProjectTagsViewLabel *label = [ProjectTagsViewLabel new];
    label.curTag = tag;
    label.deleteBlock = block;
    return label;
}

- (void)setCurTag:(ProjectTag *)curTag{
    _curTag = curTag;
    [self setup];
}

- (void)setup{
    if (!self.curTag || self.curTag.name.length <= 0) {
        [self setSize:CGSizeZero];
        return;
    }
    UIColor *tagColor = self.curTag.color.length > 1? [UIColor colorWithHexString:[self.curTag.color stringByReplacingOccurrencesOfString:@"#" withString:@"0x"]]: kColorBrandGreen;
    self.layer.backgroundColor = tagColor.CGColor;
    self.textColor = [tagColor isDark]? [UIColor whiteColor]: [UIColor blackColor];
    
    CGFloat selfWidth = MAX([self.curTag.name getWidthWithFont:kProjectTagsViewLabel_Font constrainedToSize:CGSizeMake(CGFLOAT_MAX, kProjectTagsViewLabel_Height_Content)] + kProjectTagsViewLabel_Padding_Content, kProjectTagsViewLabel_MinWidth);
    [self setSize:CGSizeMake(selfWidth, kProjectTagsViewLabel_Height_Content)];
    self.text = self.curTag.name;
}

@end
