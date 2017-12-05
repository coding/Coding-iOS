//
//  ProjectItemsCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define ProjectItemsCell_ItemHeight (kScreen_Width/4)
#define ProjectItemsCell_PadingHeight kScaleFrom_iPhone5_Desgin(10)

#import "ProjectItemsCell.h"
#import <FontAwesome+iOS/UIImage+FontAwesome.h>

@interface ProjectItemsCell ()
@property (strong, nonatomic) NSMutableArray *items;
@end


@implementation ProjectItemsCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSInteger itemsNum = 0, itemsNumInLine = 1;
        NSArray *itemsIconList, *itemsColorList, *itemsTitleList;
        if ([reuseIdentifier isEqualToString:kCellIdentifier_ProjectItemsCell_Private]) {
            itemsNum = 6;
            itemsNumInLine = 3;

            itemsIconList = @[@"icon-bolt", @"icon-tasks", @"icon-comments", @"icon-folder-open", @"icon-code", @"icon-user"];
            itemsColorList = @[@"0x2EBE76", @"0x25c2d5", @"0x3899d0", @"0xf8b327", @"0xee8c35", @"0xe7683d"];
            itemsTitleList = @[@"动态", @"任务", @"讨论", @"文件", @"代码", @"成员"];

        }else if ([reuseIdentifier isEqualToString:kCellIdentifier_ProjectItemsCell_Public]){
            itemsNum = 4;
            itemsNumInLine = 4;
            
            itemsIconList = @[@"icon-bolt", @"icon-comments", @"icon-code", @"icon-user"];
            itemsColorList = @[@"0x2EBE76", @"0x3899d0", @"0xee8c35", @"0xe7683d"];
            itemsTitleList = @[@"动态", @"讨论", @"代码", @"成员"];
        }
        
        if (MIN(MIN(itemsIconList.count, itemsColorList.count), itemsTitleList.count) < itemsNum || itemsNum <= 0) {
            return self;
        }else{
            _items = [[NSMutableArray alloc] initWithCapacity:itemsNum];
            CGFloat itemWidth = kScreen_Width/itemsNumInLine;
            for (int i = 0; i < itemsNum; i++) {
                CGRect frame = CGRectMake(itemWidth *(i%itemsNumInLine), ProjectItemsCell_PadingHeight+ ProjectItemsCell_ItemHeight *(i/itemsNumInLine), itemWidth, ProjectItemsCell_ItemHeight);
                UIButton *item = [self itemWithFrame:frame icon:itemsIconList[i] color:itemsColorList[i] title:itemsTitleList[i] index:i];
                [self.contentView addSubview:item];
                [_items addObject:item];
            }
        }
    }
    return self;
}


- (void)setCurProject:(Project *)curProject{
    _curProject = curProject;
    if (!_curProject) {
        return;
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Project class]]) {
        Project *curProject = (Project *)obj;
        cellHeight = ProjectItemsCell_ItemHeight *(curProject.is_public.boolValue? 1: 2);
        cellHeight += 2* ProjectItemsCell_PadingHeight;
    }
    return cellHeight;
}

#pragma mark ButtonItem

#define kProjectItemsCell_ItemIconTag 100

- (UIButton *)itemWithFrame:(CGRect)frame icon:(NSString *)iconStr color:(NSString *)colorStr title:(NSString *)titleStr index:(NSInteger)index{
    UIButton *item = [[UIButton alloc] initWithFrame:frame];
    
    CGFloat iconWidth = kScaleFrom_iPhone5_Desgin(46);
    UIImage *itemImg = [UIImage imageWithIcon:iconStr backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] andSize:CGSizeMake(iconWidth/2.8, iconWidth/2.8)];
    UIImageView *itemImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconWidth, iconWidth)];
    itemImgView.tag = kProjectItemsCell_ItemIconTag;
    itemImgView.contentMode = UIViewContentModeCenter;
    itemImgView.layer.masksToBounds = YES;
    itemImgView.layer.cornerRadius = itemImgView.frame.size.width/2;
    [itemImgView setImage:itemImg];
    [itemImgView setBackgroundColor:[UIColor colorWithHexString:colorStr]];
    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.font = [UIFont systemFontOfSize:13];
    titleL.textColor = kColor222;
    titleL.text = titleStr;
    
//    CGFloat pading_IconToTitle = kScaleFrom_iPhone5_Desgin(10);
//    CGFloat pading = (CGRectGetHeight(item.frame) - iconWidth - 15 - pading_IconToTitle)/2;
    CGFloat pading = (CGRectGetHeight(item.frame) - iconWidth - 15)/3;
    
    [item addSubview:itemImgView];
    [item addSubview:titleL];
    [itemImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(item.mas_centerX);
        make.top.equalTo(item.mas_top).offset(pading);
        make.size.mas_equalTo(CGSizeMake(iconWidth, iconWidth));
    }];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.left.right.equalTo(item);
        make.bottom.equalTo(item.mas_bottom).offset(-pading);
        make.bottom.equalTo(item.mas_centerY).offset(iconWidth/2);
        make.height.mas_equalTo(15);
    }];
    
    [item bk_addEventHandler:^(id sender) {
        if (self.itemClickedBlock) {
            self.itemClickedBlock(index);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    return item;
}

@end
