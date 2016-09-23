//
//  ProjectTopicCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kProjectTopicCell_PadingLeft 55.0
#define kProjectTopicCell_PadingRight 30.0

#define kProjectTopicCell_ContentWidth (kScreen_Width - kProjectTopicCell_PadingLeft - kProjectTopicCell_PadingRight)
#define kProjectTopicCell_ContentHeightMax 40.0
#define kProjectTopicCell_ContentFont [UIFont systemFontOfSize:16]

#define kProjectTopicCellTagsView_Font [UIFont systemFontOfSize:12]

#import "ProjectTopicCell.h"
#import "ProjectTag.h"
#import "ProjectTagLabel.h"

@interface ProjectTopicCell ()
@property (strong, nonatomic) UILabel *titleLabel, *userNameLabel, *timeLabel, *commentCountLabel, *numLabel;
@property (strong, nonatomic) UIImageView *userIconView, *timeClockIconView, *commentIconView;
@property (strong, nonatomic) ProjectTopicCellTagsView *tagsView;

@end

@implementation ProjectTopicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 33, 33)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 12, kProjectTopicCell_ContentWidth, 20)];
            _titleLabel.font = kProjectTopicCell_ContentFont;
            _titleLabel.textColor = kColor222;
            [self.contentView addSubview:_titleLabel];
        }
        
        if (!_tagsView) {
            _tagsView = [ProjectTopicCellTagsView viewWithTags:nil];
            [self.contentView addSubview:_tagsView];
        }
        
        if (!_numLabel) {
            _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 150, 15)];
            _numLabel.backgroundColor = [UIColor clearColor];
            _numLabel.font = [UIFont systemFontOfSize:10];
            _numLabel.textColor = kColor222;
            [self.contentView addSubview:_numLabel];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 150, 15)];
            _userNameLabel.backgroundColor = [UIColor clearColor];
            _userNameLabel.font = [UIFont systemFontOfSize:10];
            _userNameLabel.textColor = kColor666;
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_timeClockIconView) {
            _timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 12, 12)];
            _timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:_timeClockIconView];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 80, 15)];
            _timeLabel.font = [UIFont systemFontOfSize:10];
            _timeLabel.textColor = kColor999;
            [self.contentView addSubview:_timeLabel];
        }
        if (!_commentIconView) {
            _commentIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 12, 12)];
            [_commentIconView setImage:[UIImage imageNamed:@"topic_comment_icon"]];
            [self.contentView addSubview:_commentIconView];
        }
        if (!_commentCountLabel) {
            _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 20, 15)];
            _commentCountLabel.font = [UIFont systemFontOfSize:10];
            _commentCountLabel.minimumScaleFactor = 0.5;
            _commentCountLabel.adjustsFontSizeToFitWidth = YES;
            _commentCountLabel.textColor = kColor999;
            [self.contentView addSubview:_commentCountLabel];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_curTopic) {
        return;
    }
    [_userIconView sd_setImageWithURL:[_curTopic.owner.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    [_titleLabel setLongString:_curTopic.title withFitWidth:kProjectTopicCell_ContentWidth maxHeight:kProjectTopicCell_ContentHeightMax];
    
    CGFloat curBottomY = 12 + [_curTopic.title getHeightWithFont:kProjectTopicCell_ContentFont constrainedToSize:CGSizeMake(kProjectTopicCell_ContentWidth, kProjectTopicCell_ContentHeightMax)] + 12;
    CGFloat curRightX = kProjectTopicCell_PadingLeft;
    
    _tagsView.tags = _curTopic.labels;
    [_tagsView setOrigin:CGPointMake(curRightX, curBottomY)];

    curBottomY += [ProjectTopicCellTagsView getHeightForTags:_curTopic.labels];
    
    [_numLabel setOrigin:CGPointMake(curRightX, curBottomY)];
    _numLabel.text = [NSString stringWithFormat:@"#%@", _curTopic.number.stringValue];
    [_numLabel sizeToFit];
    
    curRightX = _numLabel.maxXOfFrame + 10;
    [_userNameLabel setOrigin:CGPointMake(curRightX, curBottomY)];
    _userNameLabel.text = _curTopic.owner.name;
    [_userNameLabel sizeToFit];
    
    curRightX = _userNameLabel.maxXOfFrame+ 10;
    [_timeClockIconView setOrigin:CGPointMake(curRightX, curBottomY)];
    [_timeLabel setOrigin:CGPointMake(curRightX + 15, curBottomY)];
    _timeLabel.text = [_curTopic.created_at stringDisplay_MMdd];
    [_timeLabel sizeToFit];
    
    curRightX = _timeLabel.maxXOfFrame + 10;
    [_commentIconView setOrigin:CGPointMake(curRightX, curBottomY)];
    [_commentCountLabel setOrigin:CGPointMake(curRightX +15, curBottomY)];
    _commentCountLabel.text = _curTopic.child_count.stringValue;
    [_commentCountLabel sizeToFit];
}

+(CGFloat)cellHeightWithObj:(id)aObj{
    CGFloat cellHeight = 0;
    if ([aObj isKindOfClass:[ProjectTopic class]]) {
        ProjectTopic *curTopic = (ProjectTopic *)aObj;
        cellHeight += 12 + [curTopic.title getHeightWithFont:kProjectTopicCell_ContentFont constrainedToSize:CGSizeMake(kProjectTopicCell_ContentWidth, kProjectTopicCell_ContentHeightMax)] + 12;
        cellHeight += [ProjectTopicCellTagsView getHeightForTags:curTopic.labels];
        cellHeight += 15 + 12;
    }
    return cellHeight;
}

@end


@interface ProjectTopicCellTagsView ()
@property (strong, nonatomic) NSMutableArray *tagLabelList;
@end

@implementation ProjectTopicCellTagsView

static CGFloat kProjectTopicCellTagsView_Height_PerLine = 25.0;
static CGFloat kProjectTopicCellTagsView_Padding_Space = 5.0;
static CGFloat kProjectTopicCellTagsView_Padding_Content = 10.0;

- (instancetype)initWithTags:(NSArray *)tags{
    self = [super init];
    if (self) {
        _tagLabelList = [NSMutableArray new];
        self.tags = tags;
    }
    return self;
}
+ (instancetype)viewWithTags:(NSArray *)tags{
    ProjectTopicCellTagsView *tagsView = [[self alloc] initWithTags:tags];
    return tagsView;
}

+ (CGFloat)getHeightForTags:(NSArray *)tags{
    CGFloat height = 0;
    if (tags.count > 0) {
        CGFloat viewWidth = kProjectTopicCell_ContentWidth;
        CGFloat curX = 0, curY = 0;

        for (ProjectTag *curTag in tags) {
            CGFloat textWidth = [curTag.name getWidthWithFont:kProjectTopicCellTagsView_Font constrainedToSize:CGSizeMake(CGFLOAT_MAX, kProjectTopicCellTagsView_Height_PerLine)];
            CGFloat curTagWidth = MIN(textWidth + kProjectTopicCellTagsView_Padding_Content, viewWidth);
            curX += curTagWidth;
            if (curX > viewWidth) {
                curY += kProjectTopicCellTagsView_Height_PerLine;
                curX = curTagWidth + kProjectTopicCellTagsView_Padding_Space;
            }else{
                curX += kProjectTopicCellTagsView_Padding_Space;
            }
        }
        height = curY + kProjectTopicCellTagsView_Height_PerLine;
        height += 7.0;//与下面内容的间隔
    }else{
        height = 0.0;
    }
    return height;
}

#define kProjectTopicCellTagsView_HeightPerLine 25.0


- (void)setTags:(NSArray *)tags{
    _tags = tags;
    if (_tags.count > 0) {
        if (!_tagLabelList) {
            _tagLabelList = [NSMutableArray new];
        }
        CGPoint curPoint = CGPointZero;
        CGFloat viewWidth = kProjectTopicCell_ContentWidth;
        
        int index;
        for (index = 0; index < _tags.count; index++) {
            ProjectTagLabel *curLabel;
            if (_tagLabelList.count > index) {
                curLabel = _tagLabelList[index];
                curLabel.curTag = _tags[index];
            }else{
                curLabel = [ProjectTagLabel labelWithTag:_tags[index] font:kProjectTopicCellTagsView_Font height:20 widthPadding:kProjectTopicCellTagsView_Padding_Content];
                [_tagLabelList addObject:curLabel];
            }
            CGFloat curPointRightX = curPoint.x + MIN(CGRectGetWidth(curLabel.frame), viewWidth);
            if (curPointRightX > viewWidth) {
                curPoint.x = 0;
                curPoint.y += kProjectTopicCellTagsView_Height_PerLine;
            }
            [curLabel setOrigin:curPoint];
            [self addSubview:curLabel];
            
            //下一个点
            curPoint.x += CGRectGetWidth(curLabel.frame) +kProjectTopicCellTagsView_Padding_Space;
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
        [self setSize:CGSizeMake(kScreen_Width, curPoint.y + kProjectTopicCellTagsView_Height_PerLine)];
        self.hidden = NO;
    }else{
        [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            [obj removeFromSuperview];
        }];
        [_tagLabelList removeAllObjects];
        self.hidden = YES;
    }
}

@end
