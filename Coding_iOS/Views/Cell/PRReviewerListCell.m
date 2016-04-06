//
//  NSObject+PRReviewerListCell.m
//  Coding_iOS
//
//  Created by hardac on 16/3/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "PRReviewerListCell.h"
#import "Reviewer.h"
#define kDefaultImageSize 33
#define kDefaultImageCount 8
@interface PRReviewerListCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) NSMutableArray *imgViews;
@property (strong, nonatomic) NSMutableArray *likeHeadImgViews;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation PRReviewerListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imgViews = [[NSMutableArray alloc] init];
        self.likeHeadImgViews  = [[NSMutableArray alloc] init];
        self.backgroundColor = kColorTableBG;
        for(int i = 0; i < kDefaultImageCount; i ++)
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(40 * (i + 1)  + 10, 15, kDefaultImageSize, kDefaultImageSize)];
            [imgView doCircleFrame];
            [imgView setHidden:true];
            [self.imgViews addObject:imgView];
            [self.contentView addSubview:imgView];
            
            UIImageView *likeHeadView = [[UIImageView alloc] initWithFrame:CGRectMake(40 * (i + 1)  + 25,30, 18, 18)];
            [likeHeadView doCircleFrame];
            [likeHeadView setHidden:true];
            [self.likeHeadImgViews addObject:likeHeadView];
            [self.contentView addSubview:likeHeadView];
            
           
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
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithArray:reviewerList];
    //NSArray *sortedArray = [[NSArray alloc] initWithArray:dataArray];
    NSMutableArray *reviewers= [dataArray sortedArrayUsingComparator:^NSComparisonResult(Reviewer *obj1, Reviewer *obj2) {
        
        NSComparisonResult result = [ obj2.value compare:obj1.value];
        
        return result;
    }];
    int index = 0;
    for (int i = 0; i < imageCount; i++) {
        UIImageView *image = self.imgViews[index];
        if(i >= reviewers.count) {
            continue;
        }
        Reviewer* reviewer = (Reviewer*)reviewers[i];
        if([reviewer.value isEqual:@0]) {
            continue;
        }
        if(index >= imageCount-1) {
            image.image = [UIImage imageNamed:@"PR_more"];
            continue;
            
        }
        [image setHidden:false];
        [image sd_setImageWithURL:[reviewer.reviewer.avatar urlImageWithCodePathResizeToView:image] placeholderImage:kPlaceholderMonkeyRoundView(image)];
        if([reviewer.value isEqual:@100]) {
            UIImageView *likeImage = self.likeHeadImgViews[index];
            [likeImage setHidden:false];
            likeImage.image = [UIImage imageNamed:@"PointLikeHead"];
        }
         index ++;
    }
    
    for(int i = index; i < kDefaultImageCount; i ++) {
        UIImageView *image = self.imgViews[i];
        [image setHidden:true];
        UIImageView *likeImage = self.likeHeadImgViews[i];
        [likeImage setHidden:true];
    }
    
}

+ (CGFloat)cellHeight{
    return 64.0;
}


@end
