//
//  ProjectTopicLabelView.m
//  Coding_iOS
//
//  Created by zwm on 15/4/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectTopicLabelView.h"
#import "ProjectTopic.h"
#import "ProjectTopicLabel.h"
#import "WMDelLabel.h"

@interface ProjectTopicLabelView () <WMDelLabelDelegate>

@end

@implementation ProjectTopicLabelView

- (id)initWithFrame:(CGRect)frame projectTopic:(ProjectTopic *)topic md:(BOOL)isMD
{
    self = [super initWithFrame:frame];
    if (self) {
        _labelH = 20;
        NSArray *labelAry = isMD ? topic.mdLabels : topic.labels;
        if (labelAry.count > 0) {
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            CGFloat limitW = kScreen_Width - kPaddingLeftWidth - 44;
            
            for (int i=0; i<labelAry.count; i++) {
                ProjectTopicLabel *label = labelAry[i];
                WMDelLabel *tLbl = [[WMDelLabel alloc] initWithFrame:CGRectMake(x, y, 0, 0)];
                tLbl.delLabelDelegate = self;
                tLbl.tag = i;
                
                tLbl.text = label.name;
                //NSString *color = [NSString stringWithFormat:@"0x%@", [label.color substringFromIndex:1]];
                //tLbl.layer.backgroundColor = kColorLabelBgColor.CGColor;
              
                [tLbl sizeToFit];
                
                CGFloat width = tLbl.frame.size.width + 20;
                if (x + width > limitW) {
                    y += 26.0f;
                    x = 0.0f;
                }
                [tLbl setFrame:CGRectMake(x, y, width - 4, 20)];
                x += width;
                
                [self addSubview:tLbl];
            }
            _labelH = y + 20;
        } else {
            UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 15, 15)];
            [iconImg setImage:[UIImage imageNamed:@"tag_icon"]];
            
            UILabel *tLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, 30, 15)];
            
            tLbl.font = [UIFont systemFontOfSize:14];
            tLbl.text = @"标签";
            tLbl.textColor = [UIColor colorWithHexString:@"0x3bbd79"];
            
            [self addSubview:iconImg];
            [self addSubview:tLbl];
        }
    }
    return self;
}

#pragma mark - WMDelLabelDelegate
- (void)delBtnClick:(WMDelLabel *)label;
{
    if (_delLabelBlock) {
        _delLabelBlock(label.tag);
    }
}

@end
