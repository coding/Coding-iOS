//
//  NSObject+PRReviewerListCell.m
//  Coding_iOS
//
//  Created by hardac on 16/3/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "MRReviewerListCell.h"
#import "Reviewer.h"
#define kDefaultImageSize 33
#define kDefaultImageCount 8
@interface MRReviewerListCell ()
//@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) NSMutableArray *imgViews;
@property (strong, nonatomic) NSMutableArray *likeHeadImgViews;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSArray *reviewerList;
@end

@implementation MRReviewerListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.imgViews = [[NSMutableArray alloc] init];
        self.likeHeadImgViews  = [[NSMutableArray alloc] init];
        self.backgroundColor = kColorTableBG;
        __weak typeof(self) weakSelf = self;
        for(int i = 0; i < kDefaultImageCount; i ++)
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(40 * (i + 1)  + 10, 15, kDefaultImageSize, kDefaultImageSize)];
            [imgView doCircleFrame];
            [imgView setHidden:true];
            [self.imgViews addObject:imgView];
            [self.contentView addSubview:imgView];
            UIImageView *likeHeadView = [[UIImageView alloc] initWithFrame:CGRectMake(40 * (i + 1)  + 23,30, 18, 18)];
            [likeHeadView doCircleFrame];
            [likeHeadView setHidden:true];
            [self.likeHeadImgViews addObject:likeHeadView];
            [self.contentView addSubview:likeHeadView];
            
            imgView.userInteractionEnabled = YES;
            [imgView bk_whenTapped:^{
                [weakSelf imgViewClicked:weakSelf.imgViews[i]];
            }];
        }
        
    }
    return self;
}

- (void)prepareForReuse{
    
    [self removeTip];
}

- (void)addTip:(NSString *)countStr{
    self.accessoryType = UITableViewCellAccessoryNone;
    CGFloat pointX = kScreen_Width - 25;
    CGFloat pointY = [[self class] cellHeight]/2;
    [self.contentView addBadgeTip:countStr withCenterPosition:CGPointMake(pointX, pointY)];
}

- (void)addTipIcon{
    CGFloat pointX = kScreen_Width - 40;
    CGFloat pointY = [[self class] cellHeight]/2;
    [self.contentView addBadgeTip:kBadgeTipStr withCenterPosition:CGPointMake(pointX, pointY)];
}

- (void)addTipHeadIcon:(NSString *)IconString {
    CGFloat pointX = kScreen_Width - 40;
    CGFloat pointY = [[self class] cellHeight]/2;
    [self.contentView addBadgeTip:IconString withCenterPosition:CGPointMake(pointX, pointY)];
}

- (void)removeTip{
    [self.contentView removeBadgeTips];
}

- (void)initCellWithReviewers:(NSArray *)reviewerList{
    int imageCount = self.contentView.size.width / 40 - 2;
    for(int i = 0; i < kDefaultImageCount; i ++) {
        UIImageView *image = self.imgViews[i];
        [image setHidden:true];
        UIImageView *likeImage = self.likeHeadImgViews[i];
        [likeImage setHidden:true];
    }
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithArray:reviewerList];
    NSArray *reviewers = [dataArray sortedArrayUsingComparator:^NSComparisonResult(Reviewer *obj1, Reviewer *obj2) {
        NSComparisonResult result = [ obj2.value compare:obj1.value];
        if(result == NSOrderedSame) {
            result = [ obj1.volunteer compare:obj2.volunteer];
        }
        return result;
    }];
    _reviewerList = reviewers.copy;
    int index = 0;
    for (int i = 0; i < imageCount; i++) {
        UIImageView *image = self.imgViews[index];
        if(i > reviewers.count) {
            continue;
        }
        if(index >= imageCount-1 || i == reviewers.count) {
            image.image = [UIImage imageNamed:i == reviewers.count? @"PR_plus": @"PR_more"];
            image.hidden = NO;
            index ++;
            continue;
        }
        Reviewer* reviewer = (Reviewer*)reviewers[i];
        [image setHidden:false];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.left.equalTo(self.contentView).offset(40 * (index + 1) + 10);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.right.equalTo(self.contentView).offset(-self.contentView.size.width + (40 * (index + 1) + 10) + 33);
        }];
        [image sd_setImageWithURL:[reviewer.reviewer.avatar urlImageWithCodePathResizeToView:image] placeholderImage:kPlaceholderMonkeyRoundView(image)];
        if([reviewer.volunteer isEqualToString:@"invitee"]) {
            if([reviewer.value isEqual:@100]) {
                UIImageView *likeImage = self.likeHeadImgViews[index];
                [likeImage setHidden:false];
                likeImage.image = [UIImage imageNamed:@"PointLikeHead"];
            }
        }
        index ++;
    }
}

- (void)imgViewClicked:(UIImageView *)imgView{
    NSUInteger index = [self.imgViews indexOfObject:imgView];
    if (index == NSNotFound) {
        return;
    }
    int imageCount = self.contentView.size.width / 40 - 2;
    BOOL isLastV = (index == _reviewerList.count) || (index == imageCount -1);
    if (isLastV && _lastItemClickedBlock) {
        _lastItemClickedBlock();
    }
}

+ (CGFloat)cellHeight{
    return 63.0;
}


@end

