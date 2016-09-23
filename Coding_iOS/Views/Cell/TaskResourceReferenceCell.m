//
//  TaskResourceReferenceCell.m
//  Coding_iOS
//
//  Created by Ease on 16/2/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TaskResourceReferenceCell.h"

@interface TaskResourceReferenceCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *codeL, *titleL;
@end

@implementation TaskResourceReferenceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_imgView) {
            _imgView = [UIImageView new];
            _imgView.contentMode = UIViewContentModeCenter;
            [self.contentView addSubview:_imgView];
        }
        if (!_codeL) {
            _codeL = ({
                UILabel *label = [UILabel new];
                label.textColor = kColorBrandGreen;
                label.font = [UIFont systemFontOfSize:15];
                label;
            });
            [self.contentView addSubview:_codeL];
        }
        if (!_titleL) {
            _titleL = ({
                UILabel *label = [UILabel new];
                label.textColor = kColor222;
                label.font = [UIFont systemFontOfSize:15];
                label;
            });
            [self.contentView addSubview:_titleL];
        }
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(0);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        [_codeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(45);
            make.centerY.equalTo(self.contentView);
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.codeL.mas_right);
            make.centerY.equalTo(self.contentView);
            make.right.lessThanOrEqualTo(self.contentView);
        }];
    }
    return self;
}

- (void)setItem:(ResourceReferenceItem *)item{
    _item = item;
    if (!_item) {
        return;
    }
    [_imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"task_resource_reference_%@", _item.target_type]]];
    _codeL.text = [NSString stringWithFormat:@"# %@ ", _item.code.stringValue];
    _titleL.text = _item.title;
}

@end
