//
//  ProjectDescriptionCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kProjectDescriptionCell_Font [UIFont systemFontOfSize:15]
#define kProjectDescriptionCell_ContentWidth (kScreen_Width - kPaddingLeftWidth*2)

#import "ProjectDescriptionCell.h"
#import "EaseGitButton.h"

@interface ProjectDescriptionCell ()
@property (strong, nonatomic) UILabel *proDesL;
@end

@implementation ProjectDescriptionCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kColorTableBG;

        if (!_proDesL) {
            _proDesL = [[UILabel alloc] init];
            _proDesL.numberOfLines = 0;
            _proDesL.font = kProjectDescriptionCell_Font;
            _proDesL.textColor = kColor222;
            [self.contentView addSubview:_proDesL];
        }
    }
    return self;
}
- (void)setDescriptionStr:(NSString *)descriptionStr{
    if (descriptionStr.length > 0) {
        _proDesL.text = descriptionStr;
    }else{
        _proDesL.text = @"未填写";
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat desHeight = [_proDesL.text getSizeWithFont:kProjectDescriptionCell_Font constrainedToSize:CGSizeMake(kProjectDescriptionCell_ContentWidth, CGFLOAT_MAX)].height;
    [_proDesL setFrame:CGRectMake(kPaddingLeftWidth, 15, kProjectDescriptionCell_ContentWidth, desHeight)];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Project class]]) {
        Project *curProject = (Project *)obj;
        NSString *descriptionStr = curProject.description_mine.length > 0? curProject.description_mine: @"未填写";
        CGFloat desHeight = [descriptionStr getSizeWithFont:kProjectDescriptionCell_Font constrainedToSize:CGSizeMake(kProjectDescriptionCell_ContentWidth, CGFLOAT_MAX)].height;
        cellHeight += desHeight + 2*15;
    }
    return cellHeight;
}

@end
