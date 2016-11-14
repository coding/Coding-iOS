//
//  TopicCommentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTopicCommentCell_FontContent [UIFont systemFontOfSize:15]

#import "TopicCommentCell.h"

#import "UICustomCollectionView.h"
#import "TopicCommentCCell.h"

#import "MJPhotoBrowser.h"
#import "Coding_NetAPIManager.h"
#import "HtmlMediaViewController.h"

@interface TopicCommentCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIImageView *ownerIconView;
@property (strong, nonatomic) UIView *bestAnswerV;
@property (strong, nonatomic) UIButton *voteBtn, *voteBtnBig;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UICustomCollectionView *imageCollectionView;
@property (strong, nonatomic) UIButton *detailBtn;

@end

@implementation TopicCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_bestAnswerV) {
            _bestAnswerV = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 80, 24)];
            _bestAnswerV.backgroundColor = [UIColor colorWithHexString:@"0x2FAEEA"];
            UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_best_answer"]];
            [_bestAnswerV addSubview:imageV];
            UILabel *label = [UILabel labelWithSystemFontSize:11 textColorHexString:@"0xFFFFFF"];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"最佳答案";
            [_bestAnswerV addSubview:label];
            [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_bestAnswerV);
                make.left.equalTo(_bestAnswerV).offset(10);
                make.size.mas_offset(CGSizeMake(11, 12));
            }];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_bestAnswerV);
                make.left.equalTo(imageV.mas_right);
                make.right.equalTo(_bestAnswerV);
            }];
            [self.contentView addSubview:_bestAnswerV];
        }
        CGFloat curBottomY = 15;
        if (!_ownerIconView) {
            _ownerIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, curBottomY, 33, 33)];
            [_ownerIconView doCircleFrame];
            [self.contentView addSubview:_ownerIconView];
        }
        if (!_voteBtn) {
            _voteBtn = [[UIButton alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 1.5, _ownerIconView.bottom, 30, 18)];
            [_voteBtn doBorderWidth:0.5 color:kColorCCC cornerRadius:2.0];
            _voteBtn.titleLabel.font = [UIFont systemFontOfSize:11];
            [_voteBtn addTarget:self action:@selector(voteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_voteBtn];
            
            _voteBtnBig = [[UIButton alloc] initWithFrame:CGRectInset(_voteBtn.frame, -10, -5)];
            [_voteBtnBig addTarget:self action:@selector(voteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView insertSubview:_voteBtnBig belowSubview:_voteBtn];
        }
        CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 40, curBottomY, curWidth, 30)];
            _contentLabel.textColor = kColor222;
            _contentLabel.font = kTopicCommentCell_FontContent;
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            [_contentLabel addLongPressForCopy];
            [self.contentView addSubview:_contentLabel];
        }
        CGFloat commentBtnWidth = 40;
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +40, 0, curWidth- commentBtnWidth, 20)];
            _timeLabel.textColor = kColor999;
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
        if ([reuseIdentifier isEqualToString:kCellIdentifier_TopicComment_Media]) {
            if (!self.imageCollectionView) {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                self.imageCollectionView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 40, 0, curWidth, 43) collectionViewLayout:layout];
                self.imageCollectionView.scrollEnabled = NO;
                [self.imageCollectionView setBackgroundView:nil];
                [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
                [self.imageCollectionView registerClass:[TopicCommentCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TopicCommentCCell];
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
    HtmlMediaViewController *vc = [HtmlMediaViewController instanceWithHtmlMedia:self.toComment.htmlMedia title:[NSString stringWithFormat:@"%@ 的评论", self.toComment.owner.name]];
    [BaseViewController goToVC:vc];
}

- (void)voteBtnClicked{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_UpvoteAnswer:_toComment inProjectId:_projectId andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf setVoteCount:weakSelf.toComment.up_vote_counts isVoted:weakSelf.toComment.is_up_voted.boolValue];
        }
    }];
}

- (void)setVoteCount:(NSNumber *)voteCount isVoted:(BOOL)isVoted{
    [_voteBtn setBackgroundColor:[UIColor colorWithHexString:isVoted? @"0x3BBD79": @"0xFFFFFF"]];
    [_voteBtn setTitleColor:[UIColor colorWithHexString:isVoted? @"0xFFFFFF": @"0x666666"] forState:UIControlStateNormal];
    [_voteBtn setTitle:[NSString stringWithFormat:@"+%@", voteCount] forState:UIControlStateNormal];
}

- (void)setToComment:(ProjectTopic *)toComment{
    _toComment = toComment;
    
    if (!_toComment) {
        return;
    }
    _detailBtn.hidden = ![self.toComment.htmlMedia needToShowDetail];
    CGFloat curBottomY = 15;
    CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
    
    _bestAnswerV.hidden = !_toComment.is_recommended.boolValue;
    if (_toComment.is_recommended.boolValue) {
        curBottomY = 35;
    }
    
    _ownerIconView.y = _contentLabel.y = curBottomY;
    _voteBtn.y = _ownerIconView.bottom + 5;
    _voteBtnBig.y = _voteBtn.y - 5;
    [self setVoteCount:_toComment.up_vote_counts isVoted:_toComment.is_up_voted.boolValue];
    [_ownerIconView sd_setImageWithURL:[_toComment.owner.avatar urlImageWithCodePathResizeToView:_ownerIconView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerIconView)];
    [_contentLabel setLongString:_toComment.content withFitWidth:curWidth];
    for (HtmlMediaItem *item in _toComment.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && item.href.length > 0) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    curBottomY += [_toComment.content getHeightWithFont:kTopicCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 10;
    
    NSInteger imagesCount = _toComment.htmlMedia.imageItems.count;
    if (imagesCount > 0) {
        self.imageCollectionView.hidden = NO;
        [self.imageCollectionView setFrame:CGRectMake(kPaddingLeftWidth +40, curBottomY, curWidth, [TopicCommentCell imageCollectionViewHeightWithCount:imagesCount])];
        [self.imageCollectionView reloadData];
    }else{
        self.imageCollectionView.hidden = YES;
    }
    
    curBottomY += [TopicCommentCell imageCollectionViewHeightWithCount:imagesCount];
    
    [_timeLabel setY:curBottomY];
    _timeLabel.width = _detailBtn.hidden? kScreen_Width - 40 - 2*kPaddingLeftWidth: kScreen_Width - 40 - 2*kPaddingLeftWidth - 60;
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", _toComment.owner.name, [_toComment.created_at stringDisplay_HHmm]];
}

- (void)setIsAnswer:(BOOL)isAnswer{
    _isAnswer = isAnswer;
    _ownerIconView.hidden = _voteBtn.hidden = _voteBtnBig.hidden = !_isAnswer;
    _contentLabel.textColor = [UIColor colorWithHexString:_isAnswer? @"0x222222": @"0x666666"];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[ProjectTopic class]]) {
        ProjectTopic *toComment = (ProjectTopic *)obj;
        CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
        cellHeight += 15 +[toComment.content getHeightWithFont:kTopicCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 10 +20 +15;
        cellHeight += [self imageCollectionViewHeightWithCount:toComment.htmlMedia.imageItems.count];
        cellHeight += toComment.is_recommended.boolValue? 20: 0;
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
    return _toComment.htmlMedia.imageItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TopicCommentCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TopicCommentCCell forIndexPath:indexPath];
    ccell.curMediaItem = [_toComment.htmlMedia.imageItems objectAtIndex:indexPath.row];
    return ccell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [TopicCommentCCell ccellSize];
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
    int count = (int)_toComment.htmlMedia.imageItems.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        HtmlMediaItem *imageItem = [_toComment.htmlMedia.imageItems objectAtIndex:i];
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
