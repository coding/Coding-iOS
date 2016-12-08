//
//  MRPRAcceptEditCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kMRPRAcceptEditCell_TextViewHeight (kScreen_Height/4)

#import "MRPRAcceptEditCell.h"

@interface MRPRAcceptEditCell ()<UITextViewDelegate>
//@property (strong, nonatomic) UIView *lineView;
@end

@implementation MRPRAcceptEditCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kColorTableBG;
        
        UILabel *titleL = [UILabel new];
        titleL.font = [UIFont systemFontOfSize:15];
        titleL.textColor = kColor999;
        titleL.text = @"Merge Commit Message";
        [self.contentView addSubview:titleL];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_line"]];
        [self.contentView addSubview:lineView];
        
        _contentTextView = [UIPlaceHolderTextView new];
        _contentTextView.backgroundColor = [UIColor clearColor];
        _contentTextView.font = [UIFont systemFontOfSize:15];
        _contentTextView.textColor = kColor222;
        _contentTextView.delegate = self;
        _contentTextView.placeholder = @"输入点什么...";
        [self.contentView addSubview:_contentTextView];

        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(15);
            make.height.mas_equalTo(20);
        }];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleL.mas_bottom).offset(15);
            make.left.right.equalTo(titleL);
            make.height.mas_equalTo(0.5);
        }];
        [_contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView).offset(7);
            make.left.equalTo(titleL).offset(-8);
            make.right.equalTo(titleL).offset(8);
            make.height.mas_equalTo(kMRPRAcceptEditCell_TextViewHeight);
        }];
    }
    return self;
}

+ (CGFloat)cellHeight{
    return 15+ 20+ 15+ kMRPRAcceptEditCell_TextViewHeight + 15;
}

#pragma mark TextView Delegate
- (void)textViewDidChange:(UITextView *)textView{
    if (self.contentChangedBlock) {
        self.contentChangedBlock(textView.text);
    }
}

@end
