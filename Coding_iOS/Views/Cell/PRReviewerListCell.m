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
#define kDefaultImageCount 6
@interface PRReviewerListCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) NSMutableArray *imgViews;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation PRReviewerListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imgViews = [[NSMutableArray alloc] init];
        self.backgroundColor = kColorTableBG;
        for(int i = 0; i < kDefaultImageCount; i ++)
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(40 * (i + 1), 10, kDefaultImageSize, kDefaultImageSize)];
            [imgView doCircleFrame];
            [imgView setHidden:true];
            [self.imgViews addObject:imgView];
            [self.contentView addSubview:imgView];
            
           
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

- (void)setImageStr:(NSArray *)reviewers{
    for (int i = 0; i < kDefaultImageCount; i++) {
        UIImageView *image = self.imgViews[i];
        if(i >= reviewers.count) {
            continue;
        }
         [image setHidden:false];
        Reviewer* reviewer = (Reviewer*)reviewers[i];
        [image sd_setImageWithURL:[reviewer.reviewer.avatar urlImageWithCodePathResizeToView:image] placeholderImage:kPlaceholderMonkeyRoundView(image)];
    }
    
}

+ (CGFloat)cellHeight{
    return 50.0;
}


@end
