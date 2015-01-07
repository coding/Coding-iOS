//
//  TaskDescriptionCell.m
//  Coding_iOS
//
//  Created by Ease on 15/1/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "TaskDescriptionCell.h"
#import <Masonry/Masonry.h>
#import "UIVerticalAlignmentLabel.h"

@interface TaskDescriptionCell ()
@property (strong, nonatomic) UIImageView *textBgView;
@property (strong, nonatomic) UIVerticalAlignmentLabel *descriptionLabel;
@end

@implementation TaskDescriptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_textBgView) {
            _textBgView = [[UIImageView alloc] init];
            [_textBgView setImage:[[UIImage imageNamed:@"textBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10) resizingMode:UIImageResizingModeTile]];
            [self.contentView addSubview:_textBgView];
        }
        if (!_descriptionLabel) {
            _descriptionLabel = [[UIVerticalAlignmentLabel alloc] init];
            _descriptionLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _descriptionLabel.font = [UIFont systemFontOfSize:15];
            _descriptionLabel.numberOfLines = 0;
            _descriptionLabel.verticalAlignment = VerticalAlignmentTop;
            [self.contentView addSubview:_descriptionLabel];
        }
        
        [_textBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.right.equalTo(self.contentView).offset(-10);
            make.top.equalTo(self.contentView).offset(10);
            
            make.height.mas_equalTo(110);
        }];
        [_descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.textBgView).insets(UIEdgeInsetsMake(19, 10, 20, 10));
        }];
        
    }
    return self;
}

- (void)setDescriptionStr:(NSString *)descriptionStr{
    if (!descriptionStr || descriptionStr.length == 0) {
        descriptionStr = descriptionStr? @"添加备注 ..." : @"正在加载 ...";
    }
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4.0];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.minimumLineHeight = 20;
    paragraphStyle.maximumLineHeight = 20;
    
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:descriptionStr attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
    self.descriptionLabel.attributedText = attrStr;
}

+ (CGFloat)cellHeight{
    return 110+10*2;
}
@end
