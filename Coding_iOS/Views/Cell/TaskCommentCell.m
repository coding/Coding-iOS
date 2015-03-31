//
//  TaskCommentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/28.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTaskCommentCell_FontContent [UIFont systemFontOfSize:15]
#define kTaskCommentCell_LeftPading 20.0
#define kTaskCommentCell_LeftContentPading (kTaskCommentCell_LeftPading + 40)
#define kTaskCommentCell_ContentWidth (kScreen_Width - kTaskCommentCell_LeftContentPading - kTaskCommentCell_LeftPading)

#import "TaskCommentCell.h"
#import "UICustomCollectionView.h"
#import "TaskCommentCCell.h"

#import "MJPhotoBrowser.h"

@interface TaskCommentCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIImageView *ownerIconView;
@property (strong, nonatomic) UILabel *contentLabel, *timeLabel;
@property (strong, nonatomic) UICustomCollectionView *imageCollectionView;

@end

@implementation TaskCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat curBottomY = 10;
        if (!_ownerIconView) {
            _ownerIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftPading, curBottomY, 33, 33)];
            [_ownerIconView doCircleFrame];
            [self.contentView addSubview:_ownerIconView];
        }
        if (!_contentLabel) {
            _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftContentPading, curBottomY, kTaskCommentCell_ContentWidth, 30)];
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x555555"];
            _contentLabel.font = kTaskCommentCell_FontContent;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftContentPading, 0, kTaskCommentCell_ContentWidth, 20)];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
        if ([reuseIdentifier isEqualToString:kCellIdentifier_TaskComment_Media]) {
            if (!self.imageCollectionView) {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                self.imageCollectionView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftContentPading, 0, kTaskCommentCell_ContentWidth, 43) collectionViewLayout:layout];
                self.imageCollectionView.scrollEnabled = NO;
                [self.imageCollectionView setBackgroundView:nil];
                [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
                [self.imageCollectionView registerClass:[TaskCommentCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TaskCommentCCell];
                self.imageCollectionView.dataSource = self;
                self.imageCollectionView.delegate = self;
                [self.contentView addSubview:self.imageCollectionView];
            }
        }
    }
    return self;
}

- (void)setCurComment:(TaskComment *)curComment{
    _curComment = curComment;
    if (!_curComment) {
        return;
    }
    CGFloat curBottomY = 10;
    [_ownerIconView sd_setImageWithURL:[_curComment.owner.avatar urlImageWithCodePathResizeToView:_ownerIconView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerIconView)];
    NSString *contentStr = _curComment.content;
    [_contentLabel setLongString:contentStr withFitWidth:kTaskCommentCell_ContentWidth];
    curBottomY += [contentStr getHeightWithFont:kTaskCommentCell_FontContent constrainedToSize:CGSizeMake(kTaskCommentCell_ContentWidth, CGFLOAT_MAX)] + 5;
    
    NSInteger imagesCount = _curComment.htmlMedia.imageItems.count;
    if (imagesCount > 0) {
        self.imageCollectionView.hidden = NO;
        [self.imageCollectionView setFrame:CGRectMake(kTaskCommentCell_LeftContentPading, curBottomY, kTaskCommentCell_ContentWidth, [TaskCommentCell imageCollectionViewHeightWithCount:imagesCount])];
        [self.imageCollectionView reloadData];
    }else{
        self.imageCollectionView.hidden = YES;
    }
    
    curBottomY += [TaskCommentCell imageCollectionViewHeightWithCount:imagesCount];
    
    [_timeLabel setY:curBottomY];
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", _curComment.owner.name, [_curComment.created_at stringTimesAgo]];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[TaskComment class]]) {
        TaskComment *curComment = (TaskComment *)obj;
        NSString *contentStr = curComment.content;
        cellHeight += 10 +[contentStr getHeightWithFont:kTaskCommentCell_FontContent constrainedToSize:CGSizeMake(kTaskCommentCell_ContentWidth, CGFLOAT_MAX)] + 5 +20 +10;
        cellHeight += [self imageCollectionViewHeightWithCount:curComment.htmlMedia.imageItems.count];
    }
    return cellHeight;
}

+ (CGFloat)imageCollectionViewHeightWithCount:(NSInteger)countNum{
    if (countNum <= 0) {
        return 0;
    }
    NSInteger numInOneLine = floorf((kTaskCommentCell_ContentWidth +10)/43);
    NSInteger numOfline = ceilf(countNum/(float)numInOneLine);
    return (43 *numOfline);
}


#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _curComment.htmlMedia.imageItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TaskCommentCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TaskCommentCCell forIndexPath:indexPath];
    ccell.curMediaItem = [_curComment.htmlMedia.imageItems objectAtIndex:indexPath.row];
    return ccell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [TaskCommentCCell ccellSize];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10/2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    HtmlMediaItem *curMediaItem = [_curComment.htmlMedia.imageItems objectAtIndex:indexPath.row];
    NSLog(@"curMediaItem: %@", curMediaItem.src);
    //        显示大图
    int count = (int)_curComment.htmlMedia.imageItems.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        HtmlMediaItem *imageItem = [_curComment.htmlMedia.imageItems objectAtIndex:i];
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
