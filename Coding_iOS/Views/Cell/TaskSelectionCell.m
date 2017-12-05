//
//  TaskSelectionCell.m
//  Coding_iOS
//
//  Created by 张达棣 on 16/12/7.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TaskSelectionCell.h"

@interface TaskSelectionCell ()
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *line;
@end

@implementation TaskSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)creatView {
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.backgroundColor=[UIColor clearColor];
    _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
    _titleLab.font=[UIFont systemFontOfSize:15];
    [self.contentView addSubview:_titleLab];
    _titleLab.sd_layout.leftSpaceToView(self.contentView, 20).topSpaceToView(self.contentView, 15).bottomSpaceToView(self.contentView, 15).widthIs(200);
    
    _selImageView = [[UIImageView alloc] init];
    _selImageView.image = [UIImage imageNamed:@"task_filter_checkIcon"];
    [self.contentView addSubview:_selImageView];
    _selImageView.hidden = YES;
    _selImageView.sd_layout.rightSpaceToView(self.contentView, 20).centerYEqualToView(self.contentView).widthIs(20).heightIs(21);
    
    _line = [[UILabel alloc] init];
    _line.backgroundColor = kColorDDD;
    [self.contentView addSubview:_line];
    _line.sd_layout.leftSpaceToView(self.contentView, 0).rightSpaceToView(self.contentView, 0).bottomSpaceToView(self.contentView, 0).heightIs(.5);
    _line.hidden = YES;

}

- (void)setIsSel:(BOOL)isSel {
    _titleLab.textColor=isSel?kColorBrandGreen:kColor222;
    _selImageView.hidden = !isSel;

}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLab.text= title;

}

- (void)setIsShowLine:(BOOL)isShowLine {
    _isShowLine = isShowLine;
    _line.hidden = !isShowLine;
}

@end
