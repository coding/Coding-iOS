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
@property (nonatomic, strong) UIImageView *selImageView;
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
    _titleLab=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
    _titleLab.font=[UIFont systemFontOfSize:15];
    [self.contentView addSubview:_titleLab];
    
    _selImageView = [[UIImageView alloc] init];
    _selImageView.image = [UIImage imageNamed:@"location_checkmark"];
    [self.contentView addSubview:_selImageView];
    _selImageView.hidden = YES;
    _selImageView.sd_layout.rightSpaceToView(self.contentView, 20).centerYEqualToView(self.contentView).widthIs(14).heightIs(11);
}

- (void)setIsSel:(BOOL)isSel {
    _titleLab.textColor=isSel?kColorBrandGreen:kColor222;
    _selImageView.hidden = !isSel;

}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLab.text= title;

}

@end
