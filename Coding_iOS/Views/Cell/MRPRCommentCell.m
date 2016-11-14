//
//  MRPRCommentCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kMRPRCommentCell_FontContent [UIFont systemFontOfSize:15]

#import "MRPRCommentCell.h"
#import "UICustomCollectionView.h"
#import "MRPRCommentCCell.h"
#import "MJPhotoBrowser.h"
#import "HtmlMediaViewController.h"

@interface MRPRCommentCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIImageView *ownerIconView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UICustomCollectionView *imageCollectionView;
@property (strong, nonatomic) UIButton *detailBtn;

@end

@implementation MRPRCommentCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = kColorTableBG;
        CGFloat curBottomY = 10;
        if (!_ownerIconView) {
            _ownerIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, curBottomY, 33, 33)];
            [_ownerIconView doCircleFrame];
            [self.contentView addSubview:_ownerIconView];
        }
        CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 40, curBottomY, curWidth, 30)];
            _contentLabel.textColor = kColor222;
            _contentLabel.font = kMRPRCommentCell_FontContent;
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            [self.contentView addSubview:_contentLabel];
        }
        CGFloat commentBtnWidth = 40;
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +40, 0, curWidth- commentBtnWidth, 20)];
            _timeLabel.textColor = kColor999;
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
        if ([reuseIdentifier rangeOfString:@"_Media"].location != NSNotFound) {
            if (!self.imageCollectionView) {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                self.imageCollectionView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 40, 0, curWidth, 43) collectionViewLayout:layout];
                self.imageCollectionView.scrollEnabled = NO;
                [self.imageCollectionView setBackgroundView:nil];
                [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
                [self.imageCollectionView registerClass:[MRPRCommentCCell class] forCellWithReuseIdentifier:kCCellIdentifier_MRPRCommentCCell];
                self.imageCollectionView.dataSource = self;
                self.imageCollectionView.delegate = self;
                [self.contentView addSubview:self.imageCollectionView];
            }
        }
        if (!_detailBtn) {
            _detailBtn = [UIButton buttonWithTitle:@"查看详情" titleColor:kColorBrandGreen];
            _detailBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            [_detailBtn addTarget:self action:@selector(goToDetail) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_detailBtn];
            [_detailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(60, 30));
                make.right.equalTo(self.contentView).offset(-10);
                make.centerY.equalTo(_timeLabel);
            }];
        }
        _timeLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return self;
}

- (void)goToDetail{
    HtmlMediaViewController *vc = [HtmlMediaViewController instanceWithHtmlMedia:self.curItem.htmlMedia title:[NSString stringWithFormat:@"%@ 的评论", self.curItem.author.name]];
    [BaseViewController goToVC:vc];
}


- (void)setCurItem:(ProjectLineNote *)curItem{
    _curItem = curItem;
    
    if (!_curItem) {
        return;
    }
    _detailBtn.hidden = ![self.curItem.htmlMedia needToShowDetail];
    CGFloat curBottomY = 10;
    CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
    [_ownerIconView sd_setImageWithURL:[_curItem.author.avatar urlImageWithCodePathResizeToView:_ownerIconView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerIconView)];
    [_contentLabel setLongString:_curItem.content withFitWidth:curWidth];
    
    for (HtmlMediaItem *item in _curItem.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && item.href.length > 0) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    curBottomY += [_curItem.content getHeightWithFont:kMRPRCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 5;
    
    NSInteger imagesCount = _curItem.htmlMedia.imageItems.count;
    if (imagesCount > 0) {
        self.imageCollectionView.hidden = NO;
        [self.imageCollectionView setFrame:CGRectMake(kPaddingLeftWidth +40, curBottomY, curWidth, [MRPRCommentCell imageCollectionViewHeightWithCount:imagesCount])];
        [self.imageCollectionView reloadData];
    }else{
        self.imageCollectionView.hidden = YES;
    }
    
    curBottomY += [MRPRCommentCell imageCollectionViewHeightWithCount:imagesCount];
    
    [_timeLabel setY:curBottomY];
    _timeLabel.width = _detailBtn.hidden? kScreen_Width - 40 - 2*kPaddingLeftWidth: kScreen_Width - 40 - 2*kPaddingLeftWidth - 60;
    _timeLabel.text = [NSString stringWithFormat:@"%@ %@", _curItem.author.name, [_curItem.created_at stringDisplay_HHmm]];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[ProjectLineNote class]]) {
        ProjectLineNote *curItem = (ProjectLineNote *)obj;
        CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
        cellHeight += 10 +[curItem.content getHeightWithFont:kMRPRCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 5 +20 +10;
        cellHeight += [self imageCollectionViewHeightWithCount:curItem.htmlMedia.imageItems.count];
    }
    return cellHeight;
}

+ (CGFloat)imageCollectionViewHeightWithCount:(NSInteger)countNum{
    if (countNum <= 0) {
        return 0;
    }
    CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
    NSInteger numInOneLine = floorf((curWidth +5)/(33 + 5));
    NSInteger numOfline = ceilf(countNum/(float)numInOneLine);
    return (43 *numOfline);
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _curItem.htmlMedia.imageItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MRPRCommentCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_MRPRCommentCCell forIndexPath:indexPath];
    ccell.curMediaItem = [_curItem.htmlMedia.imageItems objectAtIndex:indexPath.row];
    return ccell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [MRPRCommentCCell ccellSize];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //        显示大图
    int count = (int)_curItem.htmlMedia.imageItems.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        HtmlMediaItem *imageItem = [_curItem.htmlMedia.imageItems objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageItem.src]; // 图片路径
        [photos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

@end
