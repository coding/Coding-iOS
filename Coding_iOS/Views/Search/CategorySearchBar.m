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
@property (strong, nonatomic) UIButton *categoryBtn;
@end


@implementation CategorySearchBar

-(void)layoutSubviews
{
    self.autoresizesSubviews = YES;
    //找到输入框  右移
    UITextField *searchField=[[[[self subviews] firstObject] subviews] lastObject];
    [searchField setFrame:CGRectMake(55,5,250,20)];
    
    //
    [(UIImageView*)searchField.leftView setImage:[UIImage imageNamed:@"tips_menu_icon_status"]];
}

-(void)patchWithCategoryWithSelectBlock:(SelectBlock)block{
    [self addSubview:self.categoryBtn];
    _curBlock=block;
}

-(UIButton*)categoryBtn{
    if (!_categoryBtn) {
        _categoryBtn=[UIButton new];
        _categoryBtn.frame=CGRectMake(15, 0, 40, 30);
        [_categoryBtn addTarget:self action:@selector(selectCategoryAction) forControlEvents:UIControlEventTouchUpInside];
        _categoryBtn.titleLabel.font=[UIFont systemFontOfSize:12];
        [_categoryBtn setTitleColor:[UIColor colorWithHexString:@"0xcccccc"] forState:UIControlStateNormal];
        [_categoryBtn setTitle:@"项目" forState:UIControlStateNormal];
    }
    return _categoryBtn;
}


#pragma mark -- event
-(void)selectCategoryAction{
    _curBlock();
}

-(void)setSearchCategory:(NSString*)title{
    [_categoryBtn setTitle:title forState:UIControlStateNormal];
}
@end
