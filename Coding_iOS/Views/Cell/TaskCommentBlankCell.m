//
//  TaskCommentBlankCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/28.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TaskCommentBlankCell.h"

@implementation TaskCommentBlankCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_blankStrLabel) {
            _blankStrLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([self.class cellHeight]-30)/2, kScreen_Width - 2*kPaddingLeftWidth, 30)];
            _blankStrLabel.font = [UIFont boldSystemFontOfSize:15];
            _blankStrLabel.textColor = kColor999;
            _blankStrLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_blankStrLabel];
            
        }
    }
    return self;
}

+ (CGFloat)cellHeight{
    return 100.0;
}
@end
