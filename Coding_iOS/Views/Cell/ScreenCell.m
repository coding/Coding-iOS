//
//  ScreenCell.m
//  Coding_iOS
//
//  Created by zhangdadi on 2016/12/14.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "ScreenCell.h"

@interface ScreenCell ()
@property (nonatomic, strong) UIButton *tagButton;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *selImageView;
@end

@implementation ScreenCell

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
    
    _tagButton = [[UIButton alloc] init];
    UIImage *image = [[UIImage imageNamed:@"task_filter_tag"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    [_tagButton setImage:image forState:UIControlStateNormal];
    [self.contentView addSubview:_tagButton];
    _tagButton.sd_layout.leftSpaceToView(self.contentView, 20).centerYEqualToView(self.contentView).widthIs(15).heightIs(15);

    _selImageView = [[UIImageView alloc] init];
    _selImageView.image = [UIImage imageNamed:@"task_filter_checkIcon"];
    [self.contentView addSubview:_selImageView];
    _selImageView.hidden = YES;
    _selImageView.sd_layout.rightSpaceToView(self.contentView, 20).centerYEqualToView(self.contentView).widthIs(20).heightIs(21);
    
    _titleLab=[[UILabel alloc] init];
    _titleLab.font=[UIFont systemFontOfSize:15];
    [self.contentView addSubview:_titleLab];
    _titleLab.sd_layout.leftSpaceToView(_tagButton, 17).rightSpaceToView(_selImageView, 15).topSpaceToView(self.contentView, 15).bottomSpaceToView(self.contentView, 15);

}

- (void)setIsSel:(BOOL)isSel {
    _titleLab.textColor=isSel?kColorBrandGreen:kColor222;
    _selImageView.hidden = !isSel;
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLab.text= title;
}

- (void)setColor:(NSString *)color {
    _color = color;
    _tagButton.tintColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"0x%@", [color substringFromIndex:1]]];
}

@end
