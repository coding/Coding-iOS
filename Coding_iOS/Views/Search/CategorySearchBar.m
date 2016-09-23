//
//  CategorySearchBar.m
//  Coding_iOS
//
//  Created by jwill on 15/11/18.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "CategorySearchBar.h"

@interface CategorySearchBar ()
@property (copy,nonatomic)SelectBlock curBlock;
@property (strong, nonatomic)UIButton *categoryBtn;
@property (strong, nonatomic)UIButton *iconBtn;
@end


@implementation CategorySearchBar

-(void)layoutSubviews{
    self.autoresizesSubviews = YES;
    UITextField *searchField = self.eaTextField;
    [searchField setFrame:CGRectMake(60, 4.5, self.frame.size.width - 75, 22)];
    searchField.leftView = nil;
    searchField.textAlignment = NSTextAlignmentLeft;
}

-(void)patchWithCategoryWithSelectBlock:(SelectBlock)block{
    [self addSubview:self.categoryBtn];
    [self addSubview:self.iconBtn];
    _curBlock = block;
}

-(UIButton*)categoryBtn{
    if (!_categoryBtn) {
        _categoryBtn=[UIButton new];
        _categoryBtn.frame=CGRectMake(5, 0, 40, 31);
        [_categoryBtn addTarget:self action:@selector(selectCategoryAction) forControlEvents:UIControlEventTouchUpInside];
        _categoryBtn.titleLabel.font = self.eaTextField.font;
        [_categoryBtn setTitleColor:kColor666 forState:UIControlStateNormal];
        [_categoryBtn setTitle:@"项目" forState:UIControlStateNormal];
    }
    return _categoryBtn;
}

-(UIButton*)iconBtn{
    if (!_iconBtn) {
        _iconBtn=[[UIButton alloc] initWithFrame:CGRectMake(45, 11, 8, 8)];
        [_iconBtn addTarget:self action:@selector(selectCategoryAction) forControlEvents:UIControlEventTouchUpInside];
        [_iconBtn setBackgroundImage:[UIImage imageNamed:@"btn_fliter_down"] forState:UIControlStateNormal];
    }
    return _iconBtn;
}

#pragma mark -- event
-(void)selectCategoryAction{
    _curBlock();
}

-(void)setSearchCategory:(NSString*)title{
    [_categoryBtn setTitle:title forState:UIControlStateNormal];
}
@end

@implementation MainSearchBar

- (UIButton *)scanBtn{
    if (!_scanBtn) {
        _scanBtn = [UIButton new];
        [_scanBtn setImage:[UIImage imageNamed:@"button_scan"] forState:UIControlStateNormal];
        [self addSubview:_scanBtn];
        [_scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 30));
            make.centerY.equalTo(self);
            make.right.equalTo(self);
        }];
    }
    return _scanBtn;
}
@end
