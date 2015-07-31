//
//  EditLabelCell.m
//  Coding_iOS
//
//  Created by zwm on 15/4/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "EditLabelCell.h"
#import "ProjectTagLabel.h"

@interface EditLabelCell ()
@property (strong, nonatomic) ProjectTagLabel *nameLbl;
@end

@implementation EditLabelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = kColorTableBG;

        if (!_selectBtn) {
            _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 24, 10, 24, 24)];
            [_selectBtn setImage:[UIImage imageNamed:@"tag_select_no"] forState:UIControlStateNormal];
            [_selectBtn setImage:[UIImage imageNamed:@"tag_select"] forState:UIControlStateSelected];
            _selectBtn.userInteractionEnabled = NO;
            [self.contentView addSubview:_selectBtn];
        }
    }
    return self;
}

- (void)setTag:(ProjectTag *)curTag andSelected:(BOOL)selected{
    if (_nameLbl) {
        _nameLbl.curTag = curTag;
    }else{
        _nameLbl = [ProjectTagLabel labelWithTag:curTag font:[UIFont systemFontOfSize:12] height:20 widthPadding:10];
        [_nameLbl setOrigin:CGPointMake(kPaddingLeftWidth, ([EditLabelCell cellHeight] - 22)/2)];
        [self.contentView addSubview:_nameLbl];
    }
    _selectBtn.selected = selected;
}

+ (CGFloat)cellHeight
{
    return 44.0;
}

@end
