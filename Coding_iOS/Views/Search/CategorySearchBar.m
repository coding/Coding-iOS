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

-(void)layoutSubviews
{
    self.autoresizesSubviews = YES;
    NSPredicate *finalPredicate = [NSPredicate predicateWithBlock:^BOOL(UIView *candidateView, NSDictionary *bindings) {
        if ([candidateView isMemberOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            return true;
        }else{
            return false;
        }
    }];
    
    //找到输入框  右移
    UITextField *searchField=[[[[[self subviews] firstObject] subviews] filteredArrayUsingPredicate:finalPredicate] lastObject];
    searchField.textAlignment=NSTextAlignmentLeft;
    [searchField setFrame:CGRectMake(53,4.8,self.frame.size.width-55,22)];
    //
    [(UIImageView*)searchField.leftView setFrame:CGRectZero];
}

-(void)patchWithCategoryWithSelectBlock:(SelectBlock)block{
    [self addSubview:self.categoryBtn];
    [self addSubview:self.iconBtn];
    _curBlock=block;
}

-(UIButton*)categoryBtn{
    if (!_categoryBtn) {
        _categoryBtn=[UIButton new];
        _categoryBtn.frame=CGRectMake(5, 0, 40, 31);
        [_categoryBtn addTarget:self action:@selector(selectCategoryAction) forControlEvents:UIControlEventTouchUpInside];
        _categoryBtn.titleLabel.font=[UIFont systemFontOfSize:12];
        [_categoryBtn setTitleColor:[UIColor colorWithHexString:@"0x666666"] forState:UIControlStateNormal];
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

-(void)layoutSubviews
{
    //fix width in ios7
    self.width=kScreen_Width-115;
    self.autoresizesSubviews = YES;
    //找到输入框  右移
    NSPredicate *finalPredicate = [NSPredicate predicateWithBlock:^BOOL(UIView *candidateView, NSDictionary *bindings) {
        return [candidateView isMemberOfClass:NSClassFromString(@"UISearchBarTextField")];
    }];
    UITextField *searchField = [[[[[self subviews] firstObject] subviews] filteredArrayUsingPredicate:finalPredicate] lastObject];
    searchField.textAlignment = NSTextAlignmentLeft;
    [searchField setFrame:CGRectMake(-CGRectGetWidth(self.frame)/2 + 40, 4.8, CGRectGetWidth(self.frame), 22)];
    [(UIImageView*)searchField.leftView setSize:CGSizeMake(13, 13)];
}
@end
