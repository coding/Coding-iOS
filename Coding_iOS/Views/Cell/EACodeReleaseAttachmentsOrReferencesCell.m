//
//  EACodeReleaseAttachmentsOrReferencesCell.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/23.
//  Copyright © 2018年 Coding. All rights reserved.
//

#define kEACodeReleaseAttachmentsOrReferencesCell_ItemHeight 36.0

#import "EACodeReleaseAttachmentsOrReferencesCell.h"

@interface EACodeReleaseAttachmentsOrReferencesCell ()
@property (strong, nonatomic) EACodeRelease *curR;
@property (assign, nonatomic) EACodeReleaseAttachmentsOrReferencesCellType type;

@end


@implementation EACodeReleaseAttachmentsOrReferencesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupCodeRelease:(EACodeRelease *)curR type:(EACodeReleaseAttachmentsOrReferencesCellType)type{
    _type = type;
    _curR = curR;
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (_type == EACodeReleaseAttachmentsOrReferencesCellTypeAttachments) {
        [self p_addHeaderV];
        [self p_addItemWithIndex:0];
        [self p_addItemWithIndex:1];
        for (NSInteger index = 0; index < _curR.attachments.count; index++) {
            [self p_addItemWithIndex:index + 2];
        }
    }else if (_curR.resource_references.count > 0){
        [self p_addHeaderV];
        for (NSInteger index = 0; index < _curR.resource_references.count; index++) {
            [self p_addItemWithIndex:index];
        }
    }
}

- (void)p_addHeaderV{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - 2* kPaddingLeftWidth, kEACodeReleaseAttachmentsOrReferencesCell_ItemHeight + 2)];
    headerV.backgroundColor = kColorTableSectionBg;
    headerV.borderColor = kColorD8DDE4;
    headerV.borderWidth = 1.0;
    headerV.cornerRadius = 2.0;
    headerV.masksToBounds = YES;
    UILabel *titleL = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:kColorDark4];
    titleL.text = _type == EACodeReleaseAttachmentsOrReferencesCellTypeAttachments? @"下载": @"关联资源";
    [headerV addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.centerY.offset(-1.0);
    }];
    [self.contentView addSubview:headerV];
}

- (void)p_addItemWithIndex:(NSInteger)index{
    UIView *itemV = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kEACodeReleaseAttachmentsOrReferencesCell_ItemHeight * (index + 1), kScreen_Width - 2* kPaddingLeftWidth, kEACodeReleaseAttachmentsOrReferencesCell_ItemHeight + 1)];
    itemV.backgroundColor = kColorWhite;
    itemV.borderColor = kColorD8DDE4;
    itemV.borderWidth = 1.0;
    __weak typeof(self) weakSelf = self;
    [itemV bk_whenTapped:^{
        [weakSelf p_handleTappedIndex:index];
    }];
    UIImageView *iconV = [UIImageView new];
    UILabel *nameL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark4];
    nameL.lineBreakMode = NSLineBreakByTruncatingMiddle;
    UILabel *sizeL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark4];
    [itemV addSubview:iconV];
    [itemV addSubview:nameL];
    [itemV addSubview:sizeL];
    [iconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.centerY.equalTo(itemV);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconV.mas_right).offset(5);
        make.centerY.equalTo(itemV);
        make.right.lessThanOrEqualTo(sizeL.mas_left);
    }];
    [sizeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-10);
        make.centerY.equalTo(itemV);
    }];
    [sizeL setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [sizeL setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    if (_type == EACodeReleaseAttachmentsOrReferencesCellTypeAttachments) {
        if (index < 2) {
            iconV.image = [UIImage imageNamed:@"code_release_resource_Zip"];
            nameL.text = index == 0? @"Source code (zip)": @"Source code (tar.gz)";
        }else{
            EACodeReleaseAttachment *item = _curR.attachments[index - 2];
            iconV.image = [UIImage imageNamed:@"code_release_resource_Default"];
            nameL.text = item.name;
            sizeL.text = [NSString sizeDisplayWithByte:item.size.floatValue];
        }
    }else{
        ResourceReferenceItem *item = _curR.resource_references[index];
        iconV.image = [UIImage imageNamed:[NSString stringWithFormat:@"code_release_resource_%@", item.target_type]] ?: [UIImage imageNamed:@"code_release_resource_Default"];
        nameL.text = [NSString stringWithFormat:@"#%@ %@", item.code, item.title];
    }
    [self.contentView addSubview:itemV];
}

- (void)p_handleTappedIndex:(NSInteger)index{
    if (_type == EACodeReleaseAttachmentsOrReferencesCellTypeAttachments) {
        if (index < 2) {
            [NSObject showHudTipStr:@"暂不支持下载"];
        }else if (_itemClickedBlock){
            _itemClickedBlock(_curR.attachments[index - 2]);
        }
    }else{
        if (_itemClickedBlock) {
            _itemClickedBlock(_curR.resource_references[index]);
        }
    }
}


+ (CGFloat)cellHeightWithObj:(EACodeRelease *)obj type:(EACodeReleaseAttachmentsOrReferencesCellType)type{
    CGFloat cellHeight = 0;
    if (type == EACodeReleaseAttachmentsOrReferencesCellTypeAttachments) {
        cellHeight = kEACodeReleaseAttachmentsOrReferencesCell_ItemHeight * (3 + obj.attachments.count) + 15;
    }else{
        cellHeight = obj.resource_references.count > 0? kEACodeReleaseAttachmentsOrReferencesCell_ItemHeight * (1 + obj.resource_references.count) + 15: 0;
    }
    return cellHeight;
}

@end
