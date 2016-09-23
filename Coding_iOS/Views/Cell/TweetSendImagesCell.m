//
//  TweetSendImagesCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCCellIdentifier_TweetSendImage @"TweetSendImageCCell"
#import "TweetSendImagesCell.h"
#import "TweetSendImageCCell.h"
#import "UICustomCollectionView.h"
#import "MJPhotoBrowser.h"

@interface TweetSendImagesCell ()
@property (strong, nonatomic) UICustomCollectionView *mediaView;
@property (strong, nonatomic) NSMutableDictionary *imageViewsDict;
@end

@implementation TweetSendImagesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!self.mediaView) {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            self.mediaView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(15, 0, kScreen_Width-2*15, 80) collectionViewLayout:layout];
            self.mediaView.scrollEnabled = NO;
            [self.mediaView setBackgroundView:nil];
            [self.mediaView setBackgroundColor:[UIColor clearColor]];
            [self.mediaView registerClass:[TweetSendImageCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TweetSendImage];
            self.mediaView.dataSource = self;
            self.mediaView.delegate = self;
            [self.contentView addSubview:self.mediaView];
        }
        if (!_imageViewsDict) {
            _imageViewsDict = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCurTweet:(Tweet *)curTweet{
    if (_curTweet != curTweet) {
        _curTweet = curTweet;
    }
    [self.mediaView setHeight:[TweetSendImagesCell cellHeightWithObj:_curTweet]];
    [_mediaView reloadData];
}
+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Tweet class]]) {
        Tweet *curTweet = (Tweet *)obj;
        NSInteger row;
        if (curTweet.tweetImages.count <= 0) {
            row = 0;
        }else{
            row = ceilf((float)(curTweet.tweetImages.count +1)/4.0);
        }
        cellHeight = ([TweetSendImageCCell ccellSize].height +10) *row;
    }
    return cellHeight;
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger num = _curTweet.tweetImages.count;
    return num < 9? num+ 1: num;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    
    TweetSendImageCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetSendImage forIndexPath:indexPath];
    if (indexPath.row < _curTweet.tweetImages.count) {
        TweetImage *curImage = [weakSelf.curTweet.tweetImages objectAtIndex:indexPath.row];
        ccell.curTweetImg = curImage;
    }else{
        ccell.curTweetImg = nil;
    }
    ccell.deleteTweetImageBlock = ^(TweetImage *toDelete){
        if (weakSelf.deleteTweetImageBlock) {
            weakSelf.deleteTweetImageBlock(toDelete);
        }
    };
    [_imageViewsDict setObject:ccell.imgView forKey:indexPath];
    return ccell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [TweetSendImageCCell ccellSize];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _curTweet.tweetImages.count) {
        if (_addPicturesBlock) {
            _addPicturesBlock();
        }
    }else{
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:_curTweet.tweetImages.count];
        for (int i = 0; i < _curTweet.tweetImages.count; i++) {
            TweetImage *imageItem = [_curTweet.tweetImages objectAtIndex:i];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.srcImageView = [_imageViewsDict objectForKey:indexPath]; // 来源于哪个UIImageView
            photo.image = imageItem.image; // 图片路径
            [photos addObject:photo];
        }
        // 2.显示相册
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        browser.showSaveBtn = NO;
        [browser show];
    }
}


@end
