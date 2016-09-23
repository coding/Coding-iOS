//
//  TopicSearchCell.m
//  Coding_iOS
//
//  Created by jwill on 15/11/23.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kBaseCellHeight 86
#define kDetialContentMaxHeight 36

#define kProjectTopicCell_PadingLeft 55.0
#define kProjectTopicCell_PadingRight 15.0

#define kProjectTopicCell_ContentWidth (kScreen_Width - kProjectTopicCell_PadingLeft - kProjectTopicCell_PadingRight)
#define kProjectTopicCell_ContentFont [UIFont systemFontOfSize:15]
#define kInnerHorizonOffset 12

#import "TopicSearchCell.h"
#import "ProjectTag.h"
#import "NSString+Attribute.h"

@interface TopicSearchCell ()
@property (strong, nonatomic) UILabel *titleLabel, *userNameLabel, *timeLabel, *commentCountLabel, *numLabel,*describeLabel;
@property (strong, nonatomic) UIImageView *userIconView, *timeClockIconView, *commentIconView;

@end

@implementation TopicSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryNone;
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 18, 40, 40)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+40+kInnerHorizonOffset, 15, kProjectTopicCell_ContentWidth, 20)];
            _titleLabel.font = kProjectTopicCell_ContentFont;
            _titleLabel.textColor = kColor222;
            [self.contentView addSubview:_titleLabel];
        }
        
        if (!_describeLabel) {
            _describeLabel = [UILabel new];
            _describeLabel.textColor = kColor666;
            _describeLabel.font = kProjectTopicCell_ContentFont;
            _describeLabel.numberOfLines=2;
            [self.contentView addSubview:_describeLabel];
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
        
        
        [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-10);
            make.left.equalTo(self.userIconView.mas_right).offset(kInnerHorizonOffset);
            make.height.mas_equalTo(15);
        }];
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.numLabel.mas_right).offset(5);
            make.centerY.equalTo(self.numLabel);
            make.height.mas_equalTo(15);
        }];
        [_timeClockIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.userNameLabel.mas_right).offset(10);
            make.centerY.equalTo(self.userNameLabel);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.timeClockIconView.mas_right).offset(5);
            make.centerY.equalTo(self.userNameLabel);
            make.height.mas_equalTo(15);
        }];
        [_commentIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.timeLabel.mas_right).offset(10);
            make.centerY.equalTo(self.userNameLabel);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        [_commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.commentIconView.mas_right).offset(5);
            make.centerY.equalTo(self.userNameLabel);
            make.height.mas_equalTo(15);
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_curTopic) {
        return;
    }
    [_userIconView sd_setImageWithURL:[_curTopic.owner.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
//    [_titleLabel setLongString:_curTopic.title withFitWidth:kProjectTopicCell_ContentWidth maxHeight:kProjectTopicCell_ContentHeightMax];
    _titleLabel.attributedText=[NSString getAttributeFromText:[_curTopic.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
    
    CGFloat curBottomY = 12 + [_curTopic.title getHeightWithFont:kProjectTopicCell_ContentFont constrainedToSize:CGSizeMake(kProjectTopicCell_ContentWidth, [TopicSearchCell contentLabelHeightWithProjectTopic:_curTopic])] + 12;
    CGFloat curRightX = kProjectTopicCell_PadingLeft;
    
    [_numLabel setOrigin:CGPointMake(curRightX, curBottomY)];
    _numLabel.text = [NSString stringWithFormat:@"#%@", _curTopic.resource_id.stringValue];
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
    
    [_describeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self.userIconView.mas_right).offset(kInnerHorizonOffset);
        make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        make.height.mas_equalTo([TopicSearchCell contentLabelHeightWithProjectTopic:_curTopic]);
    }];

    NSString *content=[_curTopic.contentStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    _describeLabel.attributedText=[NSString getAttributeFromText:[content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
}

+ (CGFloat)cellHeightWithObj:(id)obj {
    ProjectTopic *topic = (ProjectTopic *)obj;
    return kBaseCellHeight+[TopicSearchCell contentLabelHeightWithProjectTopic:topic];
}

+ (CGFloat)contentLabelHeightWithProjectTopic:(ProjectTopic *)topic{
    NSString *content=[topic.contentStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *realContent=[NSString getStr:content removeEmphasize:@"em"];
    CGFloat realheight = [realContent getHeightWithFont:kProjectTopicCell_ContentFont constrainedToSize:CGSizeMake(kProjectTopicCell_ContentWidth, 1000)];
    return MIN(realheight, kDetialContentMaxHeight);
}

@end


